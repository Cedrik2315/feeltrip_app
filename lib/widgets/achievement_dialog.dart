import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class AchievementDialog extends StatefulWidget {
  final String title;
  final IconData icon;
  final String? description;

  const AchievementDialog(
      {super.key, required this.title, required this.icon, this.description});

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play(); // ¡Inicia la fiesta!
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Icon(widget.icon, size: 80, color: Colors.amber),
                const SizedBox(height: 15),
                const Text("¡NUEVO LOGRO!",
                    style: TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple)),
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(widget.description ?? "Tu viaje está dejando huella.",
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("¡Genial!"),
                )
              ],
            ),
          ),
          // El emisor de confeti
          ConfettiWidget(
            confettiController: _controller,
            blastDirection: -pi / 2, // Hacia arriba
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 20,
            minBlastForce: 10,
            gravity: 0.1,
            colors: const [
              Colors.deepPurple,
              Colors.amber,
              Colors.pink,
              Colors.blue
            ],
          ),
        ],
      ),
    );
  }
}
