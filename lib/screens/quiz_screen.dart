import 'package:flutter/material.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  List<String> answers = [];

  final questions = [
    {
      'question': '¿Qué querés sentir en tu próximo viaje?',
      'options': [
        '😍 Deseo',
        '🤗 Abrazo',
        '😭 Lágrima',
        '😱 Susto',
        '🤯 Boom',
        '😌 Paz'
      ]
    },
    {
      'question': '¿Con quién compartirás esa sensación?',
      'options': ['Solo/a', 'Pareja', 'Amigos', 'Familia', 'Desconocidos']
    },
    {
      'question': '¿Cuánto podés gastar sin culpa?',
      'options': [
        '0-500 €',
        '500-1500 €',
        '1500-3000 €',
        '3000+ €',
        'No me importa'
      ]
    },
    {
      'question': '¿En qué estación te gustaría respirar el aire nuevo?',
      'options': ['Primavera', 'Verano', 'Otoño', 'Invierno', 'Cualquiera']
    },
    {
      'question': '¿Qué tamaño de lugar te hace más ruido en el pecho?',
      'options': [
        'Ciudad que nunca duerme',
        'Pueblo que silencia',
        'Naturaleza que respira',
        'Desierto que absorbe'
      ]
    },
    {
      'question': '¿Cómo querés que pase el tiempo?',
      'options': ['Lento', 'Ritmo normal', 'Intenso', 'Sin plan, solo flow']
    },
    {
      'question': '¿Qué color te atrapa hoy?',
      'options': ['Rojo', 'Verde', 'Azul', 'Amarillo', 'Blanco', 'Negro']
    }
  ];

  void nextQuestion(String answer) {
    answers.add(answer);
    if (currentQuestion < questions.length - 1) {
      setState(() => currentQuestion++);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(answers: answers),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FeelTrip Quiz'),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[800]!, Colors.blue[200]!],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pregunta ${currentQuestion + 1} de ${questions.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                questions[currentQuestion]['question'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              ...(questions[currentQuestion]['options'] as List<String>)
                  .map((option) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue[800],
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () => nextQuestion(option),
                            child: Text(
                              option,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
