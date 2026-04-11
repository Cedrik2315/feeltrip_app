import 'dart:io';
import 'dart:async';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:feeltrip_app/core/error/error_handler.dart';
import 'package:feeltrip_app/models/instagram_story_model.dart';
import 'package:feeltrip_app/presentation/providers/story_provider.dart';

class InstagramStoriesScreen extends ConsumerStatefulWidget {
  const InstagramStoriesScreen({super.key});

  @override
  ConsumerState<InstagramStoriesScreen> createState() => _InstagramStoriesScreenState();
}

class _InstagramStoriesScreenState extends ConsumerState<InstagramStoriesScreen> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentIndex = 0;
  bool _isCreatingStory = false;

  // Paleta FeelTrip
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color carbon = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer(int storyCount) {
    _timer?.cancel();
    if (storyCount == 0 || _isCreatingStory) return;

    _timer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;

      if (_currentIndex < storyCount - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
        );
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _createStory() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    
    if (image == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isCreatingStory = true;
      _timer?.cancel();
    });

    try {
      await ref.read(instagramStoryServiceProvider).createStory(
            userId: uid,
            imageFile: File(image.path),
          );
      
      if (mounted) {
        _showStatus('LOG: EXPEDICIÃ“N_VISUAL_CARGADA');
      }
    } catch (error, stackTrace) {
      if (mounted) ErrorHandler.handleError(context, error, stackTrace);
    } finally {
      if (mounted) setState(() => _isCreatingStory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(instagramStoriesProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: carbon,
        body: storiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: boneWhite, strokeWidth: 1)),
          error: (error, _) => _buildErrorState(error.toString()),
          data: (stories) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_isCreatingStory && _timer == null) {
                _startTimer(stories.length);
              }
            });

            if (stories.isEmpty) return _buildEmptyState();

            return Stack(
              children: [
                // Visor de Historias
                PageView.builder(
                  controller: _pageController,
                  itemCount: stories.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                    _startTimer(stories.length);
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTapDown: (details) => _handleTap(details, stories.length),
                      child: _StorySlide(story: stories[index]),
                    );
                  },
                ),

                // Overlay Superior (Gradiente + ProgresiÃ³n)
                _buildTopOverlay(stories.length),

                // BotÃ³n de Cierre
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: boneWhite, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Indicador de Carga de Nueva Historia
                if (_isCreatingStory)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: boneWhite, strokeWidth: 2),
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: boneWhite.withValues(alpha: 0.15),
          elevation: 0,
          onPressed: _isCreatingStory ? null : _createStory,
          child: const Icon(Icons.add_a_photo_outlined, color: boneWhite),
        ),
      ),
    );
  }

  Widget _buildTopOverlay(int count) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          bottom: 30,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: .7), Colors.transparent],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: List.generate(count, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: index < _currentIndex ? 1.0 : (index == _currentIndex ? null : 0.0),
                        backgroundColor: boneWhite.withValues(alpha: .2),
                        valueColor: const AlwaysStoppedAnimation<Color>(boneWhite),
                        minHeight: 2,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LIVE_FEED_SYS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: boneWhite.withValues(alpha: .5),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details, int totalStories) {
    final width = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < width / 3) {
      if (_currentIndex > 0) {
        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      if (_currentIndex < totalStories - 1) {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      } else {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_enhance_outlined, color: boneWhite.withValues(alpha: .2), size: 48),
          const SizedBox(height: 16),
          Text(
            'SIN_HISTORIAS_DISPONIBLES',
            style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: .4), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Text('// ERROR_STORY_FEED: $error', 
        style: GoogleFonts.jetBrainsMono(color: Colors.red.shade900, fontSize: 11)),
    );
  }

  void _showStatus(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.jetBrainsMono(fontSize: 11)),
        backgroundColor: carbon,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _StorySlide extends StatelessWidget {
  const _StorySlide({required this.story});
  final InstagramStory story;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      story.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(color: Color(0xFFF5F5DC), strokeWidth: 1));
      },
      errorBuilder: (context, _, __) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white24)),
    );
  }
}



