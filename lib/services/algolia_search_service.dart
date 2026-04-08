import 'package:algoliasearch/algoliasearch.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Servicio para la integración con Algolia (Fase 3).
/// Permite realizar búsquedas rápidas y semánticas a gran escala.
class AlgoliaSearchService {
  late final SearchClient _client;
  static const String _indexName = 'experiences';

  AlgoliaSearchService() {
    final appId = dotenv.env['ALGOLIA_APP_ID'] ?? '';
    final apiKey = dotenv.env['ALGOLIA_SEARCH_API_KEY'] ?? '';

    if (appId.isEmpty || apiKey.isEmpty) {
      AppLogger.w('AlgoliaSearchService: Faltan credenciales (APP_ID/API_KEY) en el archivo .env');
    }

    _client = SearchClient(appId: appId, apiKey: apiKey);
  }

  /// Realiza una búsqueda de experiencias.
  Future<List<Map<String, dynamic>>> searchExperiences(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final response = await _client.searchIndex(
        request: SearchForHits(
          indexName: _indexName,
          query: query,
          hitsPerPage: 20,
        ),
      );

      return response.hits.map((hit) => hit.toJson()).toList();
    } catch (e) {
      AppLogger.e('AlgoliaSearchService Error: $e');
      return [];
    }
  }
}