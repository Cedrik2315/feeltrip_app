import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feeltrip_app/features/premium/presentation/screens/premium_screen.dart';
import 'package:feeltrip_app/screens/agency_profile_screen.dart';
import 'package:feeltrip_app/screens/bookings_screen.dart';
import 'package:feeltrip_app/screens/comments_screen.dart';
import 'package:feeltrip_app/screens/creator_stats_screen.dart';
import 'package:feeltrip_app/screens/custom_map_screen.dart';
import 'package:feeltrip_app/features/city_mode/presentation/city_mode_screen.dart';
import 'package:feeltrip_app/screens/diary_screen.dart';
import 'package:feeltrip_app/screens/emotional_preferences_quiz_screen.dart';
import 'package:feeltrip_app/screens/emotional_results_screen.dart';
import 'package:feeltrip_app/screens/feed_screen.dart';
import 'package:feeltrip_app/screens/reels_screen.dart';
import 'package:feeltrip_app/screens/forgot_password_screen.dart';
import 'package:feeltrip_app/screens/user_preferences.dart';
import 'package:feeltrip_app/screens/home_screen.dart';
import 'package:feeltrip_app/screens/instagram_stories_screen.dart';
import 'package:feeltrip_app/screens/login_screen.dart';
import 'package:feeltrip_app/screens/manifesto_screen.dart';
import 'package:feeltrip_app/screens/notifications_screen.dart';
import 'package:feeltrip_app/screens/ocr_screen.dart';
import 'package:feeltrip_app/screens/onboarding_screen.dart';
import 'package:feeltrip_app/screens/privacy_policy_screen.dart';
import 'package:feeltrip_app/screens/terms_screen.dart';
import 'package:feeltrip_app/screens/register_screen.dart';
import 'package:feeltrip_app/features/search/presentation/screens/search_screen.dart';
import 'package:feeltrip_app/screens/welcome_screen.dart';
import 'package:feeltrip_app/screens/stories_screen.dart';
import 'package:feeltrip_app/screens/translator_screen.dart';
import 'package:feeltrip_app/screens/trip_detail_screen.dart';
import 'package:feeltrip_app/screens/travel_diary_screen.dart';
import 'package:feeltrip_app/screens/travel_suggestions_screen.dart';
import 'package:feeltrip_app/screens/referral_screen.dart';
import 'package:feeltrip_app/screens/auth_gate.dart';
import 'package:feeltrip_app/screens/metrics_dashboard_screen.dart';
import 'package:feeltrip_app/screens/wear_os_companion_screen.dart';
import 'package:feeltrip_app/screens/scout_agent_screen.dart';
import 'package:feeltrip_app/screens/proof_of_expedition_screen.dart';
import 'package:feeltrip_app/features/merchandising/presentation/artifact_lab_screen.dart';
import 'package:feeltrip_app/features/merchandising/presentation/impact_summary_screen.dart';
import 'package:feeltrip_app/features/merchandising/presentation/memory_wall_screen.dart';
import 'package:feeltrip_app/services/emotional_engine_service.dart';

GoRouter createAppRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/welcome',
    debugLogDiagnostics: true, // Útil para ver qué pasa en la consola durante el desarrollo
    routes: [
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) => const AuthGate(),
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
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
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
        path: '/wear-companion',
        name: 'wear-companion',
        builder: (context, state) => const WearOSCompanionScreen(),
      ),
      GoRoute(
        path: '/emotional-prediction',
        name: 'emotional-prediction',
        builder: (context, state) => const ScoutAgentScreen(),
      ),
      GoRoute(
        path: '/proof-of-expedition',
        name: 'proof-of-expedition',
        builder: (context, state) => const ProofOfExpeditionScreen(),
      ),
      GoRoute(
        path: '/comments/:id',
        name: 'comments',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CommentsScreen(storyId: id);
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
        builder: (context, state) => TravelSuggestionsScreen(
          prediction: state.extra as EmotionalPrediction?,
        ),
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: '/quiz',
        name: 'quiz',
        builder: (context, state) => const EmotionalPreferencesQuizScreen(),
      ),
      GoRoute(
        path: '/emotional-results',
        name: 'emotional-results',
        builder: (context, state) {
          final analysis = state.extra as EmotionalAnalysis;
          return EmotionalResultsScreen(analysis: analysis);
        },
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
        path: '/feed',
        name: 'feed',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/reels',
        name: 'reels',
        builder: (context, state) => const ReelsScreen(title: 'FEELTRIP REELS'),
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) => const CustomMapScreen(),
      ),
      GoRoute(
        path: '/city-mode',
        name: 'city-mode',
        builder: (context, state) => const CityModeScreen(),
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
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/manifesto',
        name: 'manifesto',
        builder: (context, state) => const ManifestoScreen(),
      ),
      GoRoute(
        path: '/referral',
        name: 'referral',
        builder: (context, state) => const ReferralScreen(),
      ),
      GoRoute(
        path: '/metrics',
        name: 'metrics',
        builder: (context, state) => const MetricsDashboardScreen(),
      ),
      GoRoute(
        path: '/artifact-lab/:viajeId',
        name: 'artifact-lab',
        builder: (context, state) {
          final viajeId = int.tryParse(state.pathParameters['viajeId'] ?? '0') ?? 0;
          return ArtifactLabScreen(viajeId: viajeId);
        },
      ),
      GoRoute(
        path: '/artifact-summary/:viajeId',
        name: 'artifact-summary',
        builder: (context, state) {
          final viajeId = int.tryParse(state.pathParameters['viajeId'] ?? '0') ?? 0;
          return ImpactSummaryScreen(viajeId: viajeId);
        },
      ),
      GoRoute(
        path: '/memory-wall',
        name: 'memory-wall',
        builder: (context, state) => const MemoryWallScreen(),
      ),
    ],
    errorBuilder: (context, state) => _PlaceholderScreen(
      title: 'Ruta no disponible',
      message: 'No encontramos ${state.uri}.',
    ),
  );
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