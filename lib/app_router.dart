import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/core/router/route_names.dart';

import 'package:feeltrip_app/screens/splash_screen.dart';
import 'package:feeltrip_app/screens/onboarding_screen.dart';
import 'package:feeltrip_app/screens/login_screen.dart';
import 'package:feeltrip_app/screens/home_screen.dart';
import 'package:feeltrip_app/screens/agency_profile_screen.dart';
import 'package:feeltrip_app/screens/stories_screen.dart';
import 'package:feeltrip_app/screens/comments_screen.dart';
import 'package:feeltrip_app/screens/premium_subscription_screen.dart';
import 'package:feeltrip_app/screens/travel_diary_screen.dart';
import 'package:feeltrip_app/screens/notifications_screen.dart';
import 'package:feeltrip_app/screens/smart_camera_screen.dart';

String? _globalRedirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authNotifierProvider);
  final bool isLoggedIn = authState.valueOrNull != null;
  final bool isLoggingIn = state.matchedLocation == RouteNames.login;
  final bool isInsideSplash = state.matchedLocation == RouteNames.splash;

  if (isInsideSplash) return null;

  if (!isLoggedIn && !isLoggingIn) {
    return RouteNames.login;
  }

  if (isLoggedIn && isLoggingIn) {
    return RouteNames.home;
  }

  return null;
}

GoRouter createAppRouter(Ref ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: Listenable.merge([]),
    redirect: (context, state) => _globalRedirect(ref, state),
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
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
        path: RouteNames.smartCamera,
        builder: (context, state) => const SmartCameraScreen(),
      ),
      GoRoute(
        path: RouteNames.agencyDetail,
        builder: (context, state) {
          final agencyId = state.pathParameters['agencyId']!;
          return AgencyProfileScreen(agencyId: agencyId);
        },
      ),
      GoRoute(
        path: RouteNames.storyDetail,
        builder: (context, state) {
          final storyId = state.pathParameters['storyId']!;
          return StoriesScreen(tripId: storyId);
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
        path: '/premium-subscription',
        builder: (context, state) => const PremiumSubscriptionScreen(),
      ),
      GoRoute(
        path: RouteNames.travelDiary,
        builder: (context, state) => const TravelDiaryScreen(),
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
