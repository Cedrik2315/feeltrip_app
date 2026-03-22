import 'package:purchases_flutter/purchases_flutter.dart';

abstract class PremiumRepository {
  Future<List<Offering>> getOfferings();
  Future<CustomerInfo> purchasePackage(Package package);
  Future<CustomerInfo> restorePurchases();
  Future<bool> isPremium();
}