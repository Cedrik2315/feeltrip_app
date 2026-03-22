import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:feeltrip_app/features/premium/domain/entities/premium_state.dart';
import 'package:feeltrip_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:feeltrip_app/features/premium/data/revenuecat_repository_impl.dart';
import 'package:feeltrip_app/core/di/providers.dart';

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
    state = state.copyWith(isPremium: await _premiumRepository.isPremium());
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await _premiumRepository.getOfferings();
      state = state.copyWith(offerings: offerings);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> purchasePackage(Package package) async {
    try {
      await _premiumRepository.purchasePackage(package);
      await _loadPremiumStatus();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _premiumRepository.restorePurchases();
      await _loadPremiumStatus();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  final revenueCatService = ref.watch(revenueCatServiceProvider);
  return RevenueCatRepositoryImpl(revenueCatService);
});
