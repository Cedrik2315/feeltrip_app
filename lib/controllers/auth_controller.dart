import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class AuthController {
  AuthController(this._authService);

  final AuthService _authService;

  Future<void> login({required String email, required String password}) async {
    try {
      await _authService.signInWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFromCode(e.code));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _authService.registerWithEmail(
        name: name,
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFromCode(e.code, register: true));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFromCode(e.code, reset: true));
    }
  }

  String _messageFromCode(String code, {bool register = false, bool reset = false}) {
    if (register) {
      switch (code) {
        case 'email-already-in-use':
          return 'Ese email ya está registrado';
        case 'weak-password':
          return 'La contraseña es muy débil';
        case 'invalid-email':
          return 'Email inválido';
        default:
          return 'No se pudo crear la cuenta';
      }
    }

    if (reset) {
      switch (code) {
        case 'user-not-found':
          return 'No existe una cuenta con ese email';
        case 'invalid-email':
          return 'Email inválido';
        default:
          return 'No se pudo enviar el correo de recuperación';
      }
    }

    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Email inválido';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      default:
        return 'No se pudo iniciar sesión';
    }
  }
}
