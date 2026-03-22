import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DestinationService {
  static const String unsplashKey = 'mock_unsplash_key';
  static const String baseUrl = 'https://api.feeltrip.com/destinations';

  /// Get destinations by emotional archetype
  static Future<List<Map<String, dynamic>>> getDestinationsByArchetype({
    required String archetype,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/archetype/$archetype?limit=$limit'),
      );

      if (response.statusCode == 200) {
        // CORRECCIÓN: Decodificar y convertir de forma segura
        final List<dynamic> rawData = json.decode(response.body) as List<dynamic>;
        
        // Usamos .map para asegurar que cada elemento sea un Map<String, dynamic>
        final destinations = rawData.map((item) => item as Map<String, dynamic>).toList();
        
        AppLogger.i('Loaded ${destinations.length} destinations for $archetype');
        return destinations;
      }
      throw Exception('Failed to load destinations');
    } catch (e) {
      AppLogger.e('Destination load error: $e');
      
      // Mock data for archetype - CORRECCIÓN: Tipado explícito para evitar errores de inferencia
      final List<Map<String, dynamic>> mocks = [
        {
          'name': 'Bali Yoga',
          'archetype': 'spiritual',
          'image': 'assets/images/bali_yoga.png'
        },
        {
          'name': 'Queenstown Adventure',
          'archetype': 'adventurer',
          'image': 'assets/images/queenstown_adventure.png'
        },
        {
          'name': 'Tromso Aurora',
          'archetype': 'dreamer',
          'image': 'assets/images/tromso_aurora.png'
        },
        {
          'name': 'Toscana Nonna',
          'archetype': 'cultural',
          'image': 'assets/images/tuscana_nonna.png'
        },
      ];

      return mocks.where((d) => d['archetype'] == archetype).toList();
    }
  }

  /// Get destination details with weather
  static Future<Map<String, dynamic>> getDestinationDetails({
    required String destinationId,
  }) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$destinationId'));
      if (response.statusCode == 200) {
        // CORRECCIÓN: Casteo explícito a Map<String, dynamic>
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Destination not found');
    } catch (e) {
      AppLogger.e('Destination details error: $e');
      return {
        'id': destinationId,
        'name': 'Mock Destination',
        'description': 'Beautiful place for your emotional journey',
        'experiences': 12,
        'weather': 'Sunny, 24°C',
      };
    }
  }

  /// Search destinations
  static Future<List<Map<String, dynamic>>> searchDestinations({
    required String query,
  }) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search?q=$query'));
      if (response.statusCode == 200) {
        // CORRECCIÓN: Conversión segura de lista dinámica a lista de mapas
        final List<dynamic> rawData = json.decode(response.body) as List<dynamic>;
        return rawData.map((item) => item as Map<String, dynamic>).toList();
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      AppLogger.e('Search error: $e');
      return <Map<String, dynamic>>[];
    }
  }
}