import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/services/gps_service.dart';
import 'package:feeltrip_app/services/isar_service.dart';
import 'package:feeltrip_app/services/notification_service.dart';
import 'package:feeltrip_app/core/di/providers.dart';

class GeofencingService {
  final IsarService _isar;
  final NotificationService _notification;
  
  // Mantiene un registro de las cápsulas notificadas durante la sesión activa
  // para evitar enviar notificaciones repetidas sobre la misma cápsula.
  final Set<String> _notifiedCapsules = {};
  
  GeofencingService(this._isar, this._notification);

  Future<void> checkProximity(double lat, double lng) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final momentos = await _isar.getMomentos();
      // Filtrar sólo las cápsulas (Momentos que contienen la palabra CÁPSULA)
      final capsules = momentos.where((m) => 
         m.title.contains('CÁPSULA') && 
         m.locationLat != null && 
         m.locationLng != null &&
         m.userId == userId
      ).toList();

      for (final capsule in capsules) {
        if (_notifiedCapsules.contains(capsule.id)) continue;

        final distance = Geolocator.distanceBetween(
          lat, lng, 
          capsule.locationLat!, capsule.locationLng!
        );

        // Si estamos a menos de 150 metros de proximidad
        if (distance <= 150.0) {
          _notifiedCapsules.add(capsule.id);
          AppLogger.i('Geofencing: Cápsula detectada a ${distance.toInt()} metros.');
          
          await _notification.sendLocalNotification(
            userId: userId,
            title: '¡Cápsula Cercana Detectada!',
            body: 'Estás a menos de 150m de revivir un ecosistema oculto.',
            type: 'capsule_proximity',
            data: {'capsuleId': capsule.id, 'lat': capsule.locationLat, 'lng': capsule.locationLng},
          );
        }
      }
    } catch (e) {
      AppLogger.e('GeofencingService error: $e');
    }
  }
}

// Provider global para mantener vivo el monitoreo de Geofencing
final geofencingProvider = Provider<GeofencingService>((ref) {
  final isar = ref.watch(isarServiceProvider);
  final notification = ref.watch(notificationServiceProvider);
  
  final service = GeofencingService(isar, notification);
  
  // Escuchar la telemetría del GPS y procesar proximidad
  ref.listen(gpsStreamProvider, (previous, next) {
    if (next.value != null) {
      service.checkProximity(next.value!.lat, next.value!.lng);
    }
  });

  return service;
});
