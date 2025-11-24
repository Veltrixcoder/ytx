import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ytx/models/ytify_result.dart';

class YouTubeApiService {
  static const String _baseUrl = 'https://youtubei.googleapis.com/youtubei/v1/';
  static const String _referer = 'https://www.youtube.com/';
  static const String _userAgent = 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Mobile Safari/537.36';
  static const String _clientName = 'ANDROID';
  static const String _clientVersion = '19.17.34';
  static const int _clientId = 3;

  Future<String?> getStreamUrl(String videoId) async {
    try {
      final url = Uri.parse('${_baseUrl}player');
      final headers = {
        'X-Goog-Api-Format-Version': '1',
        'X-YouTube-Client-Name': _clientId.toString(),
        'X-YouTube-Client-Version': _clientVersion,
        'User-Agent': _userAgent,
        'Referer': _referer,
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        'context': {
          'client': {
            'clientName': _clientName,
            'clientVersion': _clientVersion,
          }
        },
        'videoId': videoId,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode != 200) {
        debugPrint('YouTube API Error: ${response.statusCode} - ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      
      if (data['playabilityStatus']?['status'] != 'OK') {
        debugPrint('Video not playable: ${data['playabilityStatus']?['reason']}');
        return null;
      }

      final streamingData = data['streamingData'];
      if (streamingData == null) {
        debugPrint('No streaming data found');
        return null;
      }

      // Try to find adaptive audio formats first
      final adaptiveFormats = streamingData['adaptiveFormats'] as List<dynamic>?;
      if (adaptiveFormats != null) {
        // Filter for audio-only formats
        final audioFormats = adaptiveFormats.where((f) => 
          f['mimeType'].toString().startsWith('audio/')
        ).toList();

        if (audioFormats.isNotEmpty) {
          // Sort by bitrate descending
          audioFormats.sort((a, b) => (b['bitrate'] as int).compareTo(a['bitrate'] as int));
          return audioFormats.first['url'] as String;
        }
      }

      // Fallback to regular formats if no adaptive audio found
      final formats = streamingData['formats'] as List<dynamic>?;
      if (formats != null) {
         final audioFormats = formats.where((f) => 
          f['mimeType'].toString().startsWith('audio/')
        ).toList();
        
        if (audioFormats.isNotEmpty) {
           return audioFormats.first['url'] as String;
        }
      }

      debugPrint('No suitable audio stream found');
      return null;

    } catch (e) {
      debugPrint('Error fetching stream info: $e');
      return null;
    }
  }
  Future<List<YtifyResult>> search(String query, {String filter = 'songs'}) async {
    try {
      final uri = Uri.parse('https://ytify-backend.vercel.app/api/search').replace(queryParameters: {
        'q': query,
        'filter': filter,
      });

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        debugPrint('Ytify Search Error: ${response.statusCode}');
        return [];
      }

      final data = jsonDecode(response.body);
      final resultsJson = data['results'] as List?;

      if (resultsJson == null) return [];

      return resultsJson.map((json) => YtifyResult.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching: $e');
      return [];
    }
  }
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final uri = Uri.parse('https://ytify-backend.vercel.app/api/search/suggestions').replace(queryParameters: {
        'q': query,
        'music': '1',
      });

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        debugPrint('Ytify Suggestions Error: ${response.statusCode}');
        return [];
      }

      final data = jsonDecode(response.body);
      final suggestions = data['suggestions'] as List?;

      if (suggestions == null) return [];

      return suggestions.map((s) => s.toString()).toList();
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      return [];
    }
  }
}
