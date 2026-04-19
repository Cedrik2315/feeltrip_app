import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/models/payment_item.dart'; // Añadido

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
      preferenceId: (json['preferenceId'] ?? json['id']) as String? ?? '',
      initPoint: (json['initPoint'] ?? json['init_point']) as String? ?? '',
      externalReference: (json['externalReference'] ?? json['external_reference']) as String? ?? '',
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

  /// Crea una preferencia de pago y devuelve el ID o la URL de checkout
  Future<Map<String, String>> createPreference(PaymentItem item);

  /// Procesa el resultado que devuelve el SDK o las Back URLs
  Future<void> handlePaymentResult(String status, String externalReference);
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

  @override
  Future<Map<String, String>> createPreference(PaymentItem item) async {
    try {
      // Llamamos a la Cloud Function que creamos antes
      final result = await _functions
          .httpsCallable('createMpPreference')
          .call<Map<String, dynamic>>(item.toJson());

      // Retornamos el preferenceId e initPoint
      final data = result.data;
      return {
        'id': data['id'] as String,
        'initPoint': data['initPoint'] as String,
      };
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Error al generar el pago: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado en la pasarela de pagos.');
    }
  }

  @override
  Future<void> handlePaymentResult(String status, String externalReference) async {
    switch (status) {
      case 'approved':
        // Aquí podrías disparar una sincronización manual o mostrar éxito
        print('Pago aprobado para el usuario: $externalReference');
        break;
      case 'pending':
        print('Pago en proceso/pendiente');
        break;
      default:
        throw Exception('El pago no fue completado.');
    }
  }

  /// Crea una preferencia de pago específica para el libro impreso
  /// Llama a la Cloud Function 'createMercadoPagoPreference' con purpose: 'book'
  Future<Either<Failure, PaymentSession>> createBookPayment({
    required String userId,
    required String fullName,
    required double amount,
  }) async {
    return createCheckoutSession(PaymentRequest(
      amount: amount,
      title: 'Libro de Expediciones FeelTrip',
      purpose: 'book',
      currency: 'CLP',
      bookingId: 'book_$userId',
    ));
  }
}
