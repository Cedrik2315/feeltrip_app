import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:feeltrip_app/core/error/failures.dart';

class PaymentRequest {
  const PaymentRequest({
    required this.amount,
    required this.title,
    required this.purpose,
    this.bookingId,
    this.destinationId,
    this.currency = 'ARS',
  });

  final double amount;
  final String title;
  final String purpose;
  final String? bookingId;
  final String? destinationId;
  final String currency;

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'title': title,
      'purpose': purpose,
      'bookingId': bookingId,
      'destinationId': destinationId,
      'currency': currency,
    };
  }
}

class PaymentSession {
  const PaymentSession({
    required this.preferenceId,
    required this.initPoint,
    required this.externalReference,
    required this.provider,
    required this.status,
    this.bookingId,
    this.paymentId,
  });

  factory PaymentSession.fromJson(Map<String, dynamic> json) {
    return PaymentSession(
      preferenceId: json['preferenceId'] as String? ?? '',
      initPoint: json['initPoint'] as String? ?? '',
      externalReference: json['externalReference'] as String? ?? '',
      provider: json['provider'] as String? ?? 'mercadopago',
      status: json['status'] as String? ?? 'pending',
      bookingId: json['bookingId'] as String?,
      paymentId: json['paymentId'] as String?,
    );
  }

  final String preferenceId;
  final String initPoint;
  final String externalReference;
  final String provider;
  final String status;
  final String? bookingId;
  final String? paymentId;
}

abstract class IPaymentRepository {
  Future<Either<Failure, PaymentSession>> createCheckoutSession(
    PaymentRequest request,
  );
}

class PaymentRepository implements IPaymentRepository {
  PaymentRepository({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<Either<Failure, PaymentSession>> createCheckoutSession(
    PaymentRequest request,
  ) async {
    try {
      final result = await _functions
          .httpsCallable('createMercadoPagoPreference')
          .call<Map<String, dynamic>>(request.toJson());

      final data = Map<String, dynamic>.from(result.data);
      final session = PaymentSession.fromJson(data);
      if (session.preferenceId.isEmpty || session.initPoint.isEmpty) {
        return const Left(ServerFailure('Payment session is incomplete'));
      }

      return Right(session);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? 'Payment preference error.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
