import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ErrorHandler {
  /// Global error handler con Sentry + UI feedback
  static void handleError(
    BuildContext? context,
    Object error, // Cambiado de dynamic a Object para mejor práctica
    StackTrace stackTrace,
  ) {
    // CORRECCIÓN: Si AppLogger.e no tiene parámetros nombrados 'error' y 'stackTrace',
    // debemos pasarlos como argumentos posicionales o formatearlos en el string.
    // Asumiendo que AppLogger.e(String message, {dynamic error, StackTrace? stackTrace})
    AppLogger.e(
      'Global error handler: $error',
      // Si tu AppLogger.e NO acepta estos parámetros nombrados, bórralos y deja solo el mensaje.
      // Pero según tu reporte de error, el compilador dice que no existen.
    );

    // Sentry capture
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
    );

    // UI feedback si el context es válido y el widget sigue montado
    if (context != null && context.mounted) {
      _showErrorDialog(context, error.toString());
    }
  }

  static void _showErrorDialog(BuildContext context, String message) {
    // CORRECCIÓN: Añadimos <void> para resolver el warning de inferencia
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Safe async wrapper
  static Future<T> safeAsync<T>(
    Future<T> Function() operation, {
    BuildContext? context,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      handleError(context, e, stackTrace);
      rethrow;
    }
  }
}

/// Extension para widgets
extension SafeWidget on Widget {
  Widget withErrorHandling(BuildContext context) {
    return this; // Flutter error boundaries manejan el UI
  }
}
