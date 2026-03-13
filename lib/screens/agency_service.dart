import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agency_model.dart';

class AgencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TravelAgency>> getAllAgencies() {
    return _firestore
        .collection('agencies')
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TravelAgency.fromFirestore(doc))
            .toList());
  }

  Future<TravelAgency?> getAgencyById(String agencyId) async {
    final doc = await _firestore.collection('agencies').doc(agencyId).get();
    if (doc.exists) {
      return TravelAgency.fromFirestore(doc);
    }
    return null;
  }

  Stream<List<TravelAgency>> getAgenciesByCity(String city) {
    return _firestore
        .collection('agencies')
        .where('city', isEqualTo: city)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TravelAgency.fromFirestore(doc))
            .toList());
  }

  Stream<List<TravelAgency>> getAgenciesBySpecialty(String specialty) {
    return _firestore
        .collection('agencies')
        .where('specialties', arrayContains: specialty)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TravelAgency.fromFirestore(doc))
            .toList());
  }

  Future<void> followAgency(String agencyId) async {
    // Implementar lógica de seguimiento (ej. subcolección en usuario o contador en agencia)
    await _firestore.collection('agencies').doc(agencyId).update({
      'followers': FieldValue.increment(1),
    });
  }

  Future<void> updateAgencyRating({
    required String agencyId,
    required double newRating,
  }) async {
    await _firestore.collection('agencies').doc(agencyId).update({
      'rating': newRating,
    });
  }

  Future<void> createAgency(TravelAgency agency) async {
    await _firestore
        .collection('agencies')
        .doc(agency.id)
        .set(agency.toFirestore());
  }
}
