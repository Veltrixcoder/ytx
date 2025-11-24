import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ytx/models/ytify_result.dart';

class YtifyApiService {
  static const String _baseUrl = 'https://ytify-backend.vercel.app/api/search';

  Future<List<YtifyResult>> search(String query, {String filter = 'songs'}) async {
    try {
      final uri = Uri.parse('$_baseUrl?q=$query&filter=$filter');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List?;
        if (results != null) {
          return results.map((e) => YtifyResult.fromJson(e)).toList();
        }
      } else {
        debugPrint('Ytify API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error searching Ytify: $e');
    }
    return [];
  }

  Future<List<YtifyResult>> getExploreFeed() async {
    // Using "newest" as query to simulate explore feed as requested
    // We can fetch a mix of filters if needed, but for now let's just fetch songs/videos
    // Or maybe just one call with a generic query if the API supports it without filter?
    // The user said "remove all filter and in explore page show few results from all filters with query as newest"
    // The API seems to require a filter based on the examples, but let's try calling for each and combining.
    
    // Actually, the user said "remove all filter" which implies maybe no filter param?
    // But the examples show specific filters. 
    // "for explore page show few results from all filters with query as newest"
    
    List<YtifyResult> combinedResults = [];
    
    try {
      final songs = await search('newest', filter: 'songs');
      final videos = await search('newest', filter: 'videos');
      
      combinedResults.addAll(songs.take(5));
      combinedResults.addAll(videos.take(5));
      
      // Shuffle to mix them up? Or just list them.
      return combinedResults;
    } catch (e) {
      debugPrint('Error fetching explore feed: $e');
      return [];
    }
  }
}
