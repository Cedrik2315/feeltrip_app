import 'package:flutter/material.dart';
import 'package:get/get.dart';
 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feeltrip_app/services/comment_service.dart';
import 'package:feeltrip_app/models/comment_model.dart';

class CommentsScreen extends StatefulWidget {
  final String storyId;

  const CommentsScreen({Key? key, required this.storyId}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'hace \${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'hace \${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'hace \${difference.inMinutes} minutos';
    } else {
      return 'hace unos segundos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comentarios'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
                  return Center(child: Text('Error al cargar comentarios'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay comentarios aún'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final comment = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: comment.userAvatar.isNotEmpty
                                      ? NetworkImage(comment.userAvatar)
                                      : null,
                                  child: comment.userAvatar.isEmpty
                                      ? Text(comment.userName[0])
                                      : null,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  comment.userName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  _formatDate(comment.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(comment.content),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.favorite),
                                  onPressed: () => _commentService
                                      .likeComment(widget.storyId, comment.id)
                                      .catchError((e) => Get.snackbar(
                                            'Error',
                                            e.toString(),
                                          )),
                                ),
                                Text(comment.likes.toString()),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.mood),
                                  onPressed: () => _commentService
                                      .addReaction(
                                          widget.storyId, comment.id, '👍')
                                      .catchError((e) => Get.snackbar(
                                            'Error',
                                            e.toString(),
                                          )),
                                ),
                                if (comment.reactions.isNotEmpty)
                                  Text(comment.reactions.join(' ')),
                                Spacer(),
                                if (FirebaseAuth.instance.currentUser?.uid ==
                                    comment.userId)
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _commentService
                                        .deleteComment(
                                            widget.storyId, comment.id)
                                        .catchError((e) => Get.snackbar(
                                              'Error',
                                              e.toString(),
                                            )),
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
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      _commentService
                          .addComment(widget.storyId, _commentController.text)
                          .then((_) => _commentController.clear())
                          .catchError((e) => Get.snackbar(
                                'Error',
                                e.toString(),
                              ));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}