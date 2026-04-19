import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:feeltrip_app/features/search/domain/entities/search_result.dart';
import 'package:feeltrip_app/features/search/domain/repositories/search_repository.dart';

class SearchState {
  SearchState({this.results = const [], this.isLoading = false, this.error});

  final List<Map<String, dynamic>> results;
  final bool isLoading;
  final String? error;
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(searchRepositoryProvider));
});

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._repository) : super(SearchState());

  final SearchRepository _repository;

  Future<void> search(String query, {String? collection}) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      state = SearchState(results: []);
      return;
    }

    state = SearchState(isLoading: true);

    final result = await _repository.searchExperiences(normalizedQuery);
    result.fold(
      (failure) => state = SearchState(
        results: const [],
        error: _mapFailure(failure),
      ),
      (items) => state = SearchState(
        results: items.map(_toPresentationMap).toList(),
      ),
    );
  }

  void clearSearch() {
    state = SearchState();
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ServerFailure() => failure.message,
      _ => 'No se pudo completar la búsqueda. Inténtalo de nuevo.',
    };
  }

  Map<String, dynamic> _toPresentationMap(SearchResult item) {
    return {
      'id': item.id,
      'title': item.title,
      'description': item.description,
      'rating': item.rating,
      'imageUrl': item.imageUrl,
      'destination': item.destination,
    };
  }
}
