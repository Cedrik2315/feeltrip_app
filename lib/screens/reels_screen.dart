import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class ReelsScreen extends StatefulWidget {
  @override
  _ReelsScreenState createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  List<DiaryEntry> entries = [];
  bool isGenerating = false;
  String? generatedVideoPath;
  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future<void> loadEntries() async {
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

  Future<void> generateReel() async {
    setState(() => isGenerating = true);
    
    // Simulamos la generación del video
    await Future.delayed(Duration(seconds: 3));
    
    // En una implementación real, aquí usarías:
    // - FFmpeg para unir imágenes/videos
    // - Agregar música de fondo
    // - Aplicar transiciones y efectos
    
    // Por ahora, creamos un archivo simulado
    final directory = await getApplicationDocumentsDirectory();
    final videoPath = '${directory.path}/feel_trip_reel.mp4';
    final videoFile = File(videoPath);
    await videoFile.create(recursive: true);
    
    // Guardamos metadata del reel
    final reelData = {
      'entries': entries.map((e) => e.toJson()).toList(),
      'createdAt': DateTime.now().toIso8601String(),
      'music': _getRandomMusic(),
      'transitions': _getRandomTransitions(),
    };
    
    final reelFile = File('${directory.path}/last_reel.json');
    await reelFile.writeAsString(jsonEncode(reelData));
    
    setState(() {
      isGenerating = false;
      generatedVideoPath = videoPath;
    });
    
    // Inicializar el reproductor de video
    videoController = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  String _getRandomMusic() {
    final songs = [
      'Emotional Journey',
      'Memories in Motion',
      'Wanderlust Dreams',
      'Sunset Reflections',
      'Adventure Awaits'
    ];
    return songs[Random().nextInt(songs.length)];
  }

  List<String> _getRandomTransitions() {
    final transitions = [
      'fade',
      'slide',
      'zoom',
      'blur',
      'rotate'
    ];
    return transitions.sublist(0, 3);
  }

  void shareReel() {
    if (generatedVideoPath != null) {
      // En implementación real usarías:
      // - Share plugin para compartir el archivo
      // - Social media APIs para publicar
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reel compartido exitosamente! 🎉')),
      );
    }
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Reel de Viaje'),
        backgroundColor: Colors.teal[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal[800]!, Colors.teal[200]!],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Text(
                'Tu historia en 30 segundos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Convertí tus momentos en una película',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 30),

              // Botón generar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal[800],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: isGenerating ? null : generateReel,
                  icon: isGenerating 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.movie_creation),
                  label: Text(
                    isGenerating ? 'Creando magia...' : 'Generar mi reel',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Preview del reel
              if (generatedVideoPath != null && videoController != null)
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: videoController!.value.isInitialized
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: videoController!.value.aspectRatio,
                              child: VideoPlayer(videoController!),
                            ),
                            Positioned(
                              bottom: 20,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      videoController!.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        videoController!.value.isPlaying
                                            ? videoController!.pause()
                                            : videoController!.play();
                                      });
                                    },
                                  ),
                                  SizedBox(width: 20),
                                  IconButton(
                                    icon: Icon(Icons.share, color: Colors.white),
                                    onPressed: shareReel,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                ),

              // Información del reel
              if (generatedVideoPath != null)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Detalles de tu reel:',
                          style: TextStyle(
                            color: Colors.teal[800],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('🎵 Música: ${_getRandomMusic()}'),
                        Text('🎬 Transiciones: ${_getRandomTransitions().join(', ')}'),
                        Text('📸 Momentos: ${entries.length}'),
                        Text('⏱️ Duración: 30 segundos'),
                      ],
                    ),
                  ),
                ),

              // Mensaje cuando no hay entradas
              if (entries.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    'Aún no hay momentos guardados.\nEmpezá a crear tu diario!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Clase para entradas del diario (copiada del diary_screen)
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