import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

import '../core/app_logger.dart';

class ObservabilityService {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver analyticsObserver =
      FirebaseAnalyticsObserver(analytics: analytics);

  static Future<void> initialize() async {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<T> trace<T>({
    required String name,
    required Future<T> Function() action,
  }) async {
    Trace? trace;
    try {
      trace = FirebasePerformance.instance.newTrace(name);
      await trace.start();
    } catch (_) {
      // Ignora en plataformas/tests sin plugin de performance.
    }
    try {
      return await action();
    } catch (e, st) {
      AppLogger.error(
        'Error en traza de performance: $name',
        error: e,
        stackTrace: st,
        name: 'ObservabilityService',
      );
      rethrow;
    } finally {
      try {
        await trace?.stop();
      } catch (_) {
        // Ignora en plataformas/tests sin plugin de performance.
      }
    }
  }

  static Future<void> setUserId(String? uid) async {
    if (uid == null || uid.isEmpty) return;
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(uid);
      await analytics.setUserId(id: uid);
    } catch (_) {
      // Ignora en plataformas/tests sin plugins de Firebase.
    }
  }

  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    if (kDebugMode) {
      AppLogger.debug('Analytics event: $name', name: 'ObservabilityService');
    }
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {
      // Ignora en plataformas/tests sin plugin de analytics.
    }
  }
}
