import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class DiaryScreen extends StatefulWidget {
  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<DiaryEntry> entries = [];
  CameraController? cameraController;
  bool isCameraReady = false;
  String selectedEmotion = '😊';
  
  final List<String> emotions = ['😊', '😍', '😭', '😱', '🤯', '😌', '🥰', '😢'];

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
      print('Error initializing camera: $e');
    }
  }

  Future<void> loadEntries() async {
    // Cargar entradas guardadas localmente
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/diary.json');
    
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      setState(() {
        entries = jsonList.map((json) => DiaryEntry.fromJson(json)).toList();
      });
    }
  }

  Future<void> saveEntries() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/diary.json');
    final jsonList = entries.map((entry) => entry.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  void addEntry(String text) {
    final newEntry = DiaryEntry(
      id: DateTime.now().toString(),
      text: text,
      emotion: selectedEmotion,
      date: DateTime.now(),
      imagePath: null,
    );

    setState(() {
      entries.add(newEntry);
    });
    
    saveEntries();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Momento guardado 💖')),
    );
  }

  void takePicture() async {
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
        entries.add(newEntry);
      });
      
      saveEntries();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto guardada 📸')),
      );
    } catch (e) {
      print('Error taking picture: $e');
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
                  color: Colors.white.withOpacity(0.9),
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
                      children: emotions.map((emotion) => 
                        GestureDetector(
                          onTap: () => setState(() => selectedEmotion = emotion),
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
                        )
                      ).toList(),
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
                        entry.emotion,
                        style: TextStyle(fontSize: 30),
                      ),
                      title: Text(entry.text),
                      subtitle: Text(
                        '${entry.date.day}/${entry.date.month}/${entry.date.year} ${entry.date.hour}:${entry.date.minute.toString().padLeft(2, '0')}'
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

class DiaryEntry {
  final String id;
  final String text;
  final String emotion;
  final DateTime date;
  final String? imagePath;

  DiaryEntry({
    required this.id,
    required this.text,
    required this.emotion,
    required this.date,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'emotion': emotion,
      'date': date.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'],
      text: json['text'],
      emotion: json['emotion'],
      date: DateTime.parse(json['date']),
      imagePath: json['imagePath'],
    );
  }
}