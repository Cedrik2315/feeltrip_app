import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:feeltrip_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:feeltrip_app/services/revenuecat_service.dart';

class RevenueCatRepositoryImpl implements PremiumRepository {
  RevenueCatRepositoryImpl(this.revenueCatService);

  final RevenueCatService revenueCatService;

  @override
  Future<List<Offering>> getOfferings() async {
    return revenueCatService.getOfferings();
  }

  @override
  Future<CustomerInfo> purchasePackage(Package package) async {
    return revenueCatService.purchasePackage(package);
  }

  @override
  Future<CustomerInfo> restorePurchases() async {
    return revenueCatService.restorePurchases();
  }

  @override
  Future<bool> isPremium() async {
    return revenueCatService.isPremium();
  }
}
