import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:feeltrip_app/models/experience_model.dart';
import 'package:feeltrip_app/presentation/providers/story_provider.dart';

class StoriesScreen extends ConsumerWidget {
  const StoriesScreen({super.key, this.tripId});

  final String? tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(allStoriesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
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
              context.push('/instagram-stories');
            },
          ),
        ],
      ),
      body: storiesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (error, _) => _ErrorState(message: error.toString()),
        data: (stories) {
          if (stories.isEmpty) {
            return const _EmptyState();
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: stories.length,
            itemBuilder: (context, index) => _StoryView(story: stories[index]),
          );
        },
      ),
    );
  }
}

class _StoryView extends StatelessWidget {
  const _StoryView({required this.story});

  final TravelerStory story;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (story.imageUrl.isNotEmpty)
          Image.network(
            story.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white24),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _fallbackBackground(),
          )
        else
          _fallbackBackground(),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black45,
                Colors.transparent,
                Colors.transparent,
                Colors.black87,
              ],
              stops: [0.0, 0.2, 0.6, 1.0],
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: 16,
          right: 80,
          child: _InfoPanel(story: story),
        ),
        Positioned(
          right: 12,
          bottom: 100,
          child: _ActionColumn(story: story),
        ),
      ],
    );
  }

  Widget _fallbackBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF29443A)],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.story});

  final TravelerStory story;

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: Text(
                      story.author.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                story.story,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      story.title,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionColumn extends StatelessWidget {
  const _ActionColumn({required this.story});

  final TravelerStory story;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCircleAction(Icons.favorite, '${story.likes}', color: Colors.redAccent),
        const SizedBox(height: 20),
        _buildCircleAction(Icons.chat_bubble, ''),
        const SizedBox(height: 20),
        _buildCircleAction(Icons.bookmark_border, ''),
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      child: const Center(
        child: Text(
          'AUN_NO_HAY_HISTORIAS_PUBLICADAS',
          style: TextStyle(color: Colors.white70, letterSpacing: 1.2),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'ERROR_LOADING_STORIES: $message',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
