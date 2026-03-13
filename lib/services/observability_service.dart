import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

import '../core/app_logger.dart';
import 'analytics_events.dart';

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

  static Future<void> setReleaseContext({
    required String env,
    required String version,
  }) async {
    try {
      await FirebaseCrashlytics.instance.setCustomKey('app_env', env);
      await FirebaseCrashlytics.instance.setCustomKey('app_version', version);
    } catch (_) {
      // Ignora en plataformas/tests sin plugin de crashlytics.
    }
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
    final safeName = _normalizeKey(name);
    final safeParams = _normalizeParameters(parameters);
    if (kDebugMode) {
      AppLogger.debug('Analytics event: $safeName', name: 'ObservabilityService');
    }
    try {
      await analytics.logEvent(name: safeName, parameters: safeParams);
    } catch (_) {
      // Ignora en plataformas/tests sin plugin de analytics.
    }
  }

  static Future<void> logAppStartup({
    required String env,
    required String version,
    required bool firebaseReady,
  }) async {
    await logEvent(
      AnalyticsEvents.appStartup,
      parameters: <String, Object>{
        'env': env,
        'version': version,
        'firebase_ready': firebaseReady,
      },
    );
  }

  static Future<void> logAuthGateState(String state) async {
    await logEvent(
      AnalyticsEvents.authGateState,
      parameters: <String, Object>{'state': state},
    );
  }

  static Future<void> logSearchExecuted({
    required String query,
    required int resultsCount,
    required String category,
    required String difficulty,
    required double maxPrice,
  }) async {
    await logEvent(
      AnalyticsEvents.searchExecuted,
      parameters: <String, Object>{
        'query': query.isEmpty ? 'all' : query,
        'results_count': resultsCount,
        'category': category,
        'difficulty': difficulty,
        'max_price': maxPrice.round(),
      },
    );
  }

  static Future<void> logTripOpened({
    required String tripId,
    required String source,
  }) async {
    await logEvent(
      AnalyticsEvents.tripOpened,
      parameters: <String, Object>{
        'trip_id': tripId,
        'source': source,
      },
    );
  }

  static Future<void> logAddToCart({
    required String tripId,
    required int quantity,
    required double unitPrice,
  }) async {
    await logEvent(
      AnalyticsEvents.addToCart,
      parameters: <String, Object>{
        'trip_id': tripId,
        'quantity': quantity,
        'unit_price': unitPrice.round(),
      },
    );
  }

  static Future<void> logCheckoutCompleted({
    required int itemCount,
    required double total,
  }) async {
    await logEvent(
      AnalyticsEvents.checkoutCompleted,
      parameters: <String, Object>{
        'item_count': itemCount,
        'total': total.round(),
      },
    );
  }

  static Future<void> logAffiliateClick({
    required String clickId,
    required String providerId,
    required String tripId,
    required String destination,
  }) async {
    await logEvent(
      AnalyticsEvents.affiliateClick,
      parameters: <String, Object>{
        'click_id': clickId,
        'provider_id': providerId,
        'trip_id': tripId,
        'destination': destination,
      },
    );
  }

  static Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    String reason = 'non_fatal',
  }) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: false,
      );
    } catch (_) {
      // Ignora en plataformas/tests sin plugin de crashlytics.
    }
  }

  static String _normalizeKey(String key) {
    final cleaned = key
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (cleaned.isEmpty) return 'unknown_event';
    return cleaned.length > 40 ? cleaned.substring(0, 40) : cleaned;
  }

  static Map<String, Object>? _normalizeParameters(Map<String, Object>? params) {
    if (params == null || params.isEmpty) return null;
    final output = <String, Object>{};
    params.forEach((key, value) {
      final safeKey = _normalizeKey(key);
      output[safeKey] = _normalizeValue(value);
    });
    return output;
  }

  static Object _normalizeValue(Object value) {
    if (value is num || value is bool) return value;
    final text = value.toString();
    return text.length > 100 ? text.substring(0, 100) : text;
  }
}
