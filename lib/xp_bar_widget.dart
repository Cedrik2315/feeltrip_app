import 'package:flutter/material.dart';
import 'level_service.dart';

class XpBarWidget extends StatelessWidget {
  final int totalXP;

  const XpBarWidget({super.key, required this.totalXP});

  @override
  Widget build(BuildContext context) {
    final nivel = LevelService.calcularNivel(totalXP);
    final progreso = LevelService.progresoNivel(totalXP);
    final xpSigNivel = LevelService.xpParaSiguienteNivel(totalXP);
    final titulo = LevelService.obtenerTitulo(nivel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nivel $nivel',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$xpSigNivel XP para el siguiente nivel',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
