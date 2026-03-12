import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/agency_model.dart';
import '../mock_data.dart';

abstract class AgencyRepository {
  Future<String> createAgency(TravelAgency agency);
  Future<TravelAgency?> getAgencyById(String agencyId);
  Stream<List<TravelAgency>> getAllAgencies();
  Stream<List<TravelAgency>> getAgenciesByCity(String city);
  Stream<List<TravelAgency>> getAgenciesBySpecialty(String specialty);
  Future<void> updateAgency(String agencyId, Map<String, dynamic> data);
  Future<void> addExperienceToAgency({
    required String agencyId,
    required String experienceId,
  });
  Future<void> followAgency(String agencyId);
  Future<void> followAgencyWithUser({
    required String userId,
    required String agencyId,
  });
  Future<void> unfollowAgencyWithUser({
    required String userId,
    required String agencyId,
  });
  Future<bool> isFollowingAgency({
    required String userId,
    required String agencyId,
  });
  Future<List<String>> getFollowingAgencies(String userId);
  Future<void> updateAgencyRating({
    required String agencyId,
    required double newRating,
  });
  Future<void> deleteAgency(String agencyId);
}

class MockAgencyRepository implements AgencyRepository {
  @override
  Future<String> createAgency(TravelAgency agency) async {
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
    return agencyId;
  }

  @override
  Future<TravelAgency?> getAgencyById(String agencyId) async {
    return MockData.getAgencyById(agencyId);
  }

  @override
  Stream<List<TravelAgency>> getAllAgencies() {
    final agencies = MockData.getAgencies()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return Stream.value(agencies);
  }

  @override
  Stream<List<TravelAgency>> getAgenciesByCity(String city) {
    final agencies = MockData.getAgenciesByCity(city)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return Stream.value(agencies);
  }

  @override
  Stream<List<TravelAgency>> getAgenciesBySpecialty(String specialty) {
    final agencies = MockData.getAgencies()
        .where((agency) => agency.specialties.contains(specialty))
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return Stream.value(agencies);
  }

  @override
  Future<void> updateAgency(String agencyId, Map<String, dynamic> data) async {
    final agency = MockData.mockAgencies
        .firstWhere((a) => a['id'] == agencyId, orElse: () => {});
    if (agency.isNotEmpty) {
      agency.addAll(data);
    }
  }

  @override
  Future<void> addExperienceToAgency(
      {required String agencyId, required String experienceId}) async {
    final agency = MockData.mockAgencies
        .firstWhere((a) => a['id'] == agencyId, orElse: () => {});
    if (agency.isNotEmpty) {
      final experiences =
          List<String>.from(agency['experiences'] ?? const <String>[]);
      experiences.add(experienceId);
      agency['experiences'] = experiences;
    }
  }

  @override
  Future<void> followAgency(String agencyId) async {
    final agency = MockData.mockAgencies
        .firstWhere((a) => a['id'] == agencyId, orElse: () => {});
    if (agency.isNotEmpty) {
      agency['followers'] = (agency['followers'] ?? 0) + 1;
    }
  }

  @override
  Future<void> followAgencyWithUser({
    required String userId,
    required String agencyId,
  }) async {
    // Inicializar followingAgencies si no existe
    if (!MockData.mockUsersFollowing.containsKey(userId)) {
      MockData.mockUsersFollowing[userId] = [];
    }
    final following = MockData.mockUsersFollowing[userId]!;
    if (!following.contains(agencyId)) {
      following.add(agencyId);
    }
    // También incrementar seguidores de la agencia
    await followAgency(agencyId);
  }

  @override
  Future<void> unfollowAgencyWithUser({
    required String userId,
    required String agencyId,
  }) async {
    final following = MockData.mockUsersFollowing[userId];
    if (following != null && following.contains(agencyId)) {
      following.remove(agencyId);
    }
    // Decrementar seguidores de la agencia
    final agency = MockData.mockAgencies
        .firstWhere((a) => a['id'] == agencyId, orElse: () => {});
    if (agency.isNotEmpty) {
      agency['followers'] = ((agency['followers'] ?? 1) as int) - 1;
    }
  }

  @override
  Future<bool> isFollowingAgency({
    required String userId,
    required String agencyId,
  }) async {
    final following = MockData.mockUsersFollowing[userId];
    return following?.contains(agencyId) ?? false;
  }

  @override
  Future<List<String>> getFollowingAgencies(String userId) async {
    return MockData.mockUsersFollowing[userId] ?? [];
  }

