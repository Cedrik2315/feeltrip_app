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

  static const _appBarGradient = LinearGradient(
    colors: [Colors.deepPurple, Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: _appBarGradient),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchQuery.value = value;
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Buscar historias...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                suffixIcon: _searchController.text.trim().isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery.value = '';
                          setState(() {});
                        },
                      ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.deepPurple.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
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
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: _appBarGradient,
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddStoryDialog(),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const Text('✍️', style: TextStyle(fontSize: 22)),
        ),
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
    final hasImage = story.imageUrl != null && story.imageUrl!.isNotEmpty;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: story.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(14, 34, 14, 12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xB3000000),
                                ],
                              ),
                            ),
                            child: Text(
                              story.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Text(
                story.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (!hasImage) const SizedBox(height: 12),
            Row(
              children: [
                _buildStarRating(story.rating),
                const SizedBox(width: 8),
                Text(
                  '${story.rating.toStringAsFixed(1)}/5',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${story.likes} me gusta',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
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
              runSpacing: 8,
              children: story.emotionalHighlights
                  .take(4)
                  .map((emotion) => _emotionChip(emotion))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text(
              _formatRelativeDate(story.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _storyActionButton(
                  label: '❤️ ${story.likes}',
                  onPressed: () => _controller.likeStory(story.id),
                ),
                Text('·', style: TextStyle(color: Colors.grey.shade500)),
                _storyActionButton(
                  label: '💬 Comentar',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CommentsScreen(storyId: story.id),
                      ),
                    );
                  },
                ),
                Text('·', style: TextStyle(color: Colors.grey.shade500)),
                _storyActionButton(
                  label: '📤 Compartir',
                  onPressed: () => _shareStory(story),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _storyActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        foregroundColor: Colors.deepPurple,
        backgroundColor: Colors.deepPurple.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildStarRating(double rating, {double size = 18}) {
    final normalized = rating.clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final icon = normalized >= starIndex ? Icons.star : Icons.star_border;
        return Icon(icon, size: size, color: Colors.amber.shade700);
      }),
    );
  }

  String _formatRelativeDate(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.isNegative) return 'hoy';
    if (diff.inSeconds < 60) return 'hace unos segundos';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays < 30) return 'hace ${diff.inDays} días';
    final months = (diff.inDays / 30).floor();
    if (months < 12) return 'hace $months ${months == 1 ? 'mes' : 'meses'}';
    final years = (diff.inDays / 365).floor();
    return 'hace $years ${years == 1 ? 'año' : 'años'}';
  }

  Widget _emotionChip(String emotion) {
    final color = _emotionColor(emotion);
    return Chip(
      label: Text(
        emotion,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.16),
      side: BorderSide(color: color.withValues(alpha: 0.30)),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Color _emotionColor(String emotion) {
    switch (_normalizeText(emotion)) {
      case 'transformacion':
        return Colors.deepPurple;
      case 'conexion':
        return Colors.teal;
      case 'reflexion':
        return Colors.indigo;
      case 'alegria':
        return Colors.orange;
      case 'aventura':
        return Colors.redAccent;
      case 'paz':
        return Colors.lightBlue;
      case 'nostalgia':
        return Colors.brown;
      case 'asombro':
        return Colors.pink;
      default:
        return Colors.blueGrey;
    }
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
    var rating = 5;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        24 + MediaQuery.of(context).viewInsets.bottom,
                      ),
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const Text(
                          'Comparte tu historia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título de tu historia',
                            border: OutlineInputBorder(),
                            hintText: 'Un título para tu experiencia',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: storyController,
                          decoration: const InputDecoration(
                            labelText: 'Tu historia',
                            border: OutlineInputBorder(),
                            hintText: 'Comparte tu experiencia...',
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Calificación',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (index) {
                            final value = index + 1;
                            final selected = value <= rating;
                            return IconButton(
                              tooltip: '$value',
                              onPressed: () =>
                                  setSheetState(() => rating = value),
                              icon: Icon(
                                selected ? Icons.star : Icons.star_border,
                                color: Colors.amber.shade700,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        if (imageFile != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                imageFile!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final pickedFile = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              setSheetState(() {
                                imageFile = File(pickedFile.path);
                              });
                            }
                          },
                          icon: const Icon(Icons.photo_library),
                          label: Text(
                            imageFile == null
                                ? 'Añadir una imagen'
                                : 'Cambiar imagen',
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Emociones',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: const [
                              'Transformación',
                              'Conexión',
                              'Reflexión',
                              'Alegría',
                              'Aventura',
                              'Paz',
                              'Nostalgia',
                              'Asombro',
                            ]
                                .map(
                                  (emotion) => FilterChip(
                                    label: Text(emotion),
                                    selected: emotionsSelected.contains(emotion),
                                    selectedColor: Colors.deepPurple
                                        .withValues(alpha: 0.18),
                                    onSelected: (selected) {
                                      if (selected) {
                                        emotionsSelected.add(emotion);
                                      } else {
                                        emotionsSelected.remove(emotion);
                                      }
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(sheetContext),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (storyController.text.trim().isNotEmpty &&
                                      titleController.text.trim().isNotEmpty) {
                                    final authController =
                                        Get.find<AuthController>();
                                    final user = authController.user;
                                    final authorName =
                                        (user?.displayName?.trim().isNotEmpty ==
                                                true)
                                            ? user!.displayName!
                                            : (user?.email
                                                    ?.split('@')
                                                    .first ??
                                                'Viajero Anónimo');

                                    _controller.createStory(
                                      title: titleController.text.trim(),
                                      story: storyController.text.trim(),
                                      author: authorName,
                                      emotionalHighlights:
                                          emotionsSelected.toList(),
                                      rating: rating.toDouble(),
                                      imageFile: imageFile,
                                    );
                                    Navigator.pop(sheetContext);
                                  }
                                },
                                child: const Text('Publicar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      storyController.dispose();
      titleController.dispose();
    });
  }
}
