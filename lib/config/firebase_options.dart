import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      if (_hasAll(const [
        'FIREBASE_WEB_API_KEY',
        'FIREBASE_WEB_APP_ID',
        'FIREBASE_WEB_MESSAGING_SENDER_ID',
        'FIREBASE_WEB_PROJECT_ID',
      ])) {
        return _web;
      }
      throw UnsupportedError(
        'Firebase Web no está configurado. Define FIREBASE_WEB_* en .env.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        return _ios;
      case TargetPlatform.windows:
        if (_hasAll(const [
          'FIREBASE_WINDOWS_API_KEY',
          'FIREBASE_WINDOWS_APP_ID',
          'FIREBASE_WINDOWS_MESSAGING_SENDER_ID',
          'FIREBASE_WINDOWS_PROJECT_ID',
        ])) {
          return _windows;
        }
        throw UnsupportedError(
          'Firebase Windows no está configurado. Ejecuta flutterfire configure o define FIREBASE_WINDOWS_* en .env.',
        );
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase no está configurado para $defaultTargetPlatform en este proyecto.',
        );
    }
  }

  static FirebaseOptions get _android => FirebaseOptions(
        apiKey: _require('FIREBASE_ANDROID_API_KEY'),
        appId: _require('FIREBASE_ANDROID_APP_ID'),
        messagingSenderId: _require('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
        projectId: _require('FIREBASE_ANDROID_PROJECT_ID'),
        storageBucket: _optional('FIREBASE_ANDROID_STORAGE_BUCKET'),
        databaseURL: _optional('FIREBASE_ANDROID_DATABASE_URL'),
      );

  static FirebaseOptions get _ios => FirebaseOptions(
        apiKey: _require('FIREBASE_IOS_API_KEY'),
        appId: _require('FIREBASE_IOS_APP_ID'),
        messagingSenderId: _require('FIREBASE_IOS_MESSAGING_SENDER_ID'),
        projectId: _require('FIREBASE_IOS_PROJECT_ID'),
        iosBundleId: _optional('FIREBASE_IOS_BUNDLE_ID'),
        storageBucket: _optional('FIREBASE_IOS_STORAGE_BUCKET'),
        databaseURL: _optional('FIREBASE_IOS_DATABASE_URL'),
      );

  static FirebaseOptions get _windows => FirebaseOptions(
        apiKey: _require('FIREBASE_WINDOWS_API_KEY'),
        appId: _require('FIREBASE_WINDOWS_APP_ID'),
        messagingSenderId: _require('FIREBASE_WINDOWS_MESSAGING_SENDER_ID'),
        projectId: _require('FIREBASE_WINDOWS_PROJECT_ID'),
        authDomain: _optional('FIREBASE_WINDOWS_AUTH_DOMAIN'),
        storageBucket: _optional('FIREBASE_WINDOWS_STORAGE_BUCKET'),
        databaseURL: _optional('FIREBASE_WINDOWS_DATABASE_URL'),
      );

  static FirebaseOptions get _web => FirebaseOptions(
        apiKey: _require('FIREBASE_WEB_API_KEY'),
        appId: _require('FIREBASE_WEB_APP_ID'),
        messagingSenderId: _require('FIREBASE_WEB_MESSAGING_SENDER_ID'),
        projectId: _require('FIREBASE_WEB_PROJECT_ID'),
        authDomain: _optional('FIREBASE_WEB_AUTH_DOMAIN'),
        storageBucket: _optional('FIREBASE_WEB_STORAGE_BUCKET'),
        databaseURL: _optional('FIREBASE_WEB_DATABASE_URL'),
      );

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty || value.contains('demo')) {
      throw StateError(
        'Firebase no está configurado correctamente. Falta $key en .env con valor real.',
      );
    }
    return value;
  }

  static bool _hasAll(List<String> keys) {
    return keys.every((key) {
      final value = dotenv.env[key];
      return value != null && value.trim().isNotEmpty && !value.contains('demo');
    });
  }

  static String? _optional(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty || value.contains('demo')) {
      return null;
    }
    return value;
  }
}
