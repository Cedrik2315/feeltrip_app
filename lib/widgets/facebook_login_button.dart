import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class FacebookLoginButton extends StatelessWidget {
  FacebookLoginButton({super.key});

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1877F2),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      icon: const Icon(Icons.facebook, size: 28),
      label: const Text(
        'Continuar con Facebook',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        try {
          await _auth.signInWithFacebook();
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al iniciar sesión con Facebook'),
            ),
          );
          return;
        }
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      },
    );
  }
}
