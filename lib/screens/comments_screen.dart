import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/di/providers.dart';
import '../../models/comment_model.dart';
import '../../models/travel_agency_model.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({
    super.key,
    required this.storyId,
  });
  final String storyId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  bool _permissionsRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_permissionsRequested) {
      _requestPermissions();
      _permissionsRequested = true;
    }
  }

  Future<void> _requestPermissions() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      final newSettings = await messaging.requestPermission();
      if (newSettings.authorizationStatus == AuthorizationStatus.authorized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notificaciones habilitadas ✅')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentProvider(widget.storyId));
    final commentController = TextEditingController();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final reactions = ['❤️', '😂', '😍', '🔥', '👍', '😢'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                ref.invalidate(commentProvider(widget.storyId));
                return Future.value();
              },
              child: commentsAsync.when(
                data: (comments) => comments.isEmpty 
                  ? const CenterEmptyComments()
                  : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) => CommentCard(
                        comment: comments[index],
                        storyId: widget.storyId,
                        userId: userId,
                        reactions: reactions,
                        ref: ref,
                      ),
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
          CommentInput(
            storyId: widget.storyId,
            controller: commentController,
          ),
        ],
      ),
    );
  }
}

class CenterEmptyComments extends StatelessWidget {
  const CenterEmptyComments({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.comment_bank_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Sin comentarios aún', style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Sé el primero en comentar', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  const CommentCard({
    super.key,
    required this.comment,
    required this.storyId,
    required this.userId,
    required this.reactions,
    required this.ref,
  });

  final Comment comment;
  final String storyId;
  final String userId;
  final List<String> reactions;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: comment.userAvatar.isNotEmpty
                    ? NetworkImage(comment.userAvatar)
                    : null,
                child: comment.userAvatar.isEmpty 
                  ? const Icon(Icons.person, size: 20) 
                  : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<TravelAgency?>(
                      future: ref.read(agencyServiceProvider).getAgencyById(comment.userId),
                      builder: (context, snapshot) {
                        final isVerified = snapshot.data?.verified ?? false;
                        return Row(
                          children: [
                            Flexible(
                              child: Text(
                                comment.userName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.verified, color: Colors.blue, size: 16),
                              ),
                          ],
                        );
                      },
                    ),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (comment.userId == userId)
                GestureDetector(
                  onTap: () => ref.read(commentServiceProvider).deleteComment(storyId, comment.id),
                  child: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => ref.read(commentServiceProvider).likeComment(storyId, comment.id),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${comment.likes}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _showReactionPicker(context, ref, storyId, comment.id, reactions),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_emotions_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${comment.reactions.length}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          if (comment.reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 4,
                children: comment.reactions.map((r) => Text(r, style: const TextStyle(fontSize: 16))).toList(),
              ),
            ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300),
        ],
      ),
    );
  }

  void _showReactionPicker(BuildContext context, WidgetRef ref, String storyId, String commentId, List<String> reactions) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Agrega una reacción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: reactions.map((reaction) => GestureDetector(
                onTap: () {
                  ref.read(commentServiceProvider).addReaction(storyId, commentId, reaction);
                  Navigator.pop(context);
                },
                child: Text(reaction, style: const TextStyle(fontSize: 32)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inSeconds < 60) return 'ahora';
    if (difference.inMinutes < 60) return 'hace ${difference.inMinutes}m';
    if (difference.inHours < 24) return 'hace ${difference.inHours}h';
    if (difference.inDays < 7) return 'hace ${difference.inDays}d';
    return 'hace ${difference.inDays ~/ 7}s';
  }
}

class CommentInput extends ConsumerWidget {
  const CommentInput({
    super.key,
    required this.storyId,
    required this.controller,
  });

  final String storyId;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void submitComment() {
      if (controller.text.trim().isEmpty) return;
      ref.read(commentServiceProvider).addComment(storyId, controller.text.trim());
      controller.clear();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.person, size: 16, color: Colors.blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => submitComment(),
              decoration: InputDecoration(
                hintText: 'Agrega un comentario...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: submitComment,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
