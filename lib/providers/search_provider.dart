import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ytx/models/ytify_result.dart';
import 'package:ytx/services/youtube_api_service.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchFilterProvider = StateProvider<String>((ref) => 'songs');

final searchResultsProvider = FutureProvider<List<YtifyResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(searchFilterProvider);
  
  if (query.isEmpty) {
    return [];
  }

  final apiService = YouTubeApiService();
  return await apiService.search(query, filter: filter);
});

final searchSuggestionsProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final apiService = YouTubeApiService();
  return await apiService.getSearchSuggestions(query);
});
