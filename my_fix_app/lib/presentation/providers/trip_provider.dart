import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feeltrip_app/services/isar_service.dart';
import 'package:feeltrip_app/models/booking_model.dart';
import 'package:feeltrip_app/models/trip_model.dart';
import 'package:feeltrip_app/services/booking_service.dart';

final featuredTripsProvider = FutureProvider<List<Trip>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('trips')
      .where('isFeatured', isEqualTo: true)
      .limit(5)
      .get();

  return snapshot.docs.map(Trip.fromFirestore).toList();
});

final tripDetailProvider =
    FutureProvider.family<Trip, String>((ref, tripId) async {
  final doc =
      await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
  if (!doc.exists) {
    throw StateError('Viaje no encontrado');
  }
  return Trip.fromFirestore(doc);
});

final tripPreviewProvider =
    FutureProvider.family<Trip?, String>((ref, tripId) async {
  if (tripId.isEmpty) return null;
  final doc =
      await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
  if (!doc.exists) return null;
  return Trip.fromFirestore(doc);
});

final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService();
});

final bookingsProvider =
    FutureProvider.family<List<BookingModel>, String>((ref, userId) async {
  final isar = ref.watch(isarServiceProvider);
  final localBookings = await isar.getBookingsForUser(userId);

  final snapshot = await FirebaseFirestore.instance
      .collection('bookings')
      .where('userId', isEqualTo: userId)
      .get();

  final merged = <String, BookingModel>{
    for (final booking in localBookings) booking.id: booking,
  };

  for (final doc in snapshot.docs) {
    final booking = BookingModel.fromJson({
      ...doc.data(),
      'id': doc.id,
    });
    merged[booking.id] = booking;
    await isar.saveBooking(booking);
  }

  final bookings = merged.values.toList()
    ..sort((a, b) {
      final aDate = a.updatedAt;
      final bDate = b.updatedAt;
      return bDate.compareTo(aDate);
    });

  return bookings;
});
