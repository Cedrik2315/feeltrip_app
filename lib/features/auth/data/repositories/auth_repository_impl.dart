import 'package:firebase_auth/firebase_auth.dart';
import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';
import 'package:feeltrip_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._firebaseAuth);
  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return AuthUser(
        id: user.uid,
        email: user.email!,
        name: user.displayName,
        photoUrl: user.photoURL,
      );
    });
  }

  @override
  Future<AuthUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) return null;
      return AuthUser(
        id: user.uid,
        email: user.email!,
        name: user.displayName,
        photoUrl: user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  @override
  Future<AuthUser?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) return null;
      return AuthUser(
        id: user.uid,
        email: user.email!,
        name: user.displayName,
        photoUrl: user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updateDisplayName(String? displayName) async {
    await _firebaseAuth.currentUser?.updateDisplayName(displayName);
  }

  @override
  Future<void> updatePhotoURL(String? photoURL) async {
    await _firebaseAuth.currentUser?.updatePhotoURL(photoURL);
  }

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail) async {
    try {
      await _firebaseAuth.currentUser?.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('ServerFailure: $e');
    }
  }

  @override
  Future<void> deleteUser() async {
    await _firebaseAuth.currentUser?.delete();
  }
}
