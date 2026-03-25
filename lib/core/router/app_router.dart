import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';

// IMPORTANTE: AsegÃºrate de que este archivo exista o crea una clase sencilla abajo
// import 'package:feeltrip_app/features/notifications/presentation/screens/notifications_screen.dart';

import '../../screens/home_screen.dart';
import '../../screens/comments_screen.dart';

import 'route_names.dart';

/// Unificamos la lÃ³gica de redirecciÃ³n global para evitar repeticiones
String? _globalRedirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authNotifierProvider);
  final bool isLoggedIn = authState.valueOrNull != null;
  final bool isLoggingIn = state.matchedLocation == RouteNames.login;
  final bool isInsideSplash = state.matchedLocation == RouteNames.splash;

  if (isInsideSplash) return null;

  // Si no estÃ¡ logueado y trata de entrar a una ruta protegida
  if (!isLoggedIn && !isLoggingIn) {
    return RouteNames.login;
  }

  // Si ya estÃ¡ logueado y trata de ir al login
  if (isLoggedIn && isLoggingIn) {
    return RouteNames.home; // O la ruta principal que uses
  }

  return null;
}

GoRouter createAppRouter(Ref ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    // Escuchamos los cambios de auth para que el router reaccione automÃ¡ticamente
    refreshListenable: Listenable.merge([
      // AquÃ­ podrÃ­as aÃ±adir un ValueNotifier si fuera necesario,
      // pero Riverpod suele manejarse mejor con el redirect interno.
    ]),
    redirect: (context, state) => _globalRedirect(ref, state),
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) =>
            const SplashScreen(), // Replace Placeholder
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.agencyDetail,
        builder: (context, state) {
          final agencyId = state.pathParameters['agencyId']!;
          return AgencyProfileScreen(agencyId: agencyId);
        },
        redirect: (context, state) async {
          final container = ProviderContainer();
          final agencyService = AgencyService();
          final agency = await agencyService
              .getAgencyById(state.pathParameters['agencyId']!);
          container.dispose();
          return agency == null ? RouteNames.home : null;
        },
      ),
      GoRoute(
        path: RouteNames.storyDetail,
        builder: (context, state) {
          final storyId = state.pathParameters['storyId']!;
          return StoriesScreen(storyId: storyId);
        },
      ),
      GoRoute(
        path: RouteNames.commentsDetail,
        builder: (context, state) {
          final storyId = state.pathParameters['storyId']!;
          return CommentsScreen(storyId: storyId);
        },
      ),
      GoRoute(
        path: RouteNames.premium,
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: RouteNames.diario,
        builder: (context, state) => const DiarioScreen(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
}

// --- Mantenemos tu Placeholder para evitar errores de compilaciÃ³n mientras desarrollas ---
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

// --- Missing Classes Stubs ---

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(name: 'Splash');
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(name: 'Onboarding');
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(name: 'Login');
}

class AgencyProfileScreen extends StatelessWidget {
  const AgencyProfileScreen({super.key, required this.agencyId});
  final String agencyId;

  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(name: 'Agency $agencyId');
}

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key, required this.storyId});
  final String storyId;

  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(name: 'Story $storyId');
}

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(name: 'Premium');
}

class DiarioScreen extends StatelessWidget {
  const DiarioScreen({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderScreen(name: 'Diario');
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(name: 'Notifications');
}

class AgencyService {
  Future<dynamic> getAgencyById(String id) async => null;
}
