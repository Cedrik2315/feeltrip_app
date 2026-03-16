import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/experience_model.dart';
import '../controllers/experience_controller.dart';

class TravelDiaryScreen extends StatefulWidget {
  const TravelDiaryScreen({super.key});

  @override
  State<TravelDiaryScreen> createState() => _TravelDiaryScreenState();
}

class _TravelDiaryScreenState extends State<TravelDiaryScreen> {
  late ExperienceController _controller;
  bool _isAddingEntry = false;
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  final List<String> _selectedEmotions = [];
  int _reflectionDepth = 3;

  final List<String> _emotionOptions = [
    'Alegría',
    'Asombro',
    'Gratitud',
    'Transformación',
    'Miedo',
    'Paz',
    'Conexión',
    'Nostalgia',
    'Esperanza',
    'Reflexión',
  ];

  @override
  void initState() {
    super.initState();
    // Get or create the controller
    _controller = Get.isRegistered<ExperienceController>()
        ? Get.find<ExperienceController>()
        : Get.put(ExperienceController());

    // Load diary entries if not already loaded
    if (_controller.diaryEntries.isEmpty) {
      _controller.loadAllData();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Diario de Viaje'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isAddingEntry ? _buildEntryForm() : _buildDiaryList(),
      floatingActionButton: !_isAddingEntry
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isAddingEntry = true;
                  _reflectionDepth = 3;
                });
              },
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDiaryList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mi Diario Personal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                      '${_controller.diaryEntries.length} reflexiones capturadas',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    )),
              ],
            ),
          ),

          // Stats Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final stats = _controller.diaryStats;
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildStatCard(
                    'Total',
                    '${_controller.diaryEntries.length}',
                    Icons.note,
                  ),
                  _buildStatCard(
                    'Promedio Profundidad',
                    '${(stats['avgReflectionDepth'] ?? 0).toStringAsFixed(1)}/5',
                    Icons.trending_up,
                  ),
                  _buildStatCard(
                    'Emociones Únicas',
                    '${stats['uniqueEmotionCount'] ?? 0}',
                    Icons.sentiment_very_satisfied,
                  ),
                  _buildStatCard(
                    'Impacto General',
                    '${stats['overallImpactScore'] ?? 0}',
                    Icons.stars,
                  ),
                ],
              );
            }),
          ),

          // Timeline
          Obx(() {
            if (_controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              );
            }

            if (_controller.diaryEntries.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Aún no tienes entradas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Captura tus pensamientos y emociones durante el viaje',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controller.diaryEntries.length,
              itemBuilder: (context, index) {
                return _buildDiaryEntryCard(_controller.diaryEntries[index]);
              },
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryEntryCard(DiaryEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          entry.location,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.content,
                  style: TextStyle(color: Colors.grey[700], height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Profundidad de Reflexión: ${entry.reflectionDepth}/5',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: entry.emotions
                      .map((emotion) => Chip(
                            label: Text(emotion),
                            backgroundColor:
                                Colors.deepPurple.withValues(alpha: 0.2),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _controller.deleteDiaryEntry(entry.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Entrada eliminada')),
                        );
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Nueva Entrada en el Diario',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Ubicación',
              hintText: 'Dónde estás ahora?',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Tus Pensamientos',
              hintText: 'Escribe lo que sientes y piensas...',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
          ),
          const SizedBox(height: 16),
          const Text(
            'Profundidad de Reflexión',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _reflectionDepth.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (value) {
              setState(() {
                _reflectionDepth = value.toInt();
              });
            },
            label: '$_reflectionDepth/5',
          ),
          Text(
            '$_reflectionDepth - ${[
              'Superficial',
              'Ligera',
              'Moderada',
              'Profunda',
              'Muy Profunda'
            ][_reflectionDepth - 1]}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          const Text(
            'Emociones que Sientes:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _emotionOptions
                .map((emotion) => FilterChip(
                      label: Text(emotion),
                      selected: _selectedEmotions.contains(emotion),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedEmotions.add(emotion);
                          } else {
                            _selectedEmotions.remove(emotion);
                          }
                        });
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isAddingEntry = false;
                      _contentController.clear();
                      _locationController.clear();
                      _selectedEmotions.clear();
                      _reflectionDepth = 3;
                    });
                  },
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_contentController.text.isNotEmpty &&
                        _locationController.text.isNotEmpty &&
                        _selectedEmotions.isNotEmpty) {
                      _controller.createDiaryEntry(
                        location: _locationController.text,
                        content: _contentController.text,
                        emotions: _selectedEmotions,
                        reflectionDepth: _reflectionDepth,
                      );
                      setState(() {
                        _isAddingEntry = false;
                        _contentController.clear();
                        _locationController.clear();
                        _selectedEmotions.clear();
                        _reflectionDepth = 3;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Entrada guardada exitosamente')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Por favor completa todos los campos')),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
