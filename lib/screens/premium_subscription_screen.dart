import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';

// Asumo que este es el provider que mencionabas en los comentarios
// final premiumNotifierProvider = ...

class PremiumSubscriptionScreen extends ConsumerStatefulWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  ConsumerState<PremiumSubscriptionScreen> createState() =>
      _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState
    extends ConsumerState<PremiumSubscriptionScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _crownController;
  String? selectedPackageIdentifier;

  final List<Animation<double>> _particleAnimations = [];

  @override
  void initState() {
    super.initState();
    AnalyticsService.logPremiumViewed();
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _crownController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    for (int i = 0; i < 25; i++) {
      _particleAnimations.add(
        Tween<double>(begin: 0.8, end: 1.2).animate(
          CurvedAnimation(
            parent: _particleController,
            curve: Interval(i * 0.04, 1.0, curve: Curves.easeInOut),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _crownController.dispose();
    super.dispose();
  }

  Widget _buildBenefitRow(String emoji, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FeelTrip Premium',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D0D0D), Colors.black],
              ),
            ),
          ),
          ...List.generate(
            25,
            (index) => AnimatedBuilder(
              animation: _particleAnimations[index],
              builder: (context, child) {
                final size = MediaQuery.of(context).size;
                final x = (index * 123.45) % size.width;
                final y = (index * 234.56) % size.height;
                return Positioned(
                  left: x +
                      (math.sin(_particleController.value * 2 * math.pi) * 15),
                  top: y + (math.cos(_particleController.value * math.pi) * 10),
                  child: Container(
                    width: 4 + 2 * _particleAnimations[index].value,
                    height: 4 + 2 * _particleAnimations[index].value,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Premium Header
                Column(
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                        CurvedAnimation(
                            parent: _crownController, curve: Curves.easeInOut),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.6),
                              blurRadius: 25,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.3),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          size: 80,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'FeelTrip Premium',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Desbloquea IA ilimitada, mapas exclusivos y analytics avanzados',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
                // Benefits
                Column(
                  children: [
                    _buildBenefitRow('✨', 'Sin anuncios',
                        'Disfruta la app sin interrupciones'),
                    _buildBenefitRow(
                        '🗺️', 'Mapas exclusivos', 'Descubre destinos únicos'),
                    _buildBenefitRow(
                        '🤖', 'IA ilimitada', 'Genera planes sin límites'),
                    _buildBenefitRow('📊', 'Analytics avanzados',
                        'Métricas de tu transformación'),
                  ],
                ),
                const SizedBox(height: 40),

                // Aquí deberías mapear tus paquetes reales de RevenueCat
                // Por ahora, el botón de CTA se mantiene visible

                const SizedBox(height: 24),
                // CTA Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: selectedPackageIdentifier != null
                        ? () {
                            // Lógica de compra
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Prueba 7 días GRATIS',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
