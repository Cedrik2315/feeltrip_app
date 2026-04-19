import 'dart:math';

class SpatialAudioEngine {
  /// Calcula el volumen (entre 0.0 y 1.0) basado en la distancia del usuario al epicentro del hito.
  /// Mientras más cerca, más fuerte. Si está fuera del radio, el volumen es 0.
  static double calculateDynamicVolume({
    required double currentDistanceInMeters,
    required double hitoRadiusInMeters,
  }) {
    if (currentDistanceInMeters > hitoRadiusInMeters) {
      return 0.0;
    }

    // Fórmula lineal simple: si estás a 0 metros, volumen es 1.0
    // Si estás en el borde del radio (Ej: 50m), el volumen se acerca a 0.0.
    double rawVolume = 1.0 - (currentDistanceInMeters / hitoRadiusInMeters);

    // Ajuste logarítmico para hacer el acercamiento más "dramático" auditivamente
    // (Opcional, pero da mejor sensación de tensión)
    double cinematicVolume = pow(rawVolume, 1.5).toDouble();

    return cinematicVolume.clamp(0.0, 1.0);
  }

  /// Retorna un filtro sugerido para el ecualizador (Ej. paso bajo) basado en distancia.
  /// Si estás lejos, el sonido es "opaco" (lowpass). Si estás cerca, es cristalino.
  static double calculateLowpassCutoff({
    required double currentDistanceInMeters,
    required double hitoRadiusInMeters,
  }) {
    if (currentDistanceInMeters > hitoRadiusInMeters) {
      return 1000.0; // Muy opaco
    }

    double ratio = 1.0 - (currentDistanceInMeters / hitoRadiusInMeters);
    // 20000 Hz es claridad total, 1000 Hz es apagado.
    return 1000.0 + (19000.0 * ratio);
  }
}
