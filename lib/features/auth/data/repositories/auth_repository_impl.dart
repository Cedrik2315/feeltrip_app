import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';
import 'package:feeltrip_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(
    this._firebaseAuth,
    this._facebookAuth,
    this._googleSignIn,
  );

  final FirebaseAuth _firebaseAuth;
  final FacebookAuth _facebookAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crea o actualiza el perfil del usuario en Firestore.
  /// Se usa [SetOptions(merge: true)] para evitar sobrescribir datos existentes 
  /// como el 'createdAt' si ya estuviera definido por una lógica previa.
  Future<void> _bootstrapUserDocument(User user) async {
    try {
      final ref = _firestore.collection('users').doc(user.uid);
      
      final Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'username': user.displayName ?? 'Explorador',
        'profileImageUrl': user.photoURL,
        'subscriptionLevel': 'free',
        'lastLoginAt': FieldValue.serverTimestamp(),
        // Usamos FieldValue.serverTimestamp() para consistencia en el servidor.
        // Si el documento es nuevo, 'createdAt' se crea; si existe, se mantiene.
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Agregamos createdAt solo si el documento no existe (opcional, manejado por merge)
      await ref.set(userData, SetOptions(merge: true));
      
      AppLogger.i('AuthRepository: Documento users/${user.uid} sincronizado.');
    } catch (e, st) {
      AppLogger.e('AuthRepository: Error crítico en _bootstrapUserDocument (Permisos/Red)', e, st);
      // Opcional: Podrías re-lanzar el error si consideras que sin perfil la app no debe abrirse.
    }
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

  /// Prepara la sesión asegurando que los claims del token estén frescos antes de escribir en DB.
  Future<void> _prepareAuthenticatedSession(User user) async {
    // Forzar refresco asegura que las Rules de Firestore reconozcan al usuario recién logueado.
    await user.getIdToken(true);
    
    AppLogger.i('AuthRepository: Iniciando sesión para uid=${user.uid}');
    
    // El bootstrap ocurre después de tener un token válido.
    await _bootstrapUserDocument(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.idTokenChanges().map(_mapFirebaseUser);
  }

  @override
  Future<Either<Failure, AuthUser?>> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _prepareAuthenticatedSession(userCredential.user!);
      }
      return Right(_mapFirebaseUser(userCredential.user));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Error de inicio de sesión'));
    } catch (e) {
      return Left(AuthFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _prepareAuthenticatedSession(userCredential.user!);
      }
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return Left(AuthFailure('Inicio de sesión cancelado'));

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      
      final result = await _firebaseAuth.signInWithCredential(credential);
      if (result.user != null) {
        await _prepareAuthenticatedSession(result.user!);
      }
      return Right(_mapFirebaseUser(result.user));
    } catch (e) {
      AppLogger.e('Google Sign-In error: $e');
      return Left(AuthFailure('Google Sign-In fallido: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status == LoginStatus.cancelled) {
        return Left(AuthFailure('Inicio de sesión cancelado.'));
      }

      if (result.status != LoginStatus.success) {
        return Left(AuthFailure('Facebook Error: ${result.message}'));
      }

      final credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _prepareAuthenticatedSession(userCredential.user!);
      }
      return Right(_mapFirebaseUser(userCredential.user));
    } catch (e) {
      return Left(AuthFailure('Facebook Sign-In error: $e'));
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _facebookAuth.logOut();
    await _firebaseAuth.signOut();
  }

  // --- MÉTODOS DE PERFIL (FASE 6) ---

  @override
  Future<void> deleteUser() async {
    await _firebaseAuth.currentUser?.delete();
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return Left(AuthFailure('No hay sesión activa'));

      final uid = user.uid;

      // 1. Purgar subcolecciones de Firestore
      final subCollections = [
        'diary_entries',
        'momentos',
        'notifications',
        'expedition_proofs',
        'proposals',
        'itineraries',
        'cartItems',
        'private',
      ];

      for (final sub in subCollections) {
        final snap = await _firestore
            .collection('users')
            .doc(uid)
            .collection(sub)
            .get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      }

      // 2. Eliminar documento raíz del usuario
      await _firestore.collection('users').doc(uid).delete();
      AppLogger.i('AuthRepository: Firestore purgado para uid=$uid');

      // 3. Cerrar sesiones de terceros
      await _googleSignIn.signOut();
      await _facebookAuth.logOut();

      // 4. Eliminar usuario de Firebase Auth
      await user.delete();
      AppLogger.i('AuthRepository: Cuenta eliminada para uid=$uid');

      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      // Si el token expiró, Firebase requiere re-autenticación antes de delete()
      AppLogger.e('deleteAccount FirebaseAuthException: ${e.code}');
      return Left(AuthFailure('Sesión expirada. Vuelve a iniciar sesión e intenta de nuevo.'));
    } catch (e, st) {
      AppLogger.e('deleteAccount error', e, st);
      return Left(AuthFailure('Error al eliminar cuenta: $e'));
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updatePhotoURL(String? photoURL) async {
    await _firebaseAuth.currentUser?.updatePhotoURL(photoURL);
    if (_firebaseAuth.currentUser != null) {
      await _bootstrapUserDocument(_firebaseAuth.currentUser!);
    }
  }

  @override
  Future<void> updateDisplayName(String? displayName) async {
    await _firebaseAuth.currentUser?.updateDisplayName(displayName);
    // Sincronizar con Firestore si es necesario
    if (_firebaseAuth.currentUser != null) {
      await _bootstrapUserDocument(_firebaseAuth.currentUser!);
    }
  }

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail) async {
    await _firebaseAuth.currentUser?.verifyBeforeUpdateEmail(newEmail);
  }

  @override
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  @override
  AuthUser? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);
}
