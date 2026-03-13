import 'package:flutter_test/flutter_test.dart';
import 'package:feeltrip_app/services/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    test('métodos existen y son llamables', () {
      expect(AnalyticsService.logPremiumViewed, isNotNull);
      expect(AnalyticsService.logAffiliateClick, isNotNull);
      expect(AnalyticsService.logTripViewed, isNotNull);
    });
  });
}
