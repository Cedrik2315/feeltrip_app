import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'config/firebase_options.dart';
import 'constants/strings.dart';
import 'controllers/auth_controller.dart';
import 'controllers/diary_controller.dart';
import 'controllers/experience_controller.dart';
import 'controllers/home_controller.dart';
import 'screens/diary_screen.dart';
import 'screens/experience_impact_dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/register_screen.dart';
import 'screens/stories_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'services/api_service.dart';
import 'services/admob_service.dart';
import 'services/auth_service.dart';
import 'services/consent_service.dart';
import 'services/database_service.dart';
import 'services/diary_service.dart';
import 'services/emotion_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'services/story_service.dart';
import 'services/travel_service.dart';
import 'services/observability_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('=== INICIANDO APP ===');

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('.env cargado correctamente');
  } catch (e) {
    debugPrint('Archivo .env no encontrado, omitiendo...: $e');
  }

  // Inicializar Firebase
  try {
    debugPrint('Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase inicializado correctamente');
  } catch (e, st) {
    debugPrint('ERROR inicializando Firebase: $e');
    debugPrint('Stack trace: $st');
    // Continuar sin Firebase para diagnóstico
  }

  // Inicializar servicios de observabilidad
  try {
    debugPrint('Inicializando ObservabilityService...');
    await ObservabilityService.initialize();
    debugPrint('ObservabilityService inicializado');
  } catch (e, st) {
    debugPrint('ERROR en ObservabilityService: $e');
    debugPrint('Stack trace: $st');
  }

  // Inicializar anuncios (solo si es Android/iOS)
  try {
    if (AdMobService.isSupported) {
      debugPrint('Inicializando ConsentService para anuncios...');
      await ConsentService.initializeAdsIfPermitted();
      debugPrint('ConsentService inicializado');
    }
  } catch (e, st) {
    debugPrint('ERROR en ConsentService: $e');
    debugPrint('Stack trace: $st');
  }

  debugPrint('Ejecutando runApp...');

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<EmotionService>(create: (_) => EmotionService()),
        Provider<StoryService>(create: (_) => StoryService()),
        Provider<DiaryService>(create: (_) => DiaryService()),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<TravelService>(create: (_) => TravelService()),
        ProxyProvider<AuthService, AuthController>(
          update: (_, authService, __) => AuthController(authService),
        ),
        ChangeNotifierProvider(
          create: (context) => DiaryController(
            emotionService: context.read<EmotionService>(),
            databaseService: context.read<DatabaseService>(),
            locationService: context.read<LocationService>(),
            storageService: context.read<StorageService>(),
          ),
        ),
        ProxyProvider<ApiService, HomeController>(
          update: (_, apiService, __) => HomeController(apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => ExperienceController(
            storyService: context.read<StoryService>(),
            diaryService: context.read<DiaryService>(),
          ),
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'), // Español
        Locale('en'), // Inglés (futuro)
      ],
      navigatorObservers: [ObservabilityService.analyticsObserver],
      home: const AuthGate(),
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/diary': (_) => const DiaryScreen(),
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
    // Timeout de 10 segundos para evitar pantalla negra infinita
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _timeoutReached = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthService>().user,
      builder: (context, snapshot) {
        final uid = snapshot.data?.uid;
        if (uid != null && uid.isNotEmpty) {
          ObservabilityService.setUserId(uid);
        }

        debugPrint(
            'AuthGate - connectionState: ${snapshot.connectionState}, hasError: ${snapshot.hasError}, error: ${snapshot.error}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          if (_timeoutReached) {
            // Si pasó el timeout, mostrar opción de continuar sin autenticación
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Tiempo de espera de autenticación excedido'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text('Continuar a Login'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint('AuthGate error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Continuar a Login'),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.data != null) {
          return const HomeScreen();
        }

        return const OnboardingScreen();
      },
    );
  }
}
