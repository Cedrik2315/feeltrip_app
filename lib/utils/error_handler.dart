import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'snackbar_controller.dart';

class AppErrorHandler {
  static final SnackBarController _snackBar = SnackBarController();

  static void handle(
    dynamic error, {
    StackTrace? stackTrace,
    BuildContext? uiContext, // Contexto para mostrar UI (SnackBar, Dialog)
    String? reason, // Razón para Crashlytics, antes llamado 'context'
  }) {
    debugPrint("-------------------- ERROR CAPTURADO --------------------");
    if (reason != null) {
      debugPrint("Contexto (razón): $reason");
    }
    debugPrint("Error: $error");
    if (stackTrace != null) {
      debugPrint("Stack Trace: $stackTrace");
    }
    debugPrint("---------------------------------------------------------");

    FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: reason);

    final message =
        error is Exception ? error.toString() : 'Ocurrió un error inesperado';

    if (uiContext != null && uiContext.mounted) {
      _snackBar.showError(uiContext, 'Error: $message');
    }
  }
}
