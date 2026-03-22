import 'package:dartz/dartz.dart';
import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';
import 'package:feeltrip_app/features/auth/domain/repositories/auth_repository.dart';

class SignInEmailUseCase {
  const SignInEmailUseCase(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, AuthUser>> call({
    required String email,
    required String password,
  }) async {
    try {
      final user = await repository.signInWithEmailAndPassword(email, password);
      if (user == null) return const Left(AuthFailure('No user found'));
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('Sign in failed: ${e.toString()}'));
    }
  }
}
