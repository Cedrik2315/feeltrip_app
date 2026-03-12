import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/video_background.dart';
import '../widgets/glass_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Inicia una animación con retardo para dar tiempo a que el video de fondo cargue.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FeelTripVideoBackground(), // El video de fondo
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.80),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 2),
              curve: Curves.easeIn,
              child: SizedBox.expand(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset('assets/images/logo.png', height: 64),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: GlassButton(
                          text: "EMPEZAR VIAJE",
                          onPressed: () {
                            Get.offNamed('/onboarding');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
