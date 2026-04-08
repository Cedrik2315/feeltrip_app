import 'package:dartz/dartz.dart';
import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';
import 'package:feeltrip_app/features/auth/domain/repositories/auth_repository.dart';

class SignInEmailUseCase {
  const SignInEmailUseCase(this.repository);
  
  // Mantenemos la abstracción usando la Interfaz en lugar de la implementación
  // para respetar los principios de Inversión de Dependencias (D de SOLID)

  final IAuthRepository repository;

  Future<Either<Failure, AuthUser>> call({
    required String email,
    required String password,
  }) async {
    // El repositorio devuelve Either<Failure, AuthUser?>
    final result = await repository.signInWithEmailAndPassword(email, password);
    
    // La lógica del UseCase asegura que si la autenticación es exitosa, 
    // devolvemos un AuthUser no nulo. Si es nulo, lo tratamos como un fallo.
    return result.fold(
      (failure) => Left(failure),
      (user) => user != null ? Right(user) : const Left(AuthFailure('No user found')),
    );
  }
}
