import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/update_service.dart';
import '../providers/update_provider.dart';

class AppUpdateCard extends ConsumerStatefulWidget {
  const AppUpdateCard({super.key});

  @override
  ConsumerState<AppUpdateCard> createState() => _AppUpdateCardState();
}

class _AppUpdateCardState extends ConsumerState<AppUpdateCard> {
  bool _isCheckingManual = false;
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: updateAsync.when(
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.system_update, color: Colors.teal),
                  const SizedBox(width: 12),
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
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          error: (_, __) => _buildUpToDateState(),
          data: (AppRelease? release) {
            if (release == null) {
              return _buildUpToDateState();
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
                      const Icon(Icons.downloading, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Downloading Update v${release.version}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: downloadState.progress > 0 ? downloadState.progress : null,
                    backgroundColor: Colors.blue.shade50,
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$downloadedMb of $totalMb',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                      TextButton.icon(
                        onPressed: downloadNotifier.cancelDownload,
                        icon: const Icon(Icons.cancel, size: 16, color: Colors.red),
                        label: const Text('Cancel', style: TextStyle(color: Colors.red)),
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
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Update Ready: v${release.version}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Downloaded. Tap Install, then confirm on the Android prompt.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Android will ask you to confirm this installation. Your clinic data will not be affected by the update.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _handleInstall(downloadState.downloadedFilePath!),
                    icon: const Icon(Icons.system_update),
                    label: const Text('Install Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
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
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Download Failed',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    downloadState.errorMessage ?? 'An error occurred during download.',
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => downloadNotifier.startDownload(release),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Download'),
                      ),
                      const SizedBox(width: 8),
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
                        color: Colors.teal.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.system_update, color: Colors.teal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Update Available',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (release.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showNotes = !_showNotes;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            _showNotes ? 'Hide Release Notes' : 'View Release Notes',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Icon(
                            _showNotes
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.teal,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showNotes) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 4, bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        release.notes,
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => downloadNotifier.startDownload(release),
                  icon: const Icon(Icons.download),
                  label: const Text('Download & Install'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
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

  Widget _buildUpToDateState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.system_update, color: Colors.teal),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Version',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'v$_runningVersion · You are on the latest version',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
