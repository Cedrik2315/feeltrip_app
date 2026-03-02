import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:get/get.dart';
import 'package:feeltrip_app/services/storage_service.dart';

class ReviewService extends GetxService {
  final InAppReview _inAppReview = InAppReview.instance;
  
  // Configuración: Pedir review cada 3 "momentos felices"
  static const int _eventsUntilPrompt = 3;
  static const String _storageKey = 'review_happy_moments_count';

  /// Registra un momento positivo (ej: reserva, medalla, like)
  /// Si se acumulan suficientes, muestra el prompt de calificación.
  Future<void> trackHappyMoment() async {
    int currentEvents = StorageService.getInt(_storageKey) ?? 0;
    currentEvents++;
    
    if (currentEvents >= _eventsUntilPrompt) {
      if (await _inAppReview.isAvailable()) {
        // Muestra el popup nativo de iOS/Android
        _inAppReview.requestReview();
        
        // Reiniciamos el contador (o podrías aumentarlo para pedir menos frecuente)
        await StorageService.setInt(_storageKey, 0); 
        debugPrint('⭐ Solicitando review al usuario');
      }
    } else {
      await StorageService.setInt(_storageKey, currentEvents);
      debugPrint('⭐ Momento feliz registrado ($currentEvents/$_eventsUntilPrompt)');
    }
  }
}
