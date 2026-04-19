import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feeltrip_app/models/booking_model.dart';
import 'package:feeltrip_app/services/isar_service.dart';

/// SIMULACIÓN DE WEBHOOK DE PAGO
/// Este script emula lo que ocurriría en el servidor cuando Mercado Pago
/// confirma un pago exitoso mediante un webhook.
Future<void> simulatePaymentWebhook({
  required String bookingId,
  required String paymentId,
  required String externalReference,
}) async {
  print('--- INICIANDO SIMULACIÓN DE WEBHOOK ---');
  
  final firestore = FirebaseFirestore.instance;
  final isar = IsarService();
  await isar.init();

  try {
    // 1. EL SERVIDOR ACTUALIZA FIRESTORE (Simulado aquí)
    print('1. Servidor: Marcando booking $bookingId como PAGADO en Firestore...');
    await firestore.collection('bookings').doc(bookingId).update({
      'status': 'paid',
      'paymentId': paymentId,
      'externalReference': externalReference,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. LA APP RECIBE EL CAMBIO Y ACTUALIZA LOCALMENTE
    // (En una app real, esto lo haría un listener o el SyncService)
    print('2. App: Sincronizando estado "paid" en base de datos local Isar...');
    
    // Buscamos el booking en Isar
    final bookings = await isar.getBookingsForUser('currentUserPlaceholder'); // Simplificado
    final localBooking = bookings.firstWhere((b) => b.id == bookingId);
    
    final updatedBooking = localBooking.copyWith(
      status: BookingStatus.paid,
      paymentId: paymentId,
      externalReference: externalReference,
    );
    
    await isar.saveBooking(updatedBooking);
    
    print('--- SIMULACIÓN COMPLETADA EXITOSAMENTE ---');
    print('Estado final: Booking $bookingId vinculado con Pago $paymentId');
  } catch (e) {
    print('ERROR EN SIMULACIÓN: $e');
  }
}

void main() {
  // Para ejecutar esta simulación, necesitarías un ID de booking real de tu emulador/dispositivo
  print('Para ejecutar: simulatePaymentWebhook(bookingId: "XYZ", paymentId: "MERCADPAGO_123", externalReference: "REF_456")');
}
