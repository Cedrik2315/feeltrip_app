import 'package:flutter/material.dart';

class SnackBarController {
  static final SnackBarController _instance = SnackBarController._internal();
  factory SnackBarController() => _instance;
  SnackBarController._internal();

  void showError(BuildContext context, String message) {
    _show(context, message, Colors.red.shade700);
  }

  void showSuccess(BuildContext context, String message) {
    _show(context, message, Colors.green.shade700);
  }

  void showInfo(BuildContext context, String message) {
    _show(context, message, Colors.blue.shade700);
  }

  void _show(BuildContext context, String message, Color backgroundColor) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
