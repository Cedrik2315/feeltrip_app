import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/core/security/security_utils.dart';
import 'package:feeltrip_app/services/notification_service.dart';


/// [FeelTrip] Servicio de gestión del sistema de referidos.
///
/// Maneja generación de códigos, aplicación de invitaciones, recompensas
/// al referidor y verificación de expiración Pro por bonus.
/// No integra RevenueCat (fase 3).
class ReferralService {
  ReferralService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const int _bonusDaysCap = 90;
  static const int _refereeRewardDays = 30;
  static const int _referrerBonusDays = 15;
  static const double _ambassadorCommission = 5.0; // USD per referral
  static const String _codePrefix = 'FELT-';
  static const String _codeChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  // ── Helpers ──────────────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _firestore.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> _codeRef(String code) =>
      _firestore.collection('inviteCodes').doc(code.toUpperCase());

  // ── Generación de código ──────────────────────────────────────────────────

  /// Genera un código único "FELT-XXXX" para el usuario y lo persiste.
  Future<String> generateReferralCode(String userId) async {
    try {
      final code = await _generateUniqueCode();

      final batch = _firestore.batch();

      batch.set(_codeRef(code), {
        'ownerId': userId,
        'usedBy': null,
        'usedAt': null,
        'isActive': true,
      });

      batch.update(_userRef(userId), {'referralCode': code});

      await batch.commit();
      AppLogger.i('ReferralService: Código $code generado para $userId');
      return code;
    } catch (e, st) {
      AppLogger.e('ReferralService.generateReferralCode error', e, st);
      return '';
    }
  }

  /// Genera un código "FELT-XXXX" que no exista ya en Firestore.
  Future<String> _generateUniqueCode() async {
    final rng = Random.secure();
    for (var attempt = 0; attempt < 10; attempt++) {
      final suffix = List.generate(
        4,
        (_) => _codeChars[rng.nextInt(_codeChars.length)],
      ).join();
      final candidate = '$_codePrefix$suffix';
      final snap = await _codeRef(candidate).get();
      if (!snap.exists) return candidate;
    }
    final rngFallback = Random.secure();
    final suffix = List.generate(
      5,
      (_) => _codeChars[rngFallback.nextInt(_codeChars.length)],
    ).join();
    return '$_codePrefix$suffix';
  }

  // ── Aplicar código de invitación ──────────────────────────────────────────

  /// Valida y aplica un código de invitación al registrarse.
  Future<bool> applyInviteCode(String userId, String code) async {
    final sCode = SecurityUtils.sanitizeInput(code, maxLength: 20);
    final normalizedCode = sCode.trim().toUpperCase();
    try {
      final codeSnap = await _codeRef(normalizedCode).get();
      if (!codeSnap.exists) {
        AppLogger.w('ReferralService: Código $normalizedCode no existe');
        return false;
      }

      final codeData = codeSnap.data()!;
      final isActive = (codeData['isActive'] as bool?) ?? false;
      final usedBy = codeData['usedBy'] as String?;
      final ownerId = codeData['ownerId'] as String? ?? '';

      if (!isActive || usedBy != null) {
        AppLogger.w('ReferralService: Código $normalizedCode ya fue usado o inactivo');
        return false;
      }

      if (ownerId == userId) {
        AppLogger.w('ReferralService: El usuario $userId intentó usar su propio código');
        return false;
      }

      final now = DateTime.now();
      final proExpiry = now.add(const Duration(days: _refereeRewardDays));

      final batch = _firestore.batch();

      batch.update(_codeRef(normalizedCode), {
        'usedBy': userId,
        'usedAt': Timestamp.fromDate(now),
        'isActive': false,
      });

      batch.update(_userRef(userId), {
        'referredBy': normalizedCode,
        'proExpiresAt': Timestamp.fromDate(proExpiry),
        'hasReferralDiscount': true,
        'referralDiscountUsed': false,
      });

      await batch.commit();
      AppLogger.i(
        'ReferralService: Código $normalizedCode aplicado. '
        'Usuario $userId tiene Pro hasta $proExpiry',
      );

      unawaited(_rewardReferrer(ownerId));
      return true;
    } catch (e, st) {
      AppLogger.e('ReferralService.applyInviteCode error', e, st);
      return false;
    }
  }

  // ── Recompensa al referidor ───────────────────────────────────────────────

