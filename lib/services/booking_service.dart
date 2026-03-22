import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/core/local_storage/isar_service.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/core/network/sync_service.dart';
import 'package:feeltrip_app/models/booking_model.dart';
import 'package:feeltrip_app/services/currency_service.dart';
import 'package:feeltrip_app/services/destination_service.dart';
import 'package:feeltrip_app/services/mercado_pago_service.dart';
import 'package:feeltrip_app/services/metrics_service.dart';
import 'package:fpdart/fpdart.dart';

class BookingService {
  BookingService(this._isar, this._sync);
  final IsarService _isar;
  final SyncService _sync;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<Failure, String>> createBookingFromCart({
    required String destinationId,
    required String dates,
    required double priceUsd,
    required String currency,
  }) async {
    try {
      // 1. Lógica de Clima y Descuento
      await DestinationService.getDestinationDetails(
          destinationId: destinationId);
      const discount = 0.1;
      final finalPrice = priceUsd * (1 - discount);

      // 2. Conversión de moneda segura
      final convertedPrice = await CurrencyService.convert(
        from: 'USD',
        to: currency,
        amount: finalPrice,
      );

      // 3. Preparar items para Mercado Pago (Evitando dynamic calls erróneos)
      final List<Map<String, dynamic>> items = [
        {
          'title': 'FeelTrip: $destinationId',
          'unit_price': convertedPrice,
          'quantity': 1,
          'currency_id': currency,
        }
      ];

      // 4. Llamada al servicio de pago (Asegúrate que coincida con la firma del método)
      final prefIdEither = await MercadoPagoService.createPreference(
        amount: convertedPrice,
        title: 'FeelTrip Booking',
        items: items,
      );

      return prefIdEither.fold(
        (failure) => left(failure),
        (prefId) async {
          final booking = BookingModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: FirebaseAuth.instance.currentUser?.uid ?? 'guest',
            destinationId: destinationId,
            tripDates: dates,
            priceUsd: finalPrice,
            currency: currency,
            commission: finalPrice * 0.10,
          );

          // 5. Persistencia Local (Isar)
          await _isar.saveBooking(booking.toJson());

          // 6. Sincronización (Sync)
          await _sync.addToSyncQueue(booking);

          AppLogger.i('Booking creada localmente y enviada a cola: $prefId');
          return right(prefId);
        },
      );
    } catch (e) {
      AppLogger.e('Error en el flujo de Booking: $e');
      return left(ServerFailure());
    }
  }

  Future<void> confirmBooking(String prefId, String status) async {
    if (status == 'approved') {
      // Obtenemos de Isar las reservas que coinciden con este prefId o que están pendientes
      final pendingBookingsData = await _isar.getPendingBookings();

      for (final bookingData in pendingBookingsData) {
        final booking =
            BookingModel.fromJson(bookingData as Map<String, dynamic>);
        try {
          await _firestore
              .collection('users')
              .doc(booking.userId)
              .collection('bookings')
              .doc(booking.id)
              .set(booking.toJson());

          await _isar.markAsSynced(booking.id);
          MetricsService.logRevenueEvent(booking.priceUsd);
        } catch (e) {
          AppLogger.e('Error confirmando booking ${booking.id}: $e');
        }
      }
    }
  }
}
