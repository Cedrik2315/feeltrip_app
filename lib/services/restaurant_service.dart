import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Provider para acceder al servicio de restaurantes desde cualquier parte de la app.
final restaurantServiceProvider = Provider<RestaurantService>((ref) => RestaurantService());

class RestaurantService {
  static const String _baseUrl = 'https://api.foursquare.com/v3/places/search';

  Future<List<Map<String, dynamic>>> getNearbyRestaurants(
      double lat, double lng,
      {int limit = 5}) async {
    final apiKey = dotenv.env['FOURSQUARE_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      AppLogger.e('FOURSQUARE_API_KEY is missing in .env');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl?ll=$lat,$lng&categories=13065&limit=$limit'), // 13065 = Restaurant category
        headers: {
          'Authorization': apiKey,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results.map((place) => place as Map<String, dynamic>).toList();
      }
      AppLogger.w('Foursquare API error: ${response.statusCode}');
      return [];
    } catch (e) {
      AppLogger.e('Error fetching restaurants: $e');
      return [];
    }
  }
}
