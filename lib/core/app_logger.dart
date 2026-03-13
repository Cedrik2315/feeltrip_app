import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _defaultName = 'FeelTrip';

  static void debug(String message, {String name = _defaultName}) {
    if (!kReleaseMode) {
      developer.log(message, name: name);
    }
  }

  static void info(String message, {String name = _defaultName}) {
    developer.log(message, name: name);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = _defaultName,
  }) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
