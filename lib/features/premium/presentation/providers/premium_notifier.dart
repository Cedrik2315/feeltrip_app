import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/features/premium/data/revenuecat_repository_impl.dart';
import 'package:feeltrip_app/features/premium/domain/entities/premium_state.dart';
import 'package:feeltrip_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:feeltrip_app/services/metrics_service.dart';

part 'premium_notifier.g.dart';

@riverpod
class PremiumNotifier extends _$PremiumNotifier {
  @override
  PremiumState build() {
    // Start in a loading state if data is fetched immediately
    Future.microtask(_bootstrap);
    return const PremiumState(isLoading: true);
  }

  Future<void> _bootstrap() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    MetricsService.logPremiumViewed();
    try {
      final repository = ref.read(premiumRepositoryProvider);
      final results = await Future.wait<dynamic>([
        repository.isPremium(),
        repository.getOfferings(),
      ]);

      final isPremium = results[0] as bool;
      final offerings = results[1] as List<Offering>;

      state = state.copyWith(
        isLoading: false,
        isPremium: isPremium,
        offerings: offerings,
        errorMessage:
            offerings.isEmpty ? 'No hay planes premium disponibles.' : null,
      );
    } catch (e) {
      AppLogger.e('Premium bootstrap error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Premium no esta disponible temporalmente.',
      );
    }
  }

  Future<void> refresh() async {
    await _bootstrap();
  }

  Future<void> purchasePackage(Package package) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    MetricsService.logPremiumPurchaseStarted(source: 'revenuecat');
    try {
      final repository = ref.read(premiumRepositoryProvider);
      final CustomerInfo customerInfo = await repository.purchasePackage(package);
      final isPremium = customerInfo.entitlements.active.isNotEmpty;
      state = state.copyWith(
        isLoading: false,
        isPremium: isPremium,
        activePackage: package,
      );
      if (isPremium) {
        MetricsService.logPremiumPurchaseSuccess(source: 'revenuecat');
      }
    } catch (e) {
      AppLogger.e('Purchase error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo completar la compra premium.',
      );
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(premiumRepositoryProvider);
      final CustomerInfo customerInfo = await repository.restorePurchases();
      final isPremium = customerInfo.entitlements.active.isNotEmpty;
      state = state.copyWith(
        isLoading: false,
        isPremium: isPremium,
      );
    } catch (e) {
      AppLogger.e('Restore purchases error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudieron restaurar las compras.',
      );
    }
  }
}

@riverpod
PremiumRepository premiumRepository(PremiumRepositoryRef ref) {
  final revenueCatService = ref.watch(revenueCatServiceProvider);
  return RevenueCatRepositoryImpl(revenueCatService);
}
