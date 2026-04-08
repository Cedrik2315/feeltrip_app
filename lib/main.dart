import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:feeltrip_app/config/firebase_config.dart';
import 'package:feeltrip_app/core/di/providers.dart' hide syncServiceProvider;
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/features/profile/presentation/profile_controller.dart';
import 'package:feeltrip_app/services/chronicle_repository_impl.dart';
import 'package:feeltrip_app/services/isar_service.dart';
import 'package:feeltrip_app/services/revenuecat_service.dart';
import 'package:feeltrip_app/services/sync_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
    await RevenueCatService().init();
  } catch (_) {
    // Optional .env file.
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await FirebaseConfig.initialize();

  // Firebase App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(
      dotenv.env['RECAPTCHA_SITE_KEY'] ?? 'recaptcha-v3-site-key',
    ),
  );

  // Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = (FlutterErrorDetails details) async {
    await FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Centralized Initialization via Singletons
  final isar = IsarService();
  await isar.init();

  final syncService = SyncService();
  await syncService.init(isar);

  final sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';
  
  final app = ProviderScope(
    overrides: [
      chronicleApiKeyProvider.overrideWithValue(dotenv.env['CHRONICLE_API_KEY'] ?? ''),
    ],
    child: const FeelTripApp(),
  );

  if (sentryDsn.isEmpty) {
    runApp(app);
    return;
  }

  await SentryFlutter.init(
    (options) => options
      ..dsn = sentryDsn
      ..tracesSampleRate = 1.0
      ..environment = const String.fromEnvironment(
        'FLUTTER_ENV',
        defaultValue: 'development',
      ),
    appRunner: () => runApp(app),
  );
}

class FeelTripApp extends ConsumerStatefulWidget {
  const FeelTripApp({super.key});

  @override
  ConsumerState<FeelTripApp> createState() => _FeelTripAppState();
}

class _FeelTripAppState extends ConsumerState<FeelTripApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    ref.read(connectivityServiceProvider).monitorConnection();

    // Listener de notificaciones
    final notificationService = ref.read(notificationServiceProvider);
    notificationService.navigationStream.listen((Map<String, dynamic> payload) {
      final String? type = payload['type'] as String?;
      final String? id = payload['id'] as String?;
      if (type == null || id == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final router = ref.read(routerProvider);
        switch (type) {
          case 'story':
          case 'story_comments':
            router.go('/comments/$id');
            break;
          case 'booking':
          case 'booking_confirm':
            router.go('/bookings');
            break;
          default:
            router.go('/notifications');
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    // --- LÓGICA DE SINCRONIZACIÓN AUTOMÁTICA ---
    ref.listen(connectivityProvider, (previous, next) {
      next.whenData((result) {
        if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
          final user = ref.read(authNotifierProvider).value;
          if (user != null) {
            // Sincronizar perfil al recuperar conexión
            ref.read(profileControllerProvider.notifier).refreshProfile();
            ref.read(syncServiceProvider).syncUserEntries(user.id);
          }
        }
      });
    });

    return MaterialApp.router(
      title: 'FeelTrip - Viaja para recordar, no para mostrar',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: _buildAppTheme(),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal[800]!,
        primary: Colors.teal[800],
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal[800]!, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIconColor: Colors.teal[800],
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.teal[800],
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}