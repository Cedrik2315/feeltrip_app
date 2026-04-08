import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/presentation/providers/story_provider.dart';
import 'package:feeltrip_app/models/experience_model.dart';
import 'package:feeltrip_app/services/story_service.dart';

// Paleta FeelTrip
const boneWhite = Color(0xFFF5F5DC);
const mossGreen = Color(0xFF4B5320);
const carbon = Color(0xFF1A1A1A);

final storyServiceProvider = Provider((ref) => StoryService());

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(allStoriesProvider);

    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: carbon,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'EXPLORAR_EXPERIENCIAS',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12, 
            color: boneWhite, 
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded, color: boneWhite, size: 20),
            onPressed: () => context.push('/impact-dashboard'),
            tooltip: 'Ver mi impacto',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: mossGreen,
        backgroundColor: boneWhite,
        onRefresh: () async => ref.refresh(allStoriesProvider.future),
        child: storiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: mossGreen, strokeWidth: 2)),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text('Error loading feed: $error', 
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.red.shade900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(allStoriesProvider.future),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (stories) {
            if (stories.isEmpty) {
              return _EmptyFeedView();
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return _StoryCard(story: story);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/stories'),
        backgroundColor: carbon,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        icon: const Icon(Icons.add, color: boneWhite),
        label: Text(
          'NUEVA_HISTORIA', 
          style: GoogleFonts.jetBrainsMono(
            color: boneWhite, 
            fontWeight: FontWeight.bold, 
            fontSize: 12
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends ConsumerWidget {
  const _StoryCard({required this.story});

  final TravelerStory story;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push('/comments/${story.id}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with author and date
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: mossGreen,
                    child: Text(
                      story.author.isNotEmpty ? story.author[0].toUpperCase() : '?',
                      style: const TextStyle(color: boneWhite, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatDate(story.createdAt),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _LikeButton(
                    likes: story.likes,
                    onTap: () {
                      final userId = authState.valueOrNull?.id;
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('LOG: AUTH_REQUIRED_FOR_INTERACTION')),
                        );
                        return;
                      }
                      
                      ref.read(storyServiceProvider).toggleLike(story.id, userId).then((_) {
                        // Refrescamos el feed para ver el cambio en el contador
                        ref.invalidate(allStoriesProvider);
                      }).catchError((Object e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ERR: LIKE_SYNC_FAILED > $e')),
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Image
              if (story.imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      story.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              // Content
              Text(
                story.story,
                maxLines: story.imageUrl.isEmpty ? 4 : 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ebGaramond(
                  fontSize: 17, 
                  color: Colors.black87, 
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              // Divider
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.1),
              ),
              // Highlights
              if (story.emotionalHighlights.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: story.emotionalHighlights.take(3).map((highlight) => Chip(
                    label: Text(highlight, style: GoogleFonts.jetBrainsMono(fontSize: 10)),
                    backgroundColor: mossGreen.withValues(alpha: 0.1),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({
    required this.likes,
    required this.onTap,
  });

  final int likes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            Icons.favorite_border_rounded,
            color: mossGreen,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            '$likes',
            style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeedView extends StatelessWidget {
  const _EmptyFeedView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(
          Icons.auto_awesome_outlined, 
          size: 48, 
          color: Colors.grey.withValues(alpha: 0.3)
        ),
        const SizedBox(height: 16),
        Text(
          'ESPERANDO_NUEVAS_EXPEDICIONES',
          style: GoogleFonts.jetBrainsMono(
            color: Colors.grey.withValues(alpha: 0.5), 
            fontSize: 11,
            letterSpacing: 0.5
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Publica tu primera historia o espera que otros compartan sus experiencias.',
          style: GoogleFonts.ebGaramond(
            color: Colors.grey.withValues(alpha: 0.6), 
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
