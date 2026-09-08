import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cloud/cloud_storage_connector.dart';
import '../../../core/cloud/cloud_storage_registry.dart';
import '../../../core/cloud/connectors/folder_sync_connector.dart';
import '../../../core/cloud/connectors/google_drive_connector.dart';
import '../../../core/cloud/connectors/webdav_connector.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/services/backup_container_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/entitlement/entitlement_model.dart';
import '../../../core/entitlement/entitlement_provider.dart';
import '../../../core/services/cloud_auto_sync.dart';
import '../../../core/services/cloud_auto_sync_runner.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/pro_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../clinics/providers/clinic_provider.dart';
import 'restore_preview_dialog.dart';
import 'widgets/pro_upgrade_sheet.dart';

class CloudBackupScreen extends ConsumerStatefulWidget {
  const CloudBackupScreen({super.key});

  @override
  ConsumerState<CloudBackupScreen> createState() => _CloudBackupScreenState();
}

class _CloudBackupScreenState extends ConsumerState<CloudBackupScreen> {
  bool _isBackingUp = false;
  bool _isRestoring = false;

  /// Automated cloud sync: the Pro-gated half of cloud backup.
  ///
  /// Connecting a provider and backing up by hand stay free; only the
  /// unattended schedule is gated, which is what AppFeature.cloudAutoSync
  /// has always described.
  Widget _buildAutoSyncCard(
    BuildContext context,
    ColorScheme scheme,
    ThemeData theme,
  ) {
    final unlocked = ref.watch(
      featureUnlockedProvider(AppFeature.cloudAutoSync),
    );
    final enabled = CloudAutoSyncRunner.isEnabled;
    final lastRun = CloudAutoSyncRunner.lastRun;
    final lastResult = CloudAutoSyncRunner.lastResult;

    return AppCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Automated Cloud Sync',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ProBadge(
                  label: unlocked ? 'PRO' : 'UPGRADE',
                  onTap: () => ProUpgradeSheet.show(context),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              unlocked
                  ? 'Uploads an encrypted .cpbak to your connected cloud on a '
                      'schedule, checked each time the app opens.'
                  : 'Upgrade to back up automatically. Connecting a provider '
                      'and backing up by hand stay free.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            SwitchListTile(
              value: enabled && unlocked,
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Back up automatically'),
              onChanged:
                  unlocked
                      ? (v) async {
                        AppHaptics.selection();
                        await CloudAutoSyncRunner.setEnabled(v);
                        if (mounted) setState(() {});
                      }
                      : null,
            ),
            if (unlocked && enabled) ...[
              PickerField<String>(
                label: 'Frequency',
                value: CloudAutoSyncRunner.frequency,
                options: [
                  for (final f in CloudAutoSyncSchedule.frequencies)
                    PickerOption(value: f, label: f),
                ],
                onChanged: (v) async {
                  await CloudAutoSyncRunner.setFrequency(v);
                  if (mounted) setState(() {});
                },
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                lastRun == null
                    ? 'Not run yet — the first backup happens next launch.'
                    : 'Last run ${Formatters.formatDate(lastRun)}'
                        '${lastResult == null ? '' : ' · $lastResult'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _triggerCloudBackup() async {
    AppHaptics.selection();
    setState(() => _isBackingUp = true);

    final messenger = ScaffoldMessenger.of(context);
    final registry = ref.read(cloudStorageRegistryProvider);
    final db = ref.read(databaseProvider);

    try {
      final result = await registry.createAndUploadBackup(db);
      if (!mounted) return;

      if (result.success) {
        AppHaptics.success();
        ref.invalidate(remoteBackupsProvider);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Backup uploaded to cloud: ${result.fileName}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        AppHaptics.error();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Cloud backup failed: ${result.errorMessage ?? "Unknown error"}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppHaptics.error();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to perform cloud backup: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreRemoteItem(RemoteBackupItem item) async {
    AppHaptics.selection();
    final messenger = ScaffoldMessenger.of(context);
    final registry = ref.read(cloudStorageRegistryProvider);
    final connector = registry.activeConnector;
    final db = ref.read(databaseProvider);

    if (connector == null) return;

    setState(() => _isRestoring = true);
    try {
      final bytes = await connector.downloadBackup(item.id);
      final metadata = BackupContainerService.inspectBackup(bytes);

      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (ctx) => RestorePreviewDialog(
              metadata: metadata,
              onConfirm: () async {
                final result = await BackupContainerService(
                  db,
                ).restoreFromBackupBytes(bytes);
                if (ctx.mounted) {
                  Navigator.of(ctx).pop(result.success);
                }
              },
            ),
      );

      if (confirmed == true) {
        ref.invalidate(clinicsStreamProvider);
        ref.invalidate(databaseProvider);

        if (!mounted) return;
        AppHaptics.success();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Practice data restored from cloud! (${metadata.totalRecords} records restored)',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppHaptics.error();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to restore from cloud: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _deleteRemoteItem(RemoteBackupItem item) async {
    AppHaptics.error();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AppConfirmDialog(
            title: 'Delete Cloud Backup',
            message:
                'Are you sure you want to permanently delete "${item.name}" from your cloud storage?',
            confirmLabel: 'Delete',
            isDestructive: true,
            onConfirm: () => Navigator.of(ctx).pop(true),
          ),
    );

    if (confirmed != true) return;

    final registry = ref.read(cloudStorageRegistryProvider);
    final connector = registry.activeConnector;
    if (connector == null) return;

    try {
      final ok = await connector.deleteBackup(item.id);
      if (ok) {
        AppHaptics.medium();
        ref.invalidate(remoteBackupsProvider);
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Deleted "${item.name}" from cloud storage.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete cloud backup: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showConfigureProviderDialog() {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => const _ConfigureCloudProviderDialog(),
    );
  }

  Future<void> _disconnectActive() async {
    AppHaptics.error();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AppConfirmDialog(
            title: 'Disconnect Cloud Storage',
            message:
                'Are you sure you want to disconnect this cloud provider? Your local backups and remote cloud files will remain safe.',
            confirmLabel: 'Disconnect',
            isDestructive: true,
            onConfirm: () => Navigator.of(ctx).pop(true),
          ),
    );

    if (confirmed == true) {
      final registry = ref.read(cloudStorageRegistryProvider);
      await registry.disconnectActive();
      ref.invalidate(activeCloudConnectorProvider);
      ref.invalidate(cloudConnectionStatusProvider);
      ref.invalidate(cloudAccountInfoProvider);
      ref.invalidate(remoteBackupsProvider);
    }
  }

  Widget _buildAccountDetails(
    BuildContext context,
    ColorScheme scheme,
    ThemeData theme,
    CloudAccountInfo info,
  ) {
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  info.email != null && info.email!.isNotEmpty
                      ? '${info.accountName} (${info.email})'
                      : info.accountName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CustomBadge(label: 'Zero-Liability', color: scheme.tertiary),
            ],
          ),
          if (info.storageTotalBytes != null &&
              info.storageTotalBytes! > 0) ...[
            const SizedBox(height: Spacing.xs),
            ClipRRect(
              borderRadius: Radii.pillAll,
              child: LinearProgressIndicator(
                value: info.usageFraction ?? 0.0,
                backgroundColor: scheme.surfaceContainerHighest,
                color: scheme.primary,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatBytes(info.storageUsedBytes ?? 0)} used of ${_formatBytes(info.storageTotalBytes!)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${((info.usageFraction ?? 0.0) * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final activeConnector = ref.watch(activeCloudConnectorProvider);
    final isConnectedAsync = ref.watch(cloudConnectionStatusProvider);
    final isConnected = isConnectedAsync.value ?? false;
    final accountInfoAsync = ref.watch(cloudAccountInfoProvider);
    final remoteBackupsAsync = ref.watch(remoteBackupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Backup & Sync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh remote backups',
            onPressed: () {
              AppHaptics.selection();
              ref.invalidate(cloudConnectionStatusProvider);
              ref.invalidate(cloudAccountInfoProvider);
              ref.invalidate(remoteBackupsProvider);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        children: [
          // ── 1. ACTIVE CONNECTOR STATUS ──────────────────────────
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  title: 'Cloud Storage Provider',
                  subtitle:
                      'Personal cloud storage for offsite practice backups',
                  tightTop: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          AppCard(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color:
                              isConnected
                                  ? scheme.primaryContainer
                                  : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                        child: Icon(
                          activeConnector?.icon ?? Icons.cloud_off_outlined,
                          color:
                              isConnected
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeConnector?.displayName ??
                                  'No Provider Connected',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isConnected
                                  ? 'Connected and ready for backup & restore'
                                  : 'Tap configure to connect your Google Drive, OneDrive, or WebDAV storage',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomBadge(
                        label: isConnected ? 'Connected' : 'Offline',
                        color: isConnected ? scheme.primary : scheme.outline,
                      ),
                    ],
                  ),
                  if (isConnected && accountInfoAsync.value != null) ...[
                    const SizedBox(height: Spacing.md),
                    _buildAccountDetails(
                      context,
                      scheme,
                      theme,
                      accountInfoAsync.value!,
                    ),
                  ],
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.outlined(
                          label:
                              activeConnector == null
                                  ? 'Connect Cloud'
                                  : 'Configure',
                          icon: Icons.settings_outlined,
                          onPressed: _showConfigureProviderDialog,
                        ),
                      ),
                      if (activeConnector != null) ...[
                        const SizedBox(width: Spacing.sm),
                        IconButton(
                          icon: const Icon(Icons.link_off),
                          tooltip: 'Disconnect provider',
                          color: scheme.error,
                          onPressed: _disconnectActive,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: Spacing.lg),

          // ── 2. MANUAL BACK UP ACTION ───────────────────────────
          if (isConnected) ...[
            AppCard(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Immediate Cloud Backup',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Compresses all 14 clinical and financial tables into an encrypted .cpbak and uploads to your cloud.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    AppButton.primary(
                      label: 'Back Up Now',
                      icon: Icons.cloud_upload_outlined,
                      loading: _isBackingUp,
                      onPressed: _isBackingUp ? null : _triggerCloudBackup,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
          ],

          // ── 2b. AUTOMATED SYNC (PRO) ──────────────────────────
          _buildAutoSyncCard(context, scheme, theme),
          const SizedBox(height: Spacing.lg),

          // ── 3. REMOTE BACKUPS CATALOG ─────────────────────────
          SectionHeader(
            title: 'Remote Backups on Cloud',
            subtitle:
                'Archives available for instant restoration on this or a new device',
          ),
          const SizedBox(height: Spacing.xs),

          if (!isConnected)
            AppCard(
              margin: EdgeInsets.zero,
              child: EmptyState(
                icon: Icons.cloud_queue_outlined,
                title: 'No Cloud Storage Connected',
                message:
                    'Connect a cloud-synced folder or WebDAV server above to view and restore remote backups.',
                actionLabel: 'Connect Provider',
                onAction: _showConfigureProviderDialog,
              ),
            )
          else
            remoteBackupsAsync.when(
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(Spacing.xl),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              error:
                  (err, _) => AppCard(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: Text(
                        'Failed to load remote backups: $err',
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                  ),
              data: (items) {
                if (items.isEmpty) {
                  return AppCard(
                    margin: EdgeInsets.zero,
                    child: EmptyState(
                      icon: Icons.folder_open_outlined,
                      title: 'No Backups in Cloud Yet',
                      message:
                          'Tap "Back Up Now" above to upload your first practice archive to your cloud storage.',
                    ),
                  );
                }

                return Column(
                  children:
                      items.map((item) {
                        final dateStr = Formatters.formatDate(item.modifiedAt);
                        return AppCard(
                          margin: const EdgeInsets.only(bottom: Spacing.sm),
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.sm),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(Spacing.sm),
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(
                                      Radii.md,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    color: scheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: Spacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$dateStr • ${item.formattedSize}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.download_outlined,
                                    size: 20,
                                  ),
                                  tooltip: 'Restore from this backup',
                                  onPressed:
                                      _isRestoring
                                          ? null
                                          : () => _restoreRemoteItem(item),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  tooltip: 'Delete cloud file',
                                  color: scheme.error,
                                  onPressed: () => _deleteRemoteItem(item),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Dialog allowing doctor to choose and configure cloud provider credentials.
class _ConfigureCloudProviderDialog extends ConsumerStatefulWidget {
  const _ConfigureCloudProviderDialog();

  @override
  ConsumerState<_ConfigureCloudProviderDialog> createState() =>
      _ConfigureCloudProviderDialogState();
}

class _ConfigureCloudProviderDialogState
    extends ConsumerState<_ConfigureCloudProviderDialog> {
  String _selectedType = 'google_drive';
  bool _isLoading = false;
  String? _errorMessage;

  // Google Drive fields
  final _googleAccessTokenController = TextEditingController();
  final _googleRefreshTokenController = TextEditingController();
  final _googleEmailController = TextEditingController();
  final _googleNameController = TextEditingController();

  // Folder sync fields
  final _folderPathController = TextEditingController();

  // WebDAV fields
  final _webdavUrlController = TextEditingController();
  final _webdavUserController = TextEditingController();
  final _webdavPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final registry = ref.read(cloudStorageRegistryProvider);
    final active = registry.activeConnector;
    if (active is GoogleDriveConnector) {
      _selectedType = 'google_drive';
      _googleAccessTokenController.text = active.accessToken ?? '';
      _googleRefreshTokenController.text = active.refreshToken ?? '';
      _googleEmailController.text = active.userEmail ?? '';
      _googleNameController.text = active.userName ?? '';
    } else if (active is WebDavConnector) {
      _selectedType = 'webdav';
      _webdavUrlController.text = active.serverUrl ?? '';
      _webdavUserController.text = active.username ?? '';
    } else if (active is FolderSyncConnector) {
      _selectedType = 'folder_sync';
      _folderPathController.text = active.targetPath ?? '';
    }
  }

  @override
  void dispose() {
    _googleAccessTokenController.dispose();
    _googleRefreshTokenController.dispose();
    _googleEmailController.dispose();
    _googleNameController.dispose();
    _folderPathController.dispose();
    _webdavUrlController.dispose();
    _webdavUserController.dispose();
    _webdavPassController.dispose();
    super.dispose();
  }

  Future<void> _pickFolder() async {
    if (kIsWeb) return;
    AppHaptics.selection();
    final selected = await FilePicker.platform.getDirectoryPath();
    if (selected != null) {
      setState(() => _folderPathController.text = selected);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final registry = ref.read(cloudStorageRegistryProvider);
    try {
      if (_selectedType == 'google_drive') {
        final token = _googleAccessTokenController.text.trim();
        if (token.isEmpty) {
          throw ArgumentError('Please enter a Google OAuth Access Token.');
        }
        await registry.configureAndConnect('google_drive', {
          'accessToken': token,
          if (_googleRefreshTokenController.text.trim().isNotEmpty)
            'refreshToken': _googleRefreshTokenController.text.trim(),
          if (_googleEmailController.text.trim().isNotEmpty)
            'userEmail': _googleEmailController.text.trim(),
          if (_googleNameController.text.trim().isNotEmpty)
            'userName': _googleNameController.text.trim(),
        });
      } else if (_selectedType == 'folder_sync') {
        final path = _folderPathController.text.trim();
        if (path.isEmpty) {
          throw ArgumentError('Please select or enter a synced folder path.');
        }
        await registry.configureAndConnect('folder_sync', {'path': path});
      } else {
        final url = _webdavUrlController.text.trim();
        final user = _webdavUserController.text.trim();
        final pass = _webdavPassController.text.trim();

        if (url.isEmpty || user.isEmpty || pass.isEmpty) {
          throw ArgumentError('Please complete all WebDAV server fields.');
        }
        await registry.configureAndConnect('webdav', {
          'serverUrl': url,
          'username': user,
          'password': pass,
        });
      }

      ref.invalidate(activeCloudConnectorProvider);
      ref.invalidate(cloudConnectionStatusProvider);
      ref.invalidate(cloudAccountInfoProvider);
      ref.invalidate(remoteBackupsProvider);

      if (mounted) {
        AppHaptics.success();
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
      AppHaptics.error();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Configure Cloud Storage'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Provider Type',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              RadioListTile<String>(
                value: 'google_drive',
                groupValue: _selectedType,
                title: Row(
                  children: [
                    const Text('Google Drive'),
                    const SizedBox(width: Spacing.xs),
                    CustomBadge(label: 'Zero-Cost', color: scheme.primary),
                  ],
                ),
                subtitle: const Text(
                  'Encrypted backup to your personal Google Drive (appDataFolder)',
                ),
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              RadioListTile<String>(
                value: 'folder_sync',
                groupValue: _selectedType,
                title: const Text('Cloud Synced Folder'),
                subtitle: const Text(
                  'Google Drive, OneDrive, or Dropbox folder on this device',
                ),
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              RadioListTile<String>(
                value: 'webdav',
                groupValue: _selectedType,
                title: const Text('Nextcloud / OwnCloud / WebDAV'),
                subtitle: const Text(
                  'Direct server connection (Nextcloud, Box, self-hosted NAS)',
                ),
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: Spacing.md),

              if (_selectedType == 'google_drive') ...[
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          'Direct OAuth2 connection to your personal Google Drive. Encrypted archives (.cpbak) are stored in the private appDataFolder, invisible to third-party apps.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                TextField(
                  controller: _googleAccessTokenController,
                  decoration: const InputDecoration(
                    labelText: 'Google OAuth Access Token *',
                    hintText: 'ya29.a0AfH6SM...',
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                TextField(
                  controller: _googleRefreshTokenController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Refresh Token (Optional)',
                    hintText: '1//0g...',
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                TextField(
                  controller: _googleEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Google Account Email (Optional)',
                    hintText: 'doctor@gmail.com',
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.bolt_outlined, size: 16),
                    label: const Text(
                      'Use Sandbox / Demo Token',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _googleAccessTokenController.text =
                            'demo_google_access_token_${DateTime.now().millisecondsSinceEpoch}';
                        _googleRefreshTokenController.text =
                            'demo_refresh_token';
                        _googleEmailController.text =
                            'doctor.practice@gmail.com';
                        _googleNameController.text = 'Dr. Demo Practitioner';
                      });
                    },
                  ),
                ),
              ] else if (_selectedType == 'folder_sync') ...[
                TextField(
                  controller: _folderPathController,
                  decoration: InputDecoration(
                    labelText: 'Synced Folder Path',
                    hintText: 'e.g. D:\\GoogleDrive\\ClinicPilotBackups',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: _pickFolder,
                    ),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _webdavUrlController,
                  decoration: const InputDecoration(
                    labelText: 'WebDAV Server URL',
                    hintText:
                        'https://cloud.example.com/remote.php/dav/files/user/',
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                TextField(
                  controller: _webdavUserController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: Spacing.sm),
                TextField(
                  controller: _webdavPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password or App Token',
                  ),
                ),
              ],

              if (_errorMessage != null) ...[
                const SizedBox(height: Spacing.md),
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: scheme.onErrorContainer,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton.primary(
          label: 'Save & Connect',
          loading: _isLoading,
          onPressed: _isLoading ? null : _submit,
        ),
      ],
    );
  }
}
