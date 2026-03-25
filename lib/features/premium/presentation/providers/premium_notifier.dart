import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:feeltrip_app/features/premium/domain/entities/premium_state.dart';
import 'package:feeltrip_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:feeltrip_app/features/premium/data/revenuecat_repository_impl.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

part 'premium_notifier.g.dart';

@riverpod
class PremiumNotifier extends _$PremiumNotifier {
  PremiumNotifier();

  late PremiumRepository _premiumRepository;

  @override
  PremiumState build() {
    _premiumRepository = ref.watch(premiumRepositoryProvider);
    _loadPremiumStatus();
    _loadOfferings();
    return const PremiumState();
  }

  Future<void> _loadPremiumStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final isPremium = await _premiumRepository.isPremium();
      AppLogger.i('Premium status loaded: $isPremium');
      state = state.copyWith(isPremium: isPremium);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadOfferings() async {
    state = state.copyWith(isLoading: true);
    try {
      AppLogger.i('Loading offerings...');
      final offerings = await _premiumRepository.getOfferings();
      AppLogger.i('Offerings loaded: ${offerings.length}');
      state = state.copyWith(offerings: offerings, errorMessage: null);
    } catch (e) {
      AppLogger.e('Error loading offerings: $e');
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> purchasePackage(Package package) async {
    state = state.copyWith(isLoading: true);
    try {
      AppLogger.i('Starting purchase for package: ${package.identifier}');
      final customerInfo = await _premiumRepository.purchasePackage(package);
      final isPremium = customerInfo.entitlements.active.isNotEmpty;
      AppLogger.i('Purchase completed. Is premium: $isPremium');
      state = state.copyWith(
        isPremium: isPremium,
        activePackage: package,
        errorMessage: null,
      );
    } catch (e) {
      AppLogger.e('Purchase error: $e');
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    try {
      AppLogger.i('Restoring purchases...');
      await _premiumRepository.restorePurchases();
      await _loadPremiumStatus();
      AppLogger.i('Purchases restored');
    } catch (e) {
      AppLogger.e('Restore purchases error: $e');
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  final revenueCatService = ref.watch(revenueCatServiceProvider);
  return RevenueCatRepositoryImpl(revenueCatService);
});
