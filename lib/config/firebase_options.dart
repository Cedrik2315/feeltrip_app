import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Opciones de configuración de Firebase para diferentes plataformas
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Para desarrollo local, usa estas credenciales
    // EN PRODUCCIÓN, carga desde .env o variables de ambiente
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? 'AIzaSyDemoKey',
      appId: dotenv.env['FIREBASE_APP_ID'] ?? '1:demo:android:demo',
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? 'demo',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'feeltrip-demo',
      authDomain:
          dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? 'feeltrip-demo.firebaseapp.com',
      databaseURL: dotenv.env['FIREBASE_DATABASE_URL'] ??
          'https://feeltrip-demo.firebaseio.com',
      storageBucket:
          dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'feeltrip-demo.appspot.com',
    );
  }

  /// Configuración para emulador local (desarrollo)
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
