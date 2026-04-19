import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
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

  /// Requerido por Google Play Store: Divulgación Prominente antes de pedir permiso GPS.
  static Future<bool> requestPermissionWithDisclosure(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      return true;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: colorScheme.outline),
        ),
        title: Row(
          children: [
            Icon(Icons.location_on, color: colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'USO DE UBICACIÓN',
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FeelTrip recopila datos de ubicación para habilitar el trazado continuo de tus "Expediciones" en el mapa y descubrir Cápsulas del Tiempo cercanas, incluso cuando la aplicación está cerrada o no está en uso.',
              style: GoogleFonts.ebGaramond(
                fontSize: 15,
                color: colorScheme.onSurface.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '> Puedes revocar este permiso o detener el tracking pausando la expedición en cualquier momento.',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'DENEGAR',
              style: GoogleFonts.jetBrainsMono(color: colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(
              'ENTENDIDO',
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (proceed == true) {
      final newPermission = await Geolocator.requestPermission();
      return newPermission == LocationPermission.always || newPermission == LocationPermission.whileInUse;
    }
    
    return false;
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
