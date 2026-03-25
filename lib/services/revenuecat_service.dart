import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class RevenueCatService {
  Future<void> init() async {
    // CORRECCIÓN: setDebugLogsEnabled ahora es setLogLevel
    await Purchases.setLogLevel(LogLevel.debug);

    late PurchasesConfiguration configuration;

    if (Platform.isAndroid) {
      configuration =
          PurchasesConfiguration(dotenv.env['REVENUECAT_ANDROID_KEY'] ?? 'goog_android_api_key');
    } else if (Platform.isIOS) {
      configuration =
          PurchasesConfiguration(dotenv.env['REVENUECAT_IOS_KEY'] ?? 'appl_ios_api_key');
    } else {
      AppLogger.e('RevenueCat: Plataforma no soportada');
      return;
    }

    // CORRECCIÓN: setup ahora es configure(configuration)
    try {
      await Purchases.configure(configuration);
      AppLogger.i('RevenueCat initialized successfully');
    } catch (e) {
      AppLogger.e('RevenueCat configuration error: $e');
    }
  }

  // CORRECCIÓN: getOfferings ahora devuelve una lista de Offering de forma más directa
  Future<List<Offering>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      // Retornamos la lista de offerings disponibles
      if (offerings.current != null) {
        // Podrías devolver solo el 'current' o todos los 'all'
        return offerings.all.values.toList();
      }
      return [];
    } catch (e) {
      AppLogger.e('RevenueCat offerings error: $e');
      return [];
    }
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      // purchasePackage sigue funcionando igual, pero devuelve CustomerInfo
      final customerInfo = await Purchases.purchasePackage(package);
      AppLogger.i(
          'Purchase success. Active entitlements: ${customerInfo.entitlements.active.keys}');
      return customerInfo;
    } catch (e) {
      AppLogger.e('Purchase error: $e');
      rethrow;
    }
  }

  Future<CustomerInfo> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      AppLogger.i('Purchases restored');
      return customerInfo;
    } catch (e) {
      AppLogger.e('Restore error: $e');
      rethrow;
    }
  }

  Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      // Un usuario es premium si tiene cualquier entitlement activo
      final isPremium = customerInfo.entitlements.active.isNotEmpty;
      AppLogger.i('Premium status check: $isPremium');
      return isPremium;
    } catch (e) {
      AppLogger.e('Premium check error: $e');
      return false;
    }
  }
}
