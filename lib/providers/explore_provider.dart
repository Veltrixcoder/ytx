import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ytx/models/ytify_result.dart';
import 'package:ytx/services/youtube_api_service.dart';

final exploreContentProvider = FutureProvider<List<YtifyResult>>((ref) async {
  final apiService = YouTubeApiService();
  
  // Fetch songs and videos for "newest"
  // We can run these in parallel
  final songsFuture = apiService.search('newest', filter: 'songs');
  final videosFuture = apiService.search('newest', filter: 'videos');
  
  final results = await Future.wait([songsFuture, videosFuture]);
  
  final songs = results[0];
  final videos = results[1];
  
  // Interleave or just combine
  // Let's just combine for now
  return [...songs, ...videos]..shuffle(); // Shuffle to give a "mixed" feel
});
