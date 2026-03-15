import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/agency_model.dart';
import '../mock_data.dart';

class AgencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool useMockData = true; // CAMBIAR A FALSE CUANDO FIRESTORE ESTÉ LISTO

  /// Crear nueva agencia
  Future<String> createAgency(TravelAgency agency) async {
    try {
      if (useMockData) {
        final agencyId = const Uuid().v4();
        final newAgency = {
          'id': agencyId,
          'name': agency.name,
          'description': agency.description,
          'logo': agency.logo,
          'city': agency.city,
          'country': agency.country,
          'latitude': agency.latitude,
          'longitude': agency.longitude,
          'specialties': agency.specialties,
          'rating': agency.rating,
          'reviewCount': agency.reviewCount,
          'followers': agency.followers,
          'verified': agency.verified,
          'phoneNumber': agency.phoneNumber,
          'email': agency.email,
          'website': agency.website,
          'socialMedia': agency.socialMedia,
          'createdAt': Timestamp.now(),
        };
        MockData.mockAgencies.add(newAgency);
        // log eliminado: ✅ [MOCK] Agencia creada: $agencyId
        return agencyId;
      }

      // FIRESTORE REAL
      final agencyId = const Uuid().v4();
      final newAgency = agency.copyWith(id: agencyId);

      await _firestore
          .collection('agencies')
          .doc(agencyId)
          .set(newAgency.toFirestore());

      // log eliminado: ✅ Agencia creada en Firestore: $agencyId
      return agencyId;
    } catch (e) {
      // log eliminado: ❌ Error creando agencia: $e
      rethrow;
    }
  }

  /// Obtener agencia por ID
  Future<TravelAgency?> getAgencyById(String agencyId) async {
    try {
      if (useMockData) {
        return MockData.getAgencyById(agencyId);
      }

      // FIRESTORE REAL
      final doc = await _firestore.collection('agencies').doc(agencyId).get();

      if (!doc.exists) return null;

      return TravelAgency.fromFirestore(doc);
    } catch (e) {
      print('❌ Error obteniendo agencia: $e');
      return null;
    }
  }

  /// Obtener todas las agencias
  Stream<List<TravelAgency>> getAllAgencies() {
    if (useMockData) {
      final agencies = MockData.getAgencies()
        ..sort((a, b) => b.rating.compareTo(a.rating));
      return Stream.value(agencies);
    }

    // FIRESTORE REAL
    return _firestore
        .collection('agencies')
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TravelAgency.fromFirestore(doc))
            .toList());
  }

  /// Buscar agencias por ciudad
  Stream<List<TravelAgency>> getAgenciesByCity(String city) {
    if (useMockData) {
      final agencies = MockData.getAgenciesByCity(city)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      return Stream.value(agencies);
    }

    // FIRESTORE REAL
    return _firestore
        .collection('agencies')
        .where('city', isEqualTo: city)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TravelAgency.fromFirestore(doc))
            .toList());
  }

  /// Buscar agencias por especialidad
  Stream<List<TravelAgency>> getAgenciesBySpecialty(String specialty) {
    if (useMockData) {
      final agencies = MockData.getAgencies()
          .where((agency) => agency.specialties.contains(specialty))
          .toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
      return Stream.value(agencies);
    }

    // FIRESTORE REAL
    return _firestore
        .collection('agencies')
        .where('specialties', arrayContains: specialty)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TravelAgency.fromFirestore(doc))
            .toList());
  }

  /// Actualizar agencia
  Future<void> updateAgency(String agencyId, Map<String, dynamic> data) async {
    try {
      if (useMockData) {
        print('✅ [MOCK] Agencia actualizada');
        return;
      }

      // FIRESTORE REAL
      await _firestore.collection('agencies').doc(agencyId).update(data);
      print('✅ Agencia actualizada');
    } catch (e) {
      print('❌ Error actualizando agencia: $e');
      rethrow;
    }
  }

  /// Agregar experiencia a agencia
  Future<void> addExperienceToAgency({
    required String agencyId,
    required String experienceId,
  }) async {
    try {
      if (useMockData) {
        print('✅ [MOCK] Experiencia agregada a agencia');
        return;
      }

      // FIRESTORE REAL
      await _firestore.collection('agencies').doc(agencyId).update({
        'experiences': FieldValue.arrayUnion([experienceId])
      });
      print('✅ Experiencia agregada a agencia');
    } catch (e) {
      print('❌ Error agregando experiencia: $e');
      rethrow;
    }
  }

  /// Incrementar followers
  Future<void> followAgency(String agencyId) async {
    try {
      if (useMockData) {
        final agency = MockData.mockAgencies
            .firstWhere((a) => a['id'] == agencyId, orElse: () => {});
        if (agency.isNotEmpty) {
          agency['followers'] = (agency['followers'] ?? 0) + 1;
          print('✅ [MOCK] Siguiendo agencia');
        }
        return;
      }

      // FIRESTORE REAL
      await _firestore
          .collection('agencies')
          .doc(agencyId)
          .update({'followers': FieldValue.increment(1)});
      print('✅ Siguiendo agencia');
    } catch (e) {
      print('❌ Error siguiendo agencia: $e');
      rethrow;
    }
  }

  /// Actualizar rating de agencia
  Future<void> updateAgencyRating({
    required String agencyId,
    required double newRating,
  }) async {
    try {
      final agency = await getAgencyById(agencyId);
      if (agency == null) throw Exception('Agencia no encontrada');

      final totalReviews = agency.reviewCount;
      final currentTotal = agency.rating * totalReviews;
      final newTotal = currentTotal + newRating;
      final finalRating = newTotal / (totalReviews + 1);

      await _firestore.collection('agencies').doc(agencyId).update({
        'rating': finalRating,
        'reviewCount': totalReviews + 1,
      });

      print('✅ Rating de agencia actualizado: $finalRating');
    } catch (e) {
      print('❌ Error actualizando rating: $e');
      rethrow;
    }
  }

  /// Eliminar agencia
  Future<void> deleteAgency(String agencyId) async {
    try {
      await _firestore.collection('agencies').doc(agencyId).delete();
      print('✅ Agencia eliminada');
    } catch (e) {
      print('❌ Error eliminando agencia: $e');
      rethrow;
    }
  }
}
