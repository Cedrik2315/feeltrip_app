import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

import '../core/app_logger.dart';
import 'firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      AppLogger.debug('Inicializando Firebase...', name: 'FirebaseConfig');

      final initTask = Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          AppLogger.info('Firebase timeout - usando MOCK data', name: 'FirebaseConfig');
          throw TimeoutException('Firebase initialization timed out');
        },
      );

      await initTask;
      AppLogger.info('Firebase inicializado exitosamente', name: 'FirebaseConfig');
    } catch (e, st) {
      if (e.toString().contains('duplicate-app') ||
          e.toString().contains('already exists')) {
        AppLogger.info('Firebase ya estaba inicializado', name: 'FirebaseConfig');
        return;
      }
      if (e.toString().contains('TimeoutException')) {
        AppLogger.info(
          'Firebase timeout - usando MOCK data sin problemas',
          name: 'FirebaseConfig',
        );
        return;
      }
      AppLogger.error(
        'Error inicializando Firebase (continuando con MOCK)',
        error: e,
        stackTrace: st,
        name: 'FirebaseConfig',
      );
    }
  }

  static const String usersCollection = 'users';
  static const String storiesCollection = 'stories';
  static const String storiesSubcollection = 'stories';
  static const String diaryEntriesSubcollection = 'diaryEntries';
  static const String impactMetricsSubcollection = 'impactMetrics';
  static const String quizResultsSubcollection = 'quizResults';

  static const String userProfileDoc = 'profile';
  static const String userDiaryStatsDoc = 'stats';

  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String userIdField = 'userId';
}

