import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/features/search/domain/entities/search_result.dart';
import 'package:feeltrip_app/services/algolia_search_service.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import '../../domain/repositories/search_repository.dart';

part 'search_repository_impl.g.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this.firestore, this.algoliaService);

  final FirebaseFirestore firestore;
  final AlgoliaSearchService algoliaService;

  @override
  Future<Either<Failure, List<SearchResult>>> searchExperiences(String query) async {
    try {
      final normalizedQuery = query.trim();
      if (normalizedQuery.isEmpty) {
        return const Right([]);
      }

      // 1. Intentar con Algolia (Alta performance / SemÃ¡ntica)
      final algoliaHits = await algoliaService.searchExperiences(normalizedQuery);
      
      if (algoliaHits.isNotEmpty) {
        final results = algoliaHits.map((hit) {
          return SearchResult(
            id: (hit['objectID'] ?? hit['id']) as String? ?? '',
            title: (hit['title'] ?? '') as String,
            description: (hit['description'] ?? '') as String,
            rating: (hit['rating'] as num?)?.toDouble() ?? 0.0,
            imageUrl: (hit['imageUrl'] ?? '') as String,
            destination: (hit['destination'] ?? '') as String,
          );
        }).toList();
        return Right(results);
      }

      // 2. Fallback a Firestore (BÃºsqueda bÃ¡sica)
      final titleSnapshot = await firestore
          .collection('experiences')
          .where('title', isGreaterThanOrEqualTo: normalizedQuery)
          .where('title', isLessThanOrEqualTo: '$normalizedQuery\uf8ff')
          .limit(10)
          .get();

      final results = titleSnapshot.docs.map((doc) {
        final data = doc.data();
        return SearchResult(
          id: doc.id,
          title: data['title'] as String? ?? '',
          description: data['description'] as String? ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['imageUrl'] as String? ?? '',
          destination: data['destination'] as String? ?? '',
        );
      }).toList();

      return Right(results);
    } catch (e) {
      return const Left(ServerFailure('Search error'));
    }
  }
}

@riverpod
SearchRepository searchRepository(SearchRepositoryRef ref) {
  return SearchRepositoryImpl(
    FirebaseFirestore.instance, 
    ref.watch(algoliaServiceProvider),
  );
}
