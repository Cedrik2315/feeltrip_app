import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/comment_model.dart';
import '../mock_data.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool useMockData = true; // CAMBIAR A FALSE CUANDO FIRESTORE ESTÉ LISTO

  /// Crear un nuevo comentario
  Future<void> addComment({
    required String storyId,
    required String userId,
    required String userName,
    required String userAvatar,
    required String content,
  }) async {
    try {
      if (useMockData) {
        // MOCK: Simular guardar en mock_data
        final commentId = const Uuid().v4();
        final newComment = {
          'id': commentId,
          'storyId': storyId,
          'userId': userId,
          'userName': userName,
          'userAvatar': userAvatar,
          'content': content,
          'reactions': [],
          'createdAt': Timestamp.now(),
          'likes': 0,
        };
        
        MockData.mockComments.putIfAbsent(storyId, () => []);
        MockData.mockComments[storyId]!.insert(0, newComment);
        print('✅ [MOCK] Comentario agregado: $commentId');
        return;
      }

      // FIRESTORE REAL (cuando esté disponible)
      final commentId = const Uuid().v4();
      final comment = Comment(
        id: commentId,
        storyId: storyId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        content: content,
        reactions: [],
        createdAt: DateTime.now(),
        likes: 0,
      );

      await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc(commentId)
          .set(comment.toFirestore());

      print('✅ Comentario agregado a Firestore: $commentId');
    } catch (e) {
      print('❌ Error agregando comentario: $e');
      rethrow;
    }
  }

  /// Obtener comentarios de una historia
  Stream<List<Comment>> getComments(String storyId) {
    if (useMockData) {
      // MOCK: Retornar datos mock como stream
      final mockCommentsList = MockData.mockComments[storyId] ?? [];
      final comments = mockCommentsList.map((data) {
        return Comment(
          id: data['id'],
          storyId: data['storyId'],
          userId: data['userId'],
          userName: data['userName'],
          userAvatar: data['userAvatar'],
          content: data['content'],
          reactions: List<String>.from(data['reactions']),
          createdAt: data['createdAt'].toDate(),
          likes: data['likes'],
        );
      }).toList();
      
      // Retornar como Stream (simulando Firestore)
      return Stream.value(comments);
    }

    // FIRESTORE REAL
    return _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromFirestore(doc))
            .toList());
  }

  /// Agregar reacción a un comentario
  Future<void> addReaction({
    required String storyId,
    required String commentId,
    required String reaction, // '❤️', '😂', '🔥', etc
  }) async {
    try {
      if (useMockData) {
        // MOCK: Agregar reacción al mock data
        final comments = MockData.mockComments[storyId] ?? [];
        final comment = comments.firstWhere((c) => c['id'] == commentId, orElse: () => {});
        if (comment.isNotEmpty) {
          final reactions = List<String>.from(comment['reactions']);
          reactions.add(reaction);
          comment['reactions'] = reactions;
          print('✅ [MOCK] Reacción agregada: $reaction');
        }
        return;
      }

      // FIRESTORE REAL
      final docRef = _firestore
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc(commentId);

      await docRef.update({
        'reactions': FieldValue.arrayUnion([reaction])
      });

      print('✅ Reacción agregada: $reaction');
    } catch (e) {
      print('❌ Error agregando reacción: $e');
      rethrow;
    }
  }

  /// Dar like a un comentario
  Future<void> likeComment({
    required String storyId,
    required String commentId,
  }) async {
    try {
      await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc(commentId)
          .update({
        'likes': FieldValue.increment(1)
      });

      print('✅ Like agregado al comentario');
    } catch (e) {
      print('❌ Error dando like: $e');
      rethrow;
    }
  }

  /// Eliminar comentario
  Future<void> deleteComment({
    required String storyId,
    required String commentId,
  }) async {
    try {
      await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc(commentId)
          .delete();

      print('✅ Comentario eliminado');
    } catch (e) {
      print('❌ Error eliminando comentario: $e');
      rethrow;
    }
  }
}
