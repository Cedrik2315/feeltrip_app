import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AffiliateService {
  static String get baseUrl =>
      dotenv.env['AFFILIATE_API_URL'] ??
      'https://api.feeltrip.app/v1/affiliate';

  /// Genera un enlace de afiliado para una agencia/experiencia
  static Future<String> generateAffiliateLink({
    required String agencyId,
    required String experienceId,
    required double commissionRate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'agencyId': agencyId,
          'experienceId': experienceId,
          'commissionRate': commissionRate,
        }),
      );

      if (response.statusCode == 200) {
        // CORRECCIÓN: Casteo explícito de dynamic a Map para evitar avoid_dynamic_calls
        final data = json.decode(response.body) as Map<String, dynamic>;
        final String link = data['link'] as String? ?? '';

        AppLogger.i('Affiliate link generated: $link');
        return link;
      }
      throw Exception('Failed to generate affiliate link');
    } catch (e) {
      AppLogger.e('Affiliate error: $e');
      // Fallback mock link con tipado seguro
      return 'https://feeltrip.app/agency/$agencyId/exp/$experienceId?aff=ref_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Rastrea una conversión de afiliado
  static Future<bool> trackConversion({
    required String affiliateId,
    required String bookingId,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/track'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'affiliateId': affiliateId,
          'bookingId': bookingId,
          'amount': amount,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.e('Track conversion error: $e');
      return false;
    }
  }

  /// Obtiene estadísticas de afiliado
  static Future<Map<String, dynamic>> getStats(String affiliateId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/$affiliateId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // CORRECCIÓN: Casteo explícito a Map<String, dynamic>
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return {'clicks': 0, 'conversions': 0, 'revenue': 0.0};
    } catch (e) {
      AppLogger.e('Affiliate stats error: $e');
      return {'clicks': 0, 'conversions': 0, 'revenue': 0.0};
    }
  }
}
