import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/impact_model.dart';

class EmotionChip extends StatelessWidget {
  const EmotionChip({super.key, required this.data});
  final ImpactData data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 85, // Ancho fijo para consistencia en listas horizontales
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: .03) : Colors.black.withValues(alpha: 0.03),
        // Bordes rectos con un pequeño detalle en el color de la emoción
        border: Border(
          bottom: BorderSide(color: data.color, width: 3),
          left: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
          right: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
          top: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.emoji,
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            data.label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          // Indicador de porcentaje con estilo de progreso
          Text(
            '${data.percentage}%',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: data.color,
            ),
          ),
        ],
      ),
    );
  }
}