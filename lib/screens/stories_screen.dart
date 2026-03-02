import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../models/experience_model.dart';
import '../controllers/experience_controller.dart';
import '../services/sharing_service.dart';
import '../services/story_service.dart';
import '../services/diary_service.dart';
import 'comments_screen.dart';

class StoriesScreen extends StatefulWidget {
  final String? tripId;

  const StoriesScreen({super.key, this.tripId});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  late ExperienceController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Usar Provider si está disponible, si no crear con servicios
    try {
      _controller = context.read<ExperienceController>();
    } catch (e) {
      // Si no hay Provider, crear el controlador con los servicios necesarios
      _controller = ExperienceController(
        storyService: context.read<StoryService>(),
        diaryService: context.read<DiaryService>(),
      );
      _controller.loadAllData();
    }

    if (_controller.stories.isEmpty) {
      _controller.loadAllData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historias de Viaje'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar historias...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_controller.stories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.travel_explore,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No hay historias aÃºn'),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showAddStoryDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Comparte tu historia'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: _controller.stories.length,
                itemBuilder: (context, index) {
                  final story = _controller.stories[index];
                  return _buildStoryCard(story);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStoryDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tu Historia'),
      ),
    );
  }

  Widget _buildStoryCard(TravelerStory story) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CalificaciÃ³n: ${story.rating}/5',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${story.likes} me gusta',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              story.story,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: story.emotionalHighlights
                  .take(3)
                  .map((highlight) => Chip(
                        label: Text(highlight,
                            style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.blue.shade100,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  story.createdAt.toString().split(' ')[0],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 20),
                      onPressed: () {
                        _controller.likeStory(story.id);
                      },
                      constraints:
                          const BoxConstraints(maxHeight: 32, maxWidth: 32),
                    ),
                    IconButton(
                      icon: const Icon(Icons.comment, size: 20),
                      onPressed: () {
                        Get.to(() => CommentsScreen(storyId: story.id));
                      },
                      constraints:
                          const BoxConstraints(maxHeight: 32, maxWidth: 32),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      onPressed: () {
                        _shareStory(story);
                      },
                      constraints:
                          const BoxConstraints(maxHeight: 32, maxWidth: 32),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareStory(TravelerStory story) {
    final deepLink = SharingService.generateStoryDeepLink(story.id);
    SharingService.shareGeneral(
      title: story.title,
      description: story.story,
      deepLink: deepLink,
    );
  }

  void _showAddStoryDialog() {
    final storyController = TextEditingController();
    final emotionsSelected = <String>[].obs;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Comparte Tu Historia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: storyController,
                decoration: const InputDecoration(
                  labelText: 'Tu historia',
                  border: OutlineInputBorder(),
                  hintText: 'Comparte tu experiencia...',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              const Text(
                'Emociones:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    children: [
                      'TransformaciÃ³n',
                      'ConexiÃ³n',
                      'ReflexiÃ³n',
                      'AlegrÃ­a',
                    ]
                        .map((emotion) => FilterChip(
                              label: Text(emotion),
                              selected: emotionsSelected.contains(emotion),
                              onSelected: (selected) {
                                if (selected) {
                                  emotionsSelected.add(emotion);
                                } else {
                                  emotionsSelected.remove(emotion);
                                }
                              },
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (storyController.text.isNotEmpty) {
                        _controller.createStory(
                          title: 'Mi Historia',
                          story: storyController.text,
                          author: 'Usuario Actual',
                          emotionalHighlights: emotionsSelected.toList(),
                          rating: 5.0,
                        );
                        Navigator.pop(dialogContext);
                      }
                    },
                    child: const Text('Publicar'),
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
