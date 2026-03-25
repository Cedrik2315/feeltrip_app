import 'package:flutter/material.dart';
import 'travel_diary_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.answers});
  final List<String> answers;

  // Función para determinar el viaje según respuestas
  Map<String, dynamic> getRecommendedTrip() {
    final String emotion = answers[0];
    final String season = answers[3];
    final String budget = answers[2];

    // Lógica de recomendación básica
    if (emotion.contains('Lágrima') && season == 'Invierno') {
      return {
        'title': 'Auroras en Tromsø',
        'description':
            '5 días para llorar de emoción bajo las auroras boreales',
        'price': budget.contains('Alto') ? '€1,290' : '€890',
        'image': 'tromso_aurora.jpg',
        'emotion': 'Lágrima de emoción',
        'includes': ['Vuelos', 'Cabaña de cristal', 'Sauna', 'Guía local']
      };
    } else if (emotion.contains('Abrazo')) {
      return {
        'title': 'Cocina con Nonna',
        'description': '7 días de abrazos italianos y pasta casera',
        'price': budget.contains('Alto') ? '€980' : '€650',
        'image': 'tuscana_nonna.jpg',
        'emotion': 'Abrazo cálido',
        'includes': [
          'Vuelos',
          'Casa rural',
          'Clases de cocina',
          'Mercado local'
        ]
      };
    } else if (emotion.contains('Boom')) {
      return {
        'title': 'Aventura en Queenstown',
        'description': '6 días de adrenalina pura en Nueva Zelanda',
        'price': budget.contains('Alto') ? '€1,450' : '€980',
        'image': 'queenstown_adventure.jpg',
        'emotion': 'Explosión de adrenalina',
        'includes': ['Vuelos', 'Hotel 4★', 'Paracaídas', 'Bungee', 'Rafting']
      };
    } else {
      return {
        'title': 'Meditación en Bali',
        'description': '8 días de paz profunda y yoga',
        'price': budget.contains('Alto') ? '€850' : '€550',
        'image': 'bali_yoga.jpg',
        'emotion': 'Paz interior',
        'includes': ['Vuelos', 'Retiro', 'Yoga diario', 'Meditación', 'Spa']
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = getRecommendedTrip();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu viaje te está esperando'),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  'Encontramos tu sensación:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  trip['emotion'] as String,
                  style: TextStyle(
                    color: Colors.yellow[100],
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        trip['title'] as String,
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        trip['description'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Incluye:',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...(trip['includes'] as List<String>).map((item) =>
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 8),
                                Text(item,
                                    style: TextStyle(color: Colors.blue[600])),
                              ],
                            ),
                          )),
                      const SizedBox(height: 20),
                      Text(
                        'Precio: ${trip['price']}',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const TravelDiaryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Reservar esta sensación',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // AI Agency Recommendation Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified,
                              color: Colors.green[700], size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            '🤖 IA Recomienda',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Agencia Aventurera Pro - Verificada',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Expertos en Trekking y Rápel. 4.9⭐ (127 reseñas)',
                        style: TextStyle(color: Colors.green),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person, size: 20),
                          label: const Text('Ver Perfil Agencia'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () {
                            // Deep link /agency/:id
                            Navigator.pushNamed(
                                context, '/agency/aventura-pro-123');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Hacer el quiz de nuevo',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
