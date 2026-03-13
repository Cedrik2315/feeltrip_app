import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/trip_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getCartCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('cartItems');
  }

  Stream<List<CartItem>> getCartItems(String userId) {
    return _getCartCollection(userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList());
  }

  Future<void> addToCart(String userId, Trip trip, {int quantity = 1}) async {
    final cartCollection = _getCartCollection(userId);
    // Evita duplicados. En una app real, podrías querer aumentar la cantidad.
    final querySnapshot =
        await cartCollection.where('tripId', isEqualTo: trip.id).limit(1).get();

    if (querySnapshot.docs.isEmpty) {
      await cartCollection.add(CartItem.toFirestore(trip, quantity));
    } else {
      throw Exception('Este viaje ya está en tu carrito.');
    }
  }

  Future<void> removeFromCart(String userId, String cartItemId) async {
    await _getCartCollection(userId).doc(cartItemId).delete();
  }

  Future<void> clearCart(String userId) async {
    final cartCollection = _getCartCollection(userId);
    final snapshot = await cartCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}