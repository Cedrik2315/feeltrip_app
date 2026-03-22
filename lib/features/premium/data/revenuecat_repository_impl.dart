import 'package:feeltrip_app/features/premium/domain/repositories/premium_repository.dart';
import 'package:feeltrip_app/services/revenuecat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatRepositoryImpl implements PremiumRepository {
  RevenueCatRepositoryImpl(this.revenueCatService);
  final RevenueCatService revenueCatService;

  // By delegating to the service, we centralize the logic and make this repository
  // more testable by allowing a mock service to be injected.
  // This also resolves the `avoid_print` warnings as logging is handled in the service.

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
