import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';
import '../core/logger/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Trip?> getTripById(String id) async {
    try {
      final doc = await _firestore.collection('trips').doc(id).get();
      if (doc.exists) {
        return Trip.fromFirestore(doc);
      }
      AppLogger.w('TripService: Viaje con ID $id no encontrado.');
      return null;
    } catch (e) {
      AppLogger.e('TripService: Error al obtener detalle del viaje: $e');
      rethrow;
    }
  }
}

final tripServiceProvider = Provider((ref) => TripService());