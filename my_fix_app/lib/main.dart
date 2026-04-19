import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:feeltrip_app/config/firebase_config.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/features/profile/presentation/profile_controller.dart';
import 'package:feeltrip_app/services/isar_service.dart';
import 'package:feeltrip_app/services/revenuecat_service.dart';
import 'package:feeltrip_app/services/sync_service.dart';
import 'package:feeltrip_app/services/deep_link_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'data/services/admob_service.dart';
import 'package:feeltrip_app/theme/app_theme.dart';


/// Provider global para la API Key de Google AI (Gemini/Chronicle).
final googleAiApiKeyProvider = Provider<String>((ref) => throw UnimplementedError());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Carga de entorno y servicios básicos en paralelo
  await Future.wait([
    _loadEnvironmentAndOptionalServices(),
    _configureDeviceOrientation(),
  ]);

  // 2. Inicialización de Firebase
  final firebaseReady = await FirebaseConfig.initialize();
  
  if (firebaseReady) {
    await _configureFirebaseAppCheck();
    await _configureCrashReporting();
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } else {
    debugPrint('FeelTrip: Firebase no disponible; modo degradado activo.');
  }

  // Inicializar AdMob
  await AdMobService.initialize();

  // 3. Servicios locales (Isar y Sync)
  await _initializeLocalServices();


  final app = ProviderScope(
    overrides: [
      googleAiApiKeyProvider.overrideWithValue(
        dotenv.env['GOOGLE_AI_API_KEY'] ?? '',
      ),
    ],
    child: const FeelTripApp(),
  );

  await _runWithOptionalSentry(app);
}

// --- Métodos de Configuración ---

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

Future<void> _configureFirebaseAppCheck() async {
  const bool useDebugProvider = bool.fromEnvironment('USE_DEBUG_APPCHECK', defaultValue: false);
  
  await FirebaseAppCheck.instance.activate(
    // ignore: deprecated_member_use
    androidProvider: (kDebugMode || useDebugProvider) ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    // ignore: deprecated_member_use
    appleProvider: (kDebugMode || useDebugProvider) ? AppleProvider.debug : AppleProvider.deviceCheck,
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

// --- Componente Principal ---

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

    ref.read(connectivityServiceProvider).monitorConnection();
    _bindNotificationNavigation();

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
          case 'chronicle_ready':
            router.go('/diary');
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

    ref.listen(connectivityProvider, (previous, next) {
      next.whenData((result) {
        if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
          final user = ref.read(authNotifierProvider).value;
          if (user != null) {
            ref.read(profileControllerProvider.notifier).refreshProfile();
            ref.read(syncServiceProvider).syncUserEntries(user.id);
            
            FirebaseAnalytics.instance.logEvent(
              name: 'sync_on_connectivity_recovered',
              parameters: {'user_id': user.id},
            );
          }
        }
      });
    });

    return MaterialApp.router(
      title: 'FeelTrip - Viaja para recordar',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.darkTheme,
    );
  }
}