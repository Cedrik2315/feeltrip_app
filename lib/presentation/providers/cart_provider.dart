import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feeltrip_app/models/cart_item_model.dart';
import 'package:feeltrip_app/services/cart_service.dart';

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService();
});

final cartItemsProvider =
    StreamProvider.family<List<CartItem>, String>((ref, userId) {
  return ref.watch(cartServiceProvider).watchCart(userId);
});
