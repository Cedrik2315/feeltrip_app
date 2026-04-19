import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:feeltrip_app/models/expedition_data.dart';
import 'package:feeltrip_app/services/chronicle_repository.dart';
import 'package:feeltrip_app/services/route_repository.dart';
import 'package:feeltrip_app/services/notification_service.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

/// [Sello FeelTrip]: Servicio que escucha la reconexión y genera crónicas pendientes.
class PendingChronicleService {
  final RouteRepository _routeRepo;
  final ChronicleRepository _chronicleRepo;
  final NotificationService _notificationService;
  StreamSubscription<dynamic>? _sub;

  PendingChronicleService({
    required RouteRepository routeRepo,
    required ChronicleRepository chronicleRepo,
    NotificationService? notificationService,
  })  : _routeRepo = routeRepo,
        _chronicleRepo = chronicleRepo,
        _notificationService = notificationService ?? NotificationService();

  void init() {
    _sub = Connectivity().onConnectivityChanged.listen((dynamic result) async {
      final bool hasSignal;
      if (result is List<ConnectivityResult>) {
        hasSignal = result.any((r) => r != ConnectivityResult.none);
      } else if (result is ConnectivityResult) {
        hasSignal = result != ConnectivityResult.none;
      } else {
        hasSignal = false;
      }
      if (hasSignal) await _retryPending();
    });
  }

  Future<void> _retryPending() async {
    final pending = _routeRepo
        .getAll()
        .where((r) =>
            r.isCompleted &&
            r.linkedChronicleId == null &&
            r.pendingUniqueDetail != null)
        .toList();

    for (final route in pending) {
      try {
        final data = ExpeditionData(
          placeName: route.placeName.isNotEmpty ? route.placeName : 'Lugar sin nombre',
          region: route.region.isNotEmpty ? route.region : 'Chile',
          arrivalTime: _formatTime(route.startedAt ?? DateTime.now()),
          temperature: route.weatherSnapshot != null
              ? '${route.weatherSnapshot!.temperatureCelsius.round()}°C'
              : '—',
          uniqueDetail: route.pendingUniqueDetail!,
          explorerName: route.explorerName ?? 'El Explorador',
          tone: NarrativeTone.values.firstWhere(
            (t) => t.name == route.pendingTone,
            orElse: () => NarrativeTone.contemplativo,
          ),
          distanceKm: route.totalDistanceKm,
          durationMinutes: route.durationMinutes,
          elevationGainM: route.elevationGainMeters,
        );

        final chronicle = await _chronicleRepo.generateAndSave(
          data: data,
          userId: route.explorerName ?? '',
        );
        await _routeRepo.linkChronicle(route.id, chronicle.id);

        // ── Push nativo: crónica generada tras reconexión ──────────
        final userId = route.explorerName ?? '';
        if (userId.isNotEmpty) {
          unawaited(
            _notificationService.notifyChronicleReady(
              userId: userId,
              chronicleTitle: chronicle.title,
              chronicleId: chronicle.id,
            ),
          );
          AppLogger.i('PendingChronicleService: Notificación push enviada para crónica "${chronicle.title}"');
        }
      } catch (_) {
        // Falla silenciosa — reintenta en el próximo evento de red
      }
    }
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  void dispose() => _sub?.cancel();
}