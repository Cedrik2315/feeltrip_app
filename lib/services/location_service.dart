import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationService {
  static final Logger _logger = Logger();

  static Future<bool> checkPermission() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Location services are disabled.');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        _logger.i('Location permissions denied, requesting...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.w('Location permissions denied after request.');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.e('Location permissions permanently denied.');
        return false;
      }

      _logger.i('Location permissions granted.');
      return true;
    } catch (error) {
      _logger.e('Error checking location permission: $error');
      return false;
    }
  }

  static Future<Position?> getPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
  }) async {
    try {
      if (!await checkPermission()) {
        _logger.w('Cannot get location: permissions not granted.');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: desiredAccuracy,
          timeLimit: const Duration(seconds: 15),
        ),
      );
      _logger
          .i('Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } on LocationServiceDisabledException {
      _logger.w('GPS disabled.');
      return null;
    } catch (error) {
      _logger.e('Error getting current location: $error');
      return null;
    }
  }

  static Stream<Position> getLocationStream({
    LocationSettings? locationSettings,
  }) {
    _logger.i('Starting location stream');
    return Geolocator.getPositionStream(
      locationSettings: locationSettings ??
          const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
    );
  }

  static Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }

  static Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Calculate distance between two points in meters
  static double calculateDistance(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
