// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'config/app_flags.dart';
import 'config/firebase_options.dart';
import 'config/release_metadata.dart';
import 'constants/strings.dart';
import 'controllers/auth_controller.dart';
import 'controllers/diary_controller.dart';
import 'controllers/experience_controller.dart';
import 'controllers/home_controller.dart';
import 'repositories/trip_repository.dart';
import 'screens/diario_screen.dart';
import 'screens/preview_entry_screen.dart';
import 'screens/smart_camera_screen.dart';
import 'screens/experience_impact_dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/register_screen.dart';
import 'screens/search_screen.dart';
import 'screens/stories_screen.dart';
import 'screens/auth_gate.dart';
import 'screens/splash_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/terms_and_conditions_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/premium_subscription_screen.dart';
import 'services/api_service.dart';
import 'services/admob_service.dart';
import 'services/achievements_service.dart';
import 'services/auth_service.dart';
import 'services/consent_service.dart';
import 'services/database_service.dart';
import 'services/diary_service.dart';
import 'services/emotion_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'services/story_service.dart';
import 'services/travel_service.dart';
import 'services/cart_service.dart';
import 'services/mercado_pago_service.dart';
import 'services/purchase_service.dart';
import 'services/deep_link_service.dart';
import 'controllers/cart_controller.dart';
import 'controllers/premium_controller.dart';
import 'services/observability_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseInitialized = false;

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
    firebaseInitialized = true;
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
    await ObservabilityService.setReleaseContext(
      env: appEnv,
      version: appVersionLabel,
    );
    await ObservabilityService.logAppStartup(
      env: appEnv,
      version: appVersionLabel,
      firebaseReady: firebaseInitialized,
    );
    debugPrint('ObservabilityService inicializado');
  } catch (e, st) {
    debugPrint('ERROR en ObservabilityService: $e');
    debugPrint('Stack trace: $st');
    await ObservabilityService.recordNonFatal(
      e,
      st,
      reason: 'observability_init_failure',
    );
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
    await ObservabilityService.recordNonFatal(
      e,
      st,
      reason: 'consent_init_failure',
    );
  }

  // Inicializar DeepLinkService
  try {
    debugPrint('Inicializando DeepLinkService...');
    await DeepLinkService().initialize();
    debugPrint('DeepLinkService inicializado');
  } catch (e, st) {
    debugPrint('ERROR en DeepLinkService: $e');
    debugPrint('Stack trace: $st');
  }

  debugPrint('Ejecutando runApp...');

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, api) => api.dispose(),
        ),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<EmotionService>(create: (_) => EmotionService()),
        Provider<StoryService>(create: (_) => StoryService()),
        Provider<DiaryService>(create: (_) => DiaryService()),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<CartService>(create: (_) => CartService()),
        Provider<PurchaseService>(
          create: (_) => PurchaseService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<TravelService>(create: (_) => TravelService()),
        Provider<DiaryAchievementsService>(
            create: (_) => DiaryAchievementsService()),
        Provider<AchievementService>(create: (_) => AchievementService()),
        ChangeNotifierProvider(
          create: (context) => DiaryController(
            emotionService: context.read<EmotionService>(),
            databaseService: context.read<DatabaseService>(),
            locationService: context.read<LocationService>(),
            storageService: context.read<StorageService>(),
            diaryAchievementsService: context.read<DiaryAchievementsService>(),
            achievementService: context.read<AchievementService>(),
          ),
        ),
        Provider<TripRepository>(create: (_) => TripRepository()),
        ProxyProvider<TripRepository, HomeController>(
          update: (_, tripRepository, __) => HomeController(tripRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Set up deep link callback for navigation
    _setupDeepLinkHandler();
  }

  void _setupDeepLinkHandler() {
    DeepLinkService().onDeepLinkReceived = (Uri uri) {
      // Parse the deep link and navigate
      final navData = DeepLinkService().parseDeepLink(uri);
      if (navData != null) {
        final path = navData['path'] as String;
        final args = navData['arguments'] as Map<String, dynamic>?;

        debugPrint('DeepLink: Navigating to $path with args: $args');

        // Use GetX to navigate
        if (Get.key.currentState != null) {
          switch (path) {
            case '/story':
              if (args != null && args['storyId'] != null) {
                // Navigate to stories screen with story ID
                Get.toNamed('/stories', arguments: args);
              }
              break;
            case '/agency':
              if (args != null && args['agencyId'] != null) {
                Get.toNamed('/home', arguments: args);
              }
              break;
            case '/trip':
              if (args != null && args['tripId'] != null) {
                Get.toNamed('/trip-details', arguments: args['tripId']);
              }
              break;
            case '/join':
              if (args != null && args['referralCode'] != null) {
                // Handle referral - navigate to home with referral code
                Get.toNamed('/home', arguments: args);
              }
              break;
            case '/experience':
              if (args != null && args['experienceId'] != null) {
                Get.toNamed('/impact-dashboard', arguments: args);
              }
              break;
            default:
              Get.toNamed('/home');
          }
        }
      }
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inyectar ExperienceController con GetX
    Get.lazyPut(() => AuthController(
          context.read<AuthService>(),
        ));
    Get.lazyPut(() => ExperienceController(
          storyService: context.read<StoryService>(),
          diaryService: context.read<DiaryService>(),
          storageService: context.read<StorageService>(),
        ));
    Get.lazyPut(() => CartController(
          context.read<AuthService>(),
          context.read<CartService>(),
          MercadoPagoService(), // Assuming it's stateless
        ));
    Get.lazyPut(() => PremiumController(context.read<PurchaseService>()));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
      navigatorObservers: [
        ObservabilityService.analyticsObserver
      ], // Asegúrate de que esta línea esté correcta
      home: const SplashScreen(),
      routes: {
        '/auth_gate': (_) => const AuthGate(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/search': (_) => const SearchScreen(),
        '/cart': (_) => const CartScreen(),
        '/bookings': (_) => const BookingsScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/diary': (_) => const DiarioScreen(),
        '/smart-camera': (_) => const SmartCameraScreen(),
        '/preview-entry': (_) => const PreviewEntryScreen(),
        '/quiz': (_) => const QuizScreen(),
        '/stories': (_) => const StoriesScreen(),
        '/impact-dashboard': (_) => const ExperienceImpactDashboardScreen(),
        '/premium': (_) => const PremiumSubscriptionScreen(),
        '/terms': (_) => const TermsAndConditionsScreen(),
        '/privacy': (_) => const PrivacyPolicyScreen(),
        '/trip-details': (context) {
          // Extrae el ID del viaje de los argumentos de la ruta
          final tripId = ModalRoute.of(context)!.settings.arguments as String;
          return TripDetailScreen(tripId: tripId);
        },
      },
    );
  }
}
