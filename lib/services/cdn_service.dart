import 'package:flutter_riverpod/flutter_riverpod.dart';

final cdnServiceProvider = Provider((ref) => CdnService());

/// Servicio para gestionar la entrega de contenido a través de CDN.
/// Transforma las URLs directas de Storage a rutas optimizadas por CloudFront/Hosting.
class CdnService {
  // En producción, esto vendría de variables de entorno (.env)
  final String _cdnBaseUrl = 'https://cdn.feeltrip.app';
  final String _storageBucket = 'feeltrip-app.appspot.com';

  /// Convierte una URL de Firebase Storage en una URL de CDN.
  /// Ejemplo: de firebasestorage.googleapis.com/... a cdn.feeltrip.app/...
  String getOptimizedImageUrl(String originalUrl) {
    if (!originalUrl.contains(_storageBucket)) return originalUrl;

    try {
      // Extraemos el path del objeto y lo mapeamos al dominio del CDN
      final Uri uri = Uri.parse(originalUrl);
      final String path =
          uri.pathSegments.last; // Simplificación para el ejemplo

      // Aplicamos parámetros de optimización (resize, webp) si el CDN lo soporta
      return '$_cdnBaseUrl/$path?format=webp&quality=80';
    } catch (e) {
      return originalUrl;
    }
  }
}
