import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:feeltrip_app/models/cart_item_model.dart';
import 'package:feeltrip_app/presentation/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  // Paleta FeelTrip
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color carbonBlack = Color(0xFF1A1A1A);
  static const Color mossGreen = Color(0xFF4B5320);
  static const Color rustyEarth = Color(0xFFA52A2A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        backgroundColor: boneWhite,
        body: Center(
          child: Text('> ERROR: AUTH_SESSION_REQUIRED', 
            style: GoogleFonts.jetBrainsMono(color: rustyEarth, fontWeight: FontWeight.bold)),
        ),
      );
    }

    final cartAsync = ref.watch(cartItemsProvider(user.uid));

    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: carbonBlack,
        title: Text('CARRITO_COMPRAS.sys', 
          style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 16)),
        iconTheme: const IconThemeData(color: boneWhite),
      ),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: mossGreen)),
        error: (error, _) => Center(
          child: Text('// SYS_ERROR: $error', style: GoogleFonts.jetBrainsMono(color: rustyEarth))
        ),
        data: (cartItems) {
          if (cartItems.isEmpty) {
            return _EmptyCartView(onAction: () => context.pop());
          }

          final subtotal = cartItems.fold<double>(0, (total, item) => total + item.total);
          final tax = subtotal * 0.19; // IVA Chile
          final total = subtotal + tax;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Dismissible(
                      key: Key(item.id.isNotEmpty ? item.id : item.tripId),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) async {
                        await ref.read(cartServiceProvider).removeItem(
                          userId: user.uid,
                          itemId: item.id.isNotEmpty ? item.id : item.tripId,
                        );
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: rustyEarth,
                        child: const Icon(Icons.delete_forever, color: boneWhite),
                      ),
                      child: _CartItemCard(
                        item: item,
                        onIncrement: () => ref.read(cartServiceProvider).updateQuantity(
                          userId: user.uid,
                          item: item,
                          quantity: item.quantity + 1,
                        ),
                        onDecrement: item.quantity > 1
                            ? () => ref.read(cartServiceProvider).updateQuantity(
                                  userId: user.uid,
                                  item: item,
                                  quantity: item.quantity - 1,
                                )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              _CheckoutSummary(subtotal: subtotal, tax: tax, total: total),
            ],
          );
        },
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  final double subtotal, tax, total;
  const _CheckoutSummary({required this.subtotal, required this.tax, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF4B5320).withValues(alpha: 0.5)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _SummaryRow(label: 'SUBTOTAL', value: subtotal),
            _SummaryRow(label: 'TAX_IVA (19%)', value: tax),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Color(0xFFF5F5DC), thickness: 0.5),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL_FINAL', 
                  style: GoogleFonts.jetBrainsMono(color: const Color(0xFFF5F5DC), fontWeight: FontWeight.bold)),
                Text('\$${total.toStringAsFixed(0)}', 
                  style: GoogleFonts.jetBrainsMono(color: const Color(0xFFA52A2A), fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.push('/bookings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5DC),
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text('>> PROCEDER_AL_PAGO', 
                  style: GoogleFonts.jetBrainsMono(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.jetBrainsMono(color: const Color(0xFFF5F5DC).withValues(alpha: 0.6), fontSize: 11)),
          Text('\$${value.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(color: const Color(0xFFF5F5DC), fontSize: 12)),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item, required this.onIncrement, required this.onDecrement});
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        border: Border.all(color: const Color(0xFF1A1A1A).withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1A1A1A)),
              ),
              child: Center(child: Text(item.image, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.tripTitle.toUpperCase(), 
                    style: GoogleFonts.ebGaramond(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('LOC: ${item.destination}', 
                    style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF4B5320))),
                ],
              ),
            ),
            _QuantityController(quantity: item.quantity, onAdd: onIncrement, onRemove: onDecrement),
          ],
        ),
      ),
    );
  }
}

class _QuantityController extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;
  const _QuantityController({required this.quantity, required this.onAdd, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: onRemove, icon: const Icon(Icons.remove, size: 16), color: const Color(0xFFA52A2A)),
        Text('$quantity', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
        IconButton(onPressed: onAdd, icon: const Icon(Icons.add, size: 16), color: const Color(0xFF4B5320)),
      ],
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView({required this.onAction});
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 48, color: Color(0xFF4B5320)),
          const SizedBox(height: 16),
          Text('CARRITO_VACIO', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1A1A1A)),
              shape: const RoundedRectangleBorder(),
            ),
            child: Text('VOLVER_A_EXPLORACION', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF1A1A1A))),
          ),
        ],
      ),
    );
  }
}