import 'package:firebase_analytics/firebase_analytics.dart';

class ObservabilityService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> setUserId(String uid) async {
    await _analytics.setUserId(id: uid);
  }

  static Future<void> logAuthGateState(String state) async {
    await _analytics.logEvent(
      name: 'auth_gate_state',
      parameters: {'state': state},
    );
  }
}
