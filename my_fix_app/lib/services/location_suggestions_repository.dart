import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:feeltrip_app/services/emotional_engine_service.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Repositorio encargado de obtener sugerencias de lugares basadas en la ubicación
/// y el análisis emocional detectado en los diarios de viaje.
class LocationSuggestionsRepository {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  Future<List<Map<String, dynamic>>> getPersonalizedSuggestions({
    required Position currentPosition,
    required EmotionalAnalysis analysis,
  }) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      AppLogger.e('LocationSuggestionsRepository: GOOGLE_MAPS_API_KEY no configurada en .env.');
      return [];
    }

    try {
      // 1. Buscamos lugares cercanos genéricos en un radio de 5km
      final url = Uri.parse(
        '$_baseUrl?location=${currentPosition.latitude},${currentPosition.longitude}'
        '&radius=5000'
        '&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        AppLogger.e('LocationSuggestionsRepository: Error de red (${response.statusCode})');
        return [];
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
        AppLogger.e(
            'LocationSuggestionsRepository: API Status Error: ${data['status']}');
        return [];
      }

      final List<dynamic> results = (data['results'] as List<dynamic>?) ?? [];

      // 2. Filtramos usando los tags de la IA (comparando con la lista de 'types' de Google)
      return results.where((item) {
        final place = item as Map<String, dynamic>;
        final types = List<String>.from(place['types'] as Iterable? ?? []);
        return types.any((type) => analysis.travelTags.contains(type));
      }).map((e) => e as Map<String, dynamic>).toList();

    } catch (e) {
      AppLogger.e('LocationSuggestionsRepository: Excepción en la consulta: $e');
      return [];
    }
  }
}