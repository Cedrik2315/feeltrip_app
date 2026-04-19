import 'package:firebase_analytics/firebase_analytics.dart';

/// Servicio centralizado de Analytics para FeelTrip.
/// Registra eventos clave del ciclo de vida del usuario para medir retención,
/// conversión y uso de funcionalidades premium.
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ─── Onboarding ──────────────────────────────────────────────
  Future<void> logOnboardingStarted() async {
    await _analytics.logEvent(name: 'onboarding_started');
  }

  Future<void> logOnboardingCompleted() async {
    await _analytics.logEvent(name: 'onboarding_completed');
  }

  // ─── Autenticación ───────────────────────────────────────────
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // ─── Quiz de Arquetipo ───────────────────────────────────────
  Future<void> logQuizStarted() async {
    await _analytics.logEvent(name: 'quiz_started');
  }

  Future<void> logQuizCompleted({required String archetype}) async {
    await _analytics.logEvent(
      name: 'quiz_completed',
      parameters: {'archetype': archetype},
    );
  }

  // ─── Rutas e IA ──────────────────────────────────────────────
  Future<void> logRouteGenerated({
    required String mood,
    required String destination,
  }) async {
    await _analytics.logEvent(
      name: 'route_generated',
      parameters: {
        'mood': mood,
        'destination': destination,
      },
    );
  }

  // ─── Diario ──────────────────────────────────────────────────
  Future<void> logDiaryEntryCreated({String? location}) async {
    await _analytics.logEvent(
      name: 'diary_entry_created',
      parameters: {
        if (location != null) 'location': location,
      },
    );
  }

  // ─── Suscripción ─────────────────────────────────────────────
  Future<void> logProUpgradeViewed() async {
    await _analytics.logEvent(name: 'pro_upgrade_viewed');
  }

  Future<void> logProUpgradePurchased({required double price}) async {
    await _analytics.logPurchase(
      currency: 'USD',
      value: price,
      items: [
        AnalyticsEventItem(itemName: 'FeelTrip Pro', itemId: 'pro_monthly'),
      ],
    );
  }

  // ─── Feed y Comunidad ────────────────────────────────────────
  Future<void> logStoryPublished() async {
    await _analytics.logEvent(name: 'story_published');
  }

  Future<void> logFeedScrolled({required int storiesViewed}) async {
    await _analytics.logEvent(
      name: 'feed_scrolled',
      parameters: {'stories_viewed': storiesViewed},
    );
  }

  // ─── Idioma ──────────────────────────────────────────────────
  Future<void> logLanguageChanged({required String language}) async {
    await _analytics.logEvent(
      name: 'language_changed',
      parameters: {'language': language},
    );
  }

  // ─── Usuario ─────────────────────────────────────────────────
  Future<void> setUserId(String uid) async {
    await _analytics.setUserId(id: uid);
  }

  Future<void> setUserArchetype(String archetype) async {
    await _analytics.setUserProperty(name: 'archetype', value: archetype);
  }

  // ─── Afiliados ───────────────────────────────────────────────
  Future<void> logAffiliateClick(String name, String destination) async {
    await _analytics.logEvent(
      name: 'affiliate_click',
      parameters: {'affiliate': name, 'destination': destination},
    );
  }
}
