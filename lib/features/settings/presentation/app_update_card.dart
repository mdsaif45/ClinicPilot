import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/update_service.dart';
import '../../../core/widgets/custom_badge.dart';
import '../providers/update_provider.dart';

class AppUpdateCard extends ConsumerStatefulWidget {
  const AppUpdateCard({super.key});

  @override
  ConsumerState<AppUpdateCard> createState() => _AppUpdateCardState();
}

class _AppUpdateCardState extends ConsumerState<AppUpdateCard> {
  bool _isCheckingManual = false;

  /// Only after a check completes can the card claim the app is current.
  bool _hasCheckedThisSession = false;
  bool _showNotes = false;
  String _runningVersion = '0.2.0';

  @override
  void initState() {
    super.initState();
    _loadRunningVersion();
  }

  Future<void> _loadRunningVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _runningVersion = info.version;
        });
      }
    } catch (_) {
      // Fallback stays '0.2.0'
    }
  }

  Future<void> _triggerManualCheck() async {
    setState(() {
      _isCheckingManual = true;
    });

    ref.invalidate(availableUpdateProvider);
    final result = await ref.read(availableUpdateProvider.future);

    if (mounted) {
      setState(() {
        _isCheckingManual = false;
        _hasCheckedThisSession = true;
      });

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are on the latest version.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleInstall(String filePath) async {
    final status = await Permission.requestInstallPackages.status;
    if (status.isPermanentlyDenied || status.isDenied) {
      final reqStatus = await Permission.requestInstallPackages.request();
      if (!reqStatus.isGranted) {
        if (mounted) {
          _showPermissionDialog();
        }
        return;
      }
    }

    final service = ref.read(updateServiceProvider);
    await service.installApk(filePath);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Android requires the "Install unknown apps" permission for ClinicPilot to install updates. Please enable it in system settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 MB';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String _formatDaysAgo(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff <= 0) return 'today';
    if (diff == 1) return 'yesterday';
    return '$diff days ago';
  }

  @override
  Widget build(BuildContext context) {
    final updateAsync = ref.watch(availableUpdateProvider);
    final downloadState = ref.watch(updateDownloadProvider);
    final downloadNotifier = ref.read(updateDownloadProvider.notifier);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: updateAsync.when(
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.system_update, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'App Version',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'v$_runningVersion · Checking for updates...',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          error: (_, __) => _buildStatusState(
            'Could not check for updates',
          ),
          data: (AppRelease? release) {
            if (release == null) {
              return _buildStatusState(
                _hasCheckedThisSession
                    ? 'You are on the latest version'
                    : 'Tap to check for updates',
              );
            }

            // Downloading state
            if (downloadState.status == DownloadStatus.downloading) {
              final pct = (downloadState.progress * 100).toStringAsFixed(0);
              final downloadedMb = _formatSize(downloadState.downloadedBytes);
              final totalMb = _formatSize(release.apkSizeBytes);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.downloading, color: Theme.of(context).colorScheme.tertiary),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Text(
                          'Downloading Update v${release.version}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.tertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  LinearProgressIndicator(
                    value: downloadState.progress > 0 ? downloadState.progress : null,
                    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: Radii.smAll,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$downloadedMb of $totalMb',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                      ),
                      TextButton.icon(
                        onPressed: downloadNotifier.cancelDownload,
                        icon: Icon(Icons.cancel, size: 16, color: Theme.of(context).colorScheme.error),
                        label: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ),
                    ],
                  ),
                ],
              );
            }

            // Download ready state
            if (downloadState.status == DownloadStatus.ready &&
                downloadState.downloadedFilePath != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Text(
                          'Update Ready: v${release.version}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'Downloaded. Tap Install, then confirm on the Android prompt.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: Spacing.md),
                  Container(
                    padding: const EdgeInsets.all(Spacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: Radii.smAll,
                      border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onTertiaryContainer, size: 20),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Text(
                            'Android will ask you to confirm this installation. Your clinic data will not be affected by the update.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  ElevatedButton.icon(
                    onPressed: () => _handleInstall(downloadState.downloadedFilePath!),
                    icon: const Icon(Icons.system_update),
                    label: const Text('Install Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: const Size.fromHeight(42),
                    ),
                  ),
                ],
              );
            }

            // Error state during download
            if (downloadState.status == DownloadStatus.error) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Text(
                          'Download Failed',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    downloadState.errorMessage ?? 'An error occurred during download.',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => downloadNotifier.startDownload(release),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Download'),
                      ),
                      const SizedBox(width: Spacing.sm),
                      TextButton(
                        onPressed: downloadNotifier.reset,
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ],
              );
            }

            // Update Available state
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.system_update, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CustomBadge(
                                label: 'Update Available',
                              ),
                              const SizedBox(width: Spacing.sm),
                              Text(
                                'v${release.version}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatSize(release.apkSizeBytes)} · released ${_formatDaysAgo(release.publishedAt)}',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (release.notes.isNotEmpty) ...[
                  const SizedBox(height: Spacing.sm),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showNotes = !_showNotes;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                      child: Row(
                        children: [
                          Text(
                            _showNotes ? 'Hide Release Notes' : 'View Release Notes',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Icon(
                            _showNotes
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showNotes) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: Spacing.xs, bottom: Spacing.sm),
                      padding: const EdgeInsets.all(Spacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: Radii.smAll,
                      ),
                      child: Text(
                        release.notes,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: Spacing.md),
                ElevatedButton.icon(
                  onPressed: () => downloadNotifier.startDownload(release),
                  icon: const Icon(Icons.download),
                  label: const Text('Download & Install'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: const Size.fromHeight(42),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Version row with whatever the app can honestly say about update state.
  Widget _buildStatusState(String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.system_update, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Version',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'v$_runningVersion · $status',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        OutlinedButton.icon(
          onPressed: _isCheckingManual ? null : _triggerManualCheck,
          icon: _isCheckingManual
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh, size: 18),
          label: const Text('Check for updates'),
        ),
      ],
    );
  }
}
