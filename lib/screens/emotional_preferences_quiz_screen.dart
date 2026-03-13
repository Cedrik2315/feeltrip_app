import 'package:flutter/material.dart';

import 'package:confetti/confetti.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

// 8 Archetypes exactly as specified
const List<Map<String, dynamic>> archetypes = [
  {
    'emoji': '🌊',
    'name': 'Aventurero',
    'description': 'busca adrenalina y deportes extremos',
    'mapStyle': 'retro_style.json'
  },
  {
    'emoji': '🧘',
    'name': 'Contemplativo',
    'description': 'busca paz, meditación y naturaleza',
    'mapStyle': 'zen_style.json'
  },
  {
    'emoji': '🎨',
    'name': 'Creativo',
    'description': 'busca arte, cultura y experiencias únicas',
    'mapStyle': 'vibrant_style.json'
  },
  {
    'emoji': '🤝',
    'name': 'Conector',
    'description': 'busca comunidad, voluntariado y personas',
    'mapStyle': 'cyberpunk_style.json'
  },
  {
    'emoji': '🦁',
    'name': 'Explorador',
    'description': 'busca lugares remotos y off-the-beaten-path',
    'mapStyle': 'mystery_style.json'
  },
  {
    'emoji': '🌱',
    'name': 'Eco-consciente',
    'description': 'busca turismo sostenible y naturaleza',
    'mapStyle': 'zen_style.json'
  },
  {
    'emoji': '💆',
    'name': 'Sanador',
    'description': 'busca retiros, bienestar y transformación',
    'mapStyle': 'retro_style.json'
  },
  {
    'emoji': '🎉',
    'name': 'Festivo',
    'description': 'busca gastronomía, fiestas y vida nocturna',
    'mapStyle': 'vibrant_style.json'
  },
];

/// Fallback destinations por arquetipo para cuando falle la API
const Map<String, List<String>> _staticDestinations = {
  'Aventurero': [
    '🪂 Queenstown: Bungee jumping mundial',
    '🏔️ Patagonia: Trekking glaciar',
    '🌋 Islandia: Volcanes activos',
    '🏜️ Namibia: Dunas 4x4',
    '🦈 Sudáfrica: Tiburones jaula',
  ],
  'Contemplativo': [
    '🧘 Bali Ubud: Templos meditación',
    '🏔️ Himalaya: Retiros silencio',
    '🌅 Santorini: Atardeceres paz',
    '🏞️ Lake District: Caminatas reflexivas',
    '🌊 Tulum: Cenotes sagrados',
  ],
  'Creativo': [
    '🎨 París: Museos arte',
    '📸 Marruecos: Fotografía color',
    '🎪 Lisboa: Street art',
    '🕌 Estambul: Mezquitas historia',
    '🎭 Edimburgo: Festivales arte',
  ],
  'Conector': [
    '🤝 Bali Canggu: Comunidades nómadas',
    '🌍 Volunteer Africa: Proyectos impacto',
    '🏘️ Porto: Vecinos hospitalarios',
    '🎪 Burning Man: Conexiones profundas',
    '🏝️ Koh Phangan: Retiros grupo',
  ],
  'Explorador': [
    '🏔️ Mongolia: Nómadas estepas',
    '🏜️ Antártida: Última frontera',
    '🌋 Kamchatka: Volcanes salvaje',
    '🗺️ Papua Guinea: Tribus remotas',
    '🏝️ Islas Solomon: Playas vírgenes',
  ],
  'Eco-consciente': [
    '🌿 Costa Rica: Biodiversidad pura',
    '🐼 Borneo: Orangutanes sostenibles',
    '🌊 Galápagos: Conservación marina',
    '🏞️ Nueva Zelanda: Eco-turismo',
    '🌱 Perú Amazonía: Comunidades indígenas',
  ],
  'Sanador': [
    '💆 Glastonbury: Sanación espiritual',
    '🧘 Rishikesh: Yoga Ganges',
    '🌸 Jeju Corea: Baños volcánicos',
    '🏔️ Perú Valle Sagrado: Chamanismo',
    '🌊 Sedona: Vortex energía',
  ],
  'Festivo': [
    '🍷 Río Janeiro: Carnaval samba',
    '🍻 Múnich Oktoberfest: Cerveza fiesta',
    '🎉 Ibiza: Clubbing legendario',
    '🌃 Bangkok: Street food nightlife',
    '🍝 Italia Toscana: Vinos gastronomía',
  ],
};

