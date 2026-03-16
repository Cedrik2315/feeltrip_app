import 'package:flutter/material.dart';
import 'travel_diary_screen.dart';

class ResultsScreen extends StatelessWidget {
  final List<String> answers;

  const ResultsScreen({super.key, required this.answers});

  // Función para determinar el viaje según respuestas
  Map<String, dynamic> getRecommendedTrip() {
    String emotion = answers[0];
    String season = answers[3];
    String budget = answers[2];

   // Lógica de recomendación básica
    if (emotion.contains('Lágrima') && season == 'Invierno') {
      return {
        'title': 'Auroras en Tromsø',
        'description': '5 días para llorar de emoción bajo las auroras boreales',
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
        'includes': ['Vuelos', 'Casa rural', 'Clases de cocina', 'Mercado local']
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
        title: Text('Tu viaje te está esperando'),
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
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  'Encontramos tu sensación:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  trip['emotion'],
                  style: TextStyle(
                    color: Colors.yellow[100],
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(20),
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
                      SizedBox(height: 10),
                      Text(
                        trip['description'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Incluye:',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...(trip['includes'] as List<String>)
                          .map((item) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green, size: 16),
                                    SizedBox(width: 8),
                                    Text(item,
                                        style:
                                            TextStyle(color: Colors.blue[600])),
                                  ],
                                ),
                              )),
                      SizedBox(height: 20),
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
                SizedBox(height: 30),
                SizedBox(
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TravelDiaryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Reservar esta sensación',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
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
