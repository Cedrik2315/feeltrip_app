import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/logger/app_logger.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';

/// Provider para el servicio de Deep Links.
final deepLinkServiceProvider = Provider((ref) {
  final service = DeepLinkService(ref);
  // Asegura que la suscripción al stream se cancele cuando el provider se descarte.
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Servicio encargado de capturar y procesar Deep Links entrantes (App Links / Universal Links).
/// Utiliza el paquete 'app_links' para una integración unificada en Android e iOS.
class DeepLinkService {
  final Ref _ref;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  DeepLinkService(this._ref);

  /// Inicializa la escucha de enlaces. 
  /// Se recomienda llamar a este método en el arranque de la aplicación pasando el router global.
  Future<void> initialize(GoRouter router) async {
    AppLogger.i('DeepLinkService: Inicializando sistema de enlaces dinámicos...');

    // 1. Manejo del enlace inicial (Cold Start)
    // Útil cuando la app se abre desde un link estando totalmente cerrada.
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        AppLogger.i('DeepLinkService: Link inicial detectado: $initialUri');
        _handleDeepLink(initialUri, router);
      }
    } catch (e) {
      AppLogger.e('DeepLinkService: Fallo al recuperar link inicial: $e');
    }

    // 2. Escucha reactiva de enlaces entrantes (App en segundo plano o primer plano)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        AppLogger.d('DeepLinkService: Nuevo enlace capturado: $uri');
        _handleDeepLink(uri, router);
      },
      onError: (Object err) {
        AppLogger.e('DeepLinkService: Error en el stream de enlaces: $err');
      },
    );
  }

  /// Lógica de redirección basada en la estructura de la URL.
  /// Formatos esperados basados en el protocolo FeelTrip: 
  /// - https://feeltrip.app/story/{id} -> Redirige a comentarios de la historia.
  /// - https://feeltrip.app/agency/{id} -> Redirige al perfil de la agencia.
  void _handleDeepLink(Uri uri, GoRouter router) {
    final authState = _ref.read(authNotifierProvider);
    final currentUserId = authState.value?.id ?? 'guest';
    AppLogger.d('DeepLinkService: Procesando deep link "$uri" para usuario: $currentUserId');
    
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) return;

    final type = pathSegments[0];
    final id = pathSegments.length > 1 ? pathSegments[1] : null;

    if (type == 'story' && id != null) {
      router.push('/comments/$id');
    } else if (type == 'agency' && id != null) {
      router.push('/agency/$id');
    } else {
      AppLogger.w('DeepLinkService: Ruta no reconocida o no mapeada: $type');
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}