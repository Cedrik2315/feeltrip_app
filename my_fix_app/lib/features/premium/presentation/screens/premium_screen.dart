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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('FeelTrip Premium'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome,
                  size: 80, color: colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Desbloquea tu potencial viajero',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.onSurface
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Suscríbete para acceder al diario emocional avanzado, análisis de IA y experiencias exclusivas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                    shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  onPressed: () => _handlePayment(context, ref),
                  child: const Text(
                    'COMENZAR SUSCRIPCIÓN',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
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
