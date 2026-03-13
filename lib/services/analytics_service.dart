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
}
