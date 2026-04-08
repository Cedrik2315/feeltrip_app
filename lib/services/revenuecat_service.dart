import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:feeltrip_app/core/logger/app_logger.dart';

class RevenueCatService {
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await Purchases.setLogLevel(LogLevel.debug);

    late PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      final key = dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';
      if (key.isEmpty) {
        AppLogger.w('RevenueCat Android key missing. Premium runs in disabled mode.');
        return;
      }
      configuration = PurchasesConfiguration(key);
    } else if (Platform.isIOS) {
      final key = dotenv.env['REVENUECAT_IOS_KEY'] ?? '';
      if (key.isEmpty) {
        AppLogger.w('RevenueCat iOS key missing. Premium runs in disabled mode.');
        return;
      }
      configuration = PurchasesConfiguration(key);
    } else {
      AppLogger.w('RevenueCat not supported on this platform.');
      return;
    }

    try {
      await Purchases.configure(configuration);
      _isInitialized = true;
      AppLogger.i('RevenueCat initialized successfully');
    } catch (e) {
      AppLogger.e('RevenueCat configuration error: $e');
    }
  }

  Future<List<Offering>> getOfferings() async {
    await init();
    if (!_isInitialized) return [];

    try {
      final offerings = await Purchases.getOfferings();
      return offerings.all.values.toList();
    } catch (e) {
      AppLogger.e('RevenueCat offerings error: $e');
      return [];
    }
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    await init();
    if (!_isInitialized) {
      throw StateError('RevenueCat is not initialized');
    }

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      AppLogger.i(
        'Purchase success. Active entitlements: ${customerInfo.entitlements.active.keys}',
      );
      return customerInfo;
    } catch (e) {
      AppLogger.e('Purchase error: $e');
      rethrow;
    }
  }

  Future<CustomerInfo> restorePurchases() async {
    await init();
    if (!_isInitialized) {
      throw StateError('RevenueCat is not initialized');
    }

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
    await init();
    if (!_isInitialized) return false;

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements.active.isNotEmpty;
      AppLogger.i('Premium status check: $isPremium');
      return isPremium;
    } catch (e) {
      AppLogger.e('Premium check error: $e');
      return false;
    }
  }
}
