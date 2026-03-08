import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_flags.dart';
import '../core/error_presenter.dart';
import '../models/cart_item_model.dart';
import '../repositories/app_data_repository.dart';
import '../services/observability_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final AppDataRepository _repository = AppDataRepository();

  List<CartItem> _cartItems = <CartItem>[];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isVerifyingPayment = false;
  String? _errorMessage;
  String? _pendingOrderId;

  double get _subtotal =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get _tax => _subtotal * 0.1;
  double get _total => _subtotal + _tax;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _repository.getCurrentUserCartItems();
      if (!mounted) return;
      setState(() {
        _cartItems = result.getOrElse(<CartItem>[]);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = ErrorPresenter.message(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changeQuantity(CartItem item, int nextQuantity) async {
    if (nextQuantity < 1) return;

    setState(() {
      item.quantity = nextQuantity;
    });

    try {
      await _repository.updateCartItemQuantity(
        tripId: item.tripId,
        quantity: nextQuantity,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(ErrorPresenter.message(e)),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _removeItem(CartItem item) async {
    setState(() {
      _cartItems.removeWhere((it) => it.tripId == item.tripId);
    });

    try {
      await _repository.removeCartItem(item.tripId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(ErrorPresenter.message(e)),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadCart,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState(context)
              : _cartItems.isEmpty
                  ? _buildEmptyState(context)
                  : _buildCartContent(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text('Continuar Comprando'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final normalizedError = (_errorMessage ?? '').toLowerCase();
    final isPermissionError = normalizedError.contains('permiso') ||
        normalizedError.contains('permission-denied') ||
        normalizedError.contains('the caller does not have permission');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 44, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'No se pudo cargar el carrito',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadCart,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
            if (isPermissionError) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                icon: const Icon(Icons.login),
                label: const Text('Iniciar sesión'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (showDemoIndicators && _repository.isMockMode)
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Modo demo activo: carrito simulado',
                textAlign: TextAlign.center,
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return Dismissible(
                key: Key(item.tripId),
                onDismissed: (_) {
                  _removeItem(item);
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
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
                          child: const Center(
                            child: Icon(
                              Icons.luggage,
                              size: 32,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.tripTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.destination,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  _changeQuantity(item, item.quantity + 1),
                              iconSize: 18,
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: item.quantity > 1
                                  ? () =>
                                      _changeQuantity(item, item.quantity - 1)
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
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen de Pago',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text('\$${_subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Impuestos (10%):'),
                    Text('\$${_tax.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '\$${_total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _showCheckoutDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Proceder al Pago',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_pendingOrderId != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _isVerifyingPayment ? null : _verifyPendingOrder,
                      icon: _isVerifyingPayment
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.verified),
                      label: Text(
                        _isVerifyingPayment
                            ? 'Verificando pago...'
                            : 'Verificar pago de orden $_pendingOrderId',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.deepPurple),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continuar Comprando',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_cartItems.length} viajes en tu carrito'),
            const SizedBox(height: 12),
            Text(
              'Total: \$${_total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Se enviarán detalles a tu email'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);

              setState(() => _isSubmitting = true);
              try {
                final result = await _repository.startCheckout(
                  items: _cartItems,
                  currency: 'usd',
                );
                final response = result.getOrElse(<String, dynamic>{});
                final orderId = (response['orderId'] ?? '').toString();
                final checkoutUrl = (response['checkoutUrl'] ?? '').toString();

                if (orderId.isNotEmpty) {
                  _pendingOrderId = orderId;
                }

                if (checkoutUrl.isNotEmpty) {
                  final uri = Uri.tryParse(checkoutUrl);
                  if (uri != null) {
                    final launched = await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!launched) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No se pudo abrir checkout automaticamente.',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Orden creada. Falta URL de checkout. Revisa backend.',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                setState(() => _isSubmitting = false);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(ErrorPresenter.message(e)),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
              if (!mounted) return;

              setState(() {
                _isSubmitting = false;
              });

              messenger.showSnackBar(
                const SnackBar(
                  content: Text(
                    'Checkout iniciado. Completa el pago y luego verifica.',
                  ),
                  backgroundColor: Colors.deepPurple,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text('Confirmar Pago'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPendingOrder() async {
    final orderId = _pendingOrderId;
    if (orderId == null || orderId.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isVerifyingPayment = true);

    try {
      final result = await _repository.getCheckoutOrderStatus(orderId);
      final statusResponse = result.getOrElse(<String, dynamic>{});
      final status = (statusResponse['status'] ?? '').toString().toLowerCase();

      if (status == 'paid') {
        await _repository.clearCurrentUserCart();
        await ObservabilityService.logCheckoutCompleted(
          itemCount: _cartItems.length,
          total: _total,
        );
        if (!mounted) return;
        setState(() {
          _pendingOrderId = null;
        });
        await _loadCart();
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Pago confirmado. Orden marcada como pagada.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Estado actual de la orden: $status'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(ErrorPresenter.message(e)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isVerifyingPayment = false);
      }
    }
  }
}
