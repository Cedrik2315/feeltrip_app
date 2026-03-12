import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/observability_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

/// AuthGate es el "portero" de la autenticación.
///
/// Decide qué pantalla mostrar al usuario basado en su estado de autenticación
/// con Firebase. Maneja los estados de carga, error y éxito.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _timeoutReached = false;

  @override
  void initState() {
    super.initState();
    // Timeout de 10 segundos para evitar que el usuario se quede en una
    // pantalla de carga infinita si la autenticación no responde.
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _timeoutReached = true;
        });
      }
    });
  }

  /// Construye la vista de error que se muestra si el stream de autenticación falla.
  Widget _buildErrorView(String errorMessage) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Ocurrió un error',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Ir a Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la vista de carga, con una opción de escape si tarda demasiado.
  Widget _buildLoadingView({bool withTimeoutMessage = false}) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text('Verificando sesión...'),
              if (withTimeoutMessage) ...[
                const SizedBox(height: 24),
                const Text(
                  'La verificación está tardando más de lo esperado.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Continuar a Login'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthService>().userStream,
      builder: (context, snapshot) {
        final uid = snapshot.data?.uid;
        if (uid != null && uid.isNotEmpty) {
          ObservabilityService.setUserId(uid);
        }

        if (snapshot.hasError) {
          ObservabilityService.logAuthGateState('error_auth_stream');
          debugPrint('AuthGate error: ${snapshot.error}');
          return _buildErrorView(
              'No pudimos verificar tu sesión. Por favor, intenta iniciar sesión de nuevo.');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          if (_timeoutReached) {
            ObservabilityService.logAuthGateState('timeout_waiting_auth');
            return _buildLoadingView(withTimeoutMessage: true);
          }
          return _buildLoadingView();
        }

        if (snapshot.data != null) {
          ObservabilityService.logAuthGateState('authenticated');
          return const HomeScreen();
        }

        ObservabilityService.logAuthGateState('anonymous');
        return const OnboardingScreen();
      },
    );
  }
}
