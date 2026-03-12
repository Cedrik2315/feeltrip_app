import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:feeltrip_app/models/comment_model.dart';
import 'package:feeltrip_app/services/comment_service.dart';

class CommentsScreen extends StatefulWidget {
  final String storyId;

  const CommentsScreen({super.key, required this.storyId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();

  static const _appBarGradient = LinearGradient(
    colors: [Colors.deepPurple, Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minutos';
    } else {
      return 'hace unos segundos';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 52,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sé el primero en comentar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Comparte tu opinión y conecta con otros viajeros.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCommentCard({
    required Comment comment,
    required int index,
  }) {
    final avatarProvider = comment.userAvatar.isNotEmpty
        ? NetworkImage(comment.userAvatar)
        : null;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1, end: 0),
      duration: Duration(milliseconds: 380 + (index * 45).clamp(0, 260)),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 18 * t),
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: avatarProvider,
                    backgroundColor: Colors.deepPurple.withValues(alpha: 0.12),
                    child: avatarProvider == null
                        ? Text(
                            comment.userName.isNotEmpty
                                ? comment.userName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.deepPurple,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(comment.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (FirebaseAuth.instance.currentUser?.uid == comment.userId)
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.grey.shade700,
                      onPressed: () => _commentService
                          .deleteComment(widget.storyId, comment.id)
                          .catchError((e) => Get.snackbar('Error', e.toString())),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  comment.content,
                  style: const TextStyle(height: 1.35),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    iconSize: 26,
                    constraints:
                        const BoxConstraints(minHeight: 44, minWidth: 44),
                    icon: const Icon(Icons.favorite),
                    color: Colors.deepPurple,
                    onPressed: () => _commentService
                        .likeComment(widget.storyId, comment.id)
                        .catchError((e) => Get.snackbar('Error', e.toString())),
                  ),
                  Text(
                    comment.likes.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    iconSize: 26,
                    constraints:
                        const BoxConstraints(minHeight: 44, minWidth: 44),
                    icon: const Icon(Icons.mood),
                    color: Colors.deepPurple,
                    onPressed: () => _commentService
                        .addReaction(widget.storyId, comment.id, '👍')
                        .catchError((e) => Get.snackbar('Error', e.toString())),
                  ),
                  if (comment.reactions.isNotEmpty)
                    Expanded(
                      child: Text(
                        comment.reactions.join(' '),
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

  Widget _buildComposer() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Escribe un comentario...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
              const SizedBox(width: 10),
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.white,
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      _commentService
                          .addComment(widget.storyId, _commentController.text)
                          .then((_) => _commentController.clear())
                          .catchError((e) => Get.snackbar('Error', e.toString()));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: _appBarGradient),
        ),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Comment>>(
              stream: _commentService.getComments(widget.storyId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error al cargar comentarios'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final comment = snapshot.data![index];
                    return _buildAnimatedCommentCard(
                      comment: comment,
                      index: index,
                    );
                  },
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(height: 2, color: Colors.grey.shade200),
                  ),
                );
              },
            ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }
}
