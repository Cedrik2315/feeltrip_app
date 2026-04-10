import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:feeltrip_app/config/firebase_config.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/features/profile/presentation/profile_controller.dart';
import 'package:feeltrip_app/services/isar_service.dart';
import 'package:feeltrip_app/services/revenuecat_service.dart';
import 'package:feeltrip_app/services/sync_service.dart';
import 'package:feeltrip_app/services/deep_link_service.dart'; // Importado de la raíz
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Provider for the Chronicle API Key, initialized as an empty string and overridden in main.
final chronicleApiKeyProvider = Provider<String>((ref) => throw UnimplementedError());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización paralela para mejorar el tiempo de carga
  await Future.wait([
    _loadEnvironmentAndOptionalServices(),
    _configureDeviceOrientation(),
  ]);

  final firebaseReady = await FirebaseConfig.initialize();
  
  if (firebaseReady) {
    await _configureFirebaseAppCheck();
    await _configureCrashReporting();
  } else {
    debugPrint('FeelTrip: Firebase no disponible; modo degradado activo.');
  }

  await _initializeLocalServices();

  final app = ProviderScope(
    overrides: [
      chronicleApiKeyProvider.overrideWithValue(
        dotenv.env['CHRONICLE_API_KEY'] ?? '',
      ),
    ],
    child: const FeelTripApp(),
  );

  await _runWithOptionalSentry(app);
}

// --- Métodos de Configuración del Sistema ---

Future<void> _loadEnvironmentAndOptionalServices() async {
  try {
    await dotenv.load();
    await RevenueCatService().init();
  } catch (e) {
    debugPrint('Error cargando entorno: $e');
  }
}

Future<void> _configureDeviceOrientation() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> _configureFirebaseAppCheck() {
  return FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(
      dotenv.env['RECAPTCHA_SITE_KEY'] ?? 'recaptcha-v3-site-key',
    ),
  );
}

Future<void> _configureCrashReporting() async {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> _initializeLocalServices() async {
  final isar = IsarService();
  await isar.init();
  await SyncService().init(isar);
}

Future<void> _runWithOptionalSentry(Widget app) async {
  final sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';
  if (sentryDsn.isEmpty) return runApp(app);

  await SentryFlutter.init(
    (options) => options
      ..dsn = sentryDsn
      ..tracesSampleRate = 1.0
      ..environment = const String.fromEnvironment('FLUTTER_ENV', defaultValue: 'development'),
    appRunner: () => runApp(app),
  );
}

// --- Componente Principal de la Aplicación ---

class FeelTripApp extends ConsumerStatefulWidget {
  const FeelTripApp({super.key});

  @override
  ConsumerState<FeelTripApp> createState() => _FeelTripAppState();
}

class _FeelTripAppState extends ConsumerState<FeelTripApp> with WidgetsBindingObserver {
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Monitorización de servicios
    ref.read(connectivityServiceProvider).monitorConnection();
    _bindNotificationNavigation();

    // INTEGRACIÓN: Inicialización de Deep Links post-frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final router = ref.read(routerProvider);
      final deepLinkService = ref.read(deepLinkServiceProvider);
      await deepLinkService.initialize(router);
    });
  }

  void _bindNotificationNavigation() {
    final notificationService = ref.read(notificationServiceProvider);
    _notificationSubscription = notificationService.navigationStream.listen((payload) {
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
        }
      });
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    // Listener de conectividad para refrescar perfil y sincronizar
    ref.listen(connectivityProvider, (previous, next) {
      next.whenData((result) {
        if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
          final user = ref.read(authNotifierProvider).value;
          if (user != null) {
            ref.read(profileControllerProvider.notifier).refreshProfile();
            ref.read(syncServiceProvider).syncUserEntries(user.id);
          }
        }
      });
    });

    return MaterialApp.router(
      title: 'FeelTrip - Viaja para recordar',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: _buildAppTheme(),
    );
  }

  ThemeData _buildAppTheme() {
    final brandTeal = Colors.teal[800]!;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: brandTeal, primary: brandTeal),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide(color: brandTeal, width: 1.5)
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: brandTeal,
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }
}