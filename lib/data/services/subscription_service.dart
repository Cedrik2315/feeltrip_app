import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/services/notification_service.dart';


/// [FeelTrip] Servicio de gestión de suscripciones sobre Firestore.
///
/// No contiene lógica de UI. No integra RevenueCat (fase 2).
/// Todos los métodos manejan excepciones internamente y loguean con AppLogger.
class SubscriptionService {
  SubscriptionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ── Helpers ──────────────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _userRef(String userId) =>
      _firestore.collection('users').doc(userId);

  // ── Trial ─────────────────────────────────────────────────────────────────

  /// Activa el trial Pro por 30 días si el usuario nunca lo ha usado.
  ///
  /// Llama esto cuando el usuario completa su primera ruta.
  Future<void> activateTrialIfEligible(String userId) async {
    try {
      final snap = await _userRef(userId).get();
      final data = snap.data();
      if (data == null) return;
      if (data['trialUsed'] == true) return;

      final now = DateTime.now();
      final existingProExpiry =
          (data['proExpiresAt'] as Timestamp?)?.toDate();

      final DateTime newProExpiry;
      if (existingProExpiry != null && existingProExpiry.isAfter(now)) {
        newProExpiry = existingProExpiry.add(const Duration(days: 30));
      } else {
        newProExpiry = now.add(const Duration(days: 30));
      }

      await _userRef(userId).update({
        'subscriptionLevel': 'trial',
        'trialActivatedAt': Timestamp.fromDate(now),
        'trialExpiresAt': Timestamp.fromDate(now.add(const Duration(days: 30))),
        'trialUsed': true,
        'firstRouteCompletedAt': Timestamp.fromDate(now),
        'proExpiresAt': Timestamp.fromDate(newProExpiry),
      });

      final notifService = NotificationService();
      final hasDiscount = data['hasReferralDiscount'] == true;
      await notifService.scheduleTrialConversionSequence(
        userId: userId,
        trialExpiresAt: now.add(const Duration(days: 30)),
        referralDiscount: hasDiscount ? 'FELTDESC30' : null,
      );

      AppLogger.i('SubscriptionService: Trial Pro activado para $userId. Pro hasta $newProExpiry');

    } catch (e, st) {
      AppLogger.e('SubscriptionService.activateTrialIfEligible error', e, st);
    }
  }

  // ── Contador de rutas ─────────────────────────────────────────────────────

  /// Incrementa el contador de rutas completadas.
  Future<void> incrementRouteCount(String userId) async {
    try {
      await _userRef(userId).update({
        'totalRoutesCompleted': FieldValue.increment(1),
      });
      AppLogger.i('SubscriptionService: Ruta completada incrementada para $userId');
    } catch (e, st) {
      AppLogger.e('SubscriptionService.incrementRouteCount error', e, st);
    }
  }

  // ── Degradación de trial ──────────────────────────────────────────────────

  /// Comprueba si el trial expiró y degrada al nivel free si es así.
  ///
  /// Llama esto en el arranque de la app o al volver al primer plano.
  Future<void> checkAndDowngradeExpiredTrial(String userId) async {
    try {
      // FIX: asegurar que el token JWT esté listo antes de leer Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await user.getIdToken(true);

      final snap = await _userRef(userId).get();
      final data = snap.data();
      if (data == null) return;
      if (data['subscriptionLevel'] != 'trial') return;

      final trialExpiresAt =
          (data['trialExpiresAt'] as Timestamp?)?.toDate();
      if (trialExpiresAt == null) return;

      if (DateTime.now().isAfter(trialExpiresAt)) {
        await _userRef(userId).update({'subscriptionLevel': 'free'});
        AppLogger.i('SubscriptionService: Trial expirado. $userId degradado a free.');
      }
    } catch (e, st) {
      AppLogger.e('SubscriptionService.checkAndDowngradeExpiredTrial error', e, st);
    }
  }

  // ── Libro impreso ─────────────────────────────────────────────────────────

  /// Solicita el libro físico impreso con las mejores crónicas del usuario.
  Future<void> requestBook({
    required String userId,
    required Map<String, String> shippingAddress,
    required int totalRoutesCompleted,
  }) async {
    try {
      final now = DateTime.now();
      final batch = _firestore.batch();

      final orderRef = _firestore.collection('bookOrders').doc();

      batch.set(orderRef, {
        'userId': userId,
        'requestedAt': Timestamp.fromDate(now),
        'status': 'pending',
        'shippingAddress': shippingAddress,
        'routesSnapshot': totalRoutesCompleted,
        'notes': null,
      });

      batch.update(_userRef(userId), {
        'bookRequestedAt': Timestamp.fromDate(now),
      });

      await batch.commit();
      AppLogger.i('SubscriptionService: Libro solicitado por $userId. Order: ${orderRef.id}');
    } catch (e, st) {
      AppLogger.e('SubscriptionService.requestBook error', e, st);
      rethrow;
    }
  }

  // ── Embajador ─────────────────────────────────────────────────────────────

  /// Eleva al usuario al rango de Embajador (Self-Elevation for Demo/Testing).
  Future<void> setAmbassadorStatus(String userId, {bool isActive = true, double initialBalance = 0.0}) async {
    try {
      await _userRef(userId).update({
        'isAmbassador': isActive,
        'ambassadorBalance': initialBalance,
        'ambassadorSalesCount': isActive ? 0 : 0,
      });
      AppLogger.i('SubscriptionService: Rando de EMBAJADOR actualizado para $userId: $isActive');
    } catch (e, st) {
      AppLogger.e('SubscriptionService.setAmbassadorStatus error', e, st);
    }
  }
}