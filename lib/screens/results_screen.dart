import 'package:flutter/material.dart';

import '../constants/strings.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.answers});

  final List<String> answers;

  Map<String, dynamic> getRecommendedTrip() {
    final emotion = answers[0];
    final season = answers[3];

    if (emotion.contains('Lágrima') && season == 'Invierno') {
      return {
        'tripId': 'trip_1',
        'title': 'Auroras en Tromsø',
        'description':
            '5 días para llorar de emoción bajo las auroras boreales',
        'price': 'EUR 1,290',
        'emotion': 'Lágrima de emoción',
        'includes': ['Vuelos', 'Cabaña de cristal', 'Sauna', 'Guía local']
      };
    } else if (emotion.contains('Abrazo')) {
      return {
        'tripId': 'trip_2',
        'title': 'Cocina con Nonna',
        'description': '7 días de abrazos italianos y pasta casera',
        'price': 'EUR 980',
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
        'tripId': 'trip_3',
        'title': 'Aventura en Queenstown',
        'description': '6 días de adrenalina pura en Nueva Zelanda',
        'price': 'EUR 1,450',
        'emotion': 'Explosión de adrenalina',
        'includes': ['Vuelos', 'Hotel 4*', 'Paracaídas', 'Bungee', 'Rafting']
      };
    }

    return {
      'tripId': 'trip_4',
      'title': 'Meditación en Bali',
      'description': '8 días de paz profunda y yoga',
      'price': 'EUR 850',
      'emotion': 'Paz interior',
      'includes': ['Vuelos', 'Retiro', 'Yoga diario', 'Meditación', 'Spa']
    };
  }

  @override
  Widget build(BuildContext context) {
    final trip = getRecommendedTrip();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resultsTitle),
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
                  AppStrings.resultsFound,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  trip['emotion'],
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
                        trip['title'],
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        trip['description'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.resultsIncludes,
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...(trip['includes'] as List<String>).map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(item, style: TextStyle(color: Colors.blue[600])),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${AppStrings.resultsPrice}: ${trip['price']}',
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
                      Navigator.pushNamed(
                        context,
                        '/trip-details',
                        arguments: trip['tripId'],
                      );
                    },
                    child: const Text(
                      AppStrings.resultsBook,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    AppStrings.resultsRedoQuiz,
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
