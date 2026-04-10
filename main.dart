import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // Asumiendo que usas Firebase
import 'package:feeltrip_app/config/router.dart'; // Tu provider de GoRouter
import 'package:feeltrip_app/services/deep_link_service.dart'; // Tu DeepLinkService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase primero

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Usa un callback post-frame para asegurar que el router esté completamente construido
    // y el contexto esté disponible para la navegación.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final router = ref.read(goRouterProvider);
      final deepLinkService = ref.read(deepLinkServiceProvider);
      await deepLinkService.initialize(router);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'FeelTrip',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Tema de ejemplo
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: router,
    );
  }
}