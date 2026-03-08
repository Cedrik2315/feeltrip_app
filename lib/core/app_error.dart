import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

class AppException implements Exception {
  AppException({
    required this.code,
    required this.message,
    this.retryable = false,
  });

  final String code;
  final String message;
  final bool retryable;

  @override
  String toString() => message;

  factory AppException.from(Object error) {
    if (error is AppException) return error;

    if (error is TimeoutException) {
      return AppException(
        code: 'timeout',
        message: 'La solicitud tardó demasiado. Intenta nuevamente.',
        retryable: true,
      );
    }

    if (error is SocketException) {
      return AppException(
        code: 'offline',
        message: 'Sin conexión a internet. Revisa tu red e intenta nuevamente.',
        retryable: true,
      );
    }

    if (error is FirebaseAuthException) {
      return AppException(
        code: 'auth',
        message: error.message ?? 'Error de autenticación. Vuelve a intentarlo.',
        retryable: true,
      );
    }

    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return AppException(
          code: 'permission',
          message: 'No tienes permisos para realizar esta operación.',
          retryable: false,
        );
      }
      return AppException(
        code: 'firebase',
        message: error.message ?? 'Error de servicio. Intenta nuevamente.',
        retryable: true,
      );
    }

    final raw = error.toString();
    if (raw.contains('SocketException') || raw.contains('connection')) {
      return AppException(
        code: 'offline',
        message: 'Sin conexión a internet. Revisa tu red e intenta nuevamente.',
        retryable: true,
      );
    }

    if (raw.toLowerCase().contains('the caller does not have permission') ||
        raw.toLowerCase().contains('permission-denied')) {
      return AppException(
        code: 'permission',
        message: 'No tienes permisos para realizar esta operación.',
        retryable: false,
      );
    }

    return AppException(
      code: 'unknown',
      message: 'Ocurrió un error inesperado. Intenta nuevamente.',
      retryable: true,
    );
  }
}
