import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:feeltrip_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('AuthRepository Tests', () {
    test('signInWithEmailAndPassword success', () async {
      when(() => mockRepository.signInWithEmailAndPassword(
              'test@test.com', 'password'))
          .thenAnswer((_) async =>
              const Right(AuthUser(id: '123', email: 'test@test.com')));

      final result = await mockRepository.signInWithEmailAndPassword(
          'test@test.com', 'password');

      expect(result.isRight(), true);
      final user = result.getOrElse(() => null);
      expect(user, isNotNull);
      expect(user?.id, '123');
    });

    test('signInWithGoogle success', () async {
      when(() => mockRepository.signInWithGoogle()).thenAnswer((_) async =>
          const Right(AuthUser(id: 'google123', email: 'google@test.com')));

      final result = await mockRepository.signInWithGoogle();
      expect(result.isRight(), true);
      expect(result.getOrElse(() => null)?.id, 'google123');
    });

    test('registerWithEmail success', () async {
      when(() => mockRepository.registerWithEmailAndPassword(
              'new@test.com', 'password'))
          .thenAnswer((_) async =>
              const Right(AuthUser(id: 'new123', email: 'new@test.com')));

      final result = await mockRepository.registerWithEmailAndPassword(
          'new@test.com', 'password');
      expect(result.getOrElse(() => null)?.id, 'new123');
    });
  });
}
