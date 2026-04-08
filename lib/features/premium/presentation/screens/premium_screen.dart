import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/core/error/error_handler.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/payment_repository.dart';
import 'package:feeltrip_app/services/metrics_service.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FeelTrip Premium'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome,
                  size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text(
                'Desbloquea tu potencial viajero',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Suscribete para acceder al diario emocional avanzado, analisis de IA y experiencias exclusivas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => _handlePayment(context, ref),
                child: const Text('Comenzar Suscripcion'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayment(BuildContext context, WidgetRef ref) async {
    final authState = ref.read(authNotifierProvider);
    final String? userId = authState.whenOrNull(data: (user) => user?.id);

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, inicia sesion para continuar'),
        ),
      );
      return;
    }

    MetricsService.logPremiumViewed();
    MetricsService.logPremiumPurchaseStarted(source: 'premium_screen');

    final result = await ref.read(paymentRepositoryProvider).createCheckoutSession(
          const PaymentRequest(
            amount: 5000.0,
            title: 'FeelTrip Premium Subscription',
            purpose: 'premium',
          ),
        );

    await result.fold(
      (failure) async => ErrorHandler.handleError(
        context,
        failure.message,
        StackTrace.current,
      ),
      (session) async {
        final url = Uri.parse(session.initPoint);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication) &&
            context.mounted) {
          ErrorHandler.handleError(
            context,
            'No se pudo abrir el enlace de pago',
            StackTrace.current,
          );
        }
      },
    );
  }
}
