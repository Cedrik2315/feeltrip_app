import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/features/search/domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';

part 'search_repository_impl.g.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Future<Either<Failure, List<SearchResult>>> searchExperiences(String query) async {
    try {
      final normalizedQuery = query.trim();
      if (normalizedQuery.isEmpty) {
        return const Right([]);
      }

      final titleSnapshot = await firestore
          .collection('experiences')
          .where('title', isGreaterThanOrEqualTo: normalizedQuery)
          .where('title', isLessThanOrEqualTo: '$normalizedQuery\uf8ff')
          .limit(10)
          .get();

      final destinationSnapshot = await firestore
          .collection('experiences')
          .where('destination', isGreaterThanOrEqualTo: normalizedQuery)
          .where('destination', isLessThanOrEqualTo: '$normalizedQuery\uf8ff')
          .limit(10)
          .get();

      final docsById = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
      for (final doc in titleSnapshot.docs) {
        docsById[doc.id] = doc;
      }
      for (final doc in destinationSnapshot.docs) {
        docsById[doc.id] = doc;
      }

      final results = docsById.values.map((doc) {
        final data = doc.data();
        return SearchResult(
          id: doc.id,
          title: data['title'] as String? ?? '',
          description: data['description'] as String? ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['imageUrl'] as String? ?? '',
          destination: data['destination'] as String? ?? '',
        );
      }).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));

      return Right(results);
    } catch (e) {
      return const Left(ServerFailure('Search error'));
    }
  }
}

@riverpod
SearchRepository searchRepository(SearchRepositoryRef ref) {
  return SearchRepositoryImpl(FirebaseFirestore.instance);
}
