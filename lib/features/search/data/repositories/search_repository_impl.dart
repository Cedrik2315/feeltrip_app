import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../../../../core/error/failures.dart';

part 'search_repository_impl.g.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this.firestore);
  final FirebaseFirestore firestore;

  @override
  Future<Either<Failure, List<SearchResult>>> searchExperiences(
      String query) async {
    try {
      final snapshot = await firestore
          .collection('experiences')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(20)
          .get();

      final results = snapshot.docs.map((doc) {
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
      return Left(ServerFailure());
    }
  }
}

@riverpod
SearchRepository searchRepository(SearchRepositoryRef ref) {
  return SearchRepositoryImpl(FirebaseFirestore.instance);
}
