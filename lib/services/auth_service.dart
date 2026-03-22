import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider global de AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Provider del estado de autenticación (stream)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Provider del usuario actual
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Login con email y password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Registro con email y password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Actualizar nombre
      await credential.user?.updateDisplayName(name);
      // Crear perfil en Firestore
      await _createUserProfile(credential.user!, name);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Crear perfil de usuario en Firestore
  Future<void> _createUserProfile(User user, String name) async {
    await _firestore.collection('users').doc(user.uid).set({
      'id': user.uid,
      'name': name,
      'email': user.email,
      'createdAt': DateTime.now().toIso8601String(),
      'avatarUrl': null,
      'bio': '',
      'city': '',
      'badges': <String>[],
      'archetype': null,
    });
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Recuperar contraseña
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Manejo de errores Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'El email ya está en uso';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-email':
        return 'Email inválido';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
