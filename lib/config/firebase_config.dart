import 'dart:async';

import 'package:feeltrip_app/config/firebase_options.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static bool _isInitialized = false;
  static Object? _lastInitializationError;

  static bool get isInitialized => _isInitialized;
  static Object? get lastInitializationError => _lastInitializationError;

  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final initTask = Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException(
            'Firebase timeout',
            const Duration(seconds: 5),
          );
        },
      );

      await initTask;
      _isInitialized = true;
      _lastInitializationError = null;
      AppLogger.i('FirebaseConfig: Firebase inicializado correctamente.');
      return true;
    } catch (e) {
      if (e.toString().contains('duplicate-app') ||
          e.toString().contains('already exists')) {
        _isInitialized = true;
        _lastInitializationError = null;
        AppLogger.i('FirebaseConfig: Firebase ya estaba inicializado.');
        return true;
      }

      _isInitialized = false;
      _lastInitializationError = e;
      AppLogger.w(
        'FirebaseConfig: Firebase no quedó inicializado. La app continuará en modo degradado.',
        e,
      );
      return false;
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