// 10 Questions with 4 options, each option points to 2-3 archetypes (indices)
const List<Map<String, dynamic>> questions = [
  {
    'text': '¿Qué te motiva a viajar?',
    'options': [
      {
        'text': 'Transformación personal',
        'points': [6, 1]
      }, // Sanador, Contemplativo
      {
        'text': 'Diversión y placer',
        'points': [7, 0]
      }, // Festivo, Aventurero
      {
        'text': 'Conexión con otros',
        'points': [3, 2]
      }, // Conector, Creativo
      {
        'text': 'Aventura extrema',
        'points': [0, 4]
      }, // Aventurero, Explorador
    ],
    'bgColor': Colors.deepPurple,
  },
  {
    'text': '¿Cómo prefieres moverte?',
    'options': [
      {
        'text': 'Solo/a explorando',
        'points': [4, 1]
      }, // Explorador, Contemplativo
      {
        'text': 'Con mi pareja',
        'points': [6, 3]
      }, // Sanador, Conector
      {
        'text': 'Grupo pequeño de amigos',
        'points': [3, 7]
      }, // Conector, Festivo
      {
        'text': 'Grupo grande organizado',
        'points': [2, 5]
      }, // Creativo, Eco
    ],
    'bgColor': Colors.teal,
  },
  // ... (full 10)
  {
    'text': '¿Qué tipo de alojamiento prefieres?',
    'options': [
      {
        'text': 'Tienda de campaña',
        'points': [0, 4, 5]
      }, // Aventurero, Explorador, Eco
      {
        'text': 'Hostel social',
        'points': [3, 7]
      }, // Conector, Festivo
      'Hotel boutique', [2, 6], // Creativo, Sanador
      'Villa de lujo', [1, 7], // Contemplativo, Festivo
    ],
    'bgColor': Colors.orange,
  },
  {
    'text': '¿Qué actividad te emociona más?',
    'options': [
      {
        'text': 'Senderismo extremo',
        'points': [0, 4]
      },
      'Meditación guiada',
      [1, 6],
      'Visitar museos',
      [2],
      'Ir de fiestas',
      [7, 3],
    ],
    'bgColor': Colors.green,
  },
  {
    'text': '¿Cómo planificas tu viaje?',
    'options': [
      {
        'text': 'Totalmente improvisado',
        'points': [4, 0]
      },
      'Poco planificado',
      [1, 6],
      'Moderadamente organizado',
      [2, 5],
      'Todo planificado',
      [3, 7],
    ],
    'bgColor': Colors.indigo,
  },
  {
    'text': '¿Qué paisaje te llama más?',
    'options': [
      {
        'text': 'Montañas desafiantes',
        'points': [0, 4]
      },
      'Mar tranquilo',
      [1, 6],
      'Ciudades vibrantes',
      [2, 7],
      'Selva misteriosa',
      [5],
    ],
    'bgColor': Colors.blue,
  },
  {
    'text': '¿Qué defines como éxito en un viaje?',
    'options': [
      {
        'text': 'Fotos increíbles',
        'points': [2, 0]
      },
      'Nuevos amigos',
      [3],
      'Paz interior',
      [1, 6],
      'Aprendizaje profundo',
      [5, 4],
    ],
    'bgColor': Colors.amber,
  },
  {
    'text': '¿Cuánto tiempo libre necesitas?',
    'options': [
      {
        'text': 'Nada, acción total',
        'points': [0, 7]
      },
      'Poco, equilibrio',
      [3, 2],
      'Bastante, contemplación',
      [1, 6],
      'Todo el tiempo libre',
      [4, 5],
    ],
    'bgColor': Colors.pink,
  },
  {
    'text': '¿Qué comes en tus viajes?',
    'options': [
      {
        'text': 'Comida local auténtica',
        'points': [4, 2]
      },
      'Opciones veganas sostenibles',
      [5, 1],
      'Internacional gourmet',
      [7],
      'Lo que sea disponible',
      [0, 3],
    ],
    'bgColor': Colors.brown,
  },
  {
    'text': '¿Cómo terminas un viaje?',
    'options': [
      {
        'text': 'Agotado pero feliz',
        'points': [0, 7]
      },
      'Renovado espiritualmente',
      [6, 1],
      'Inspirado creativamente',
      [2],
      'Con nuevos amigos',
      [3, 4],
    ],
    'bgColor': Colors.red,
  },
];

class EmotionalPreferencesQuizScreen extends StatefulWidget {
  const EmotionalPreferencesQuizScreen({super.key});

  @override
  State<EmotionalPreferencesQuizScreen> createState() =>
      _EmotionalPreferencesQuizScreenState();
}

