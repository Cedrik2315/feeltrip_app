import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:purchases_flutter/purchases_flutter.dart';
import '../controllers/premium_controller.dart';
import '../services/analytics_service.dart';

class PremiumSubscriptionScreen extends StatefulWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  State<PremiumSubscriptionScreen> createState() =>
      _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends State<PremiumSubscriptionScreen>
    with TickerProviderStateMixin {
  final PremiumController controller = Get.find();
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
                            (math.sin(_particleController.value * 2 * math.pi) *
                                15),
                        top: y +
                            (math.cos(_particleController.value * math.pi) *
                                10),
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
                  )),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.amber));
            }

            if (controller.offerings.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No hay planes de suscripción disponibles en este momento. Por favor, intenta más tarde.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            final offering = controller.offerings
                .firstWhereOrNull((o) => o.availablePackages.isNotEmpty);

            if (offering == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No se encontraron paquetes de suscripción válidos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Premium Header
                  Column(
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                          CurvedAnimation(
                              parent: _crownController,
                              curve: Curves.easeInOut),
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
                                spreadRadius: 0,
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
                          'Disfruta la app completamente sin interrupciones'),
                      _buildBenefitRow('🗺️', 'Mapas exclusivos',
                          'Descubre destinos únicos con nuestras capas premium'),
                      _buildBenefitRow('🤖', 'IA ilimitada',
                          'Genera planes personalizados sin límites'),
                      _buildBenefitRow('📊', 'Analytics avanzados',
                          'Métricas profundas de tu transformación emocional'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Plans
                  ...offering.availablePackages
                      .map((package) => _buildPackageCard(context, package))
                      .toList(),
                  const SizedBox(height: 24),
                  // CTA Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
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
                              final pkg = offering.availablePackages.firstWhere(
                                (p) =>
                                    p.identifier == selectedPackageIdentifier,
                              );
                              AnalyticsService.logPremiumAttempt(
                                  pkg.storeProduct.title);
                              controller.purchase(pkg);
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, Package package) {
    final isAnnual =
        package.storeProduct.title.toLowerCase().contains('anual') ||
            package.storeProduct.title.toLowerCase().contains('year');
    final isLifetime =
        package.storeProduct.title.toLowerCase().contains('lifetime') ||
            package.storeProduct.title.toLowerCase().contains('vitalicio');
    final isSelected = selectedPackageIdentifier == package.identifier;
    final isPopular = isAnnual;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Colors.amber
              : isLifetime || isPopular
                  ? Colors.amber.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
          width: isSelected
              ? 3
              : isLifetime
                  ? 2
                  : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              selectedPackageIdentifier =
                  selectedPackageIdentifier == package.identifier
                      ? null
                      : package.identifier;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            package.storeProduct.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        if (isPopular) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red, width: 1),
                            ),
                            child: const Text(
                              'Más popular 🔥',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      package.storeProduct.description,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      package.storeProduct.priceString,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.amber, size: 24),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
