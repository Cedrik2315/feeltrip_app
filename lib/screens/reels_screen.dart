import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import '../models/experience_model.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key, required this.title});
  final String title;

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  List<DiaryEntry> entries = [];
  bool isGenerating = false;
  VideoPlayerController? _videoController;
  String? _lastVideoPath;

  // Metadata para la UI
  String? _selectedMusic;
  List<String>? _selectedTransitions;
  String _loadingMessage = 'INICIANDO ALQUIMIA...';

  // Paleta de colores FeelTrip (Carbon & Bone)

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> loadEntries() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      entries = [
        DiaryEntry(
          id: 'demo1',
          userId: FirebaseAuth.instance.currentUser?.uid ?? 'traveler_valpo',
          title: 'Atardecer en el Valle de Aconcagua',
          content: 'Paz absoluta en la zona rural de Quillota.',
          emotions: ['Gratitud'],
          photoUrls: [],
          reflectionDepth: 3,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        DiaryEntry(
          id: 'demo2',
          userId: 'traveler_valpo',
          title: 'Encuentro en Limache',
          content: 'Conexión con productores de tomate locales.',
          emotions: ['Conexión'],
          photoUrls: [],
          reflectionDepth: 4,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    });
  }

  Future<void> generateReel() async {
    if (entries.isEmpty) return;

    setState(() {
      isGenerating = true;
      _loadingMessage = 'ANALIZANDO EMOCIONES...';
    });

    try {
      // 1. Simulación de pasos de la IA
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _loadingMessage = 'COMPONIENDO BANDA SONORA...');
      final music = _getRandomMusic();
      
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _loadingMessage = 'RENDERIZANDO ATMÓSFERA RURAL...');
      final transitions = _getRandomTransitions();

      // 2. Prompt Técnico (Alquimia Cinematográfica)
      final videoPrompt = """
      RAW cinematic 4k footage, 16mm film grain. 
      Visuals: ${entries.map((e) => e.title).join(' -> ')}.
      Atmosphere: Golden hour light, rural Valparaíso, poetic realism.
      Style: ${transitions.join(' & ')} transitions.
      Audio: $music.
      """;

      AppLogger.i('Video Alchemy Prompt -> $videoPrompt');

      // 3. Manejo de archivos (Mock)
      final directory = await getApplicationDocumentsDirectory();
      final videoPath = '${directory.path}/feeltrip_reel_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final videoFile = File(videoPath);
      await videoFile.create(recursive: true);

      // 4. Actualizar estado y video
      setState(() {
        _selectedMusic = music;
        _selectedTransitions = transitions;
      });

      _initializeVideo(videoPath);

    } catch (e) {
      AppLogger.e('Error en generación de reel: $e');
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  void _initializeVideo(String path) {
    _videoController?.dispose();
    // NOTA: Para el pitch, usar VideoPlayerController.asset si no tienes un archivo real
    _videoController = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _lastVideoPath = path;
            _videoController?.play();
            _videoController?.setLooping(true);
          });
        }
      });
  }

  String _getRandomMusic() => ['Andino Chill', 'Rural Beats', 'Wanderlust', 'Deep Reflections'][Random().nextInt(4)];
  List<String> _getRandomTransitions() => ['Fade', 'Zoom', 'Dissolve'].sublist(0, Random().nextInt(2) + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('FEELTRIP REELS', 
          style: GoogleFonts.jetBrainsMono(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(colorScheme),
            const SizedBox(height: 32),
            _buildGenerateButton(colorScheme),
            const SizedBox(height: 40),
            if (_lastVideoPath != null && !isGenerating) ...[
              _buildVideoPreview(colorScheme),
              const SizedBox(height: 24),
              _buildDetailsCard(colorScheme),
            ] else if (isGenerating) ...[
              _buildLoadingState(colorScheme),
            ] else if (entries.isEmpty) ...[
              _buildEmptyState(colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          _loadingMessage,
          style: GoogleFonts.jetBrainsMono(fontSize: 12, color: colorScheme.onSurface),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.movie_outlined, color: colorScheme.onSurface.withValues(alpha: 0.3), size: 64),
        const SizedBox(height: 16),
        Text(
          'Sin reels generados',
          style: GoogleFonts.jetBrainsMono(fontSize: 14, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'Genera tu primera historia visual',
          style: GoogleFonts.jetBrainsMono(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(Icons.auto_awesome_outlined, color: colorScheme.primary, size: 48),
        const SizedBox(height: 16),
        Text('TU HISTORIA EN 30"', 
          style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        Text('IA OPTIMIZADA PARA ENTORNOS RURALES', 
          style: GoogleFonts.jetBrainsMono(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.5))),
      ],
    );
  }

  Widget _buildGenerateButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: isGenerating || entries.isEmpty ? null : generateReel,
        icon: isGenerating 
          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary))
          : Icon(Icons.movie_creation_outlined, color: colorScheme.primary),
        label: Text(
          isGenerating ? 'GENERANDO...' : 'GENERAR EXPEDIENTE REEL',
          style: GoogleFonts.jetBrainsMono(color: colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildVideoPreview(ColorScheme colorScheme) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_videoController?.value.isInitialized ?? false)
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
          else
            const Icon(Icons.videocam_off_outlined, color: Colors.white24, size: 48),
          
          Positioned(
            bottom: 16,
            child: Row(
              children: [
                _videoActionButton(colorScheme, Icons.play_arrow, () => _videoController?.play()),
                const SizedBox(width: 12),
                _videoActionButton(colorScheme, Icons.pause, () => _videoController?.pause()),
                const SizedBox(width: 12),
                _videoActionButton(colorScheme, Icons.share_outlined, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoActionButton(ColorScheme colorScheme, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: colorScheme.onSurface,
        child: Icon(icon, color: colorScheme.surface, size: 20),
      ),
    );
  }

  Widget _buildDetailsCard(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow('BANDA SONORA', _selectedMusic ?? 'N/A'),
          _detailRow('TRANSICIONES', _selectedTransitions?.join(', ') ?? 'N/A'),
          _detailRow('FORMATO', '16:9_VERTICAL'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 10)),
        ],
      ),
    );
  }
}
