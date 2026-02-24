import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<DiaryEntry> entries = [];
  CameraController? cameraController;
  bool isCameraReady = false;
  String selectedEmotion = '??';

  final List<String> emotions = ['??', '??', '??', '??', '??', '??', '??', '??'];

  @override
  void initState() {
    super.initState();
    initializeCamera();
    loadEntries();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    try {
      await cameraController!.initialize();
      setState(() => isCameraReady = true);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> loadEntries() async {
    final registros = await _dbService.obtenerEntradas().first;
    if (!mounted) return;

    setState(() {
      entries = registros
          .map(
            (r) => DiaryEntry(
              id: '${r.fecha.millisecondsSinceEpoch}',
              text: r.texto,
              emotion: r.emociones.isNotEmpty ? r.emociones.first : '??',
              date: r.fecha,
              imagePath: null,
            ),
          )
          .toList();
    });
  }

  Future<void> addEntry(String text) async {
    final newEntry = DiaryEntry(
      id: DateTime.now().toString(),
      text: text,
      emotion: selectedEmotion,
      date: DateTime.now(),
      imagePath: null,
    );

    setState(() {
      entries.insert(0, newEntry);
    });

    await _dbService.guardarEntrada(
      texto: text,
      emociones: [selectedEmotion],
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Momento guardado')),
    );
  }

  Future<void> takePicture() async {
    if (!isCameraReady) return;

    try {
      final image = await cameraController!.takePicture();
      final newEntry = DiaryEntry(
        id: DateTime.now().toString(),
        text: 'Foto del momento',
        emotion: selectedEmotion,
        date: DateTime.now(),
        imagePath: image.path,
      );

      setState(() {
        entries.insert(0, newEntry);
      });

      await _dbService.guardarEntrada(
        texto: 'Foto del momento',
        emociones: [selectedEmotion],
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto guardada')),
      );
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Diario Emocional'),
        backgroundColor: Colors.purple[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[800]!, Colors.purple[200]!],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Como te sentis ahora?',
                      style: TextStyle(
                        color: Colors.purple[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: emotions
                          .map(
                            (emotion) => GestureDetector(
                              onTap: () => setState(() => selectedEmotion = emotion),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: selectedEmotion == emotion ? Colors.purple[800] : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.purple[800]!,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  emotion,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: selectedEmotion == emotion ? Colors.white : Colors.purple[800],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: takePicture,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Foto'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => showAddEntryDialog(),
                      icon: const Icon(Icons.edit),
                      label: const Text('Texto'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: Text(
                        entry.emotion,
                        style: const TextStyle(fontSize: 30),
                      ),
                      title: Text(entry.text),
                      subtitle: Text(
                        '${entry.date.day}/${entry.date.month}/${entry.date.year} ${entry.date.hour}:${entry.date.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: entry.imagePath != null
                          ? Image.file(File(entry.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddEntryDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar momento'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Describe lo que sentis...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                addEntry(textController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.text,
    required this.emotion,
    required this.date,
    this.imagePath,
  });

  final String id;
  final String text;
  final String emotion;
  final DateTime date;
  final String? imagePath;
}
