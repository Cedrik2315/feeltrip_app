import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:feeltrip_app/core/error/failures.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class MercadoPagoService {
  static const String _baseUrl = 'https://api.mercadopago.com/checkout/preferences';

  static Future<Either<Failure, String>> createPreference({
    required double amount,
    required String title,
    required List<Map<String, dynamic>> items,
    String payerEmail = 'test@test.com',
  }) async {
    try {
      final token = dotenv.env['MERCADO_PAGO_ACCESS_TOKEN'] ?? '';
      if (token.isEmpty) {
        AppLogger.w('MercadoPago token missing. Booking payment stays in beta mode.');
        return const Left(ServerFailure('MercadoPago token missing'));
      }

      final body = json.encode({
        'items': items,
        'payer': {'email': payerEmail},
        'back_urls': {
          'success': 'feeltrip://booking/success',
          'failure': 'feeltrip://booking/failure',
          'pending': 'feeltrip://booking/pending',
        },
        'auto_return': 'approved',
        'external_reference': DateTime.now().millisecondsSinceEpoch.toString(),
        'metadata': {
          'source': 'feeltrip_mobile_beta',
          'warning': 'client_side_preference_only',
        },
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final prefId = data['id'] as String?;
        if (prefId != null) {
          AppLogger.i('Preference created in beta mode: $prefId');
          return Right(prefId);
        }
      }

      AppLogger.e('MercadoPago preference error: ${response.statusCode} ${response.body}');
      return const Left(ServerFailure('Preference creation failed'));
    } catch (e) {
      AppLogger.e('MercadoPago error: $e');
      return const Left(ServerFailure('MercadoPago error'));
    }
  }

  static Future<Either<Failure, Map<String, dynamic>>> getPaymentStatus(String externalRef) async {
    try {
      final token = dotenv.env['MERCADO_PAGO_ACCESS_TOKEN'] ?? '';
      if (token.isEmpty) {
        AppLogger.w('MercadoPago token missing. Payment status is unavailable in beta mode.');
        return const Left(ServerFailure('Payment status unavailable'));
      }

      final response = await http.get(
        Uri.parse('$_baseUrl?external_reference=$externalRef'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return Right(json.decode(response.body) as Map<String, dynamic>);
      }

      AppLogger.e('MercadoPago status error: ${response.statusCode} ${response.body}');
      return const Left(ServerFailure('Status lookup failed'));
    } catch (e) {
      AppLogger.e('Status error: $e');
      return const Left(ServerFailure('Status error'));
    }
  }
}

