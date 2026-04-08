import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Un indicador visual minimalista para notificaciones.
/// Diseñado para encajar en el AppBar de la expedición.
class NotificationBadge extends StatelessWidget {
  final int? count;
  final Color color;

  const NotificationBadge({
    super.key,
    this.count,
    this.color = const Color(0xFFFF8F00), // Color de acento de FeelTrip
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCount = count != null && count! > 0;

    return Container(
      width: hasCount ? 14 : 10,
      height: hasCount ? 14 : 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: hasCount
          ? Center(
              child: Text(
                count! > 9 ? '!' : count.toString(),
                style: GoogleFonts.jetBrainsMono(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}