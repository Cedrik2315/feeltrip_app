import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Pantallas
  static Future<void> logScreen(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  // Autenticación
  static Future<void> logLogin(String method) =>
      _analytics.logLogin(loginMethod: method);
  static Future<void> logSignUp(String method) =>
      _analytics.logSignUp(signUpMethod: method);

  // Viajes
  static Future<void> logViewTrip(String tripId, String tripName) =>
      _analytics.logViewItem(
        currency: 'USD',
        value: 0,
        items: [
          AnalyticsEventItem(
            itemId: tripId,
            itemName: tripName,
            itemCategory: 'trip',
          ),
        ],
      );
  static Future<void> logAddToCart(String tripId, double price) =>
      _analytics.logAddToCart(
        currency: 'USD',
        value: price,
        items: [
          AnalyticsEventItem(
            itemId: tripId,
            itemName: tripId,
            itemCategory: 'trip',
            price: price,
          ),
        ],
      );
  static Future<void> logPurchase(double value) => _analytics.logPurchase(
        currency: 'USD',
        value: value,
      );

  // Quiz
  static Future<void> logQuizCompleted(String archetype) => _analytics.logEvent(
        name: 'quiz_completed',
        parameters: {'archetype': archetype},
      );

  // Historias
  static Future<void> logStoryCreated() =>
      _analytics.logEvent(name: 'story_created');
  static Future<void> logStoryShared(String platform) => _analytics.logEvent(
        name: 'story_shared',
        parameters: {'platform': platform},
      );

  // Diario
  static Future<void> logDiaryEntry() =>
      _analytics.logEvent(name: 'diary_entry_created');

  // Afiliados
  static Future<void> logAffiliateClick(String provider, String destination) =>
      _analytics.logEvent(
        name: 'affiliate_click',
        parameters: {
          'provider': provider,
          'destination': destination,
        },
      );

  // Premium
  static Future<void> logPremiumViewed() =>
      _analytics.logEvent(name: 'premium_screen_viewed');
  static Future<void> logPremiumAttempt(String plan) => _analytics.logEvent(
        name: 'premium_purchase_attempt',
        parameters: {'plan': plan},
      );
}
