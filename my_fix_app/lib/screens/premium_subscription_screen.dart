import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:feeltrip_app/features/premium/presentation/providers/premium_notifier.dart';
import 'package:feeltrip_app/features/premium/domain/entities/premium_state.dart';

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

  static const Color rustyEarth = Color(0xFFB85C38);
  static const Color mossGreen = Color(0xFF4A5D23);
  static const Color carbonBlack = Color(0xFF1A1A1B);
  static const Color boneWhite = Color(0xFFF9F6EE);

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _crownController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _particleController.dispose();
    _crownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumNotifierProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: carbonBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('FEELTRIP PREMIUM', 
          style: GoogleFonts.jetBrainsMono(color: rustyEarth, fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: rustyEarth),
      ),
      body: Stack(
        children: [
          // Fondo gradiente base
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF252526), carbonBlack],
                ),
              ),
            ),
          ),

          // Sistema de Partículas (Polvo Dorado)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return Stack(
                  children: List.generate(15, (index) {
                    final x = (index * 137.5) % size.width;
                    final y = (index * 254.1) % size.height;
                    final drift = math.sin(_particleController.value * 2 * math.pi + index) * 30;
                    
                    return Positioned(
                      left: x + drift,
                      top: y + (math.cos(_particleController.value * math.pi + index) * 20),
                      child: Container(
                        width: (index % 3 + 1).toDouble(),
                        height: (index % 3 + 1).toDouble(),
                        decoration: BoxDecoration(
                          color: rustyEarth.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: rustyEarth.withValues(alpha: 0.1), blurRadius: 10)
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  _buildHeader(),
                  const SizedBox(height: 50),
                  _buildBenefitsSection(),
                  const SizedBox(height: 50),
                  _buildOffersList(premiumState),
                  const SizedBox(height: 30),
                  _buildRestoreButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.05).animate(
            CurvedAnimation(parent: _crownController, curve: Curves.easeInOutQuad),
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: rustyEarth.withValues(alpha: 0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: rustyEarth.withValues(alpha: 0.05),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, size: 64, color: rustyEarth),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'DOMINA LA RUTA',
          textAlign: TextAlign.center,
          style: GoogleFonts.jetBrainsMono(
            color: boneWhite,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Desbloquea cartografía avanzada de la V Región y herramientas de análisis con IA para tus expediciones sin conexión.',
          textAlign: TextAlign.center,
          style: GoogleFonts.ebGaramond(
            color: boneWhite.withValues(alpha: 0.7),
            fontSize: 18,
            height: 1.3,
            fontStyle: FontStyle.italic
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      children: [
        _benefitItem(Icons.public_off_outlined, 'Modo Offline Pro', 'Cartografía vectorial de Quillota y alrededores.'),
        const SizedBox(height: 20),
        _benefitItem(Icons.psychology_outlined, 'IA Expert Advisor', 'Consultas técnicas de ruta ilimitadas.'),
        const SizedBox(height: 20),
        _benefitItem(Icons.analytics_outlined, 'Telemetry Cloud', 'Sincroniza tus estadísticas al volver a la red.'),
      ],
    );
  }

  Widget _benefitItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: mossGreen, size: 24),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(subtitle, style: GoogleFonts.ebGaramond(color: boneWhite.withValues(alpha: 0.5), fontSize: 14, height: 1.1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOffersList(PremiumState premiumState) {
    if (premiumState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: rustyEarth, strokeWidth: 1));
    }
    
    final offerings = premiumState.offerings as List<Package>? ?? [];
    if (offerings.isEmpty) {
      return Text('// NO_OFFERS_LOADED', style: GoogleFonts.jetBrainsMono(color: rustyEarth, fontSize: 10));
    }
    
    return Column(
      children: offerings.map<Widget>((Package pkg) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: boneWhite.withValues(alpha: 0.02),
            border: Border.all(color: rustyEarth.withValues(alpha: 0.4), width: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: InkWell(
            onTap: () => ref.read(premiumNotifierProvider.notifier).purchasePackage(pkg),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(pkg.storeProduct.title.toUpperCase(), 
                    style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 11, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Text(pkg.storeProduct.priceString, 
                    style: GoogleFonts.jetBrainsMono(color: rustyEarth, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: rustyEarth,
                    child: Center(
                      child: Text('ACTIVAR SUSCRIPCIÓN', 
                        style: GoogleFonts.jetBrainsMono(color: carbonBlack, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: () => ref.read(premiumNotifierProvider.notifier).restorePurchases(),
      child: Text('RESTORE PREVIOUS PURCHASES', 
        style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.3), fontSize: 10)),
    );
  }
}