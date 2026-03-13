import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logAffiliateClick(
      String platform, String destination) async {
    await _analytics.logEvent(
      name: 'affiliate_click',
      parameters: {'platform': platform, 'destination': destination},
    );
  }

  static Future<void> logPremiumViewed() async {
    await _analytics.logEvent(name: 'premium_viewed');
  }

  static Future<void> logPremiumPurchased(String packageId) async {
    await _analytics.logEvent(
      name: 'premium_purchased',
      parameters: {'package_id': packageId},
    );
  }

  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  static Future<void> logTripViewed(String tripId) async {
    await _analytics.logEvent(
      name: 'trip_viewed',
      parameters: {'trip_id': tripId},
    );
  }

  static Future<void> logPremiumAttempt(String packageId) async {
    await _analytics.logEvent(
      name: 'premium_attempt',
      parameters: {'package_id': packageId},
    );
  }
}
