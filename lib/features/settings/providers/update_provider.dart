import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/update_service.dart';

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

// Checked once per app start in the background. Null when up to date or check failed.
final availableUpdateProvider = FutureProvider<AppRelease?>((ref) async {
  final service = ref.watch(updateServiceProvider);
  return await service.checkForUpdate();
});

enum DownloadStatus { idle, downloading, ready, error }

class UpdateDownloadState {
  final DownloadStatus status;
  final double progress; // 0.0 to 1.0
  final int downloadedBytes;
  final String? downloadedFilePath;
  final String? errorMessage;

  const UpdateDownloadState({
    this.status = DownloadStatus.idle,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.downloadedFilePath,
    this.errorMessage,
  });

  UpdateDownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    int? downloadedBytes,
    String? downloadedFilePath,
    String? errorMessage,
  }) {
    return UpdateDownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UpdateDownloadNotifier extends StateNotifier<UpdateDownloadState> {
  final UpdateService _updateService;
  StreamSubscription<double>? _downloadSub;

  UpdateDownloadNotifier(this._updateService) : super(const UpdateDownloadState());

  void startDownload(AppRelease release) {
    if (state.status == DownloadStatus.downloading) return;

    state = const UpdateDownloadState(
      status: DownloadStatus.downloading,
      progress: 0.0,
    );

    _downloadSub?.cancel();
    _downloadSub = _updateService.downloadApkStream(
      release,
      onComplete: (filePath) {
        state = state.copyWith(
          status: DownloadStatus.ready,
          progress: 1.0,
          downloadedFilePath: filePath,
        );
      },
      onError: (error) {
        state = state.copyWith(
          status: DownloadStatus.error,
          errorMessage: error.toString(),
        );
      },
    ).listen(
      (progress) {
        final downloadedBytes = (progress * release.apkSizeBytes).round();
        state = state.copyWith(
          progress: progress,
          downloadedBytes: downloadedBytes,
        );
      },
      onError: (error) {
        state = state.copyWith(
          status: DownloadStatus.error,
          errorMessage: error.toString(),
        );
      },
    );
  }

  void cancelDownload() {
    _downloadSub?.cancel();
    _downloadSub = null;
    state = const UpdateDownloadState(status: DownloadStatus.idle);
  }

  void reset() {
    _downloadSub?.cancel();
    _downloadSub = null;
    state = const UpdateDownloadState(status: DownloadStatus.idle);
  }

  @override
  void dispose() {
    _downloadSub?.cancel();
    super.dispose();
  }
}

final updateDownloadProvider =
    StateNotifierProvider<UpdateDownloadNotifier, UpdateDownloadState>((ref) {
  final service = ref.watch(updateServiceProvider);
  return UpdateDownloadNotifier(service);
});

final updateBadgeDismissedProvider = StateProvider<bool>((ref) => false);
