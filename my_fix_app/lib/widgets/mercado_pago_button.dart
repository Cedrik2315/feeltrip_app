import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/models/payment_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/core/navigation/url_launcher_service.dart';

class MercadoPagoButton extends ConsumerStatefulWidget {
  final PaymentItem paymentItem;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const MercadoPagoButton({
    super.key,
    required this.paymentItem,
    this.onSuccess,
    this.onError,
  });

  @override
  ConsumerState<MercadoPagoButton> createState() => _MercadoPagoButtonState();
}

class _MercadoPagoButtonState extends ConsumerState<MercadoPagoButton> {
  bool _isLoading = false;

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);
    
    try {
      final repository = ref.read(paymentRepositoryProvider);
      
      // 1. Crear preferencia y obtener URL dinámica
      final Map<String, dynamic> session = await repository.createPreference(widget.paymentItem);
      final String? initPoint = session['initPoint'] as String?;
      
      // 2. Lanzar la pasarela con la URL oficial de Mercado Pago para el país correspondiente
      if (mounted && initPoint != null) {
        await UrlLauncherService.openUrl(context, initPoint);
        widget.onSuccess?.call();
      }
    } catch (e) {
      debugPrint('Error de pago: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar pago: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
          )
        );
      }
      widget.onError?.call();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _processPayment,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF009EE3), // Mercado Pago Blue
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: _isLoading 
          ? const SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            )
          : const Icon(Icons.shopping_bag_outlined),
      label: Text(
        _isLoading 
          ? 'CONECTANDO PASARELA...'
          : 'PAGAR \$${widget.paymentItem.unitPrice.toStringAsFixed(0)} ${widget.paymentItem.currencyId}',
        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }
}
