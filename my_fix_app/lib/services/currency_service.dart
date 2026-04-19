import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyService {
  static const String apiKey = 'mock_api_key'; // ExchangeRate-API o similar
  static const String baseUrl = 'https://api.exchangerate-api.com/v4/latest';

  /// Convert amount from base to target currency
  static Future<double> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$from'));
      if (response.statusCode == 200) {
        // CORRECCIÓN: Casteo a Map para evitar 'dynamic calls'
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;

        // CORRECCIÓN: Usar .toDouble() porque la API puede devolver int o double
        final rate = (rates[to] as num).toDouble();
        final converted = amount * rate;

        AppLogger.i('Converted $amount $from to ${converted.toStringAsFixed(2)} $to');
        return converted;
      }
      throw Exception('Conversion failed');
    } catch (e) {
      AppLogger.e('Currency conversion error: $e');
      // Fallback rates - CORRECCIÓN: Tipado explícito para el fallback
      final Map<String, Map<String, double>> fallbackRates = {
        'USD': {'EUR': 0.92, 'ARS': 950.0, 'MXN': 18.0},
        'EUR': {'USD': 1.09, 'ARS': 1030.0, 'MXN': 19.5},
      };

      final rate = fallbackRates[from]?[to] ?? 1.0;
      return amount * rate;
    }
  }

  /// Get current rates for popular currencies
  static Future<Map<String, double>> getRates(String base) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$base'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final ratesData = data['rates'] as Map<String, dynamic>;

        // CORRECCIÓN: Convertir el mapa de dynamic a double de forma segura
        return ratesData.map((key, value) => MapEntry(key, (value as num).toDouble()));
      }
      return {};
    } catch (e) {
      AppLogger.e('Get rates error: $e');
      return {'USD': 1.0, 'EUR': 0.92, 'ARS': 950.0};
    }
  }

  /// Format currency for display
  static String format(double amount, String currency) {
    return '${amount.toStringAsFixed(2)} $currency';
  }
}
