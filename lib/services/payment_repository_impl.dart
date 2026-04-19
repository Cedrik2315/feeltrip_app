import 'package:dartz/dartz.dart';
import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/services/metrics_service.dart' hide metricsServiceProvider;
import 'package:feeltrip_app/services/revenuecat_service.dart';
import 'package:feeltrip_app/services/booking_service.dart';

import 'package:purchases_flutter/purchases_flutter.dart';





class PaymentRepository {
  PaymentRepository({
    required MetricsService metrics,
    required RevenueCatService revenueCat,
    required BookingService bookingService,
  })  : _metrics = metrics,
        _revenueCat = revenueCat,
        _bookingService = bookingService;
        
  final MetricsService _metrics;
  final RevenueCatService _revenueCat;
  final BookingService _bookingService;

  Future<Either<Failure, String>> startBookingPayment({
    required String userId,
    required String experienceId,
    required double amount,
  }) async {
    try {
      final bookingId = await _bookingService.createPendingBooking(
        userId: userId,
        experienceId: experienceId,
        amount: amount,
      );

      _metrics.logBookingStarted(experienceId, amount);

      final paymentResult = await _bookingService.initiateServerSidePayment(
        bookingId: bookingId,
        amount: amount,
        experienceId: experienceId,
      );
      final initPoint = (paymentResult['initPoint'] ?? paymentResult['init_point']) as String?;
      final preferenceId = (paymentResult['preferenceId'] ?? paymentResult['id']) as String?;

      if (initPoint == null || preferenceId == null) {
        return const Left(ServerFailure('Error al generar link de pago'));
      }

      // Skip local save for now, server handles it
      AppLogger.i('PaymentRepository: Preferencia generada: $preferenceId');
      return Right(initPoint);
    } catch (e) {
      AppLogger.e('PaymentRepository Error: $e');
      return const Left(ServerFailure('No se pudo iniciar el proceso de pago'));
    }
  }

  Future<Either<Failure, bool>> purchasePremium(Package package) async {
    try {
      AppLogger.i('PaymentRepository: Iniciando compra RevenueCat: ${package.identifier}');
      
      final customerInfo = await _revenueCat.purchasePackage(package);
      // Verificamos si el entitlement 'premium' existe y está activo
      final isPremiumActive = customerInfo.entitlements.active['premium']?.isActive ?? false;
      
if (isPremiumActive) {
        MetricsService.logSubscriptionSuccess();
        return const Right(true);
      }
      return const Left(ServerFailure('La compra fue cancelada o no se pudo procesar'));
    } catch (e) {
      AppLogger.e('PaymentRepository RevenueCat Error: $e');
      return const Left(ServerFailure('Error al comunicarse con la tienda de aplicaciones'));
    }
  }
}
