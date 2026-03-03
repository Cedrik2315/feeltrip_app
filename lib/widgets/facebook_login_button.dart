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
        final user = await _auth.iniciarSesionConFacebook();
        if (!context.mounted) return;

        if (user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al iniciar sesión con Facebook'),
            ),
          );
        }
      },
    );
  }
}
