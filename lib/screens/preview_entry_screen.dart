import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/experience_controller.dart';
import '../services/vision_service.dart';

class PreviewEntryScreen extends StatefulWidget {
  const PreviewEntryScreen({super.key});

  @override
  State<PreviewEntryScreen> createState() => _PreviewEntryScreenState();
}

class _PreviewEntryScreenState extends State<PreviewEntryScreen> {
  final ExperienceController _experienceController = Get.find();
  final VisionService _visionService = VisionService();

  // State
  String? _imagePath;
  File? _imageFile;
  bool _isGenerating = true; // Start in generating state
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedEmotion;

  final List<String> _emotionOptions = [
    'Alegría', 'Asombro', 'Gratitud', 'Transformación', 'Miedo', 'Paz',
    'Conexión', 'Nostalgia', 'Esperanza', 'Reflexión',
  ];

  @override
  void initState() {
    super.initState();
    _imagePath = Get.arguments as String?;
    if (_imagePath != null) {
      _imageFile = File(_imagePath!);
      _generatePoeticEntry();
    } else {
      // Handle error: no image path provided
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar('Error', 'No se pudo obtener la imagen capturada.');
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _generatePoeticEntry() async {
    if (_imageFile == null) return;

    setState(() => _isGenerating = true);

    // Aquí puedes cambiar el perfil del usuario según lo que hayas implementado en el quiz de personalidad.
    const userProfile = "Explorador";

    final poeticText = await _visionService.generatePoeticEntry(
      imageFile: _imageFile!,
      userProfile: userProfile,
    );

    if (!mounted) return;
    _contentController.text = poeticText;
    setState(() => _isGenerating = false);
  }

  void _saveEntry() {
    if (_imageFile != null &&
        _titleController.text.isNotEmpty &&
        _contentController.text.isNotEmpty &&
        _selectedEmotion != null) {
      _experienceController.createDiaryEntry(
        title: _titleController.text,
        content: _contentController.text,
        emotion: _selectedEmotion!,
        imageFile: _imageFile!,
      );
      // Go back to the diary screen and refresh it
      Get.offAllNamed('/diary'); 
      Get.snackbar('¡Guardado!', 'Tu nuevo momento ha sido guardado en la bitácora.');
    } else {
      Get.snackbar(
        'Faltan datos',
        'Por favor completa el título, el contenido y elige una emoción.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Momento'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _imageFile == null
          ? const Center(child: Text('Error: No se encontró la imagen.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título del Momento',
                      hintText: 'Ej: Luces que bailan en el cielo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Tus Pensamientos (Generado por IA)',
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                      suffixIcon: _isGenerating
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.auto_awesome),
                              tooltip: 'Volver a generar',
                              onPressed: _generatePoeticEntry,
                            ),
                    ),
                    maxLines: 6,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Emoción Principal:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _emotionOptions
                        .map((emotion) => FilterChip(
                              label: Text(emotion),
                              selected: _selectedEmotion == emotion,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedEmotion = selected ? emotion : null;
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _saveEntry,
                    icon: const Icon(Icons.save_alt_outlined),
                    label: const Text('Guardar Momento'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}