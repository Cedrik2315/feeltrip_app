import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/data/services/referral_service.dart';
import 'package:feeltrip_app/data/services/subscription_service.dart';
import 'package:feeltrip_app/domain/entities/user_subscription.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';

// ── Providers de infraestructura ─────────────────────────────────────────────

/// Instancia singleton del [SubscriptionService].
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// Instancia singleton del [ReferralService].
final referralServiceProvider = Provider<ReferralService>((ref) {
  return ReferralService();
});

// ── Provider principal ────────────────────────────────────────────────────────

/// Stream en tiempo real del [UserSubscription] del usuario autenticado.
///
/// - Devuelve [UserSubscription.empty] mientras no hay usuario.
/// - Al recibir el primer dato, dispara [checkAndDowngradeExpiredTrial]
///   para asegurar que un trial expirado se degrade inmediatamente.
final subscriptionProvider =
    StreamProvider.autoDispose<UserSubscription>((ref) async* {
  final authState = ref.watch(authNotifierProvider);
  final userId = authState.value?.id;

  // Sin usuario autenticado: emitimos un estado vacío y terminamos.
  if (userId == null) {
    yield UserSubscription.empty;
    return;
  }

  // Verificamos al inicio si el trial expiró y si el acceso Pro bonus expiró.
  ref
      .read(subscriptionServiceProvider)
      .checkAndDowngradeExpiredTrial(userId)
      .catchError((Object e) {
    AppLogger.w('subscriptionProvider: error en downgrade check: $e');
  });

  ref
      .read(referralServiceProvider)
      .checkProExpiration(userId)
      .catchError((Object e) {
    AppLogger.w('subscriptionProvider: error en pro expiration check: $e');
  });

  // Escuchamos el documento en tiempo real.
  yield* FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((snap) {
    if (!snap.exists || snap.data() == null) {
      return UserSubscription.empty;
    }
    return _fromFirestore(snap.data()!);
  }).handleError((Object error, StackTrace st) {
    AppLogger.e('subscriptionProvider: error en stream Firestore', error, st);
    // No re-lanzamos: el StreamProvider mostrará AsyncError automáticamente.
    throw error;
  });
});

// ── Mapper ────────────────────────────────────────────────────────────────────

/// Convierte el mapa de Firestore en la entidad de dominio [UserSubscription].
UserSubscription _fromFirestore(Map<String, dynamic> data) {
  final levelRaw = data['subscriptionLevel'] as String? ?? 'free';
  final level = _parseLevel(levelRaw);

  return UserSubscription(
    level: level,
    trialExpiresAt: (data['trialExpiresAt'] as Timestamp?)?.toDate(),
    trialUsed: (data['trialUsed'] as bool?) ?? false,
    subscriptionExpiresAt:
        (data['subscriptionExpiresAt'] as Timestamp?)?.toDate(),
    totalRoutesCompleted: (data['totalRoutesCompleted'] as int?) ?? 0,
    bookRequestedAt: (data['bookRequestedAt'] as Timestamp?)?.toDate(),
    // Referral fields
    referralCode: (data['referralCode'] as String?) ?? '',
    referredBy: data['referredBy'] as String?,
    invitesAccepted: (data['invitesAccepted'] as int?) ?? 0,
    bonusDaysEarned: (data['bonusDaysEarned'] as int?) ?? 0,
    bonusDaysAccumulated: (data['bonusDaysAccumulated'] as int?) ?? 0,
    proExpiresAt: (data['proExpiresAt'] as Timestamp?)?.toDate(),
    // Discount fields
    hasReferralDiscount: (data['hasReferralDiscount'] as bool?) ?? false,
    referralDiscountUsed: (data['referralDiscountUsed'] as bool?) ?? false,
  );
}

SubscriptionLevel _parseLevel(String raw) {
  switch (raw) {
    case 'aventurero':
      return SubscriptionLevel.aventurero;
    case 'pro':
      return SubscriptionLevel.pro;
    case 'trial':
      return SubscriptionLevel.trial;
    default:
      return SubscriptionLevel.free;
  }
}
