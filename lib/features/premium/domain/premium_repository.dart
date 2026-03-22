import 'package:purchases_flutter/purchases_flutter.dart';

abstract class PremiumRepository {
  Future<Offerings?> getOfferings();

  Future<CustomerInfo> purchasePackage(Package package);

  Future<CustomerInfo> restorePurchases();

  Future<bool> isPremium();
}

class PremiumFailure implements Exception {
  PremiumFailure(this.message);
  final String message;
}
