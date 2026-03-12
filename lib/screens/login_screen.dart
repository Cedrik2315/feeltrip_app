import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../controllers/auth_controller.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.find();
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _runSignIn(Future<void> Function() action) async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);

    try {
      await action().timeout(const Duration(seconds: 45));
      if (!mounted) return;
      Get.offAll(() => const HomeScreen());
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El inicio de sesión tardó demasiado. Revisa tu conexión e inténtalo de nuevo.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(message.isEmpty ? 'No se pudo iniciar sesión' : message),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define un estilo de texto base para los botones.
    const buttonTextStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    // Estilo base para los botones de login para mantener consistencia.
    final baseButtonStyle = ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        textStyle: buttonTextStyle);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/tromso_aurora.png'),
                  fit: BoxFit.cover,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 120),
                  const SizedBox(height: 28),
                  GoogleSignInButton(
                    onPressed: _isSigningIn
                        ? null
                        : () => _runSignIn(_authController.loginWithGoogle),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _isSigningIn
                        ? null
                        : () => _runSignIn(_authController.loginWithFacebook),
                    icon: Icon(
                      Icons.facebook,
                      color: Colors.white,
                      size: buttonTextStyle.fontSize! * 1.4,
                    ),
                    label: Text(_isSigningIn
                        ? 'Iniciando sesión...'
                        : 'Continuar con Facebook'),
                    style: baseButtonStyle.copyWith(
                      backgroundColor:
                          WidgetStateProperty.all(const Color(0xFF1877F2)),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white54)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'O',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white54)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isSigningIn
                        ? null
                        : () => Get.offAll(() => const HomeScreen()),
                    child: const Text(
                      'Continuar como invitado',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta?',
                          style: TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: _isSigningIn
                            ? null
                            : () => Get.to(() => const RegisterScreen()),
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _isSigningIn
                        ? null
                        : () {
                            Get.snackbar(
                              'Próximamente',
                              'La recuperación de contraseña estará disponible pronto.',
                            );
                          },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
