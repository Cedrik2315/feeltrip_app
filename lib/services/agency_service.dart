import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/travel_agency_model.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class AgencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<TravelAgency?> getAgencyById(String agencyId) async {
    try {
      final doc = await _firestore.collection('agencies').doc(agencyId).get();
      if (doc.exists) {
        return TravelAgency.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      // Reemplazado print por AppLogger.e para higiene de código
      // print("Error getting agencies by mood $mood: $e");
      AppLogger.e('Error getting agency by ID $agencyId: $e');
      return null;
    }
  }

  Future<void> createAgency(TravelAgency agency) async {
    await _firestore.collection('agencies').doc(agency.id).set(agency.toMap());
  }

  Future<void> updateAgency(String agencyId, Map<String, dynamic> data) async {
    await _firestore.collection('agencies').doc(agencyId).update(data);
  }

  Future<void> followAgency(String agencyId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();

    // Agregar a la subcolección 'following' del usuario
    final userRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('following_agencies')
        .doc(agencyId);
    batch.set(userRef, {'followedAt': Timestamp.now()});

    // Incrementar contador en la agencia
    final agencyRef = _firestore.collection('agencies').doc(agencyId);
    batch.update(agencyRef, {'followers': FieldValue.increment(1)});

    await batch.commit();
  }

  Future<void> addExperienceToAgency(
      String agencyId, String experienceId) async {
    await _firestore.collection('agencies').doc(agencyId).update({
      'experiences': FieldValue.arrayUnion([experienceId])
    });
  }

  /// Get agencies matching mood specialties, verified first
  Future<List<TravelAgency>> getAgenciesByMood(String mood) async {
    try {
      // Mood-specialty mappings
      final Map<String, List<String>> moodSpecialties = {
        'aventura': [
          'Trekking',
          'Rápel',
          'deportes extremos',
          'aventura',
          'bungee',
          'paracaidismo'
        ],
        'conexion': [
          'voluntariado',
          'homestays',
          'talleres locales',
          'cocina',
          'cultural'
        ],
        'transformacion': ['retiros', 'yoga', 'meditación', 'espiritual'],
        'reflexion': [
          'naturaleza',
          'fotografía',
          'santuarios',
          'contemplativo'
        ],
        'aprendizaje': [
          'académico',
          'museos',
          'historia',
          'talleres educativos'
        ],
        'aventurero': ['Trekking', 'Rápel', 'deportes extremos'],
      };

      final specialties = moodSpecialties[mood.toLowerCase()] ??
          moodSpecialties['aventura'] ??
          <String>[];

      final snapshot = await _firestore
          .collection('agencies')
          .orderBy('verified', descending: true)
          .orderBy('rating', descending: true)
          .orderBy('followers', descending: true)
          .limit(20)
          .get();

      final agencies = <TravelAgency>[];
      for (final doc in snapshot.docs) {
        final agency = TravelAgency.fromFirestore(doc);
        // Check specialty match (case insensitive)
        if (specialties.any((spec) => agency.specialties
            .any((s) => s.toLowerCase().contains(spec.toLowerCase())))) {
          agencies.add(agency);
        }
      }
      return agencies;
    } catch (e) {
      AppLogger.e('Error getting agencies by mood $mood: $e');
      return [];
    }
  }
}
