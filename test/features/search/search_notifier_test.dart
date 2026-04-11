import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:feeltrip_app/features/search/domain/entities/search_result.dart';
import 'package:feeltrip_app/features/search/domain/repositories/search_repository.dart';
import 'package:feeltrip_app/features/search/presentation/providers/search_notifier.dart';

class FakeSearchRepository implements SearchRepository {
  @override
  Future<Either<Failure, List<SearchResult>>> searchExperiences(String query) async {
    return const Right([
      SearchResult(
        id: 'exp_1',
        title: 'Patagonia Reset',
        description: 'Trip',
        rating: 4.9,
        imageUrl: '',
        destination: 'Chile',
      ),
    ]);
  }
}

void main() {
  group('SearchNotifier', () {
    test('loads search results from repository', () async {
      final container = ProviderContainer(
        overrides: [
          searchRepositoryProvider.overrideWithValue(FakeSearchRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(searchNotifierProvider.notifier)
          .search('patagonia');

      final state = container.read(searchNotifierProvider);
      expect(state.results, isNotEmpty);
      expect(state.results.first['id'], 'exp_1');
    });
  });
}
