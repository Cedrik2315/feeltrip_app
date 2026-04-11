import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class PremiumState {

  PremiumState({
    this.isPremium = false,
    this.isLoading = false,
    this.customerInfo,
    this.error,
  });
  final bool isPremium;
  final bool isLoading;
  final CustomerInfo? customerInfo;
  final String? error;
}

final premiumNotifierProvider = StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  return PremiumNotifier();
});

class PremiumNotifier extends StateNotifier<PremiumState> {
  PremiumNotifier() : super(PremiumState()) {
    _init();
  }

  Future<void> _init() async {
    state = PremiumState(isLoading: true);
    try {
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      _updateState(customerInfo);
    } catch (e) {
      AppLogger.e('Error inicializando RevenueCat: $e');
      state = PremiumState(error: e.toString());
    }
  }

  void _updateState(CustomerInfo customerInfo) {
    // Verificamos el entitlement 'premium' configurado en el dashboard de RevenueCat
    final isPremium = customerInfo.entitlements.active.containsKey('premium');
    state = PremiumState(
      isPremium: isPremium,
      customerInfo: customerInfo,
    );
  }

  Future<bool> purchasePackage(Package package) async {
    state = PremiumState(isLoading: true, isPremium: state.isPremium, customerInfo: state.customerInfo);
    try {
      final CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      _updateState(customerInfo);
      return true;
    } catch (e) {
      AppLogger.e('Error en compra: $e');
      state = PremiumState(isPremium: state.isPremium, customerInfo: state.customerInfo, error: e.toString());
      return false;
    }
  }

  Future<void> restorePurchases() async {
    state = PremiumState(isLoading: true, isPremium: state.isPremium, customerInfo: state.customerInfo);
    try {
      final CustomerInfo customerInfo = await Purchases.restorePurchases();
      _updateState(customerInfo);
    } catch (e) {
      AppLogger.e('Error restaurando compras: $e');
      state = PremiumState(isPremium: state.isPremium, customerInfo: state.customerInfo, error: e.toString());
    }
  }
}