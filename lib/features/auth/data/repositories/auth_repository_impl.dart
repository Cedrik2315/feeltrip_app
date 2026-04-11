import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';
import 'package:dartz/dartz.dart';
import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(
    this._firebaseAuth,
    this._googleSignIn,
    this._facebookAuth,
  );

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  static Future<void>? _googleSignInInitialization;

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitialization ??= _googleSignIn.initialize();
  }

  AuthUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  Future<Either<Failure, AuthUser?>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(_mapFirebaseUser(userCredential.user));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Error de inicio de sesion'));
    } catch (e) {
      return Left(AuthFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(_mapFirebaseUser(userCredential.user));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Error en registro'));
    } catch (e) {
      return Left(AuthFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();

      GoogleSignInAccount? account;
      if (_googleSignIn.supportsAuthenticate()) {
        account = await _googleSignIn.authenticate();
      } else {
        final lightweightAuth = _googleSignIn.attemptLightweightAuthentication();
        account = lightweightAuth == null ? null : await lightweightAuth;
      }

      if (account == null) {
        return const Right(null);
      }

      final GoogleSignInAuthentication googleAuth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final result = await _firebaseAuth.signInWithCredential(credential);
      return Right(_mapFirebaseUser(result.user));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Google Sign-In fallido'));
    } catch (e) {
      AppLogger.e('Google Sign-In error: $e');
      return Left(AuthFailure('Google Sign-In error: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) return const Right(null);

      final credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return Right(_mapFirebaseUser(userCredential.user));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Facebook Sign-In fallido'));
    } catch (e) {
      AppLogger.e('Facebook Sign-In error: $e');
      return Left(AuthFailure('Facebook Sign-In error: $e'));
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _facebookAuth.logOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
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
    await _firebaseAuth.currentUser?.verifyBeforeUpdateEmail(newEmail);
  }

  @override
  Future<void> deleteUser() async {
    await _firebaseAuth.currentUser?.delete();
  }

  @override
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  @override
  AuthUser? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);
}
