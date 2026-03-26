import 'package:feeltrip_app/config/firebase_config.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/core/providers/connectivity_provider.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/services/notification_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) => options
      ..dsn = const String.fromEnvironment('SENTRY_DSN')
      ..tracesSampleRate = 1.0
      ..environment = const String.fromEnvironment(
        'FLUTTER_ENV',
        defaultValue: 'development',
      ),
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        await dotenv.load();
      } catch (_) {
        // Optional .env file.
      }

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await FirebaseConfig.initialize();

      final notificationService = NotificationService();
      await notificationService.initialize();

      runApp(
        const ProviderScope(
          child: FeelTripApp(),
        ),
      );
    },
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

    final notificationService = ref.read(notificationServiceProvider);
    notificationService.navigationStream.listen((payload) {
      final type = payload['type'] as String?;
      final id = payload['id'] as String?;
      if (type == 'story_comments' && id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final router = ref.read(routerProvider);
          router.go('/comments/$id');
        });
      }
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

    ref.listen(connectivityProvider, (previous, next) {
      next.whenData((result) {
        if (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi) {
          ref.read(authNotifierProvider).whenOrNull(data: (user) {
            if (user != null) {
              // ref.read(syncServiceProvider).syncPendingMomentos(user.id);
            }
          });
        }
      });
    });

    return MaterialApp.router(
      title: 'FeelTrip - Agencia de Viajes',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.deepPurple,
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
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
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
