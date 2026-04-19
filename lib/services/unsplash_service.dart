import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/core/security/security_utils.dart';

class UnsplashService {
  static const String _baseUrl = 'https://api.unsplash.com';

  Future<List<String>> getDestinationPhotos(String query,
      {int count = 5}) async {
    final accessKey = dotenv.env['UNSPLASH_ACCESS_KEY'];
    final sQuery = SecurityUtils.sanitizeInput(query);
    if (accessKey == null || accessKey.isEmpty) {
      AppLogger.e('UNSPLASH_ACCESS_KEY is missing in .env');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/search/photos?query=$sQuery&per_page=$count&orientation=landscape'),
        headers: {'Authorization': 'Client-ID $accessKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results.map<String>((img) {
          final item = img as Map<String, dynamic>;
          final urls = item['urls'] as Map<String, dynamic>;
          return urls['regular'] as String;
        }).toList();
      }
      AppLogger.w('Unsplash API error: ${response.statusCode}');
      return [];
    } catch (e) {
      AppLogger.e('Error fetching photos: $e');
      return [];
    }
  }
}
