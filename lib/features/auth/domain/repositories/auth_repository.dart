import 'package:dartz/dartz.dart';
import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AuthUser?>> signInWithEmailAndPassword(
      String email, String password);
  Future<Either<Failure, AuthUser?>> registerWithEmailAndPassword(
      String email, String password);
  Future<Either<Failure, AuthUser?>> signInWithGoogle();
  Future<Either<Failure, AuthUser?>> signInWithFacebook();
  Future<void> signOut();
  
  // Métodos de gestión de cuenta necesarios para la coherencia de la App
  Stream<AuthUser?> authStateChanges();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> updateDisplayName(String? displayName);
  Future<void> updatePhotoURL(String? photoURL);
  Future<void> verifyBeforeUpdateEmail(String newEmail);
  Future<void> deleteUser();
  bool get isSignedIn;
  AuthUser? get currentUser;
}
