import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/experience_model.dart' show DiaryEntry;
import '../services/auth_service.dart';
import '../services/diary_service.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();

  List<DiaryEntry> _entriesWithImages = const [];
  bool _isLoading = true;
  String? _errorMessage;

  bool _isGenerating = false;
  bool _isSlideshowReady = false;
  bool _isPlaying = false;
  int _currentIndex = 0;
  String _suggestedMusic = '';

  Timer? _timer;
  bool _servicesLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_servicesLoaded) return;
    _servicesLoaded = true;
    _loadEntries();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final authService = context.read<AuthService>();
    final diaryService = context.read<DiaryService>();

    final uid = authService.user?.uid;
    if (uid == null || uid.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Inicia sesión para ver tu reel.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isSlideshowReady = false;
      _isPlaying = false;
      _isGenerating = false;
    });
    _timer?.cancel();

    try {
      final entries = await diaryService.getDiaryEntries(uid, limit: 200);
      final filtered = entries
          .where((e) => e.imageUrl.trim().isNotEmpty)
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _entriesWithImages = filtered;
        _isLoading = false;
        _currentIndex = 0;
      });
      _pageController.jumpToPage(0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se pudieron cargar tus momentos. Intenta de nuevo.';
      });
    }
  }

  Future<void> generateSlideshow() async {
    if (_entriesWithImages.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _isSlideshowReady = false;
      _isPlaying = false;
    });

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    setState(() {
      _isGenerating = false;
      _isSlideshowReady = true;
      _isPlaying = true;
      _currentIndex = 0;
      _suggestedMusic = _getRandomMusic();
    });

    _pageController.jumpToPage(0);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (_entriesWithImages.length < 2) return;

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_isPlaying) return;
      if (!_pageController.hasClients) return;
      if (_entriesWithImages.isEmpty) return;

      final next = (_currentIndex + 1) % _entriesWithImages.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOut,
      );
    });
  }

  void _togglePlayback() {
    if (!_isSlideshowReady) return;
    setState(() => _isPlaying = !_isPlaying);

    if (_isPlaying) {
      _startAutoPlay();
    } else {
      _timer?.cancel();
    }
  }

  String _getRandomMusic() {
    const songs = [
      'Emotional Journey',
      'Memories in Motion',
      'Wanderlust Dreams',
      'Sunset Reflections',
      'Adventure Awaits',
    ];
    return songs[Random().nextInt(songs.length)];
  }

  Future<void> _shareReel() async {
    final count = _entriesWithImages.length;
    if (count == 0) return;
    await Share.share('Mi viaje en FeelTrip - $count momentos');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Reel de Viaje'),
        backgroundColor: Colors.teal[800],
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _isLoading ? null : _loadEntries,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                'Tu historia en 30 segundos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Convertí tus momentos en un slideshow',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (_errorMessage != null)
                Expanded(
                  child: Center(
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
              else if (_entriesWithImages.isEmpty)
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Agrega fotos a tu diario para crear tu reel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.teal[800],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _isGenerating ? null : generateSlideshow,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.movie_creation),
                          label: Text(
                            _isGenerating
                                ? 'Creando magia...'
                                : 'Generar mi reel',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() => _currentIndex = index);
                                },
                                itemCount: _entriesWithImages.length,
                                itemBuilder: (context, index) {
                                  final entry = _entriesWithImages[index];
                                  return CachedNetworkImage(
                                    imageUrl: entry.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, _) =>
                                        const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, _, __) =>
                                        const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 14,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: SmoothPageIndicator(
                                    controller: _pageController,
                                    count: _entriesWithImages.length,
                                    effect: WormEffect(
                                      dotHeight: 8,
                                      dotWidth: 8,
                                      activeDotColor:
                                          Colors.white.withValues(alpha: 0.92),
                                      dotColor:
                                          Colors.white.withValues(alpha: 0.35),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 18,
                                child: _SlideOverlay(
                                  entry: _entriesWithImages[_currentIndex],
                                  showControls: _isSlideshowReady,
                                  isPlaying: _isPlaying,
                                  onTogglePlayback: _togglePlayback,
                                  onShare: _shareReel,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isSlideshowReady)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                _infoRow(
                                  'Momentos incluidos',
                                  '${_entriesWithImages.length}',
                                ),
                                const SizedBox(height: 8),
                                _infoRow('Música sugerida', _suggestedMusic),
                                const SizedBox(height: 8),
                                _infoRow(
                                  'Reproducción',
                                  'Automática cada 2s',
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_isSlideshowReady)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                              onPressed: _shareReel,
                              icon: const Icon(Icons.share),
                              label: const Text('Compartir resumen'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SlideOverlay extends StatelessWidget {
  const _SlideOverlay({
    required this.entry,
    required this.showControls,
    required this.isPlaying,
    required this.onTogglePlayback,
    required this.onShare,
  });

  final DiaryEntry entry;
  final bool showControls;
  final bool isPlaying;
  final VoidCallback onTogglePlayback;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final emotion =
        entry.emotions.isNotEmpty ? entry.emotions.first : 'Sin emoción';
    final date = DateFormat('dd MMM yyyy', 'es').format(entry.createdAt);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    emotion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (showControls) ...[
              IconButton(
                tooltip: isPlaying ? 'Pausar' : 'Reproducir',
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: onTogglePlayback,
              ),
              IconButton(
                tooltip: 'Compartir',
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: onShare,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
