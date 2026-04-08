import 'package:logger/logger.dart';

final logger = Logger();

// AnalyticsService DEPRECATED - use MetricsService with FirebaseAnalytics (Día 11-12)
class AnalyticsService {
  static void logPremiumViewed() {
    // Redirect to MetricsService.logPremiumView()
  }

  static void logPremiumAttempt(String? productTitle) {
    // Redirect to MetricsService.logPremiumView()
  }

  static void logAffiliateClick(String name, String destination) {
    // No real impl - log as event if needed
  }
}
