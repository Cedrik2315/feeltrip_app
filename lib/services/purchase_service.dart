import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as purchases;

class PurchaseService {
  static const String premiumEntitlementId = 'premium';

  final _customerInfoController =
      StreamController<purchases.CustomerInfo>.broadcast();
  Stream<purchases.CustomerInfo> get customerInfoStream =>
      _customerInfoController.stream;

  bool _isConfigured = false;

  PurchaseService() {
    purchases.Purchases.addCustomerInfoUpdateListener((customerInfo) {
      if (!_customerInfoController.isClosed) {
        _customerInfoController.add(customerInfo);
      }
    });
  }

  Future<void> initialize() async {
    await _ensureConfigured();
  }

  Future<void> _ensureConfigured() async {
    if (_isConfigured) return;
    if (kIsWeb) return;

    final apiKey = switch (defaultTargetPlatform) {
      TargetPlatform.android => dotenv.env['REVENUECAT_GOOGLE_KEY'] ?? '',
      TargetPlatform.iOS => dotenv.env['REVENUECAT_APPLE_KEY'] ?? '',
      _ => '',
    };

    if (apiKey.isEmpty) {
      debugPrint(
        'RevenueCat not configured: set REVENUECAT_GOOGLE_KEY/REVENUECAT_APPLE_KEY in .env',
      );
      return;
    }

    try {
      await purchases.Purchases.setLogLevel(
          kDebugMode ? purchases.LogLevel.debug : purchases.LogLevel.info);
      await purchases.Purchases.configure(
          purchases.PurchasesConfiguration(apiKey));
      _isConfigured = true;
    } on PlatformException catch (e) {
      debugPrint('RevenueCat configure failed: ${e.message}');
    }
  }

  Future<void> login(String userId) async {
    await _ensureConfigured();
    if (!_isConfigured) return;

    try {
      await purchases.Purchases.logIn(userId);
    } on PlatformException catch (e) {
      debugPrint('RevenueCat logIn failed: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _ensureConfigured();
    if (!_isConfigured) return;

    try {
      await purchases.Purchases.logOut();
    } on PlatformException catch (e) {
      debugPrint('RevenueCat logOut failed: ${e.message}');
    }
  }

  Future<List<purchases.Offering>> getOfferings() async {
    await _ensureConfigured();
    if (!_isConfigured) return [];

    try {
      final offerings = await purchases.Purchases.getOfferings();
      return offerings.all.values.toList();
    } catch (e) {
      debugPrint('RevenueCat getOfferings failed: $e');
      return [];
    }
  }

  Future<bool> purchasePackage(purchases.Package package) async {
    await _ensureConfigured();
    if (!_isConfigured) return false;

    try {
      // ignore: deprecated_member_use
      final purchaseResult = await purchases.Purchases.purchasePackage(package);
      return purchaseResult
              .customerInfo.entitlements.all[premiumEntitlementId]?.isActive ??
          false;
    } catch (e) {
      debugPrint('RevenueCat purchase failed: $e');
      return false;
    }
  }

  void dispose() {
    _customerInfoController.close();
  }
}
