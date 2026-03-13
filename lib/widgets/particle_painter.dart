import 'dart:math';
import 'package:flutter/material.dart';

class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final Random random = Random();

  ParticlePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.amber.withValues(alpha: 0.6);

    for (int i = 0; i < 50; i++) {
      // Calculamos posiciones erráticas que convergen al centro
      double progress = animation.value;
      double x = size.width / 2 +
          (random.nextDouble() - 0.5) * size.width * (1 - progress);
      double y = size.height / 2 +
          (random.nextDouble() - 0.5) * size.height * (1 - progress);

      canvas.drawCircle(Offset(x, y), 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
