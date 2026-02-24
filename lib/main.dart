import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'config/firebase_options.dart';
import 'constants/strings.dart';
import 'controllers/auth_controller.dart';
import 'controllers/diary_controller.dart';
import 'controllers/home_controller.dart';
import 'screens/diario_screen.dart';
import 'screens/experience_impact_dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/register_screen.dart';
import 'screens/stories_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'services/api_service.dart';
import 'services/admob_service.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/emotion_service.dart';
import 'services/observability_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('Archivo .env no encontrado, omitiendo...');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ObservabilityService.initialize();
  if (AdMobService.isSupported) {
    await MobileAds.instance.initialize();
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<EmotionService>(create: (_) => EmotionService()),
        ProxyProvider<AuthService, AuthController>(
          update: (_, authService, __) => AuthController(authService),
        ),
        ProxyProvider2<EmotionService, DatabaseService, DiaryController>(
          update: (_, emotionService, databaseService, __) => DiaryController(
            emotionService: emotionService,
            databaseService: databaseService,
          ),
        ),
        ProxyProvider<ApiService, HomeController>(
          update: (_, apiService, __) => HomeController(apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      navigatorObservers: [ObservabilityService.analyticsObserver],
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/diary': (_) => const DiarioScreen(),
        '/quiz': (_) => const QuizScreen(),
        '/stories': (_) => const StoriesScreen(),
        '/impact-dashboard': (_) => const ExperienceImpactDashboardScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/trip-details') {
          final tripId = settings.arguments as String?;
          if (tripId != null && tripId.isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => TripDetailScreen(tripId: tripId),
            );
          }
        }
        return null;
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthService>().user,
      builder: (context, snapshot) {
        final uid = snapshot.data?.uid;
        if (uid != null && uid.isNotEmpty) {
          ObservabilityService.setUserId(uid);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}


