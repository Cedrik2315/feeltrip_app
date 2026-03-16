import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/experience_model.dart';
import '../controllers/experience_controller.dart';
import '../services/sharing_service.dart';
import '../services/story_service.dart';
import '../services/auth_service.dart';
import 'comments_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key, this.tripId});

  final String? tripId;

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  late ExperienceController _controller;
  final TextEditingController _searchController = TextEditingController();
  final RxList<TravelerStory> _filteredStories = <TravelerStory>[].obs;
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ExperienceController>()
        ? Get.find<ExperienceController>()
        : Get.put(ExperienceController());

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamBuilder<List<TravelerStory>>(
              stream: _controller.getStoriesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error loading stories');
                }
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final allStories = snapshot.data!;
                final uniqueTags = allStories
                    .expand((s) => s.tags)
                    .toSet()
                    .toList()
                  ..insert(0, 'Todas');
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: uniqueTags
                        .map((tag) => FilterChip(
                              label: Text(tag),
                              selected: _selectedTag == tag,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedTag = selected ? tag : null;
                                });
                              },
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              var filtered = _controller.stories.toList();
              if (_selectedTag != null && _selectedTag != 'Todas') {
                filtered = filtered
                    .where((story) => story.tags.contains(_selectedTag))
                    .toList();
              }
              _filteredStories.assignAll(filtered);
              if (_filteredStories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tag, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_selectedTag == null || _selectedTag == 'Todas'
                          ? 'No hay historias aún'
                          : 'No hay historias con el tag "$_selectedTag"'),
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
                itemCount: _filteredStories.length,
                itemBuilder: (context, index) {
                  final story = _filteredStories[index];
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
                        'Calificación: ${story.rating}/5',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withAlpha(51),
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
                    Obx(() => IconButton(
                          icon: Icon(
                            (_controller.stories
                                        .firstWhereOrNull(
                                            (s) => s.id == story.id)
                                        ?.likedBy
                                        .contains(
                                            AuthService.currentUser?.uid ??
                                                '') ??
                                    false)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: (_controller.stories
                                        .firstWhereOrNull(
                                            (s) => s.id == story.id)
                                        ?.likedBy
                                        .contains(
                                            AuthService.currentUser?.uid ??
                                                '') ??
                                    false)
                                ? Colors.red
                                : null,
                            size: 20,
                          ),
                          onPressed: () {
                            _controller.toggleLike(story.id);
                          },
                          constraints:
                              const BoxConstraints(maxHeight: 32, maxWidth: 32),
                        )),
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
                    // Reaction buttons (❤️ 🔥 😮 😂)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: ['❤️', '🔥', '😮', '😂']
                            .map((emoji) => IconButton(
                                  icon: Icon(
                                    story.reaction == emoji
                                        ? Icons.favorite
                                        : Icons.add_reaction,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    StoryService().addReaction(
                                        story.id,
                                        AuthService.currentUser?.uid ?? '',
                                        emoji);
                                  },
                                  constraints: const BoxConstraints(
                                      maxHeight: 28, maxWidth: 28),
                                ))
                            .toList(),
                      ),
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
                      'Transformación',
                      'Conexión',
                      'Reflexión',
                      'Alegría',
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
