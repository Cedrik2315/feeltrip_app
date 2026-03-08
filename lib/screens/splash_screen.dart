import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/particle_painter.dart';

class FeelTripSplashScreen extends StatefulWidget {
  const FeelTripSplashScreen({super.key});

  @override
  State<FeelTripSplashScreen> createState() => _FeelTripSplashScreenState();
}

class _FeelTripSplashScreenState extends State<FeelTripSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..forward();

    // Aparece el logo suavemente después de las partículas
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
        HapticFeedback.lightImpact();
      }
    });

    // Navegar a la Home después de la intro
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth_gate');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // Azul muy oscuro, casi negro
      body: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: ParticlePainter(_controller),
            child: Container(),
          ),
          AnimatedOpacity(
            duration: const Duration(seconds: 2),
            opacity: _opacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tu logo. Se ajustó la ruta según tu pubspec.yaml
                Image.asset('assets/images/logo.png', width: 120),
                const SizedBox(height: 20),
                const Text(
                  "FEELTRIP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
                Text(
                  "EL MUNDO TE ESPERA",
                  style: TextStyle(
                      color: Colors.amber.withValues(alpha: 0.7),
                      fontSize: 12,
                      letterSpacing: 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
