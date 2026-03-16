import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../services/diary_service.dart';
import '../models/experience_model.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

// ignore: library_private_types_in_public_api
  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DiaryService _diaryService = DiaryService();
  List<DiaryEntry> entries = [];
  CameraController? cameraController;
  bool isCameraReady = false;
  String selectedEmotion = '😊';
  String? mockUserId = 'test_user';

  @override
  void initState() {
    super.initState();
    _diaryService; // Initialize singleton
    initializeCamera();
    loadEntries();
  }

  final List<String> emotions = [
    '😊',
    '😍',
    '😭',
    '😱',
    '🤯',
    '😌',
    '🥰',
    '😢'
  ];

  // Removed duplicate initState

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
      // log eliminado: Error initializing camera: $e
    }
  }

  Future<void> loadEntries() async {
    if (mockUserId == null) return;
    try {
      entries = await _diaryService.getDiaryEntries(mockUserId!);
      setState(() {});
    } catch (e) {
      // ignore: empty_catches
    }
  }

  Future<void> saveEntry(DiaryEntry entry) async {
    if (mockUserId == null) return;
    try {
      await _diaryService.createDiaryEntry(mockUserId!, entry);
      loadEntries(); // Reload list
    } catch (e) {
      // ignore: empty_catches
    }
  }

  void addEntry(String text) async {
    final newEntry = DiaryEntry(
      id: const Uuid().v4(),
      tripId: 'default',
      userId: FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
      location: 'Emotional Diary',
      content: text,
      emotions: [selectedEmotion],
      photos: [],
      reflectionDepth: 1,
      createdAt: DateTime.now(),
    );

    await saveEntry(newEntry);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Momento guardado 💖')),
    );
  }

  void takePicture() async {
    if (!isCameraReady) return;

    try {
      final image = await cameraController!.takePicture();
      final newEntry = DiaryEntry(
        id: const Uuid().v4(),
        tripId: 'default',
        userId: FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
        location: 'Emotional Diary Photo',
        content: 'Foto del momento $selectedEmotion',
        emotions: [selectedEmotion],
        photos: [image.path],
        reflectionDepth: 1,
        createdAt: DateTime.now(),
      );

      await saveEntry(newEntry);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto guardada 📸')),
      );
    } catch (e) {
      // ignore: empty_catches
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
        title: Text('Mi Diario Emocional'),
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
            // Selector de emoción
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(230),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '¿Cómo te sentís ahora?',
                      style: TextStyle(
                        color: Colors.purple[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: emotions
                          .map((emotion) => GestureDetector(
                                onTap: () =>
                                    setState(() => selectedEmotion = emotion),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: selectedEmotion == emotion
                                        ? Colors.purple[800]
                                        : Colors.white,
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
                                      color: selectedEmotion == emotion
                                          ? Colors.white
                                          : Colors.purple[800],
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Botones de acción
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple[800],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: takePicture,
                      icon: Icon(Icons.camera_alt),
                      label: Text('Foto'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple[800],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => showAddEntryDialog(),
                      icon: Icon(Icons.edit),
                      label: Text('Texto'),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de entradas
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: Text(
                        entry.emotions.isNotEmpty ? entry.emotions.first : '😊',
                        style: TextStyle(fontSize: 30),
                      ),
                      title: Text(entry.content),
                      subtitle: Text(
                          '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year} ${entry.createdAt.hour}:${entry.createdAt.minute.toString().padLeft(2, '0')}'),
                      trailing: entry.photos.isNotEmpty
                          ? Image.file(File(entry.photos.first),
                              width: 50, height: 50, fit: BoxFit.cover)
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
        title: Text('Agregar momento'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Describí lo que sentís...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                addEntry(textController.text);
                Navigator.pop(context);
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
