import 'package:dartz/dartz.dart';
import 'package:feeltrip_app/core/error/failures.dart';
import '../entities/search_result.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<SearchResult>>> searchExperiences(String query);
}
