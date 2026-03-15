import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/stories_screen.dart';
import 'screens/travel_diary_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/emotional_preferences_quiz_screen.dart';
import 'screens/experience_impact_dashboard_screen.dart';
import 'screens/comments_screen.dart';
import 'screens/premium_subscription_screen.dart';
import 'screens/creator_stats_screen.dart';
import 'screens/translator_screen.dart';
import 'screens/ocr_screen.dart';
import 'screens/instagram_stories_screen.dart';
import 'screens/agency_profile_screen.dart';
import 'screens/reels_screen.dart';
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (e) {
    // log eliminado: ⚠️ Warning: Could not load .env file: $e
  }
  await FirebaseConfig.initialize();
  runApp(const FeelTripApp());
}

class FeelTripApp extends StatelessWidget {
  const FeelTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FeelTrip - Agencia de Viajes',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.deepPurple,
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.deepPurple,
            side: const BorderSide(color: Colors.deepPurple),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const MainApp(),
        '/search': (context) => SearchScreen(),
        '/cart': (context) => CartScreen(),
        '/bookings': (context) => BookingsScreen(),
        '/profile': (context) => ProfileScreen(),
        '/stories': (context) => const StoriesScreen(),
        '/diary': (context) => const TravelDiaryScreen(),
        '/feed': (context) => const FeedScreen(),
        '/quiz': (context) => EmotionalPreferencesQuizScreen(),
        '/impact-dashboard': (context) => ExperienceImpactDashboardScreen(),
        '/comments': (context) => CommentsScreen(storyId: ''),
        '/premium': (context) => const PremiumSubscriptionScreen(),
        '/creator-stats': (context) => const CreatorStatsScreen(),
        '/translator': (context) => const TranslatorScreen(),
        '/ocr': (context) => const OCRScreen(),
        '/instagram-stories': (context) => const InstagramStoriesScreen(),
        '/agency-profile': (context) => AgencyProfileScreen(agencyId: ''),
        '/reels': (context) => const ReelsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/trip-details') {
          final tripId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => TripDetailScreen(tripId: tripId),
          );
        }
        if (settings.name == '/comments') {
          final storyId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => CommentsScreen(storyId: storyId ?? ''),
          );
        }
        if (settings.name == '/agency-profile') {
          final agencyId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => AgencyProfileScreen(agencyId: agencyId ?? ''),
          );
        }
        return null;
      },
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    SearchScreen(),
    CartScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
