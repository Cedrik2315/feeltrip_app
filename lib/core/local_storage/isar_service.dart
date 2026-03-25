import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feeltrip_app/features/diario/domain/models/momento_model.dart';

class IsarService {
  Future<void> saveMomento(Momento nuevoMomento) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(nuevoMomento.userId)
        .collection('momentos')
        .doc(nuevoMomento.id)
        .set(nuevoMomento.toJson());
  }

  Future<List<Map<String, dynamic>>> getMomentos(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('momentos')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<dynamic>> getPendingBookings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> markAsSynced(String id) async {
    await FirebaseFirestore.instance.collection('bookings').doc(id).update({'isSynced': true});
  }

  Future<void> saveBooking(Map<String, dynamic> booking) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(booking['id'] as String?)
        .set(booking);
  }

  Future<void> clearAll() async {
    // No-op for Firestore stub
  }
}

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});