class _EmotionalPreferencesQuizScreenState
    extends State<EmotionalPreferencesQuizScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  late ConfettiController _confettiController;
  int currentIndex = 0;
  List<int> selectedOptions = List.filled(questions.length, -1);
  Map<String, int> points = {
    for (int i = 0; i < archetypes.length; i++) archetypes[i]['name']: 0
  };
  String? _archetype;
  Future<List<String>>? _destinationsFuture;
  Color? _bgColor = questions[0]['bgColor'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _bgColor = questions[0]['bgColor'] as Color?;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void selectOption(int questionIndex, int optionIndex) {
    setState(() {
      selectedOptions[questionIndex] = optionIndex;
    });

    // Add points
    final optPoints =
        ((questions[questionIndex]['options'] as List)[optionIndex]['points'] ??
            []) as List<int>;
    for (int idx in optPoints) {
      final name = archetypes[idx]['name'] as String;
      points[name] = (points[name] ?? 0) + 1;
    }

    if (currentIndex < questions.length - 1) {
      final nextColor = questions[currentIndex + 1]['bgColor'] as Color;
      _bgColor = nextColor;
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _showResults();
    }
  }

  void _showResults() {
    // Compute top
    final topArchetypes = points.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final primary = topArchetypes[0].key;
    _archetype = primary;
    _destinationsFuture = _getAIDestinations(primary);
    setState(() {});
    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Colors.purple, Colors.deepPurple]),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConfettiWidget(confettiController: _confettiController),
              Text('¡Tu perfil $_archetype!',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...topArchetypes.take(2).map((e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Text(
                              archetypes.firstWhere(
                                (a) => a['name'] == e.key,
                                orElse: () => {'emoji': '🌍'},
                              )['emoji'] as String,
                              style: const TextStyle(fontSize: 40),
                            ),
                            Text(
                              '${e.value} puntos',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context)
                      .pop(primary); // Return primary archetype
                },
                icon: const Icon(Icons.map),
                label: const Text('Ver mi mapa'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              if (_destinationsFuture != null)
                FutureBuilder<List<String>>(
                  future: _destinationsFuture,
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                           const Text ('✨ Consultando IA...',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            const SizedBox(height: 16),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Column(
                        children: [
                          const Text('No se pudieron cargar destinos',
                              style: TextStyle(color: Colors.white70)),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _destinationsFuture =
                                    _getAIDestinations(_archetype!);
                              });
                            },
                            child: const Text('Reintentar',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      );
                    }
                    final destinations = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Destinos para ti:',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...destinations.map((dest) => AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: Text(dest,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                            )),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Refacer quiz',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> _getAIDestinations(String archetype) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'x-api-key': const String.fromEnvironment('ANTHROPIC_API_KEY'),
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'claude-haiku-4-5-20251001',
          'max_tokens': 500,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Soy un viajero tipo $archetype. Recomiéndame exactamente 5 destinos con una línea cada uno. Formato: emoji Destino: descripción. Solo la lista.'
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'][0]['text'] as String;
        return content
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .take(5)
            .toList();
      }
    } catch (e) {
      debugPrint('AI destinations error: $e');
    }

    // Fallback
    return _staticDestinations[archetype] ??
        [
          '🌍 Destino 1: Increíble experiencia',
          '🏔️ Destino 2: Aventura única',
          '🌅 Destino 3: Paz total',
          '🎉 Destino 4: Fiesta inolvidable',
          '🧘 Destino 5: Transformación personal',
        ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (_bgColor ?? Colors.deepPurple).withValues(alpha: 0.8),
              (_bgColor ?? Colors.deepPurple).withValues(alpha: 0.3)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: (currentIndex + 1) / questions.length,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${currentIndex + 1}/${questions.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) {
                    setState(() {
                      currentIndex = idx;
                    });
                  },
                  itemCount: questions.length,
                  itemBuilder: (ctx, idx) {
                    final q = questions[idx];
                    final options = q['options'] as List;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            q['text'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 60),
                          ...options.asMap().entries.map((entry) {
                            final optIdx = entry.key;
                            final opt = entry.value;
                            final selected = selectedOptions[idx] == optIdx;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: GestureDetector(
                                onTap: () => selectOption(idx, optIdx),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white.withValues(
                                            alpha: selected ? 0.5 : 0.3)),
                                    boxShadow: selected
                                        ? [
                                            BoxShadow(
                                                color: Colors.white
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 20,
                                                spreadRadius: 0)
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      Text(opt['text'],
                                          style: TextStyle(
                                              color: selected
                                                  ? Colors.deepPurple
                                                  : Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      Icon(Icons.arrow_forward_ios,
                                          color: selected
                                              ? Colors.deepPurple
                                              : Colors.white
                                                  .withValues(alpha: 0.7)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
