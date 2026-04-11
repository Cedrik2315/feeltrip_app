import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/gps_models.dart';

/// [Sello FeelTrip]: Wrapper sobre Geolocator para telemetría constante.
class GpsService {
  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 10, // metros mínimos entre waypoints
  );

  Stream<GpsPoint> get waypointStream =>
      Geolocator.getPositionStream(locationSettings: _settings).map(
        (pos) => GpsPoint(
          lat: pos.latitude,
          lng: pos.longitude,
          altitudeM: pos.altitude,
          accuracyM: pos.accuracy,
          timestamp: pos.timestamp ?? DateTime.now(),
        ),
      );

  Future<GpsPoint?> getCurrentPoint() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return GpsPoint(
        lat: pos.latitude,
        lng: pos.longitude,
        altitudeM: pos.altitude,
        accuracyM: pos.accuracy,
        timestamp: pos.timestamp ?? DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}

final gpsServiceProvider = Provider((ref) => GpsService());

final gpsStreamProvider = StreamProvider<GpsPoint>((ref) {
  return ref.watch(gpsServiceProvider).waypointStream;
});