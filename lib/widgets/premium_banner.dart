import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart'; // Para el brillo

class PremiumBanner extends StatelessWidget {
  final int nivel;
  final String titulo;

  const PremiumBanner({
    super.key,
    required this.nivel,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        // Degradado Dorado Premium
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animación de Brillo Sutil
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: LoopAnimationBuilder<double>(
                tween: Tween(begin: -1.0, end: 2.0),
                duration: const Duration(seconds: 3),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(value * 100, 0), // Mueve el brillo
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          colors: [Colors.white, Colors.transparent],
                          radius: 1.5,
                          stops: [0.0, 1.0],
                          center: Alignment.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Contenido del Banner
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icono de Corona Dorada
                const Icon(Icons.star, color: Colors.white, size: 40),
                const SizedBox(width: 15),
                // Información del Usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "EXPLORADOR PREMIUM",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Nivel $nivel - $titulo",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
