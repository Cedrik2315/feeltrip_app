import 'dart:developer' as developer;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  /// Convierte un nombre de lugar en Coordenadas (LatLng)
  Future<LatLng?> obtenerCoordenadas(String direccion) async {
    try {
      List<Location> locations = await locationFromAddress(direccion);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      return null;
    } catch (e) {
      developer.log("Error en Geocoding: $e", name: 'LocationService');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> buscarLugares(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      return locations
          .map((l) => {'nombre': query, 'lat': l.latitude, 'lng': l.longitude})
          .toList();
    } catch (e) {
      developer.log("Error buscando lugares: $e", name: 'LocationService');
      return [];
    }
  }
}
