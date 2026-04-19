import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Opciones de configuracion de Firebase para diferentes plataformas
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // En Android usamos el appId real de com.feeltrip.app para mantener
    // alineados Firebase Auth, Firestore y Google Play services.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ??
            'AIzaSyAfg-_6MyMO_CNZ9R2GUSMbaeudlXV96eY',
        appId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ??
            '1:315728939057:android:736dbb99246ca65f71ed10',
        messagingSenderId:
            dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '315728939057',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'feeltrip-app',
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ??
            'feeltrip-app.firebaseapp.com',
        databaseURL: 'https://feeltrip-app.firebaseio.com',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ??
            'feeltrip-app.firebasestorage.app',
      );
    }
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ??
          'AIzaSyAfg-_6MyMO_CNZ9R2GUSMbaeudlXV96eY',
      appId: dotenv.env['FIREBASE_APP_ID'] ??
          '1:315728939057:android:736dbb99246ca65f71ed10',
      messagingSenderId:
          dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '315728939057',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'feeltrip-app',
      authDomain:
          dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? 'feeltrip-app.firebaseapp.com',
      databaseURL: 'https://feeltrip-app.firebaseio.com',
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ??
          'feeltrip-app.firebasestorage.app',
    );
  }

  /// Configuracion para emulador local (desarrollo)
  static FirebaseOptions get emulator {
    return const FirebaseOptions(
      apiKey: 'demo-key',
      appId: '1:demo:android:demo',
      messagingSenderId: 'demo',
      projectId: 'feeltrip-demo',
      authDomain: 'feeltrip-demo.firebaseapp.com',
      databaseURL: 'http://localhost:9000',
      storageBucket: 'feeltrip-demo.appspot.com',
    );
  }
}
