import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comment_model.dart';
import '../services/story_service.dart';

class CommentsScreen extends StatefulWidget {
  final String storyId;

  const CommentsScreen({super.key, required this.storyId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  late Future<List<Comment>> _commentsFuture;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  void _fetchComments() {
    // Usamos un setState para que el FutureBuilder se reconstruya con el nuevo future.
    setState(() {
      _commentsFuture =
          context.read<StoryService>().getCommentsForStory(widget.storyId);
    });
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty || _isPosting) return;

    setState(() => _isPosting = true);

    try {
      await context.read<StoryService>().addComment(
            storyId: widget.storyId,
            content: _commentController.text.trim(),
          );

      // --- INICIO DE LA CORRECCIÓN ---
      // El error 'use_build_context_synchronously' ocurre si se usa 'context'
      // después de un 'await' sin verificar si el widget sigue "montado".
      if (!mounted) return;
      // --- FIN DE LA CORRECCIÓN ---

      _commentController.clear();
      // Refrescar comentarios
      _fetchComments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al publicar el comentario: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comentarios')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Center(
                      child: Text('Sé el primero en comentar.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                            child: Text(comment.userName.isNotEmpty
                                ? comment.userName.substring(0, 1).toUpperCase()
                                : "?")),
                        title: Text(comment.userName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(comment.content),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration:
                    const InputDecoration(hintText: 'Añade un comentario...'),
                onSubmitted: _isPosting ? null : (_) => _postComment(),
              ),
            ),
            IconButton(
              icon: _isPosting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
              onPressed: _isPosting ? null : _postComment,
            ),
          ],
        ),
      ),
    );
  }
}
