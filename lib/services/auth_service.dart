import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/app_logger.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // Stream para saber si el usuario esta logueado o no.
  Stream<User?> get userStream => _auth.authStateChanges();

  // Getter para el usuario actual de forma síncrona.
  User? get user => _auth.currentUser;

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

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      return _auth.signInWithPopup(provider);
    }

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Inicio de sesion con Google cancelado');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    if (kIsWeb) {
      final provider = FacebookAuthProvider();
      provider.addScope('email');
      provider.setCustomParameters({'display': 'popup'});
      final credential = await _auth.signInWithPopup(provider);
      await _persistFacebookUserId(credential.user);
      return credential;
    }

    final result = await FacebookAuth.instance
        .login(permissions: const ['public_profile', 'email']);
    if (result.status == LoginStatus.cancelled) {
      throw Exception('Inicio de sesion con Facebook cancelado');
    }
    if (result.status != LoginStatus.success || result.accessToken == null) {
      final message = result.message ?? 'No se pudo autenticar con Facebook';
      throw Exception(message);
    }

    final credential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);
    final userCredential = await _auth.signInWithCredential(credential);
    await _persistFacebookUserId(userCredential.user);
    return userCredential;
  }

  Future<void> _persistFacebookUserId(User? user) async {
    if (user == null) return;

    try {
      String? facebookUserId;
      for (final provider in user.providerData) {
        if (provider.providerId == 'facebook.com') {
          final uid = provider.uid?.trim() ?? '';
          if (uid.isNotEmpty) {
            facebookUserId = uid;
            break;
          }
        }
      }

      if (facebookUserId == null) return;
      if (facebookUserId.isEmpty) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'facebookUserId': facebookUserId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      AppLogger.debug('No se pudo persistir facebookUserId: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
