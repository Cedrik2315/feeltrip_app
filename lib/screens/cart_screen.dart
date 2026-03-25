import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión')),
      );
    }

    final cartRef =
        FirebaseFirestore.instance.collection('carts').doc(user.uid).collection('items');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error: \${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Tu carrito está vacío',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    child: const Text('Continuar Comprando'),
                  ),
                ],
              ),
            );
          }

          final cartItems = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return CartItem.fromJson(data);
          }).toList();

          final subtotal = cartItems.fold<double>(0, (total, item) => total + item.total);
          final tax = subtotal * 0.1;
          final total = subtotal + tax;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Items
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    CartItem item = cartItems[index];

                    final docRef =
                        cartRef.doc(item.tripId); // Use tripId as doc id or item.id if set

                    return Dismissible(
                      key: Key(item.tripId),
                      onDismissed: (_) async {
                        await docRef.delete();
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: const EdgeInsets.all(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.purple[100],
                                ),
                                child: Center(
                                    child: Text(item.image, style: const TextStyle(fontSize: 32))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.tripTitle,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text(item.destination,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    Text('\$${item.price}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () async {
                                      item = item.copyWith(quantity: item.quantity + 1);
                                      await docRef.update({'quantity': item.quantity});
                                      setState(() {}); // Refresh UI
                                    },
                                    iconSize: 18,
                                  ),
                                  const Text('\${item.quantity}'),
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: item.quantity > 1
                                        ? () async {
                                            item = item.copyWith(quantity: item.quantity - 1);
                                            await docRef.update({'quantity': item.quantity});
                                            setState(() {}); // Refresh UI
                                          }
                                        : null,
                                    iconSize: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Summary
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Resumen de Pago',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Subtotal:'),
                        Text('\$${subtotal.toStringAsFixed(2)}')
                      ]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Impuestos (10%):'),
                        Text('\$${tax.toStringAsFixed(2)}')
                      ]),
                      const SizedBox(height: 8),
                      const Divider(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Total:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepPurple)),
                      ]),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/bookings'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Proceder al Pago',
                              style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.deepPurple),
                              padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Continuar Comprando',
                              style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