  @override
  Future<void> updateAgencyRating(
      {required String agencyId, required double newRating}) async {
    final agency = MockData.mockAgencies
        .firstWhere((a) => a['id'] == agencyId, orElse: () => {});
    if (agency.isEmpty) return;

    final totalReviews = (agency['reviewCount'] ?? 0) as int;
    final currentRating = ((agency['rating'] ?? 0.0) as num).toDouble();
    final currentTotal = currentRating * totalReviews;
    final finalRating = (currentTotal + newRating) / (totalReviews + 1);

    agency['rating'] = finalRating;
    agency['reviewCount'] = totalReviews + 1;
  }

  @override
  Future<void> deleteAgency(String agencyId) async {
    MockData.mockAgencies.removeWhere((a) => a['id'] == agencyId);
  }
}

class FirestoreAgencyRepository implements AgencyRepository {
  FirestoreAgencyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<String> createAgency(TravelAgency agency) async {
    final agencyId = const Uuid().v4();
    final newAgency = agency.copyWith(id: agencyId);
    await _firestore
        .collection('agencies')
        .doc(agencyId)
        .set(newAgency.toFirestore());
    return agencyId;
  }

  @override
  Future<TravelAgency?> getAgencyById(String agencyId) async {
    final doc = await _firestore.collection('agencies').doc(agencyId).get();
    if (!doc.exists) return null;
    return TravelAgency.fromFirestore(doc);
  }

  @override
  Stream<List<TravelAgency>> getAllAgencies() {
    return _firestore
        .collection('agencies')
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TravelAgency.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<TravelAgency>> getAgenciesByCity(String city) {
    return _firestore
        .collection('agencies')
        .where('city', isEqualTo: city)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TravelAgency.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<TravelAgency>> getAgenciesBySpecialty(String specialty) {
    return _firestore
        .collection('agencies')
        .where('specialties', arrayContains: specialty)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TravelAgency.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> updateAgency(String agencyId, Map<String, dynamic> data) {
    return _firestore.collection('agencies').doc(agencyId).update(data);
  }

  @override
  Future<void> addExperienceToAgency(
      {required String agencyId, required String experienceId}) {
    return _firestore.collection('agencies').doc(agencyId).update({
      'experiences': FieldValue.arrayUnion([experienceId])
    });
  }

  @override
  Future<void> followAgency(String agencyId) {
    return _firestore
        .collection('agencies')
        .doc(agencyId)
        .update({'followers': FieldValue.increment(1)});
  }

  @override
  Future<void> followAgencyWithUser({
    required String userId,
    required String agencyId,
  }) async {
    // 1. Agregar la agencia al array followingAgencies del usuario
    await _firestore.collection('users').doc(userId).update({
      'followingAgencies': FieldValue.arrayUnion([agencyId]),
    });
    // 2. Incrementar el contador de seguidores de la agencia
    await followAgency(agencyId);
  }

  @override
  Future<void> unfollowAgencyWithUser({
    required String userId,
    required String agencyId,
  }) async {
    // 1. Remover la agencia del array followingAgencies del usuario
    await _firestore.collection('users').doc(userId).update({
      'followingAgencies': FieldValue.arrayRemove([agencyId]),
    });
    // 2. Decrementar el contador de seguidores de la agencia
    await _firestore.collection('agencies').doc(agencyId).update({
      'followers': FieldValue.increment(-1),
    });
  }

  @override
  Future<bool> isFollowingAgency({
    required String userId,
    required String agencyId,
  }) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;
    final followingAgencies =
        List<String>.from(userDoc.get('followingAgencies') ?? []);
    return followingAgencies.contains(agencyId);
  }

  @override
  Future<List<String>> getFollowingAgencies(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return [];
    return List<String>.from(userDoc.get('followingAgencies') ?? []);
  }

  @override
  Future<void> updateAgencyRating(
      {required String agencyId, required double newRating}) async {
    final agency = await getAgencyById(agencyId);
    if (agency == null) throw Exception('Agencia no encontrada');

    final totalReviews = agency.reviewCount;
    final currentTotal = agency.rating * totalReviews;
    final finalRating = (currentTotal + newRating) / (totalReviews + 1);

    await _firestore.collection('agencies').doc(agencyId).update({
      'rating': finalRating,
      'reviewCount': totalReviews + 1,
    });
  }

  @override
  Future<void> deleteAgency(String agencyId) {
    return _firestore.collection('agencies').doc(agencyId).delete();
  }
}
