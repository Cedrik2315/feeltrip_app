import 'package:logger/logger.dart';

final logger = Logger();

class AnalyticsService {
  static void logAffiliateClick(String name, String destination) {
    // Mock implementation
    logger.i('Analytics: $name clicked for $destination');
  }
}
