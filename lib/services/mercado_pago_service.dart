import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class MercadoPagoService {
  // El Access Token se obtiene de forma segura desde el archivo .env
  // Se incluye un valor por defecto para facilitar las pruebas
  // ADVERTENCIA: Se han eliminado las claves hardcodeadas por seguridad.
  // Asegúrate de que estén configuradas en tu archivo .env
  static String get _accessToken =>
      dotenv.env['MERCADOPAGO_ACCESS_TOKEN'] ?? '';

  /// Método privado que centraliza la creación de preferencias en Mercado Pago.
  Future<bool> _crearPreferenciaYRedirigir({
    required List<Map<String, dynamic>> items,
    required Map<String, String> backUrls,
  }) async {
    if (_accessToken.isEmpty) {
      debugPrint(
          'CRITICAL: MERCADOPAGO_ACCESS_TOKEN no está configurado en el archivo .env');
      return false;
    }

    final url = Uri.parse('https://api.mercadopago.com/checkout/preferences');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "items": items,
          "back_urls": backUrls,
          "auto_return": "approved",
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String? initPoint = data['init_point'];

        if (initPoint != null && await canLaunchUrl(Uri.parse(initPoint))) {
          await launchUrl(Uri.parse(initPoint),
              mode: LaunchMode.externalApplication);
          debugPrint('✅ Abriendo link de pago de Mercado Pago: $initPoint');
          return true;
        } else {
          debugPrint('❌ No se pudo abrir el link de pago de Mercado Pago.');
          return false;
        }
      } else {
        debugPrint(
            '❌ Error al crear preferencia: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Excepción al llamar a Mercado Pago: $e');
      return false;
    }
  }

  /// Crea una preferencia de pago en Mercado Pago y abre el link de pago.
  /// Devuelve `true` si el proceso se inició correctamente, `false` en caso de error.
  ///
  /// [title]: El título del producto a vender.
  /// [price]: El precio del producto.
  /// [currencyId]: El ID de la moneda (ej. 'CLP', 'ARS', 'MXN').
  Future<bool> crearPreferenciaYPagar({
    required String title,
    required double price,
    String currencyId = 'CLP',
  }) async {
    return _crearPreferenciaYRedirigir(
      items: [
        {
          "title": title,
          "quantity": 1,
          "unit_price": price,
          "currency_id": currencyId
        }
      ],
      backUrls: {
        "success": "feeltrip://pago-exitoso",
        "failure": "feeltrip://pago-fallido",
        "pending": "feeltrip://pago-pendiente",
      },
    );
  }

  /// Inicia un pago de prueba con parámetros fijos (ARS)
  Future<bool> iniciarPagoMercadoPago() async {
    return _crearPreferenciaYRedirigir(
      items: [
        {
          "title": "Viaje Emocional - Feeltrip App",
          "quantity": 1,
          "unit_price": 5000, // Precio en tu moneda
          "currency_id": "ARS" // O MXN, CLP, etc.
        }
      ],
      backUrls: {
        "success": "feeltrip://success", // Tu esquema de uni_links
        "failure": "feeltrip://failure",
        "pending": "feeltrip://pending"
      },
    );
  }
}
