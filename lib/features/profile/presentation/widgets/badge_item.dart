import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BadgeItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isUnlocked;
  final String description;

  const BadgeItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isUnlocked,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final color = isUnlocked ? const Color(0xFFFF8F00) : Colors.grey;

    return Tooltip(
      message: description,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1, // Envolvemos en AspectRatio para que sea cuadrado
            child: Container(
              decoration: BoxDecoration(
                color: isUnlocked 
                    ? color.withValues(alpha: 0.1) // Nueva sintaxis .withValues
                    : Colors.transparent,
                border: Border.all(
                  color: isUnlocked ? color : color.withValues(alpha: 0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.white : Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}