import 'dart:async';
import '../services/mercado_pago_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cart_item_model.dart';
import '../models/trip_model.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';

class CartController extends GetxController {
  final AuthService _authService;
  final CartService _cartService;
  final MercadoPagoService _mercadoPagoService;

  CartController(
      this._authService, this._cartService, this._mercadoPagoService);

  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxBool isLoading = false.obs;
  StreamSubscription? _cartSubscription;

  String? get _userId => _authService.user?.uid;

  @override
  void onInit() {
    super.onInit();
    // Vincula el stream del carrito al estado del usuario
    _authService.userStream.listen((user) {
      _cartSubscription?.cancel();
      if (user != null) {
        _cartSubscription = _cartService.getCartItems(user.uid).listen((items) {
          cartItems.value = items;
        });
      } else {
        cartItems.clear();
      }
    });
  }

  @override
  void onClose() {
    _cartSubscription?.cancel();
    super.onClose();
  }

  double get totalPrice =>
      cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  Future<void> addToCart(Trip trip) async {
    if (_userId == null) {
      Get.snackbar('Error', 'Debes iniciar sesión para añadir al carrito.');
      return;
    }
    try {
      await _cartService.addToCart(_userId!, trip);
      Get.snackbar(
        '¡Añadido!',
        '${trip.title} se ha añadido a tu carrito.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (_userId == null) return;
    try {
      await _cartService.removeFromCart(_userId!, cartItemId);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar el item del carrito.');
    }
  }

  Future<void> checkout() async {
    if (cartItems.isEmpty) {
      Get.snackbar('Carrito Vacío', 'Añade viajes para poder pagar.');
      return;
    }

    // En una app real, se procesarían todos los items. Aquí usamos el total.
    final success = await _mercadoPagoService.crearPreferenciaYPagar(
      title: 'Compra de Viajes en Feeltrip',
      price: totalPrice,
    );

    if (!success) {
      Get.snackbar('Error de Pago', 'No se pudo iniciar el proceso de pago.');
    }
  }
}
