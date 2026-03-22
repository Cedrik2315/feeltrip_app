import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';

abstract class AuthRemoteDataSource {
  Stream<AuthUser?> authStateChanges();
  Future<AuthUser?> signInWithEmailAndPassword(String email, String password);
  Future<AuthUser?> registerWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateDisplayName(String? displayName);
  Future<void> updatePhotoURL(String? photoURL);
  Future<void> verifyBeforeUpdateEmail(String newEmail);
  Future<void> deleteUser();
}
