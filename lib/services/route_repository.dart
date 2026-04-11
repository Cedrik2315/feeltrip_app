import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:feeltrip_app/models/gps_models.dart';
import 'package:feeltrip_app/services/isar_service.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  final isar = ref.watch(isarServiceProvider);
  return RouteRepository(isar: isar);
});

/// [Sello FeelTrip]: Repositorio de rutas GPS con persistencia atómica en Hive.
class RouteRepository {
  final IsarService _isar;

  RouteRepository({required IsarService isar}) : _isar = isar;

  Box<RouteModel> get _box => _isar.routesBox;

  // ── Ciclo de Vida ──────────────────────────────────────────────────────

  Future<RouteModel> startRoute(RouteModel route) async {
    await _box.put(route.id, route);
    AppLogger.d('RouteRepository: Ruta iniciada ${route.id}');
    return route;
  }

  Future<void> addWaypoint(String routeId, GpsPoint point) async {
    final route = _box.get(routeId);
    if (route == null) return;
    final updatedWaypoints = List<GpsPoint>.from(route.waypoints)..add(point);
    await _box.put(routeId, route.copyWith(waypoints: updatedWaypoints));
  }

  Future<RouteModel> finishRoute(String routeId) async {
    final route = _box.get(routeId);
    if (route == null) throw Exception('Ruta $routeId no encontrada');

    final finishedAt = DateTime.now();
    final startedAt = route.startedAt ?? finishedAt;
    final duration = finishedAt.difference(startedAt).inMinutes;
    final distanceKm = _computeDistanceKm(route.waypoints);
    final elevationGain = _computeElevationGain(route.waypoints);

    final completed = route.copyWith(
      finishedAt: finishedAt,
      totalDistanceKm: distanceKm,
      durationMinutes: duration,
      elevationGainMeters: elevationGain,
      isCompleted: true,
    );

    await _box.put(routeId, completed);
    AppLogger.i('RouteRepository: Ruta completada: ${distanceKm}km en ${duration}min');
    return completed;
  }

  Future<void> linkChronicle(String routeId, String chronicleId) async {
    final route = _box.get(routeId);
    if (route == null) return;
    await _box.put(routeId, route.copyWith(linkedChronicleId: chronicleId));
  }

  // ── Consultas ──────────────────────────────────────────────────────────

  List<RouteModel> getAll() => _box.values.toList()
    ..sort((a, b) {
      final aDate = a.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

  // ── Cálculos ───────────────────────────────────────────────────────────

  double _computeDistanceKm(List<GpsPoint> points) {
    if (points.length < 2) return 0;
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += _haversineKm(points[i - 1], points[i]);
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double _computeElevationGain(List<GpsPoint> points) {
    double gain = 0;
    for (int i = 1; i < points.length; i++) {
      final delta = (points[i].altitudeM ?? 0) - (points[i - 1].altitudeM ?? 0);
      if (delta > 0) gain += delta;
    }
    return double.parse(gain.toStringAsFixed(1));
  }

  double _haversineKm(GpsPoint a, GpsPoint b) {
    const r = 6371.0;
    final dLat = (b.lat - a.lat) * math.pi / 180;
    final dLng = (b.lng - a.lng) * math.pi / 180;
    final h = math.pow(math.sin(dLat / 2), 2) +
        math.cos(a.lat * math.pi / 180) *
            math.cos(b.lat * math.pi / 180) *
            math.pow(math.sin(dLng / 2), 2);
    return r * 2 * math.asin(math.sqrt(h));
  }
}