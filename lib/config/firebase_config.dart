import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      // Si estamos usando MOCK data, saltamos Firebase
      print('⏳ Inicializando Firebase...');
      
      final initTask = Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ Firebase timeout - usando MOCK data');
          throw TimeoutException('Firebase timeout', const Duration(seconds: 5));
        },
      );
      
      await initTask;
      print('✅ Firebase inicializado exitosamente');
    } catch (e) {
      // Si Firebase ya está inicializado, esto es esperado
      if (e.toString().contains('duplicate-app') || 
          e.toString().contains('already exists')) {
        print('✅ Firebase ya estaba inicializado');
        return;
      }
      if (e.toString().contains('TimeoutException')) {
        print('⚠️ Firebase timeout - usando MOCK data sin problemas');
        return;
      }
      print('⚠️ Error inicializando Firebase (continuando con MOCK): $e');
      // No rethrow - permitir que la app continúe con MOCK data
    }
  }

  // Estructura de Firestore
  static const String usersCollection = 'users';
  static const String storiesCollection = 'stories';
  static const String storiesSubcollection = 'stories';
  static const String diaryEntriesSubcollection = 'diaryEntries';
  static const String impactMetricsSubcollection = 'impactMetrics';
  static const String quizResultsSubcollection = 'quizResults';

  // Documentos y campos
  static const String userProfileDoc = 'profile';
  static const String userDiaryStatsDoc = 'stats';
  
  // Campos comunes
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String userIdField = 'userId';
}
