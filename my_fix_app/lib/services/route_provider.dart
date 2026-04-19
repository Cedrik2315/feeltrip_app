import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/models/gps_models.dart';
import 'package:feeltrip_app/models/expedition_data.dart';
import 'package:feeltrip_app/presentation/providers/subscription_provider.dart';
import 'package:feeltrip_app/presentation/providers/admob_provider.dart';
import 'package:feeltrip_app/services/chronicle_repository_impl.dart';
import 'package:feeltrip_app/services/route_repository.dart';
import 'package:feeltrip_app/services/gps_service.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/domain/entities/user_subscription.dart';

enum RoutePhase { idle, tracking, paused, completing, done }

/// [Sello FeelTrip]: Estado de la expedición en curso
class RouteState {
  final RouteModel? route;
  final RoutePhase phase;
  final List<GpsPoint> points;
  final DateTime? startedAt;
  final String? error;

  const RouteState({
    this.route,
    this.phase = RoutePhase.idle,
    this.points = const [],
    this.startedAt,
    this.error,
  });

  RouteState copyWith({
    RouteModel? route,
    RoutePhase? phase,
    List<GpsPoint>? points,
    DateTime? startedAt,
    String? error,
  }) =>
      RouteState(
        route: route ?? this.route,
        phase: phase ?? this.phase,
        points: points ?? this.points,
        startedAt: startedAt ?? this.startedAt,
        error: error,
      );

  double get distanceKm {
    if (points.length < 2) return 0;
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += points[i - 1].distanceTo(points[i]);
    }
    return total / 1000;
  }

  Duration get elapsed =>
      startedAt == null ? Duration.zero : DateTime.now().difference(startedAt!);

  double get avgSpeedKmh {
    final secs = elapsed.inSeconds;
    if (secs == 0) return 0;
    return (distanceKm / secs) * 3600;
  }

  double get maxAltitude =>
      points.isEmpty ? 0 : points.map((p) => p.altitudeM ?? 0).reduce((a, b) => a > b ? a : b);
}

final routeNotifierProvider =
    AsyncNotifierProvider<RouteNotifier, RouteState>(RouteNotifier.new);

class RouteNotifier extends AsyncNotifier<RouteState> {
  @override
  Future<RouteState> build() async => const RouteState();

  RouteRepository get _repo => ref.read(routeRepositoryProvider);

  Future<void> startTracking(RouteModel route) async {
    AppLogger.i('RouteNotifier: Iniciando tracking para ${route.placeName}');
    final startedRoute = await _repo.startRoute(route);
    
    state = AsyncData(RouteState(
      route: startedRoute,
      phase: RoutePhase.tracking,
      startedAt: DateTime.now(),
    ));

    // Escuchamos el stream de GPS inyectado
    ref.listen(gpsStreamProvider, (_, next) {
      next.whenData(_onGpsPoint);
    });
  }

  void _onGpsPoint(GpsPoint point) {
    final current = state.valueOrNull;
    if (current == null || current.phase != RoutePhase.tracking) return;
    
    _repo.addWaypoint(current.route!.id, point);

    state = AsyncData(current.copyWith(
      points: [...current.points, point],
    ));
  }

  void pauseTracking() => _updatePhase(RoutePhase.paused);
  void resumeTracking() => _updatePhase(RoutePhase.tracking);

  void _updatePhase(RoutePhase phase) {
    final c = state.valueOrNull;
    if (c != null) state = AsyncData(c.copyWith(phase: phase));
  }

  Future<void> finishRoute({
    required String userDetail,
    required String explorerName,
    NarrativeTone tone = NarrativeTone.contemplativo,
  }) async {
    final current = state.valueOrNull;
    if (current == null || current.route == null || current.startedAt == null) return;

    state = AsyncData(current.copyWith(phase: RoutePhase.completing));

    // Finalizamos la ruta en el repositorio para obtener estadísticas reales
    // Esto ocurre offline y es el paso más crítico de persistencia.
    var finishedRoute = await _repo.finishRoute(current.route!.id);

    // Guardamos los detalles del usuario en el modelo de ruta por si falla la señal
    finishedRoute = finishedRoute.copyWith(
      pendingUniqueDetail: userDetail,
      explorerName: explorerName,
      pendingTone: tone.name,
    );
    await _repo.startRoute(finishedRoute); // Actualiza con detalles pendientes

    final data = ExpeditionData(
      placeName: finishedRoute.placeName.isNotEmpty
          ? finishedRoute.placeName
          : _coordsLabel(current.points.firstOrNull),
      region: finishedRoute.region ?? 'Desconocido',
      arrivalTime: _formatTime(current.startedAt!),
      temperature: finishedRoute.weatherSnapshot != null
          ? '${finishedRoute.weatherSnapshot!.temperatureCelsius.toStringAsFixed(0)}°C'
          : _estimateTempByAltitude(current.points.lastOrNull?.altitudeM ?? 0),
      uniqueDetail: userDetail,
      explorerName: explorerName,
      tone: tone,
      audioNuance: AudioNuance.neutro, // Valor por defecto de FeelTrip
      distanceKm: finishedRoute.totalDistanceKm,
      durationMinutes: finishedRoute.durationMinutes,
      elevationGainM: finishedRoute.elevationGainMeters,
    );

    // ── Suscripción: incrementar contador y activar trial si aplica ──────
    final userId = ref.read(authNotifierProvider).value?.id;
    if (userId != null) {
      final subService = ref.read(subscriptionServiceProvider);
      await subService.incrementRouteCount(userId);
      await subService.activateTrialIfEligible(userId);

      // Mostrar AdMob interstitial para usuarios Free (cada 3 rutas aprox)
      final subscription = ref.read(subscriptionProvider).valueOrNull;
      if (subscription != null && subscription.level == SubscriptionLevel.free) {
        await ref.read(adMobProvider).showInterstitial(isUserFree: true);
      }

    }

    try {
      await ref.read(chronicleGeneratorProvider.notifier).generate(data);

    } catch (e) {
      AppLogger.w('RouteNotifier: Error generando crónica (posible offline). Quedará pendiente.');
    }

    state = AsyncData(current.copyWith(phase: RoutePhase.done));
    AppLogger.i('RouteNotifier: Expedición finalizada y crónica enviada a IA');
  }

  String _formatTime(DateTime date) => 
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  String _estimateTempByAltitude(double alt) => '~${(20 - (alt / 1000) * 6.5).round()}°C';

  String _coordsLabel(GpsPoint? p) => p == null
      ? 'Coordenadas desconocidas'
      : '${p.lat.toStringAsFixed(4)}° S, ${p.lng.toStringAsFixed(4)}° W';
}