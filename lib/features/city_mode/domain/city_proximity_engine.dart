import 'dart:math';

class CityProximityEngine {
  /// Calcula la distancia en metros entre dos puntos geográficos usando la fórmula de Haversine.
  /// Perfecta para evaluar geofencing localmente 100% offline sin dependencias externas.
  static double calculateDistanceInMeters(
      double startLat, double startLng, double endLat, double endLng) {
    const double earthRadiusInMeters = 6371000.0; // Radio ecuatorial aproximado de la tierra

    double lat1 = _degreesToRadians(startLat);
    double lng1 = _degreesToRadians(startLng);
    double lat2 = _degreesToRadians(endLat);
    double lng2 = _degreesToRadians(endLng);

    double dLat = lat2 - lat1;
    double dLng = lng2 - lng1;

    // Fórmula Haversine
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusInMeters * c; // Devuelve metros
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Evalúa si la posición actual (userLat, userLng) ha vulnerado (entrado) 
  /// el perímetro invisible del Hito (radio en metros).
  static bool hasInvadedPerimeter({
    required double userLat,
    required double userLng,
    required double hitoLat,
    required double hitoLng,
    required double radiusInMeters,
  }) {
    final currentDistance = calculateDistanceInMeters(userLat, userLng, hitoLat, hitoLng);
    return currentDistance <= radiusInMeters;
  }
}
