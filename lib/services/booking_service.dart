import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/logger/app_logger.dart';

final bookingServiceProvider = Provider((ref) => BookingService());

class BookingService {
  final _firestore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instance;

  /// Crea una reserva inicial en estado 'pending'.
  /// Cumple con las reglas de Firestore que exigen que el estado inicial sea 'pending'
  /// y que solo el propietario pueda crearla.
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

  /// Solicita al backend la creación de la preferencia de Mercado Pago.
  /// Este es el único método seguro, ya que el backend vincula el monto real.
  Future<Map<String, dynamic>> initiateServerSidePayment({
    required String bookingId,
    required double amount,
    required String experienceId,
  }) async {
    try {
      AppLogger.i('BookingService: Solicitando preferencia de pago para el booking $bookingId');
      
      final callable = _functions.httpsCallable('createMercadoPagoPreference');
      final response = await callable.call({
        'bookingId': bookingId,
        'amount': amount,
        'experienceId': experienceId,
      });

      // Retorna id e init_point (URL de Mercado Pago)
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      AppLogger.e('BookingService: Fallo al iniciar pago en servidor: $e');
      rethrow;
    }
  }

  /// Escucha en tiempo real el estado de la reserva.
  /// Reemplaza la lógica anterior de 'confirmación manual' por una observación reactiva.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchBooking(String bookingId) {
    return _firestore.collection('bookings').doc(bookingId).snapshots();
  }

  /// Verificación final de seguridad.
  /// No confirma nada, solo consulta si el backend ya marcó la transacción como válida.
  Future<bool> isPaymentVerified(String bookingId) async {
    final doc = await _firestore.collection('bookings').doc(bookingId).get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    final isPaid = data['status'] == 'paid';
    final hasPaymentId = data['paymentId'] != null;

    return isPaid && hasPaymentId;
  }
}