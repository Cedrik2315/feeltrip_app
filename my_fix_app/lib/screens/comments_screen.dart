import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';

// Importaciones corregidas de relativo a package
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/models/comment_model.dart';
import 'package:feeltrip_app/models/travel_agency_model.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key, required this.storyId});
  final String storyId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  bool _permissionsRequested = false;
  final TextEditingController _commentController = TextEditingController();

  // Paleta FeelTrip Comunitaria
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color mossGreen = Color(0xFF4B5320);
  static const Color charcoal = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

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
      await messaging.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentProvider(widget.storyId));
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    const reactions = ['❤️', '😂', '😍', '🔥', '👍', '😢'];

    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        backgroundColor: charcoal,
        elevation: 0,
        centerTitle: false,
        title: Text('BITÁCORA COMUNIDAD', 
          style: GoogleFonts.jetBrainsMono(fontSize: 13, color: boneWhite, letterSpacing: 1)),
        iconTheme: const IconThemeData(color: boneWhite, size: 20),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: mossGreen,
              backgroundColor: boneWhite,
              onRefresh: () async => ref.invalidate(commentProvider(widget.storyId)),
              child: commentsAsync.when(
                data: (comments) => comments.isEmpty 
                  ? const CenterEmptyComments()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0x0D000000)),
                      itemBuilder: (context, index) => CommentCard(
                        comment: comments[index],
                        storyId: widget.storyId,
                        userId: userId,
                        reactions: reactions,
                        ref: ref,
                      ),
                    ),
                loading: () => const Center(child: CircularProgressIndicator(color: mossGreen, strokeWidth: 2)),
                error: (err, _) => Center(
                  child: Text('// ERROR_DE_LOG: $err', 
                    style: GoogleFonts.jetBrainsMono(color: Colors.red.shade800, fontSize: 12))
                ),
              ),
            ),
          ),
          CommentInput(
            storyId: widget.storyId,
            controller: _commentController,
          ),
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
  final String storyId, userId;
  final List<String> reactions;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _UserAvatar(avatarUrl: comment.userAvatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _UserHeader(userId: comment.userId, userName: comment.userName, ref: ref),
                    const SizedBox(height: 2),
                    Text(_timeAgo(comment.createdAt), 
                        style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              if (comment.userId == userId)
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 16, color: Colors.grey),
                  onPressed: () => _showDeleteConfirm(context),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.content, 
            style: GoogleFonts.ebGaramond(fontSize: 17, height: 1.4, color: const Color(0xFF2A2A2A))
          ),
          const SizedBox(height: 16),
          _ReactionToolbar(comment: comment, storyId: storyId, reactions: reactions, ref: ref),
          if (comment.reactions.isNotEmpty) _ReactionSummary(reactions: comment.reactions),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF5F5DC),
        title: Text('¿ELIMINAR_REGISTRO?', style: GoogleFonts.jetBrainsMono(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              ref.read(commentServiceProvider).deleteComment(storyId, comment.id);
              Navigator.pop(ctx);
            }, 
            child: const Text('CONFIRMAR', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'JUST_NOW';
    if (diff.inMinutes < 60) return '${diff.inMinutes}M_AGO';
    if (diff.inHours < 24) return '${diff.inHours}H_AGO';
    return '${diff.inDays}D_AGO';
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.userId, required this.userName, required this.ref});
  final String userId, userName;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TravelAgency?>(
      future: ref.read(agencyServiceProvider).getAgencyById(userId),
      builder: (context, snapshot) {
        final isVerified = snapshot.data?.verified ?? false;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(userName.toUpperCase(), 
                style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.5))
            ),
            if (isVerified) const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.verified_rounded, color: Color(0xFF4B5320), size: 14),
            ),
          ],
        );
      },
    );
  }
}

class _ReactionToolbar extends StatelessWidget {
  const _ReactionToolbar({required this.comment, required this.storyId, required this.reactions, required this.ref});
  final Comment comment;
  final String storyId;
  final List<String> reactions;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.favorite_border_rounded, 
          label: '${comment.likes}',
          onTap: () => ref.read(commentServiceProvider).likeComment(storyId, comment.id),
        ),
        const SizedBox(width: 20),
        _ActionButton(
          icon: Icons.add_reaction_outlined,
          label: 'REACCIONAR',
          onTap: () => _showPicker(context),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Wrap(
          spacing: 24, runSpacing: 24,
          children: reactions.map((r) => InkWell(
            onTap: () {
              ref.read(commentServiceProvider).addReaction(storyId, comment.id, r);
              Navigator.pop(context);
            },
            child: Text(r, style: const TextStyle(fontSize: 28)),
          )).toList(),
        ),
      ),
    );
  }
}

class CommentInput extends ConsumerWidget {
  const CommentInput({super.key, required this.storyId, required this.controller});
  final String storyId;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'ESCRIBIR COMENTARIO...',
                hintStyle: GoogleFonts.jetBrainsMono(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Color(0xFFF5F5DC), size: 20),
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              ref.read(commentServiceProvider).addComment(storyId, controller.text.trim());
              controller.clear();
              FocusScope.of(context).unfocus();
            },
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.avatarUrl});
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFF4B5320).withValues(alpha: 0.1),
      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
      child: avatarUrl.isEmpty 
        ? const Icon(Icons.person_outline, size: 14, color: Color(0xFF4B5320)) 
        : null,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ReactionSummary extends StatelessWidget {
  const _ReactionSummary({required this.reactions});
  final List<String> reactions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 6,
        children: reactions.toSet().map((r) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.04), 
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05))
          ),
          child: Text(r, style: const TextStyle(fontSize: 12)),
        )).toList(),
      ),
    );
  }
}

class CenterEmptyComments extends StatelessWidget {
  const CenterEmptyComments({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_rounded, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text('HISTORIAL VACÍO', 
            style: GoogleFonts.jetBrainsMono(color: Colors.grey.shade400, letterSpacing: 2, fontSize: 12)),
        ],
      ),
    );
  }
}