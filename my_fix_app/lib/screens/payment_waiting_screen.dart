import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/services/booking_service.dart';
import 'package:feeltrip_app/screens/payment_status_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentWaitingScreen extends ConsumerWidget {
  final String bookingId;

  const PaymentWaitingScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingStream = ref.watch(bookingServiceProvider).watchBooking(bookingId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: bookingStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return PaymentStatusScreen(
            status: PaymentStatus.error,
            errorMessage: 'Error al sincronizar con el modo de pago: ${snapshot.error}',
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const PaymentStatusScreen(status: PaymentStatus.pending);
        }

        final data = snapshot.data!.data();
        if (data == null) return const PaymentStatusScreen(status: PaymentStatus.pending);

        final status = data['status'] as String? ?? 'pending';

        if (status == 'paid') {
          return PaymentStatusScreen(status: PaymentStatus.success, bookingId: bookingId);
        }

        if (status == 'failed' || status == 'cancelled') {
          return PaymentStatusScreen(
            status: PaymentStatus.error,
            errorMessage: 'La transacción fue $status por el proveedor.',
          );
        }

        // Si sigue como 'pending', mostramos la pantalla de espera
        return const PaymentStatusScreen(status: PaymentStatus.pending);
      },
    );
  }
}
