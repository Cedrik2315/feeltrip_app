import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class EmotionalRadarChart extends StatelessWidget {
  const EmotionalRadarChart({super.key, required this.stats});
  
  // Mapa de: "Nombre de Emoción" -> Valor (0.0 a 1.0)
  final Map<String, double> stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: CustomPaint(
        size: Size.infinite,
        painter: RadarPainter(
          stats: stats,
          color: const Color(0xFFFF8F00),
          labelStyle: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  RadarPainter({required this.stats, required this.color, required this.labelStyle});

  final Map<String, double> stats;
  final Color color;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.8;
    final angleStep = (math.pi * 2) / stats.length;

    final paintLine = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final paintFill = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // 1. Dibujar la red de fondo (Pentágono/Hexágono)
    for (var i = 1; i <= 4; i++) {
      final r = radius * (i / 4);
      final path = Path();
      for (var j = 0; j < stats.length; j++) {
        final x = center.dx + r * math.cos(j * angleStep - math.pi / 2);
        final y = center.dy + r * math.sin(j * angleStep - math.pi / 2);
        if (j == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, paintLine);
    }

    // 2. Dibujar los datos del usuario
    final dataPath = Path();
    final keys = stats.keys.toList();
    for (var i = 0; i < keys.length; i++) {
      final val = stats[keys[i]]!;
      final r = radius * val;
      final x = center.dx + r * math.cos(i * angleStep - math.pi / 2);
      final y = center.dy + r * math.sin(i * angleStep - math.pi / 2);
      if (i == 0) dataPath.moveTo(x, y); else dataPath.lineTo(x, y);
      
      // Dibujar labels en los vértices externos
      final lx = center.dx + (radius + 20) * math.cos(i * angleStep - math.pi / 2);
      final ly = center.dy + (radius + 10) * math.sin(i * angleStep - math.pi / 2);
      _drawText(canvas, keys[i].toUpperCase(), Offset(lx - 20, ly), labelStyle);
    }
    dataPath.close();
    canvas.drawPath(dataPath, paintFill);
    canvas.drawPath(dataPath, paintLine..color = color..strokeWidth = 2);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}