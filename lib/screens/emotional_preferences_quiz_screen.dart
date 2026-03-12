import 'package:flutter/material.dart';

class EmotionalPreferencesQuizScreen extends StatefulWidget {
  const EmotionalPreferencesQuizScreen({super.key});

  @override
  State<EmotionalPreferencesQuizScreen> createState() =>
      _EmotionalPreferencesQuizScreenState();
}

class _EmotionalPreferencesQuizScreenState
    extends State<EmotionalPreferencesQuizScreen> {
  final PageController _controller = PageController();
  Color _backgroundColor = Colors.blueGrey.shade900;

  // Datos de ejemplo: Pregunta y el color que activará
  final List<Map<String, dynamic>> _questions = [
    {
      "text": "¿Cómo te sientes hoy?",
      "color": Colors.deepPurple.shade700,
      "personality": "Cyberpunk" // Asociado al estilo cyberpunk_style.json
    },
    {
      "text": "¿Qué paisaje prefieres?",
      "color": Colors.teal.shade700,
      "personality": "Default" // Asociado al estilo por defecto del mapa
    },
    {
      "text": "¿Buscas paz o aventura?",
      "color": Colors.orange.shade800,
      "personality": "Retro" // Asociado al estilo retro_style.json
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage(int index, Color nextColor) {
    // La "personalidad" se determina por la respuesta seleccionada.
    final String personality = _questions[index]['personality'] as String;

    if (index < _questions.length - 1) {
      setState(() {
        _backgroundColor = nextColor;
      });
      _controller.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      // Al llegar al final, volvemos a la pantalla anterior con el resultado.
      if (Navigator.canPop(context)) {
        Navigator.pop(context, personality);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        color: _backgroundColor,
        child: PageView.builder(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(), // Evita scroll manual
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder(
              duration: const Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0.8, end: 1.0),
              builder: (context, double scale, child) {
                return Opacity(
                  opacity:
                      scale, // Aprovechamos el valor del tween para la opacidad
                  child: Transform.scale(scale: scale, child: child),
                );
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _questions[index]["text"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => _nextPage(
                            index, _questions[index]["color"] as Color),
                        child: Text(index < _questions.length - 1
                            ? "Siguiente"
                            : "Finalizar"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
