import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:ytx/services/youtube_api_service.dart';
import 'package:ytx/models/ytify_result.dart';

import 'package:ytx/services/storage_service.dart';

class AudioHandler {
  final AudioPlayer _player = AudioPlayer();
  final YouTubeApiService _apiService = YouTubeApiService();
  final StorageService _storage = StorageService();
  
  // Playlist for queue management
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  AudioPlayer get player => _player;
  ConcatenatingAudioSource get playlist => _playlist;

  AudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // Initialize player with the playlist
    // We don't set it immediately to avoid errors if empty, 
    // but we will set it when first item is played or queue is modified.
    // Actually, setting it now is fine, it just won't play anything.
    // But usually we set it when we have something to play.
  }

  Future<void> playVideo(dynamic video) async {
    try {
      // Add to history
      if (video is YtifyResult) {
        _storage.addToHistory(video);
      }

      // Clear queue and play single video
      await _playlist.clear();
      await addToQueue(video);
      await _player.setAudioSource(_playlist);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing video: $e');
    }
  }

  Future<void> addToQueue(dynamic video) async {
    try {
      String videoId;
      String title;
      String artist;
      String artUri;
      String resultType = 'video';

      if (video is YtifyResult) {
        if (video.videoId == null) return;
        videoId = video.videoId!;
        title = video.title;
        artist = video.artists?.map((a) => a.name).join(', ') ?? video.videoType ?? 'Unknown';
        artUri = video.thumbnails.isNotEmpty ? video.thumbnails.last.url : '';
        resultType = video.resultType;
      } else {
        return;
      }

      // We need to fetch stream URL. 
      // NOTE: Fetching stream URL for every item in queue immediately might be slow/expensive.
      // Better approach: LockCachingAudioSource or similar, but for now we fetch eagerly 
      // or we can use a custom AudioSource that fetches on demand.
      // Given the constraints and simplicity, let's fetch eagerly for single items, 
      // but for "Play All" we might need a smarter way. 
      // For now, let's just fetch.
      
      final streamUrl = await _apiService.getStreamUrl(videoId);
      if (streamUrl == null) return;

      final audioSource = AudioSource.uri(
        Uri.parse(streamUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Mobile Safari/537.36',
        },
        tag: MediaItem(
          id: videoId,
          album: "YTX Music",
          title: title,
          artist: artist,
          artUri: Uri.parse(artUri),
          extras: {
            'resultType': resultType,
          },
        ),
      );

      await _playlist.add(audioSource);
      
      // If player is not set to this playlist (e.g. first item), set it
      if (_player.audioSource != _playlist) {
        await _player.setAudioSource(_playlist);
      }
    } catch (e) {
      debugPrint('Error adding to queue: $e');
    }
  }

  Future<void> playAll(List<YtifyResult> results) async {
    try {
      if (results.isEmpty) return;

      await _player.stop();
      await _playlist.clear();
      
      // Add first item and play immediately
      _storage.addToHistory(results.first);
      await addToQueue(results.first);
      
      if (_playlist.length > 0) {
         await _player.setAudioSource(_playlist);
         _player.play(); 
      }

      // Add the rest in background, but await to ensure order
      if (results.length > 1) {
        for (int i = 1; i < results.length; i++) {
          await addToQueue(results[i]); 
        }
      }
    } catch (e) {
      debugPrint('Error playing all: $e');
    }
  }

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.play();
  Future<void> seek(Duration position, {int? index}) => _player.seek(position, index: index);
  Future<void> skipToNext() => _player.seekToNext();
  Future<void> skipToPrevious() => _player.seekToPrevious();

  void dispose() {
    _player.dispose();
  }
}
