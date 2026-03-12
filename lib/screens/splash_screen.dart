import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/video_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _taglineFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );

    // Retardo breve para dar tiempo a que el video de fondo cargue.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  static const _ctaGradient = LinearGradient(
    colors: [Colors.amber, Colors.orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Widget _particle({
    required double left,
    required double top,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FeelTripVideoBackground(), // Mantener video existente
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.deepPurple.withValues(alpha: 0.80),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Stack(
                  children: [
                    // Partículas decorativas sutiles (círculos semi-transparentes).
                    _particle(left: 16, top: 18, size: 10, opacity: 0.22),
                    _particle(left: 64, top: 88, size: 16, opacity: 0.16),
                    _particle(left: 28, top: 220, size: 8, opacity: 0.18),
                    _particle(left: 120, top: 160, size: 12, opacity: 0.14),
                    _particle(left: 250, top: 60, size: 9, opacity: 0.18),
                    _particle(left: 290, top: 180, size: 18, opacity: 0.12),
                    _particle(left: 220, top: 280, size: 10, opacity: 0.14),
                    _particle(left: 40, top: 340, size: 20, opacity: 0.10),
                    _particle(left: 300, top: 360, size: 12, opacity: 0.12),

                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _logoScale,
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 96,
                            ),
                          ),
                          const SizedBox(height: 14),
                          FadeTransition(
                            opacity: _taglineFade,
                            child: Text(
                              'Transforma tu manera de viajar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: const LinearProgressIndicator(
                              minHeight: 6,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.amber),
                              backgroundColor: Color(0x33FFFFFF),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: _ctaGradient,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x66FFB300),
                                  blurRadius: 18,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () {
                                  // Mantener la lógica de navegación existente.
                                  Get.offNamed('/onboarding');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Center(
                                    child: Text(
                                      'EMPEZAR VIAJE',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
