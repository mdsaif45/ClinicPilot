import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cloud/cloud_storage_connector.dart';
import '../../../core/cloud/cloud_storage_registry.dart';
import '../../../core/cloud/connectors/folder_sync_connector.dart';
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
      ref.invalidate(remoteBackupsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final activeConnector = ref.watch(activeCloudConnectorProvider);
    final isConnectedAsync = ref.watch(cloudConnectionStatusProvider);
    final isConnected = isConnectedAsync.value ?? false;
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
                      'Personal cloud storage for automated offsite practice backups',
                  tightTop: true,
                ),
              ),
              ProBadge(
                label: 'PRO',
                onTap: () => ProUpgradeSheet.show(context),
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
  String _selectedType = 'folder_sync'; // 'folder_sync' or 'webdav'
  bool _isLoading = false;
  String? _errorMessage;

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
    if (active is WebDavConnector) {
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
      if (_selectedType == 'folder_sync') {
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

              if (_selectedType == 'folder_sync') ...[
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
