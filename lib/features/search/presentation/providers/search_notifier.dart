import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:feeltrip_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:feeltrip_app/features/search/domain/entities/search_result.dart';

part 'search_notifier.g.dart';

@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  FutureOr<List<SearchResult>> build() => [];

  Future<void> searchExperiences(String query) async {
    if (query.isEmpty) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();

    // Usamos guard para capturar errores automáticamente
    state = await AsyncValue.guard(() async {
      final repository = ref.read(searchRepositoryProvider);

      // Si tu repositorio devuelve Either<Failure, List<SearchResult>>:
      final result = await repository.searchExperiences(query);

      return result.fold(
        (failure) => throw Exception(failure.toString()),
        (results) => results,
      );
    });
  }
}
