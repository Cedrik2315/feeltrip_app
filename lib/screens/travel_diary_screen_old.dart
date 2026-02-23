import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/experience_model.dart';
import '../controllers/experience_controller.dart';

class TravelDiaryScreen extends StatefulWidget {
  @override
  State<TravelDiaryScreenState> createState() => _TravelDiaryScreenState();
}

class _TravelDiaryScreenState extends State<TravelDiaryScreen> {
  late ExperienceController _controller;
  bool _isAddingEntry = false;
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  List<String> _selectedEmotions = [];

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
        title: Text('Mi Diario de Viaje'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isAddingEntry
          ? _buildEntryForm()
          : _buildDiaryList(),
      floatingActionButton: !_isAddingEntry
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isAddingEntry = true;
                });
              },
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.add),
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
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi Diario Personal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Obx(() => Text(
                  '${_controller.diaryEntries.length} reflexiones capturadas',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                )),
              ],
            ),
          ),

          // Stats Cards
          Padding(
            padding: EdgeInsets.all(16),
            child: Obx(() {
              final stats = _controller.diaryStats;
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
              return Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              );
            }

            if (_controller.diaryEntries.isEmpty)
              return Padding(
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
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return _buildDiaryEntryCard(entries[index]);
              },
            ),

          SizedBox(height: 24),

          // Stats
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu Viaje en Números',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          '${entries.length}',
                          'Reflexiones',
                          Icons.note,
                        ),
                        _buildStatItem(
                          '${entries.fold(0, (sum, e) => sum + e.reflectionDepth) ~/ entries.length}',
                          'Profundidad Avg',
                          Icons.trending_up,
                        ),
                        _buildStatItem(
                          '${entries.fold(<String>{}, (set, e) => set..addAll(e.emotions)).length}',
                          'Emociones',
                          Icons.favorite,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDiaryEntryCard(DiaryEntry entry) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con fecha y lugar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.purple),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              entry.location,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDate(entry.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Profundidad de reflexión
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 14,
                          color: i < entry.reflectionDepth
                              ? Colors.amber
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Profundidad',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),

            // Contenido
            Text(
              entry.content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 16),

            // Emociones
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entry.emotions
                  .map((emotion) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          emotion,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),

            SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: 18),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Editar disponible próximamente')),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      entries.removeWhere((e) => e.id == entry.id);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              'Nueva Reflexión',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),

            // Ubicación
            Text('¿Dónde estás?', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Mi ubicación...',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Contenido
            Text('¿Qué sientes?', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText:
                    'Escribe tus pensamientos, emociones, reflexiones... No hay límite de palabras ni reglas de gramática. Solo sé honesto.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Emociones
            Text('¿Qué emociones experimentas?',
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.purple[200],
                      ))
                  .toList(),
            ),

            SizedBox(height: 24),

            // Profundidad
            Text('¿Cuán profunda es esta reflexión?',
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                5,
                (index) => GestureDetector(
                  onTap: () {
                    // Placeholder para seleccionar profundidad
                  },
                  child: Icon(
                    Icons.star,
                    size: 32,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isAddingEntry = false;
                        _contentController.clear();
                        _locationController.clear();
                        _selectedEmotions.clear();
                      });
                    },
                    child: Text('Cancelar'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_contentController.text.isNotEmpty) {
                        setState(() {
                          entries.add(
                            DiaryEntry(
                              id: const Uuid().v4(),
                              tripId: 'trip_1',
                              userId: 'user_1',
                              content: _contentController.text,
                              photos: [],
                              emotions: _selectedEmotions,
                              location: _locationController.text.isEmpty
                                  ? 'Sin ubicación'
                                  : _locationController.text,
                              createdAt: DateTime.now(),
                              reflectionDepth: 3,
                            ),
                          );
                          _contentController.clear();
                          _locationController.clear();
                          _selectedEmotions.clear();
                          _isAddingEntry = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reflexión guardada'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: Text('Guardar Reflexión'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
