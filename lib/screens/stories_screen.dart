import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// --- MODELO ---
class TravelerStory {
  TravelerStory({
    required this.id,
    required this.userName,
    required this.imageUrl,
    required this.location,
    required this.description,
    this.isLiked = false,
  });
  final String id;
  final String userName;
  final String imageUrl;
  final String location;
  final String description;
  final bool isLiked;
}

// --- PROVIDER ---
final storiesProvider = Provider<List<TravelerStory>>((ref) {
  return [
    TravelerStory(
      id: '1',
      userName: 'Ana de Limache',
      imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
      location: 'Valle del Aconcagua',
      description: 'Cosechando tomates limachinos bajo el sol de la mañana. 🍅',
    ),
    TravelerStory(
      id: '2',
      userName: 'Carlos_Ruta',
      imageUrl: 'https://images.unsplash.com/photo-1516655855035-d52156588298',
      location: 'Cerro La Campana',
      description: 'La vista desde la cumbre hoy estaba increíble. ¡Aire puro!',
    ),
  ];
});

// --- UI ---
class StoriesScreen extends ConsumerWidget {
  const StoriesScreen({super.key, this.tripId});
  final String? tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(storiesProvider);
    
    return Scaffold(
      extendBodyBehindAppBar: true, // Para que la imagen llegue hasta arriba
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'EXPLORACIONES',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo, color: Colors.white),
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.push('/smart-camera');
            },
          ),
        ],
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: stories.length,
        itemBuilder: (context, index) => _buildStoryItem(context, stories[index]),
      ),
    );
  }

  Widget _buildStoryItem(BuildContext context, TravelerStory story) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Imagen con Placeholder y Error handling
        Image.network(
          story.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator(color: Colors.white24)));
          },
        ),

        // 2. Gradientes combinados para contraste editorial
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black45, Colors.transparent, Colors.transparent, Colors.black87],
              stops: [0.0, 0.2, 0.6, 1.0],
            ),
          ),
        ),

        // 3. Información con Glassmorphism (Panel Inferior)
        Positioned(
          bottom: 50,
          left: 16,
          right: 80,
          child: _buildInfoPanel(story),
        ),

        // 4. Botones de Acción Verticales
        Positioned(
          right: 12,
          bottom: 100,
          child: _buildActionColumn(story),
        ),
      ],
    );
  }

  Widget _buildInfoPanel(TravelerStory story) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars, color: Colors.tealAccent, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    story.userName.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                story.description,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(story.location, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionColumn(TravelerStory story) {
    return Column(
      children: [
        _buildCircleAction(Icons.favorite, '2.4k', color: Colors.redAccent),
        const SizedBox(height: 20),
        _buildCircleAction(Icons.chat_bubble, '124'),
        const SizedBox(height: 20),
        _buildCircleAction(Icons.bookmark_border, 'Save'),
        const SizedBox(height: 20),
        _buildCircleAction(Icons.share, ''),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, String label, {Color color = Colors.white}) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black26, border: Border.all(color: Colors.white10)),
            child: Icon(icon, color: color, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        if (label.isNotEmpty)
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}