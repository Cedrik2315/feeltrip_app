import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:feeltrip_app/screens/feed_screen.dart'; // Example home screen
import 'package:feeltrip_app/screens/agency_profile_screen.dart'; // For /agency/:id
import 'package:feeltrip_app/screens/auth_gate.dart'; // For authentication flow
import 'package:feeltrip_app/screens/comments_screen.dart';
import 'package:feeltrip_app/screens/stories_screen.dart';
import 'package:feeltrip_app/screens/search_screen.dart';
import 'package:feeltrip_app/screens/profile_screen.dart';
import 'package:feeltrip_app/screens/notifications_screen.dart';
import 'package:feeltrip_app/screens/creator_stats_screen.dart';
import 'package:feeltrip_app/screens/instagram_stories_screen.dart';
import 'package:feeltrip_app/screens/trip_detail_screen.dart';
import 'package:feeltrip_app/screens/custom_map_screen.dart';

/// Provider para la instancia global de GoRouter.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const AuthGate(), // AuthGate para manejar el estado de autenticación inicial
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/comments/:id',
        builder: (BuildContext context, GoRouterState state) => CommentsScreen(storyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/agency/:id',
        builder: (BuildContext context, GoRouterState state) => AgencyProfileScreen(agencyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/stories',
        builder: (BuildContext context, GoRouterState state) => const StoriesScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (BuildContext context, GoRouterState state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (BuildContext context, GoRouterState state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/creator-stats',
        builder: (BuildContext context, GoRouterState state) => const CreatorStatsScreen(),
      ),
      GoRoute(
        path: '/instagram-stories',
        builder: (BuildContext context, GoRouterState state) => const InstagramStoriesScreen(),
      ),
      GoRoute(
        path: '/trip-details/:id',
        builder: (BuildContext context, GoRouterState state) => TripDetailScreen(tripId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/map',
        builder: (BuildContext context, GoRouterState state) => const CustomMapScreen(),
      ),
    ],
    // Puedes añadir manejo de errores, redirecciones, etc. aquí
  );
});