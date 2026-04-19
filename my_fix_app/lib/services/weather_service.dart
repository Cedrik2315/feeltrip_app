import 'dart:convert';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:feeltrip_app/core/security/security_utils.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Get current weather for a location (lat, lng)
  Future<Map<String, dynamic>?> getWeather(double lat, double lng) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      // Mock data for development if API key is missing
      return {
        'temp': 24.5,
        'description': 'Soleado',
        'icon': '01d',
        'humidity': 45,
        'wind': 12.0,
      };
    }

    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/weather?lat=$lat&lon=$lng&units=metric&lang=es&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final main = data['main'] as Map<String, dynamic>;
        final weather = (data['weather'] as List).first as Map<String, dynamic>;
        final wind = data['wind'] as Map<String, dynamic>;

        return {
          'temp': (main['temp'] as num).toDouble(),
          'description': weather['description'],
          'icon': weather['icon'],
          'humidity': main['humidity'],
          'wind': (wind['speed'] as num).toDouble(),
        };
      }
      AppLogger.w('Weather API error: ${response.statusCode}');
      return null;
    } catch (e) {
      AppLogger.e('Error fetching weather: $e');
      return null;
    }
  }

  /// Get forecast for a city name
  Future<List<Map<String, dynamic>>> getForecast(String city) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    final sCity = SecurityUtils.sanitizeInput(city);
    if (apiKey == null || apiKey.isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/forecast?q=$sCity&units=metric&lang=es&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final list = data['list'] as List<dynamic>;

        return list.take(5).map((item) {
          final i = item as Map<String, dynamic>;
          final main = i['main'] as Map<String, dynamic>;
          final weather = (i['weather'] as List).first as Map<String, dynamic>;
          return {
            'dt': i['dt'],
            'temp': (main['temp'] as num).toDouble(),
            'description': weather['description'],
            'icon': weather['icon'],
          };
        }).toList();
      }
      AppLogger.w('Forecast API error: ${response.statusCode}');
      return [];
    } catch (e) {
      AppLogger.e('Error fetching forecast: $e');
      return [];
    }
  }
}