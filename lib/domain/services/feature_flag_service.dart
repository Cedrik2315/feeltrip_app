import 'package:feeltrip_app/domain/entities/user_subscription.dart';

/// [FeelTrip] Servicio de feature flags basado en nivel de suscripción.
///
/// Todos los métodos son estáticos y puros: no tienen efectos secundarios
/// ni acceso a Firestore. La lógica de negocio vive aquí, no en la UI.
class FeatureFlagService {
  // ── Crónicas ────────────────────────────────────────────────────────────

  /// Free: máximo 3 crónicas por mes. Aventurero/Pro/Trial: ilimitado.
  static bool canGenerateCronica(
    SubscriptionLevel level,
    int cronicasThisMonth,
  ) {
    if (level == SubscriptionLevel.free) return cronicasThisMonth < 3;
    return true;
  }

  /// Tonos narrativos adicionales (Contemplativo, Salvaje, etc.)
  static bool canUseMultipleTones(SubscriptionLevel level) =>
      level != SubscriptionLevel.free;

  /// Crónica extendida (más párrafos, mayor profundidad narrativa).
  static bool canUseExtendedCronica(SubscriptionLevel level) =>
      level == SubscriptionLevel.pro || level == SubscriptionLevel.trial;

  // ── Visión y multimedia ─────────────────────────────────────────────────

  /// Detección de rostros en fotos de expedición.
  static bool canUseFaceDetection(SubscriptionLevel level) =>
      level != SubscriptionLevel.free;

  /// OCR de textos en campo (señales, carteles, etc.).
  static bool canUseOcr(SubscriptionLevel level) =>
      level != SubscriptionLevel.free;

  // ── Arquetipo y conexiones ──────────────────────────────────────────────

  /// Acceso al perfil de arquetipo completo (no solo el resumen).
  static bool canUseFullArchetype(SubscriptionLevel level) =>
      level == SubscriptionLevel.pro || level == SubscriptionLevel.trial;

  /// Conexiones cercanas P2P entre exploradores.
  static bool canUseNearbyConnections(SubscriptionLevel level) =>
      level == SubscriptionLevel.pro || level == SubscriptionLevel.trial;

  // ── Exportación ─────────────────────────────────────────────────────────

  /// Exportar crónica a PDF.
  static bool canExportPdf(SubscriptionLevel level) =>
      level != SubscriptionLevel.free;

  /// Exportar crónica con multimedia (fotos, audio, etc.).
  static bool canExportMultimedia(SubscriptionLevel level) =>
      level == SubscriptionLevel.pro || level == SubscriptionLevel.trial;

  // ── Ads y libro ─────────────────────────────────────────────────────────

  /// Muestra publicidad solo a usuarios Free.
  static bool showAds(SubscriptionLevel level) =>
      level == SubscriptionLevel.free;

  /// Solicitud de libro impreso con las 12 mejores crónicas.
  static bool canRequestBook(
    SubscriptionLevel level,
    int totalRoutes,
    DateTime? bookRequestedAt,
  ) =>
      level == SubscriptionLevel.pro &&
      totalRoutes >= 12 &&
      bookRequestedAt == null;
}
