import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/experience_model.dart';
import '../controllers/experience_controller.dart';
import '../services/vision_service.dart';
import '../services/sharing_service.dart';

class TravelDiaryScreen extends StatefulWidget {
  const TravelDiaryScreen({super.key});

  @override
  State<TravelDiaryScreen> createState() => _TravelDiaryScreenState();
}

class _TravelDiaryScreenState extends State<TravelDiaryScreen> {
  late ExperienceController _controller;
  final _visionService = VisionService();
  final _imagePicker = ImagePicker();

  // Form state
  bool _isAddingEntry = false;
  bool _isGenerating = false;
  File? _imageFile;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedEmotion;

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
    _controller = Get.find<ExperienceController>();

    // Load diary entries if not already loaded
    if (_controller.diaryEntries.isEmpty) {
      _controller.loadAllData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _imageFile = null;
    _titleController.clear();
    _contentController.clear();
    _selectedEmotion = null;
    _isAddingEntry = false;
    _isGenerating = false;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _generatePoeticEntry() async {
    if (_imageFile == null) {
      await _pickImage();
      if (_imageFile == null) return; // User cancelled image picking
    }

    setState(() => _isGenerating = true);

    // Obtener el perfil del usuario de forma dinámica.
    const userProfile = "Explorador";

    final poeticText = await _visionService.generatePoeticEntry(
      imageFile: _imageFile!,
      userProfile: userProfile,
    );

    if (!mounted) return;
    setState(() => _isGenerating = false);
    _contentController.text = poeticText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Diario de Viaje'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isAddingEntry ? _buildEntryForm() : _buildDiaryListWithSlivers(),
      floatingActionButton: !_isAddingEntry
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() => _isAddingEntry = true);
              },
              backgroundColor: const Color(0xFF1A237E),
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text("NUEVO MOMENTO",
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildDiaryListWithSlivers() {
    return Obx(() {
      if (_controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'MI BITÁCORA',
                style: TextStyle(
                  fontFamily: 'Serif', // O una fuente elegante que tengas
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              background: Container(color: const Color(0xFF1A237E)),
            ),
          ),
          if (_controller.diaryEntries.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_alt_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'Aún no tienes entradas',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Presiona "NUEVO MOMENTO" para capturar tus pensamientos y emociones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return DiaryCard(entry: _controller.diaryEntries[index]);
                },
                childCount: _controller.diaryEntries.length,
              ),
            ),
        ],
      );
    });
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
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!),
                image: _imageFile != null
                    ? DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _imageFile == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              color: Colors.grey, size: 40),
                          SizedBox(height: 8),
                          Text('Añadir una foto',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título del Momento',
              hintText: 'Ej: Atardecer en la playa',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Tus Pensamientos',
              hintText: 'Escribe lo que sientes y piensas...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _isGenerating ? null : _generatePoeticEntry,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Escribe por mí (IA)'),
            ),
          ),
          const Text(
            'Emociones que Sientes:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: _emotionOptions
                .map((emotion) => FilterChip(
                      label: Text(emotion),
                      selected: _selectedEmotion == emotion,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedEmotion = emotion;
                          } else {
                            _selectedEmotion = null;
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
                    setState(() => _resetForm());
                  },
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_imageFile != null &&
                        _titleController.text.isNotEmpty &&
                        _contentController.text.isNotEmpty &&
                        _selectedEmotion != null) {
                      _controller.createDiaryEntry(
                        title: _titleController.text,
                        content: _contentController.text,
                        emotion: _selectedEmotion!,
                        imageFile: _imageFile!,
                      );
                      setState(() => _resetForm());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Entrada guardada exitosamente'),
                        ),
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

// TARJETA ESTILO "MAGAZINE"
class DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  const DiaryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // IMAGEN DE FONDO
            CachedNetworkImage(
              imageUrl: entry.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.image_not_supported_outlined),
            ),

            // GRADIENTE PARA LEER TEXTO
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // CONTENIDO DEL TEXTO
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMMM, yyyy', 'es')
                        .format(entry.createdAt)
                        .toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, letterSpacing: 1),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    entry.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.favorite,
                          color: Colors.redAccent, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        entry.emotions.isNotEmpty
                            ? entry.emotions.first
                            : 'Sin emoción',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14),
                      ),
                      const Spacer(),
                      // BOTÓN COMPARTIR RÁPIDO
                      IconButton(
                        icon: const Icon(Icons.share_outlined,
                            color: Colors.white),
                        onPressed: () async {
                          await SharingService.shareDiaryEntry(
                            title: entry.title,
                            content: entry.content,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
