import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:feeltrip_app/controllers/auth_controller.dart';
import 'package:feeltrip_app/services/auth_service.dart';

class _MockAuthService extends Mock implements AuthService {}

void main() {
  late _MockAuthService authService;
  late AuthController controller;

  setUp(() {
    authService = _MockAuthService();
    controller = AuthController(authService);
  });

  test('login llama AuthService.signInWithEmail', () async {
    when(() => authService.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => throw UnimplementedError());

    try {
      await controller.login(email: 'a@b.com', password: '123456');
    } catch (_) {}

    verify(() => authService.signInWithEmail(email: 'a@b.com', password: '123456')).called(1);
  });

  test('login transforma código invalid-credential a mensaje de dominio', () async {
    when(() => authService.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(FirebaseAuthException(code: 'invalid-credential'));

    expect(
      () => controller.login(email: 'x@y.com', password: 'bad'),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Credenciales inválidas'),
        ),
      ),
    );
  });

  test('sendPasswordResetEmail llama al servicio', () async {
    when(() => authService.sendPasswordResetEmail(any())).thenAnswer((_) async {});

    await controller.sendPasswordResetEmail('foo@bar.com');

    verify(() => authService.sendPasswordResetEmail('foo@bar.com')).called(1);
  });
}
