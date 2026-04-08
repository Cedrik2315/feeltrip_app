import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:feeltrip_app/models/cart_item_model.dart';

class CartService {
  CartService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _cartItemsRef(String userId) {
    return _firestore.collection('carts').doc(userId).collection('items');
  }

  Stream<List<CartItem>> watchCart(String userId) {
    return _cartItemsRef(userId).snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) {
        return CartItem.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();

      items.sort((a, b) => a.title.compareTo(b.title));
      return items;
    });
  }

  Future<void> updateQuantity({
    required String userId,
    required CartItem item,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeItem(userId: userId, itemId: _resolveDocId(item));
      return;
    }

    await _cartItemsRef(userId).doc(_resolveDocId(item)).set({
      ...item.copyWith(quantity: quantity).toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeItem({
    required String userId,
    required String itemId,
  }) async {
    await _cartItemsRef(userId).doc(itemId).delete();
  }

  String _resolveDocId(CartItem item) {
    if (item.id.isNotEmpty) return item.id;
    if (item.tripId.isNotEmpty) return item.tripId;
    if (item.experienceId.isNotEmpty) return item.experienceId;
    return item.title;
  }
}
