import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class HomeRepository {
  final _firestore = FirebaseFirestore.instance;

  /// Obtiene experiencias marcadas como transformadoras para el Hero de la Home.
  /// Fundamental para la visión de "Viajes que Transforman" de la Fase 2.
  Future<List<Map<String, dynamic>>> getFeaturedExperiences() async {
    try {
      final snapshot = await _firestore
          .collection('experiences')
          .where('isTransformative', isEqualTo: true)
          .limit(10)
          .get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      AppLogger.e('HomeRepository: Error cargando experiencias destacadas: $e');
      return [];
    }
  }

  /// Obtiene las últimas historias de la comunidad para el feed rápido de la Home.
  Future<List<Map<String, dynamic>>> getLatestStories() async {
    try {
      final snapshot = await _firestore
          .collection('stories')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      AppLogger.e('HomeRepository: Error cargando últimas historias: $e');
      return [];
    }
  }
}