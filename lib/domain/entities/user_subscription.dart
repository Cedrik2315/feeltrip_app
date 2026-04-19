/// Modelo de dominio de suscripción de FeelTrip.
/// No contiene lógica de Firestore ni de UI.
enum SubscriptionLevel { free, aventurero, pro, trial }

/// Nivel de alerta según los días restantes de acceso Pro efectivo.
enum ProAlertLevel { none, safe, warning, urgent, critical, expired }

class UserSubscription {
  const UserSubscription({
    required this.level,
    this.trialExpiresAt,
    required this.trialUsed,
    this.subscriptionExpiresAt,
    required this.totalRoutesCompleted,
    this.bookRequestedAt,
    // Campos del sistema de referidos
    this.referralCode = '',
    this.referredBy,
    this.invitesAccepted = 0,
    this.bonusDaysEarned = 0,
    this.bonusDaysAccumulated = 0,
    this.proExpiresAt,
    // Campos de descuento por referido
    this.hasReferralDiscount = false,
    this.referralDiscountUsed = false,
    // Campos del modelo Embajador
    this.isAmbassador = false,
    this.ambassadorBalance = 0.0,
    this.ambassadorSalesCount = 0,
  });

  final SubscriptionLevel level;
  final DateTime? trialExpiresAt;
  final bool trialUsed;
  final DateTime? subscriptionExpiresAt;
  final int totalRoutesCompleted;
  final DateTime? bookRequestedAt;

  // ── Ambassador fields ────────────────────────────────────────────────────

  /// true si el usuario ha sido elevado al rango de Embajador.
  final bool isAmbassador;

  /// Saldo acumulado (USD/CLP) por ventas de suscripciones para costear viajes.
  final double ambassadorBalance;

  /// Cantidad de suscripciones Pro vendidas como Embajador.
  final int ambassadorSalesCount;

  // ── Referral fields ──────────────────────────────────────────────────────

  /// Código único del usuario (ej: "FELT-X7K2").
  final String referralCode;

  /// Código usado al registrarse (quién lo invitó).
  final String? referredBy;

  /// Cuántos referidos activaron la app con este código.
  final int invitesAccepted;

  /// Total histórico de días bonus ganados (sin tope).
  final int bonusDaysEarned;

  /// Días bonus pendientes de usar (tope: 90).
  final int bonusDaysAccumulated;

  /// Fecha efectiva de expiración Pro — fuente de verdad para acceso Pro.
  final DateTime? proExpiresAt;

  // ── Descuento por referido ────────────────────────────────────────────────

  /// true si llegó por código de referido válido.
  final bool hasReferralDiscount;

  /// true cuando canjea el offer code en el paywall.
  final bool referralDiscountUsed;

  // ── Getters existentes ────────────────────────────────────────────────────

  /// El trial está activo si el nivel es trial y la fecha de expiración
  /// es futura.
  bool get isTrialActive =>
      level == SubscriptionLevel.trial &&
      trialExpiresAt != null &&
      DateTime.now().isBefore(trialExpiresAt!);

  /// "Pro" incluye suscripción Pro paga, trial activo, o proExpiresAt en el futuro.
  bool get isPro =>
      level == SubscriptionLevel.pro ||
      isTrialActive ||
      (proExpiresAt != null && DateTime.now().isBefore(proExpiresAt!));

  /// "Aventurero" incluye ese nivel y todos los superiores.
  bool get isAventurero =>
      level == SubscriptionLevel.aventurero || isPro;

  /// El libro impreso solo se puede pedir si el usuario es Pro,
  /// ha completado al menos 12 rutas y no ha pedido uno antes.
  bool get canRequestBook =>
      level == SubscriptionLevel.pro &&
      totalRoutesCompleted >= 12 &&
      bookRequestedAt == null;

  // ── Getters de referidos ──────────────────────────────────────────────────

  /// Días restantes de acceso Pro efectivo (por proExpiresAt).
  int get proExpiresInDays {
    if (proExpiresAt == null) return 0;
    return proExpiresAt!.difference(DateTime.now()).inDays.clamp(0, 999);
  }

  /// Nivel de alerta según días restantes de Pro.
  ProAlertLevel get alertLevel {
    if (!isPro) return ProAlertLevel.none;
    if (proExpiresInDays > 30) return ProAlertLevel.safe;
    if (proExpiresInDays >= 15) return ProAlertLevel.warning;
    if (proExpiresInDays >= 7) return ProAlertLevel.urgent;
    if (proExpiresInDays >= 1) return ProAlertLevel.critical;
    return ProAlertLevel.expired;
  }

  /// Si puede acumular más días bonus (tope: 90).
  bool get canAccumulateMoreBonus => bonusDaysAccumulated < 90;

  /// Si el descuento por referido está disponible para usar en el paywall.
  bool get referralDiscountAvailable =>
      hasReferralDiscount && !referralDiscountUsed;

  // ── Valor por defecto ─────────────────────────────────────────────────────

  /// Valor neutral para usar como estado inicial/fallback.
  static const UserSubscription empty = UserSubscription(
    level: SubscriptionLevel.free,
    trialUsed: false,
    totalRoutesCompleted: 0,
  );
}
