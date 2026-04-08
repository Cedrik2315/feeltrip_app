import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:feeltrip_app/features/premium/presentation/screens/premium_screen.dart';
import 'package:feeltrip_app/screens/agency_profile_screen.dart';
import 'package:feeltrip_app/screens/bookings_screen.dart';
import 'package:feeltrip_app/screens/cart_screen.dart';
import 'package:feeltrip_app/screens/comments_screen.dart';
import 'package:feeltrip_app/screens/creator_stats_screen.dart';
import 'package:feeltrip_app/screens/diary_screen.dart';
import 'package:feeltrip_app/screens/emotional_preferences_quiz_screen.dart';
import 'package:feeltrip_app/screens/feed_screen.dart';
import 'package:feeltrip_app/screens/forgot_password_screen.dart';
import 'package:feeltrip_app/screens/home_screen.dart';
import 'package:feeltrip_app/screens/instagram_stories_screen.dart';
import 'package:feeltrip_app/screens/login_screen.dart';
import 'package:feeltrip_app/screens/metrics_dashboard_screen.dart';
import 'package:feeltrip_app/screens/notifications_screen.dart';
import 'package:feeltrip_app/screens/ocr_screen.dart';
import 'package:feeltrip_app/screens/onboarding_screen.dart';
import 'package:feeltrip_app/screens/register_screen.dart';
import 'package:feeltrip_app/features/search/presentation/screens/search_screen.dart';
import 'package:feeltrip_app/screens/welcome_screen.dart'; // Import de la nueva pantalla
import 'package:feeltrip_app/screens/stories_screen.dart';
import 'package:feeltrip_app/screens/translator_screen.dart';
import 'package:feeltrip_app/screens/trip_detail_screen.dart';
// import 'package:feeltrip_app/screens/my_itineraries_screen.dart';
// import 'package:feeltrip_app/screens/transformation_history_screen.dart';
import 'package:feeltrip_app/screens/travel_diary_screen.dart';
import 'package:feeltrip_app/screens/travel_suggestions_screen.dart';

GoRouter createAppRouter(Ref ref) {
  return GoRouter(
    // El sistema inicia ahora con la experiencia cinematográfica
    initialLocation: '/welcome', 
    routes: [
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) => const _LaunchGate(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/bookings',
        name: 'bookings',
        builder: (context, state) => const BookingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/creator-stats',
        name: 'creator-stats',
        builder: (context, state) => const CreatorStatsScreen(),
      ),
      GoRoute(
        path: '/instagram-stories',
        name: 'instagram-stories',
        builder: (context, state) => const InstagramStoriesScreen(),
      ),
      GoRoute(
        path: '/translator',
        name: 'translator',
        builder: (context, state) => TranslatorScreen(
          initialText: state.extra as String?,
        ),
      ),
      GoRoute(
        path: '/ocr',
        name: 'ocr',
        builder: (context, state) => const OCRScreen(),
      ),
      GoRoute(
        path: '/comments/:storyId',
        name: 'comments',
        builder: (context, state) {
          final storyId = state.pathParameters['storyId'] ?? '';
          return CommentsScreen(storyId: storyId);
        },
      ),
      GoRoute(
        path: '/diary',
        name: 'diary',
        builder: (context, state) => const DiaryScreen(),
      ),
      GoRoute(
        path: '/diary/capture',
        name: 'diary-capture',
        builder: (context, state) => const TravelDiaryScreen(),
      ),
      GoRoute(
        path: '/suggestions',
        name: 'suggestions',
        builder: (context, state) => const TravelSuggestionsScreen(),
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      // GoRoute(
      //   path: '/my-itineraries',
      //   name: 'my-itineraries',
      //   builder: (context, state) => const MyItinerariesScreen(),
      // ),
      // GoRoute(
      //   path: '/transformation-history',
      //   name: 'transformation-history',
      //   builder: (context, state) => const TransformationHistoryScreen(),
      // ),
      GoRoute(
        path: '/quiz',
        name: 'quiz',
        builder: (context, state) => const EmotionalPreferencesQuizScreen(),
      ),
      GoRoute(
        path: '/agency/:agencyId',
        name: 'agency',
        builder: (context, state) {
          final agencyId = state.pathParameters['agencyId'] ?? '';
          return AgencyProfileScreen(agencyId: agencyId);
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/stories',
        name: 'stories',
        builder: (context, state) => const StoriesScreen(),
      ),
      GoRoute(
        path: '/impact-dashboard',
        name: 'impact-dashboard',
        builder: (context, state) => const MetricsDashboardScreen(),
      ),
      GoRoute(
        path: '/feed',
        name: 'feed',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/trip-details/:tripId',
        name: 'trip-details',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId'] ?? '';
          return TripDetailScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ],
    errorBuilder: (context, state) => _PlaceholderScreen(
      title: 'Ruta no disponible',
      message: 'No encontramos ${state.uri}.',
    ),
  );
}
class _LaunchGate extends StatelessWidget {
  const _LaunchGate();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.message});
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(message)),
    );
  }
}