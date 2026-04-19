import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logger/app_logger.dart';

final bookingServiceProvider = Provider((ref) => BookingService());

class BookingService {
  BookingService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Future<String> createPendingBooking({
    required String userId,
    required String experienceId,
    required double amount,
  }) async {
    try {
      final docRef = await _firestore.collection('bookings').add({
        'userId': userId,
        'experienceId': experienceId,
        'amount': amount,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.i('BookingService: Reserva creada exitosamente con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      AppLogger.e('BookingService: Error al crear la reserva inicial: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initiateServerSidePayment({
    required String bookingId,
    required double amount,
    required String experienceId,
  }) async {
    try {
      AppLogger.i('BookingService: Solicitando preferencia de pago para el booking $bookingId');

      final callable = _functions.httpsCallable('createMercadoPagoPreference');
      final response = await callable.call<Map<String, dynamic>>({
        'bookingId': bookingId,
        'amount': amount,
        'experienceId': experienceId,
      });

      final payload = Map<String, dynamic>.from(response.data);
      final initPoint = (payload['initPoint'] ?? payload['init_point']) as String?;
      final preferenceId = (payload['preferenceId'] ?? payload['id']) as String?;
      if (initPoint == null || initPoint.isEmpty || preferenceId == null || preferenceId.isEmpty) {
        throw StateError('Respuesta de pago incompleta');
      }

      return payload;
    } catch (e) {
      AppLogger.e('BookingService: Fallo al iniciar pago en servidor: $e');
      rethrow;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchBooking(String bookingId) {
    return _firestore.collection('bookings').doc(bookingId).snapshots();
  }

  Future<bool> isPaymentVerified(String bookingId) async {
    final doc = await _firestore.collection('bookings').doc(bookingId).get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    final isPaid = data['status'] == 'paid';
    final hasPaymentId = data['paymentId'] != null;

    return isPaid && hasPaymentId;
  }
}
