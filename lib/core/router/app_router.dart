import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/features/premium/presentation/providers/premium_notifier.dart';

// IMPORTANTE: Asegúrate de que este archivo exista o crea una clase sencilla abajo
// import 'package:feeltrip_app/features/notifications/presentation/screens/notifications_screen.dart'; 

import 'route_names.dart';

/// Unificamos la lógica de redirección global para evitar repeticiones
String? _globalRedirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authNotifierProvider);
  final bool isLoggedIn = authState.valueOrNull != null;
  final bool isLoggingIn = state.matchedLocation == RouteNames.login;
  final bool isInsideSplash = state.matchedLocation == RouteNames.splash;

  if (isInsideSplash) return null;

  // Si no está logueado y trata de entrar a una ruta protegida
  if (!isLoggedIn && !isLoggingIn) {
    return RouteNames.login;
  }

  // Si ya está logueado y trata de ir al login
  if (isLoggedIn && isLoggingIn) {
    return RouteNames.home; // O la ruta principal que uses
  }

  return null;
}

GoRouter createAppRouter(Ref ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    // Escuchamos los cambios de auth para que el router reaccione automáticamente
    refreshListenable: Listenable.merge([
      // Aquí podrías añadir un ValueNotifier si fuera necesario, 
      // pero Riverpod suele manejarse mejor con el redirect interno.
    ]),
    redirect: (context, state) => _globalRedirect(ref, state),
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const PlaceholderScreen(name: 'Splash'),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const PlaceholderScreen(name: 'Onboarding'),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const PlaceholderScreen(name: 'Login'),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const PlaceholderScreen(name: 'Home'),
      ),
      GoRoute(
        path: RouteNames.premium,
        builder: (context, state) => const PlaceholderScreen(name: 'Premium'),
        redirect: (context, state) {
          final premium = ref.read(premiumNotifierProvider);
          // Si no es premium, lo mandamos a la pantalla de upgrade
          return (!premium.isPremium) ? '/upgrade' : null;
        },
      ),
      GoRoute(
        path: RouteNames.diario,
        builder: (context, state) => const PlaceholderScreen(name: 'Diario'),
      ),
      GoRoute(
        path: RouteNames.notifications,
        // SOLUCIÓN AL ERROR: Si aún no tienes la pantalla real, usa PlaceholderScreen
        // Una vez que la crees, importa el archivo y cambia esta línea.
        builder: (context, state) => const PlaceholderScreen(name: 'Notifications'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
}

// --- Mantenemos tu Placeholder para evitar errores de compilación mientras desarrollas ---
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(child: Text('Pantalla temporal: $name')),
    );
  }
}