import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class MetricsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Simulate ARPU: total revenue / total users (hardcoded demo for LTV>CAC proof)
  static double getSimulatedARPU() {
    // Demo: $12.5 ARPU (premium subs)
    const totalRevenue = 12500.0;
    const totalUsers = 1000;
    return totalRevenue / totalUsers;
  }

  /// LTV = ARPU * lifetime months * retention rate
  static double getSimulatedLTV() {
    const arpu = 12.5;
    const lifetime = 12; // 1 year
    const retention = 0.85;
    return arpu * lifetime * retention; // $127.5 > CAC $5
  }

  static double getCAC() => 5.0; // Marketing cost per user

  static bool get ltvGreaterCAC => getSimulatedLTV() > getCAC();

  static Future<void> logRevenueEvent(double revenue) async {
    await _analytics.logPurchase(
      currency: 'USD',
      value: revenue,
    );
    AppLogger.i('Logged revenue: \$${revenue.toStringAsFixed(2)}');
  }

  static Future<void> logCAC(double cac) async {
    await _analytics.logEvent(name: 'cac_update', parameters: {'value': cac});
  }
}
