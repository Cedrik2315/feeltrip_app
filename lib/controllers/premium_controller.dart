import 'package:get/get.dart';

class PremiumController extends GetxController {
  final RxBool isPremium = false.obs;
  final RxBool isLoading = false.obs;
  final RxList offerings = [].obs;

  Future<void> checkPremiumStatus() async {}
  Future<void> purchasePremium(String packageId) async {}
  Future<void> restorePurchases() async {}
  Future<void> purchase(dynamic package) async {}
}
