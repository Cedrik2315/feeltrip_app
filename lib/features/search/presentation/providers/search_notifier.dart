import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/services/algolia_search_service.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// Estado de la búsqueda
class SearchState {

  SearchState({this.results = const [], this.isLoading = false, this.error});
  final List<Map<String, dynamic>> results;
  final bool isLoading;
  final String? error;
}

final searchNotifierProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState());

  final _algoliaService = AlgoliaSearchService();

  /// Realiza una búsqueda avanzada usando Algolia (Fase 3).
  Future<void> search(String query, {String? collection}) async {
    if (query.isEmpty) {
      state = SearchState(results: []);
      return;
    }

    state = SearchState(isLoading: true);

    try {
      // Ahora usamos Algolia para búsqueda semántica y escala
      final results = await _algoliaService.searchExperiences(query);

      state = SearchState(results: results);
    } catch (e) {
      AppLogger.e('Error en la búsqueda de Firestore: $e');
      state = SearchState(
        results: [],
        error: 'No se pudo completar la búsqueda. Inténtalo de nuevo.',
      );
    }
  }

  void clearSearch() {
    state = SearchState();
  }
}