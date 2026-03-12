import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/experience_model.dart';
import '../controllers/experience_controller.dart';
import '../controllers/auth_controller.dart';
import '../services/sharing_service.dart';
import '../widgets/social_share_sheet.dart';
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
  final _searchQuery = ''.obs;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ExperienceController>();

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
              onChanged: (value) => _searchQuery.value = value,
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
              if (_controller.isLoading && _controller.stories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredStories = _filteredStories();

              if (filteredStories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.travel_explore,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _controller.stories.isEmpty
                            ? 'No hay historias aún'
                            : 'No hay resultados para tu búsqueda',
                      ),
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
                itemCount: filteredStories.length,
                itemBuilder: (context, index) {
                  final story = filteredStories[index];
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

  List<TravelerStory> _filteredStories() {
    final query = _normalizeText(_searchQuery.value.trim());
    if (query.isEmpty) return _controller.stories;

    return _controller.stories.where((story) {
      final title = _normalizeText(story.title);
      final body = _normalizeText(story.story);
      final author = _normalizeText(story.author);
      return title.contains(query) ||
          body.contains(query) ||
          author.contains(query);
    }).toList();
  }

  String _normalizeText(String input) {
    final lowered = input.toLowerCase();
    const withAccents = 'áéíóúäëïöüàèìòùâêîôûñ';
    const withoutAccents = 'aeiouaeiouaeiouaeioun';
    final buffer = StringBuffer();
    for (final rune in lowered.runes) {
      final ch = String.fromCharCode(rune);
      final idx = withAccents.indexOf(ch);
      buffer.write(idx >= 0 ? withoutAccents[idx] : ch);
    }
    return buffer.toString();
  }

  Widget _buildStoryCard(TravelerStory story) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (story.imageUrl != null && story.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: story.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CommentsScreen(storyId: story.id),
                          ),
                        );
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

  void _shareStory(TravelerStory story) async {
    await showSocialShareSheet(
      context: context,
      title: 'Compartir historia',
      actions: [
        SocialShareAction(
          icon: Icons.chat_bubble_outline,
          iconColor: const Color(0xFF25D366),
          label: 'WhatsApp',
          onTap: () => SharingService.shareToWhatsApp(
            storyTitle: story.title,
            storyDescription: story.story,
            storyId: story.id,
          ),
        ),
        SocialShareAction(
          icon: Icons.facebook,
          iconColor: const Color(0xFF1877F2),
          label: 'Facebook',
          onTap: () => SharingService.shareToFacebook(
            storyTitle: story.title,
            storyDescription: story.story,
            storyId: story.id,
          ),
        ),
        SocialShareAction(
          icon: Icons.music_video,
          iconColor: const Color(0xFF000000),
          label: 'TikTok',
          onTap: () => SharingService.shareToTikTok(
            storyTitle: story.title,
            storyId: story.id,
          ),
        ),
        SocialShareAction(
          icon: Icons.share_outlined,
          label: 'Más opciones',
          onTap: () async {
            final deepLink =
                await SharingService.generateStoryDeepLink(story.id);
            await SharingService.shareGeneral(
              title: story.title,
              description: story.story,
              deepLink: deepLink,
            );
          },
        ),
      ],
    );
  }

  void _showAddStoryDialog() {
    final storyController = TextEditingController();
    final titleController = TextEditingController();
    final emotionsSelected = <String>[].obs;
    File? imageFile;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título de tu historia',
                      border: OutlineInputBorder(),
                      hintText: 'Un título para tu experiencia',
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  if (imageFile != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          imageFile!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final pickedFile =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setDialogState(() {
                          imageFile = File(pickedFile.path);
                        });
                      }
                    },
                    icon: const Icon(Icons.photo_library),
                    label: Text(imageFile == null
                        ? 'Añadir una imagen'
                        : 'Cambiar imagen'),
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
                          if (storyController.text.trim().isNotEmpty &&
                              titleController.text.trim().isNotEmpty) {
                            final authController = Get.find<AuthController>();
                            final user = authController.user;
                            final authorName =
                                (user?.displayName?.trim().isNotEmpty == true)
                                    ? user!.displayName!
                                    : (user?.email?.split('@').first ??
                                        'Viajero Anónimo');

                            _controller.createStory(
                              title: titleController.text.trim(),
                              story: storyController.text.trim(),
                              author: authorName,
                              emotionalHighlights: emotionsSelected.toList(),
                              rating: 5.0,
                              imageFile: imageFile,
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
            );
          },
        ),
      ),
    );
  }
}
