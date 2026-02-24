import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feeltrip_app/config/firebase_options.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('currentPlatform retorna opciones Android con llaves requeridas', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await dotenv.load(
      mergeWith: const {
        'FIREBASE_ANDROID_API_KEY': 'key',
        'FIREBASE_ANDROID_APP_ID': 'app',
        'FIREBASE_ANDROID_MESSAGING_SENDER_ID': 'sender',
        'FIREBASE_ANDROID_PROJECT_ID': 'project',
      },
    );

    final options = DefaultFirebaseOptions.currentPlatform;
    expect(options.apiKey, 'key');
    expect(options.appId, 'app');
    expect(options.projectId, 'project');
  });

  test('currentPlatform lanza StateError cuando falta llave requerida', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await dotenv.load(
      mergeWith: const {
        'FIREBASE_ANDROID_API_KEY': 'key',
        'FIREBASE_ANDROID_APP_ID': '',
        'FIREBASE_ANDROID_MESSAGING_SENDER_ID': 'sender',
        'FIREBASE_ANDROID_PROJECT_ID': 'project',
      },
    );

    expect(
      () => DefaultFirebaseOptions.currentPlatform,
      throwsA(isA<StateError>()),
    );
  });
}
