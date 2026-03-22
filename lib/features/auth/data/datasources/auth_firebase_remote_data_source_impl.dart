import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';
import 'auth_remote_data_source.dart';

class AuthFirebaseRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthFirebaseRemoteDataSourceImpl(this._auth);
  final firebase.FirebaseAuth _auth;

  @override
  Future<AuthUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUser(userCredential.user);
    } on firebase.FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('ServerFailure: $e');
    }
  }

  @override
  Future<AuthUser?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUser(userCredential.user);
    } on firebase.FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('ServerFailure: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('ServerFailure: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('ServerFailure: $e');
    }
  }

  @override
  Future<void> updateDisplayName(String? displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
    } catch (e) {
      throw Exception('ServerFailure: $e');
    }
  }

  @override
  Future<void> updatePhotoURL(String? photoURL) async {
    try {
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } catch (e) {
      throw Exception('ServerFailure: $e');
    }
  }

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      throw Exception('ServerFailure: $e');
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      throw Exception('ServerFailure: $e');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception('ServerFailure: $e');
    }
  }

  
  Future<AuthUser?> getCurrentUser() async {
    return _mapFirebaseUser(_auth.currentUser);
  }

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map(_mapFirebaseUser);

  AuthUser? _mapFirebaseUser(firebase.User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
