import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

enum PaymentStatus { pending, success, error }

class PaymentStatusScreen extends StatelessWidget {
  final PaymentStatus status;
  final String? errorMessage;
  final String? bookingId;

  const PaymentStatusScreen({
    super.key,
    required this.status,
    this.errorMessage,
    this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 40),
            _buildTitle(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 60),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (status) {
      case PaymentStatus.pending:
        return Icon(Icons.hourglass_empty_rounded, size: 80, color: Colors.amber[400])
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 2.seconds)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1.seconds, curve: Curves.easeInOut);
      case PaymentStatus.success:
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.teal.withValues(alpha: 0.1),
          ),
          child: const Icon(Icons.check_circle_outline_rounded, size: 80, color: Colors.tealAccent),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).shimmer(duration: 2.seconds);
      case PaymentStatus.error:
        return const Icon(Icons.error_outline_rounded, size: 80, color: Colors.redAccent)
            .animate()
            .shake(duration: 500.ms);
    }
  }

  Widget _buildTitle() {
    String text;
    Color color;
    switch (status) {
      case PaymentStatus.pending:
        text = 'PROCESANDO VÍNCULO';
        color = Colors.amber[400]!;
        break;
      case PaymentStatus.success:
        text = 'VÍNCULO EXITOSO';
        color = Colors.tealAccent;
        break;
      case PaymentStatus.error:
        text = 'NODO INTERRUMPIDO';
        color = Colors.redAccent;
        break;
    }

    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildDescription() {
    String text;
    switch (status) {
      case PaymentStatus.pending:
        text = 'Estamos verificando tu transacción en los nodos financieros. Esto puede tomar unos segundos...';
        break;
      case PaymentStatus.success:
        text = 'Tu experiencia ha sido desbloqueada. El mapa ahora brilla con nuevas posibilidades.';
        break;
      case PaymentStatus.error:
        text = errorMessage ?? 'Hubo un problema al procesar el pago. El flujo de energía se interrumpió de forma inesperada.';
        break;
    }

    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.outfit(
        fontSize: 16,
        color: Colors.white70,
        height: 1.5,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (status == PaymentStatus.pending) {
      return const Column(
        children: [
          CircularProgressIndicator(color: Colors.white24, strokeWidth: 2),
          SizedBox(height: 20),
          Text('SINCRONIZANDO...', style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
        ],
      );
    }

    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            if (status == PaymentStatus.success) {
              context.go('/bookings');
            } else {
              context.pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: status == PaymentStatus.success ? Colors.tealAccent : Colors.white10,
            foregroundColor: status == PaymentStatus.success ? Colors.black : Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(
            status == PaymentStatus.success ? 'VER MIS VIAJES' : 'REINTENTAR ACCESO',
            style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
        if (status == PaymentStatus.error) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('VOLVER AL FEED', style: TextStyle(color: Colors.white38)),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 500.ms);
  }
}
