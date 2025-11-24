import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ytx/models/ytify_result.dart';
import 'package:ytx/services/download_service.dart';
import 'package:ytx/services/storage_service.dart';

class DownloadState {
  final Map<String, double> progressMap;
  final Map<String, YtifyResult> activeDownloads;

  DownloadState({
    this.progressMap = const {},
    this.activeDownloads = const {},
  });

  DownloadState copyWith({
    Map<String, double>? progressMap,
    Map<String, YtifyResult>? activeDownloads,
  }) {
    return DownloadState(
      progressMap: progressMap ?? this.progressMap,
      activeDownloads: activeDownloads ?? this.activeDownloads,
    );
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>((ref) {
  return DownloadNotifier(ref);
});

class DownloadNotifier extends StateNotifier<DownloadState> {
  final Ref ref;
  final DownloadService _downloadService = DownloadService();

  DownloadNotifier(this.ref) : super(DownloadState());

  Future<bool> startDownload(YtifyResult result) async {
    if (result.videoId == null) return false;
    
    // Add to active downloads
    state = state.copyWith(
      activeDownloads: {...state.activeDownloads, result.videoId!: result},
      progressMap: {...state.progressMap, result.videoId!: 0.0},
    );

    final success = await _downloadService.downloadSong(
      result,
      onProgress: (received, total) {
        if (total != -1) {
          final progress = received / total;
          state = state.copyWith(
            progressMap: {...state.progressMap, result.videoId!: progress},
          );
        }
      },
    );

    // Remove from active downloads
    final newActive = Map<String, YtifyResult>.from(state.activeDownloads);
    newActive.remove(result.videoId);
    
    final newProgress = Map<String, double>.from(state.progressMap);
    newProgress.remove(result.videoId);

    state = state.copyWith(
      activeDownloads: newActive,
      progressMap: newProgress,
    );

    return success;
  }
}
