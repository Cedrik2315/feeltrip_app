import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/purchase_service.dart';
import 'base_controller.dart';

class PremiumController extends BaseController {
  final PurchaseService _purchaseService;

  PremiumController(this._purchaseService);

  final offerings = <Offering>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    await runBusyFuture(() async {
      final fetchedOfferings = await _purchaseService.getOfferings();
      offerings.assignAll(fetchedOfferings);
    }());
  }

  Future<void> purchase(Package package) async {
    await runBusyFuture(() async {
      final success = await _purchaseService.purchasePackage(package);
      if (success) {
        Get.back(); // Cierra la pantalla premium
        Get.snackbar(
          'Gracias por tu apoyo!',
          'Ahora tienes acceso a todos los beneficios Premium.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        setError(
          'La compra no pudo ser completada. Por favor, intenta de nuevo.',
        );
      }
    }());
  }
}
