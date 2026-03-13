import 'dart:developer' as developer;

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio de suscripciones premium usando RevenueCat
/// Gestiona compras, suscripciones y entitlements
class RevenueCatService {
  RevenueCatService({
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  // Configuración de RevenueCat
  // La API Key se obtiene de las variables de entorno (.env)
  static String get _apiKey {
    final key = dotenv.env['REVENUECAT_API_KEY'] ?? '';
    if (key.isEmpty) {
      developer.log(
        'ADVERTENCIA: REVENUECAT_API_KEY no configurada en .env',
        name: 'RevenueCatService',
      );
      return key;
    }

    final isPublicKey = key.startsWith('appl_') || key.startsWith('goog_');
    if (!isPublicKey) {
      developer.log(
        'ERROR: REVENUECAT_API_KEY inválida para cliente móvil. Usa public key (appl_/goog_).',
        name: 'RevenueCatService',
      );
      return '';
    }
    return key;
  }

  static bool get isConfigured => _apiKey.isNotEmpty;

  bool _isInitialized = false;
  CustomerInfo? _customerInfo;

  // Getters
  bool get isPremium => _customerInfo?.entitlements.active['premium'] != null;
  CustomerInfo? get customerInfo => _customerInfo;

  /// Inicializa el SDK de RevenueCat
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Verificar que la API key esté configurada
    if (!isConfigured) {
      developer.log(
        'RevenueCat no inicializado: API key no configurada',
        name: 'RevenueCatService',
      );
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      // Configurar usuario autenticado si existe
      final user = _auth.currentUser;
      if (user != null) {
        await Purchases.logIn(user.uid);
      }

      await Purchases.configure(PurchasesConfiguration(_apiKey));
      _isInitialized = true;

      // Obtener info del cliente
      await _fetchCustomerInfo();

      developer.log(
        'RevenueCat initialized successfully',
        name: 'RevenueCatService',
      );
    } catch (e) {
      developer.log(
        'Error initializing RevenueCat: $e',
        name: 'RevenueCatService',
        error: e,
      );
    }
  }

  /// Obtiene la información del cliente
  Future<void> _fetchCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      developer.log(
        'Customer info fetched: ${_customerInfo?.entitlements.active.keys}',
        name: 'RevenueCatService',
      );
    } catch (e) {
      developer.log(
        'Error fetching customer info: $e',
        name: 'RevenueCatService',
        error: e,
      );
    }
  }

  /// Obtiene los paquetes disponibles
  Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
      return [];
    } catch (e) {
      developer.log(
        'Error getting packages: $e',
        name: 'RevenueCatService',
        error: e,
      );
      return [];
    }
  }

  /// Compra un paquete
  /// ignore: deprecated_member_use - El método purchasePackage es el más estable
  Future<bool> purchasePackage(Package package) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await Purchases.logIn(user.uid);
      }

      // Usar purchasePackage que está deprecated pero es estable
      // ignore: deprecated_member_use
      final result = await Purchases.purchasePackage(package);

      if (result.customerInfo.entitlements.active['premium'] != null) {
        developer.log(
          'Purchase successful! User is now premium.',
          name: 'RevenueCatService',
        );
        await _fetchCustomerInfo();
        return true;
      }
      return false;
    } catch (e) {
      developer.log(
        'Error purchasing package: $e',
        name: 'RevenueCatService',
        error: e,
      );
      return false;
    }
  }

  /// Restaura compras anteriores
  Future<bool> restorePurchases() async {
    try {
      // Usar el método correcto de RevenueCat
      final result = await Purchases.getCustomerInfo();
      await _fetchCustomerInfo();

      final isPremium = result.entitlements.active['premium'] != null;
      developer.log(
        'Restore result: isPremium=$isPremium',
        name: 'RevenueCatService',
      );
      return isPremium;
    } catch (e) {
      developer.log(
        'Error restoring purchases: $e',
        name: 'RevenueCatService',
        error: e,
      );
      return false;
    }
  }

  /// Cancela la suscripción (solo indica la UI)
  Future<void> showCancelation() async {
    // RevenueCat no permite cancelación programática
    // Redirigir a la tienda correspondiente
    developer.log(
      'User requested cancellation - redirect to store',
      name: 'RevenueCatService',
    );
  }

  /// Obtiene el estado premium actual
  Future<bool> checkPremiumStatus() async {
    try {
      await _fetchCustomerInfo();
      return isPremium;
    } catch (e) {
      return false;
    }
  }

  /// Sincroniza el usuario después del login
  Future<void> syncUserAfterLogin(String uid) async {
    try {
      await Purchases.logIn(uid);
      await _fetchCustomerInfo();
    } catch (e) {
      developer.log(
        'Error syncing user: $e',
        name: 'RevenueCatService',
        error: e,
      );
    }
  }

  /// Desconecta el usuario en logout
  Future<void> syncUserAfterLogout() async {
    try {
      await Purchases.logOut();
      _customerInfo = null;
    } catch (e) {
      developer.log(
        'Error logging out user from RevenueCat: $e',
        name: 'RevenueCatService',
        error: e,
      );
    }
  }

  /// Identifica atributos del usuario para analytics
  Future<void> setUserAttributes({
    String? email,
    String? displayName,
  }) async {
    try {
      final attributes = <String, String>{};
      if (email != null) attributes['email'] = email;
      if (displayName != null) attributes['display_name'] = displayName;

      await Purchases.setAttributes(attributes);
    } catch (e) {
      developer.log(
        'Error setting user attributes: $e',
        name: 'RevenueCatService',
        error: e,
      );
    }
  }
}

/// Extension para obtener información de los paquetes
extension PackageExtension on Package {
  String get priceString => storeProduct.priceString;
  PackageType get type => packageType;

  String get periodString {
    switch (packageType) {
      case PackageType.monthly:
        return 'mes';
      case PackageType.annual:
        return 'año';
      case PackageType.lifetime:
        return 'vida';
      default:
        return '';
    }
  }
}

/// Clase para representar información de suscripción
class SubscriptionInfo {
  final bool isPremium;
  final DateTime? expirationDate;
  final String? planName;

  SubscriptionInfo({
    required this.isPremium,
    this.expirationDate,
    this.planName,
  });

  bool get isActive =>
      isPremium &&
      (expirationDate == null || expirationDate!.isAfter(DateTime.now()));
}
