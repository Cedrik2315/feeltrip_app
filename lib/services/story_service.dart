import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';
import '../models/experience_model.dart';

class StoryService {
  static final StoryService _instance = StoryService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory StoryService() {
    return _instance;
  }

  StoryService._internal();

  // ============ CRUD OPERATIONS ============

  /// Obtener todas las historias públicas (ordenadas por más recientes)
  Future<List<TravelerStory>> getPublicStories({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.storiesCollection)
          .orderBy(FirebaseConfig.createdAtField, descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => TravelerStory.fromFirestore(doc))
          .toList();
    } catch (e) {
      // log eliminado: ❌ Error fetching public stories: $e
      rethrow;
    }
  }

  /// Obtener historias de un usuario específico
  Future<List<TravelerStory>> getUserStories(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .collection(FirebaseConfig.storiesSubcollection)
          .orderBy(FirebaseConfig.createdAtField, descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TravelerStory.fromFirestore(doc))
          .toList();
    } catch (e) {
      // log eliminado: ❌ Error fetching user stories: $e
      rethrow;
    }
  }

  /// Obtener una historia específica
  Future<TravelerStory?> getStory(String storyId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.storiesCollection)
          .doc(storyId)
          .get();

      if (doc.exists) {
        return TravelerStory.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      // log eliminado: ❌ Error fetching story: $e
      rethrow;
    }
  }

  /// Crear una nueva historia
  Future<String> createStory(String userId, TravelerStory story) async {
    try {
      final now = DateTime.now();
      final storyData = {
        'id': story.id,
        'userId': userId,
        'author': story.author,
        'title': story.title,
        'story': story.story,
        'emotionalHighlights': story.emotionalHighlights,
        'likes': 0,
        'rating': story.rating,
        'createdAt': now,
        'updatedAt': now,
        'published': true,
      };

      // Guardar en colección privada del usuario
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .collection(FirebaseConfig.storiesSubcollection)
          .doc(story.id)
          .set(storyData);

      // Publicar en colección pública
      await _firestore
          .collection(FirebaseConfig.storiesCollection)
          .doc(story.id)
          .set(storyData);

      // log eliminado: ✅ Story created: ${story.id}
      return story.id;
    } catch (e) {
      // log eliminado: ❌ Error creating story: $e
      rethrow;
    }
  }

  /// Actualizar una historia
  Future<void> updateStory(
      String userId, String storyId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now();

      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .collection(FirebaseConfig.storiesSubcollection)
          .doc(storyId)
          .update(updates);

      await _firestore
          .collection(FirebaseConfig.storiesCollection)
          .doc(storyId)
          .update(updates);

      print('✅ Story updated: $storyId');
    } catch (e) {
      print('❌ Error updating story: $e');
      rethrow;
    }
  }

  /// Toggle like en una historia (agrega/quita userId de likedBy)
  Future<void> toggleLike(String storyId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final storyRef = _firestore
            .collection(FirebaseConfig.storiesCollection)
            .doc(storyId);
        final snapshot = await transaction.get(storyRef);
        if (!snapshot.exists) throw Exception('Story not found');

        final data = snapshot.data()!;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        final likes = (data['likes'] ?? 0) as int;

        if (likedBy.contains(userId)) {
          // Unlike
          likedBy.remove(userId);
          transaction.update(storyRef, {
            'likes': likes - 1,
            'likedBy': likedBy,
          });
          print('✅ Story unliked by $userId: $storyId');
        } else {
          // Like
          likedBy.add(userId);
          transaction.update(storyRef, {
            'likes': likes + 1,
            'likedBy': likedBy,
          });
          print('✅ Story liked by $userId: $storyId');
        }
      });
    } catch (e) {
      print('❌ Error toggling like: $e');
      rethrow;
    }
  }

  /// Agregar reacción (emoji) a una historia
  Future<void> addReaction(String storyId, String userId, String emoji) async {
    try {
      await _firestore
          .collection(FirebaseConfig.storiesCollection)
          .doc(storyId)
          .update({
        'reaction': emoji,
      });
      print('✅ Reaction $emoji added to story $storyId');
    } catch (e) {
      print('❌ Error adding reaction: $e');
      rethrow;
    }
  }

  /// Eliminar una historia
  Future<void> deleteStory(String userId, String storyId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .collection(FirebaseConfig.storiesSubcollection)
          .doc(storyId)
          .delete();

      await _firestore
          .collection(FirebaseConfig.storiesCollection)
          .doc(storyId)
          .delete();

      print('✅ Story deleted: $storyId');
    } catch (e) {
      print('❌ Error deleting story: $e');
      rethrow;
    }
  }

  // ============ STREAM OPERATIONS ============

  /// Stream de historias públicas en tiempo real
  Stream<List<TravelerStory>> getPublicStoriesStream({int limit = 20}) {
    try {
      return _firestore
          .collection(FirebaseConfig.storiesCollection)
          .orderBy(FirebaseConfig.createdAtField, descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TravelerStory.fromFirestore(doc))
              .toList());
    } catch (e) {
      print('❌ Error setting up stories stream: $e');
      rethrow;
    }
  }

  /// Stream de historias de un usuario
  Stream<List<TravelerStory>> getUserStoriesStream(String userId) {
    try {
      return _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .collection(FirebaseConfig.storiesSubcollection)
          .orderBy(FirebaseConfig.createdAtField, descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TravelerStory.fromFirestore(doc))
              .toList());
    } catch (e) {
      print('❌ Error setting up user stories stream: $e');
      rethrow;
    }
  }

  // ============ SEARCH ============

  /// Buscar historias por título
  Future<List<TravelerStory>> searchStoriesByTitle(String query) async {
    try {
      // Nota: Para búsqueda completa, usar Algolia o similar
      // Esta es una búsqueda básica por prefijo
      final snapshot = await _firestore
          .collection(FirebaseConfig.storiesCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => TravelerStory.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error searching stories: $e');
      rethrow;
    }
  }

  /// Buscar historias por emoción
  Future<List<TravelerStory>> searchStoriesByEmotion(String emotion) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.storiesCollection)
          .where('emotionalHighlights', arrayContains: emotion)
          .orderBy(FirebaseConfig.createdAtField, descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => TravelerStory.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error searching by emotion: $e');
      rethrow;
    }
  }
}
