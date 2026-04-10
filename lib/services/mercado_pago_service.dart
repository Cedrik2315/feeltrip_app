import 'package:fpdart/fpdart.dart';

import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

@Deprecated('Use BookingService/PaymentRepository with Cloud Functions instead.')
class MercadoPagoService {
  static Future<Either<Failure, String>> createPreference({
    required double amount,
    required String title,
    required List<Map<String, dynamic>> items,
    String payerEmail = 'test@test.com',
  }) async {
    AppLogger.w(
      'MercadoPagoService.createPreference is deprecated. Use server-side checkout via Cloud Functions.',
    );
    return const Left(
      ServerFailure('Client-side Mercado Pago flow disabled. Use server-side checkout.'),
    );
  }

  static Future<Either<Failure, Map<String, dynamic>>> getPaymentStatus(
    String externalRef,
  ) async {
    AppLogger.w(
      'MercadoPagoService.getPaymentStatus is deprecated. Payment verification now belongs to backend/webhooks.',
    );
    return const Left(
      ServerFailure('Client-side payment status lookup disabled. Use backend verification.'),
    );
  }
}
