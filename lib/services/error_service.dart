import 'package:sentry_flutter/sentry_flutter.dart';

class ErrorService {
  // Capturar excepción con contexto
  static Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? extras,
  }) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (context != null) scope.setTag('context', context);
        if (extras != null) {
          scope.setContexts('extras', extras);
        }
      },
    );
  }

  // Capturar mensaje
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    await Sentry.captureMessage(message, level: level);
  }

  // Identificar usuario
  static Future<void> setUser(String userId, String? email) async {
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: userId, email: email));
    });
  }
}
