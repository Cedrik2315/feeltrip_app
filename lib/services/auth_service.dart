import 'package:firebase_auth/firebase_auth.dart';

import '../core/app_logger.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  // Stream para saber si el usuario esta logueado o no.
  Stream<User?> get user => _auth.authStateChanges();
  Future<UserCredential?> signInAnon() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      AppLogger.debug('Error en Auth: $e');
      return null;
    }
  }
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (name.trim().isNotEmpty) {
      await credential.user?.updateDisplayName(name.trim());
    }
    return credential;
  }
  Future<void> signOut() async {
    await _auth.signOut();
  }
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
