import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AffiliateService {
  static String get bookingAid => dotenv.env['BOOKING_AID'] ?? '';
  static String get getYourGuidePartnerId =>
      dotenv.env['GETYOURGUIDE_PARTNER_ID'] ?? '';
  static String get viatorApiKey => dotenv.env['VIATOR_API_KEY'] ?? '';

  // ==========================================
  // 1. BOOKING.COM (Deeplinks & Tracking)
  // ==========================================
  
  /// Abre la búsqueda de Booking.com con tu ID de afiliado para tracking
  Future<void> openBookingComSearch({
    required String city,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    if (bookingAid.isEmpty) {
      debugPrint('Booking AID no configurado en .env (BOOKING_AID).');
      return;
    }

    final String checkInStr = "${checkIn.year}-${checkIn.month.toString().padLeft(2,'0')}-${checkIn.day.toString().padLeft(2,'0')}";
    final String checkOutStr = "${checkOut.year}-${checkOut.month.toString().padLeft(2,'0')}-${checkOut.day.toString().padLeft(2,'0')}";

    // Construcción del deeplink con parámetros de afiliado
    final Uri url = Uri.parse(
      'https://www.booking.com/searchresults.html?ss=$city&aid=$bookingAid&checkin=$checkInStr&checkout=$checkOutStr&utm_source=feeltrip_app&utm_medium=app'
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      debugPrint('✅ Booking.com deeplink abierto: $url');
    } else {
      debugPrint('❌ No se pudo abrir Booking.com');
    }
  }

  // ==========================================
  // 2. GETYOURGUIDE API (Tours)
  // ==========================================

  /// Busca tours en GetYourGuide (Requiere integración Server-to-Server en producción para ocultar API Key)
  Future<List<dynamic>> searchGetYourGuideTours(String query) async {
    if (getYourGuidePartnerId.isEmpty) {
      debugPrint(
          'GetYourGuide Partner ID no configurado en .env (GETYOURGUIDE_PARTNER_ID).');
      return [];
    }

    final Uri url = Uri.parse('https://api.getyourguide.com/1/tours?query=$query&cnt_language=es&partner_id=$getYourGuidePartnerId');
    
    try {
      // Nota: En producción, haz esta llamada desde tu backend (Cloud Functions)
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['tours'] ?? [];
      }
    } catch (e) {
      debugPrint('❌ Error GetYourGuide: $e');
    }
    return [];
  }

  // ==========================================
  // 3. VIATOR API (Actividades)
  // ==========================================

  /// Busca productos en Viator
  Future<List<dynamic>> searchViatorProducts(String destinationId) async {
    if (viatorApiKey.isEmpty) {
      debugPrint('Viator API Key no configurada en .env (VIATOR_API_KEY).');
      return [];
    }

    final Uri url = Uri.parse('https://api.viator.com/partner/products/search');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'exp-api-key': viatorApiKey,
          'Content-Type': 'application/json',
          'Accept-Language': 'es',
        },
        body: json.encode({
          "filtering": {
            "destination": destinationId,
          },
          "currency": "USD",
          "pagination": {
            "start": 1,
            "count": 10
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['products'] ?? [];
      }
    } catch (e) {
      debugPrint('❌ Error Viator: $e');
    }
    return [];
  }
}