  /// Recompensa al referidor con 15 días bonus respetando el tope de 90.
  Future<void> _rewardReferrer(String referrerId) async {
    try {
      final snap = await _userRef(referrerId).get();
      if (!snap.exists) return;
      final data = snap.data()!;

      final currentAccumulated = (data['bonusDaysAccumulated'] as int?) ?? 0;
      final currentEarned = (data['bonusDaysEarned'] as int?) ?? 0;
      final currentInvites = (data['invitesAccepted'] as int?) ?? 0;
      final existingExpiry =
          (data['proExpiresAt'] as Timestamp?)?.toDate();

      final daysToAdd =
          (_referrerBonusDays).clamp(0, _bonusDaysCap - currentAccumulated);
      final newAccumulated = currentAccumulated + daysToAdd;
      final newEarned = currentEarned + _referrerBonusDays;

      final now = DateTime.now();
      DateTime newProExpiry;
      if (existingExpiry == null || existingExpiry.isBefore(now)) {
        newProExpiry = now.add(Duration(days: newAccumulated));
      } else {
        newProExpiry = existingExpiry.add(Duration(days: daysToAdd));
      }

      final maxExpiry = now.add(const Duration(days: _bonusDaysCap));
      if (newProExpiry.isAfter(maxExpiry)) {
        newProExpiry = maxExpiry;
      }

      final isAmbassador = (data['isAmbassador'] as bool?) ?? false;
      final currentBalance = (data['ambassadorBalance'] as num?)?.toDouble() ?? 0.0;
      final currentSales = (data['ambassadorSalesCount'] as int?) ?? 0;

      final Map<String, dynamic> updates = {
        'bonusDaysAccumulated': newAccumulated,
        'bonusDaysEarned': newEarned,
        'invitesAccepted': currentInvites + 1,
        'proExpiresAt': Timestamp.fromDate(newProExpiry),
      };

      // Si es Embajador, otorgamos comisión financiera adicional
      if (isAmbassador) {
        updates['ambassadorBalance'] = currentBalance + _ambassadorCommission;
        updates['ambassadorSalesCount'] = currentSales + 1;
        AppLogger.i('ReferralService: Embajador $referrerId recompensado con comisión.');
      }

      await _userRef(referrerId).update(updates);

      final notifService = NotificationService();
      await notifService.notifyReferralAccepted(
        userId: referrerId,
        bonusDaysEarned: 15,
        totalBonusDays: newAccumulated,
      );

      AppLogger.i(
        'ReferralService: Referidor $referrerId recompensado. '
        '+$daysToAdd días bonus. Pro hasta $newProExpiry',
      );

    } catch (e, st) {
      AppLogger.e('ReferralService._rewardReferrer error', e, st);
    }
  }

  // ── Verificar expiración Pro ──────────────────────────────────────────────

  /// Verifica si el acceso Pro por bonus expiró y degrada a free si corresponde.
  ///
  /// Solo actúa si el nivel no es "aventurero" ni "pro" (pago real via RevenueCat).
  /// Llamar al iniciar la app desde el subscriptionProvider.
  Future<void> checkProExpiration(String userId) async {
    try {
      // FIX: asegurar que el token JWT esté listo antes de leer Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await user.getIdToken(true);

      final snap = await _userRef(userId).get();
      if (!snap.exists) return;
      final data = snap.data()!;

      final proExpiresAt = (data['proExpiresAt'] as Timestamp?)?.toDate();
      if (proExpiresAt == null) return;

      final level = data['subscriptionLevel'] as String? ?? 'free';
      if (level == 'aventurero' || level == 'pro') return;

      if (DateTime.now().isAfter(proExpiresAt)) {
        await _userRef(userId).update({
          'subscriptionLevel': 'free',
          'proExpiresAt': null,
        });
        AppLogger.i(
          'ReferralService: Pro bonus expirado para $userId. Degradado a free.',
        );
      }
    } catch (e, st) {
      AppLogger.e('ReferralService.checkProExpiration error', e, st);
    }
  }

  // ── Activación Cortesía Hotel/Boutique ────────────────────────────────────

  /// Concede 3 días Pro de cortesía al usuario (activado desde una Agencia Boutique).
  Future<bool> grantBoutiquePro(String userId) async {
    try {
      final snap = await _userRef(userId).get();
      if (!snap.exists) return false;
      
      final data = snap.data()!;
      final existingExpiry = (data['proExpiresAt'] as Timestamp?)?.toDate();
      final now = DateTime.now();
      
      // Si ya tiene más de 3 días Pro, no hacemos nada
      if (existingExpiry != null && existingExpiry.isAfter(now.add(const Duration(days: 3)))) {
        AppLogger.i('ReferralService: B2B_PRO ya excede cortesía actual.');
        return true;
      }

      final newProExpiry = now.add(const Duration(days: 3));

      await _userRef(userId).update({
        'proExpiresAt': Timestamp.fromDate(newProExpiry),
        'subscriptionLevel': 'free', // Sigue siendo free, pero proExpiresAt concede VIP
      });

      AppLogger.i('ReferralService: Cortesía Boutique concedida a $userId hasta $newProExpiry');
      return true;
    } catch (e, st) {
      AppLogger.e('ReferralService.grantBoutiquePro error', e, st);
      return false;
    }
  }
}

// ignore: prefer_void_to_null
void unawaited(Future<void> future) {
  future.catchError((Object e, StackTrace st) {
    AppLogger.e('ReferralService: unawaited error', e, st);
  });
}