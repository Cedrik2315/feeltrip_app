import 'package:logger/logger.dart';

final logger = Logger();

class AnalyticsService {
  static void logPremiumViewed() {
    logger.i('Analytics: Premium screen viewed');
  }

  static void logPremiumAttempt(String? productTitle) {
    logger.i('Analytics: Premium attempt: $productTitle');
  }

  static void logAffiliateClick(String name, String destination) {
    // Mock implementation
    logger.i('Analytics: $name clicked for $destination');
  }
}
