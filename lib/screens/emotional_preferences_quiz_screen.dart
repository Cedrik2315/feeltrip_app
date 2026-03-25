import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EmotionalPreferencesQuizScreen extends StatefulWidget {
  const EmotionalPreferencesQuizScreen({super.key});
  @override
  State<EmotionalPreferencesQuizScreen> createState() =>
      _EmotionalPreferencesQuizScreenState();
}

class _EmotionalPreferencesQuizScreenState
    extends State<EmotionalPreferencesQuizScreen> {
  final PageController _pageController = PageController();
  int _currentQuestion = 0;
  final Map<String, int> _scores = {
    'conexion': 0,
    'transformacion': 0,
    'aventura': 0,
    'reflexion': 0,
    'aprendizaje': 0,
  };

  final List<QuizQuestion> questions = [
    QuizQuestion(
      question: '¿Qué buscas cuando viajas?',
      answers: [
        QuizAnswer('Conectar con nuevas personas y culturas', 'conexion'),
        QuizAnswer('Transformar mi perspectiva de la vida', 'transformacion'),
        QuizAnswer('Vivir aventuras y emociones fuertes', 'aventura'),
        QuizAnswer('Reflexionar y encontrar paz interior', 'reflexion'),
      ],
    ),
    QuizQuestion(
      question: '¿Qué tipo de experiencia te impacta más?',
      answers: [
        QuizAnswer('Momentos auténticos con gente local', 'conexion'),
        QuizAnswer(
            'Epifanías que cambian mi forma de pensar', 'transformacion'),
        QuizAnswer('Hazañas que me sacan de mi zona de confort', 'aventura'),
        QuizAnswer('Silencio y contemplación de la belleza', 'reflexion'),
      ],
    ),
    QuizQuestion(
      question: '¿Cuándo sabes que un viaje fue exitoso?',
      answers: [
        QuizAnswer(
            'Cuando he hecho amigos que durarán para siempre', 'conexion'),
        QuizAnswer(
            'Cuando regreso siendo una persona diferente', 'transformacion'),
        QuizAnswer('Cuando he hecho cosas que no pensé posibles', 'aventura'),
        QuizAnswer(
            'Cuando tengo claridad sobre quién soy realmente', 'reflexion'),
      ],
    ),
    QuizQuestion(
      question: '¿Qué emociones buscas sentir?',
      answers: [
        QuizAnswer('Pertenencia y comunidad', 'conexion'),
        QuizAnswer('Renovación y esperanza', 'transformacion'),
        QuizAnswer('Adrenalina y emoción', 'aventura'),
        QuizAnswer('Asombro y gratitud', 'reflexion'),
      ],
    ),
    QuizQuestion(
      question: '¿Cuál es tu mayor miedo en un viaje?',
      answers: [
        QuizAnswer('Sentirme solo y desconectado', 'conexion'),
        QuizAnswer('Que nada cambie en mí', 'transformacion'),
        QuizAnswer('Que sea aburrido o sin desafíos', 'aventura'),
        QuizAnswer('No tener tiempo para reflexionar', 'reflexion'),
      ],
    ),
    QuizQuestion(
      question: '¿Qué rol juegas en un grupo de viaje?',
      answers: [
        QuizAnswer('El que conecta y hace amigos', 'conexion'),
        QuizAnswer('El que cuestiona y busca significado', 'transformacion'),
        QuizAnswer('El que propone actividades audaces', 'aventura'),
        QuizAnswer('El que observa y reflexiona en silencio', 'reflexion'),
      ],
    ),
    QuizQuestion(
      question: '¿Cuál es tu ideal de un recuerdo de viaje?',
      answers: [
        QuizAnswer('Una foto con amigos que hice en el camino', 'conexion'),
        QuizAnswer(
            'Un diario lleno de reflexiones personales', 'transformacion'),
        QuizAnswer('Un video de una hazaña increíble', 'aventura'),
        QuizAnswer('Una sensación indescriptible en el pecho', 'reflexion'),
      ],
    ),
    QuizQuestion(
      question: '¿Cómo prefieres aprender del viaje?',
      answers: [
        QuizAnswer('Conversando profundamente con locales', 'conexion'),
        QuizAnswer('Enfrentando mis miedos y limitaciones', 'transformacion'),
        QuizAnswer('Probando actividades nuevas y extremas', 'aventura'),
        QuizAnswer('Observando la naturaleza y la cultura', 'reflexion'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descubre Tu Viajero Interior'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pregunta ${_currentQuestion + 1} de ${questions.length}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${((_currentQuestion + 1) / questions.length * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentQuestion + 1) / questions.length,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: questions.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 6,
                    dotWidth: 6,
                    activeDotColor: Colors.deepPurple,
                    dotColor: Colors.grey[300]!,
                  ),
                ),
              ],
            ),
          ),

          // Questions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentQuestion = index;
                });
              },
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return _buildQuestion(questions[index]);
              },
            ),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentQuestion > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Atrás'),
                    ),
                  ),
                if (_currentQuestion > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentQuestion < questions.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : () {
                            _showResults();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _currentQuestion < questions.length - 1
                          ? 'Siguiente'
                          : 'Ver Resultados',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(QuizQuestion question) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Column(
              children: question.answers
                  .map((answer) => _buildAnswerButton(answer))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(QuizAnswer answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _scores[answer.category] = (_scores[answer.category] ?? 0) + 1;
          });
          if (_currentQuestion < questions.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            _showResults();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          alignment: Alignment.centerLeft,
        ),
        child: Text(
          answer.text,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  void _showResults() {
    // Encontrar la categoría con mayor puntuación
    final String topCategory =
        _scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final Map<String, Map<String, dynamic>> results = {
      'conexion': {
        'title': 'El Viajero Conector 💕',
        'description':
            'Buscas establecer conexiones auténticas con otras personas y culturas. Para ti, los viajes son sobre crear relaciones significativas y sentir que perteneces a comunidades alrededor del mundo.',
        'recommendation':
            'Te recomendamos experiencias de voluntariado, homestays, talleres con artesanos locales y actividades en grupo donde puedas conocer gente genuina.',
        'color': const Color(0xFFE91E63),
      },
      'transformacion': {
        'title': 'El Viajero Transformado 🦋',
        'description':
            'Los viajes son tu herramienta de crecimiento personal. Buscas experiencias que desafíen tu perspectiva y te ayuden a convertirte en una versión mejorada de ti mismo.',
        'recommendation':
            'Considera retiros de reflexión, viajes de autoconocimiento, meditación, talleres de desarrollo personal y experiencias que toquen tu alma profundamente.',
        'color': const Color(0xFF9C27B0),
      },
      'aventura': {
        'title': 'El Viajero Aventurero ⚡',
        'description':
            'Buscas adrenalina, desafíos y hazañas que prueben tus límites. Para ti, un viaje memorable es aquel donde experimentas lo extraordinario y lo imposible.',
        'recommendation':
            'Explora expediciones de trekking, deportes extremos, montañismo, safaris y actividades que te saquen de tu zona de confort.',
        'color': const Color(0xFFFF6F00),
      },
      'reflexion': {
        'title': 'El Viajero Contemplativo 🌅',
        'description':
            'Viajas para encontrar paz, claridad y conexión con la belleza del mundo. Los momentos de silencio y contemplación son tan valiosos para ti como las actividades.',
        'recommendation':
            'Opta por retiros espirituales, viajes a la naturaleza, santuarios, viajes de fotografía artística y experiencias culturales sin prisa.',
        'color': const Color(0xFF00BCD4),
      },
      'aprendizaje': {
        'title': 'El Viajero Aprendiz 📚',
        'description':
            'Tienes sed de conocimiento y quieres aprender profundamente sobre las culturas, historias y tradiciones del mundo. Para ti, viajar es una educación permanente.',
        'recommendation':
            'Explora viajes académicos, visitas a museos, talleres especializados, tours con historiadores y experiencias educativas profundas.',
        'color': const Color(0xFF4CAF50),
      },
    };

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => QuizResultsScreen(
          category: topCategory,
          resultData: results[topCategory]!,
        ),
      ),
    );
  }
}

class QuizQuestion {
  QuizQuestion({
    required this.question,
    required this.answers,
  });
  final String question;
  final List<QuizAnswer> answers;
}

class QuizAnswer {
  QuizAnswer(this.text, this.category);
  final String text;
  final String category;
}

class QuizResultsScreen extends StatelessWidget {
  const QuizResultsScreen({
    super.key,
    required this.category,
    required this.resultData,
  });
  final String category;
  final Map<String, dynamic> resultData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Perfil de Viajero'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            Container(
              color: resultData['color'] as Color?,
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    resultData['title'] as String,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Icon(
                    Icons.favorite,
                    size: 64,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quién eres como viajero',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resultData['description'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Viajes perfectos para ti',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (resultData['recommendation'] as String),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Ver Viajes Recomendados',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
