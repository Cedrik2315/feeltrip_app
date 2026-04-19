import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/logger/app_logger.dart';

final metricsServiceProvider = Provider((ref) => MetricsService());

class MetricsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Eventos de Autenticación
  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  // Eventos de Búsqueda y Discovery
  Future<void> logSearch(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }

  static void logShare(String type) {
    FirebaseAnalytics.instance.logShare(
      contentType: type,
      itemId: 'shared_$type',
      method: 'native_share',
    );
  }

  // Eventos de Negocio (Funnel de Conversión)
  Future<void> logPremiumView() async {
    await _analytics.logEvent(name: 'premium_view');
  }

  Future<void> logPurchaseStarted(String productId) async {
    await _analytics.logEvent(
      name: 'premium_purchase_started',
      parameters: {'product_id': productId},
    );
  }

  Future<void> logBookingStarted(String experienceId, double amount) async {
    await _analytics.logEvent(
      name: 'booking_started',
      parameters: {
        'experience_id': experienceId,
        'value': amount,
        'currency': 'ARS',
      },
    );
    AppLogger.i('Metrics: Registro de inicio de booking para $experienceId');
  }

  Future<void> logBookingPaid(String bookingId, double amount) async {
    await _analytics.logEvent(
      name: 'booking_paid',
      parameters: {
        'transaction_id': bookingId,
        'value': amount,
      },
    );
  }

  // Premium funnel events
  static void logPremiumViewed() {
    FirebaseAnalytics.instance.logEvent(name: 'premium_viewed');
  }

  static void logPremiumPurchaseStarted({required String source}) {
    FirebaseAnalytics.instance.logEvent(
      name: 'premium_purchase_started',
      parameters: {'source': source},
    );
  }

  static void logPremiumPurchaseSuccess({required String source}) {
    FirebaseAnalytics.instance.logEvent(
      name: 'premium_purchase_success',
      parameters: {'source': source},
    );
  }

  // User actions
  static void logSaveMoment() {
    FirebaseAnalytics.instance.logEvent(name: 'save_moment');
  }

  static void logLoginSuccess() {
    FirebaseAnalytics.instance.logEvent(name: 'login_success');
  }

  static void logSubscriptionSuccess() {
    FirebaseAnalytics.instance.logEvent(name: 'subscription_success');
  }

  static void logChronicleGenerated(String archetype) {
    FirebaseAnalytics.instance.logEvent(
      name: 'chronicle_generated',
      parameters: {'archetype': archetype},
    );
  }
}
