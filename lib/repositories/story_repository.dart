import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/firebase_config.dart';
import '../models/comment_model.dart';
import '../models/experience_model.dart';

class StoryRepository {
  StoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<TravelerStory>> getPublicStories({int limit = 50}) async {
    final snapshot = await _firestore
        .collection(FirebaseConfig.storiesCollection)
        .orderBy(FirebaseConfig.createdAtField, descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => TravelerStory.fromFirestore(doc))
        .toList();
  }

  Future<List<TravelerStory>> getUserStories(String userId) async {
    final snapshot = await _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId)
        .collection(FirebaseConfig.storiesSubcollection)
        .orderBy(FirebaseConfig.createdAtField, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TravelerStory.fromFirestore(doc))
        .toList();
  }

  Future<TravelerStory?> getStory(String storyId) async {
    final doc = await _firestore
        .collection(FirebaseConfig.storiesCollection)
        .doc(storyId)
        .get();

    if (doc.exists) {
      return TravelerStory.fromFirestore(doc);
    }
    return null;
  }

  Future<String> createStory(String userId, TravelerStory story) async {
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

    await _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId)
        .collection(FirebaseConfig.storiesSubcollection)
        .doc(story.id)
        .set(storyData);

    await _firestore
        .collection(FirebaseConfig.storiesCollection)
        .doc(story.id)
        .set(storyData);

    return story.id;
  }

  Future<void> updateStory(
    String userId,
    String storyId,
    Map<String, dynamic> updates,
  ) async {
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
  }

  Future<void> likeStory(String storyId) {
    return _firestore
        .collection(FirebaseConfig.storiesCollection)
        .doc(storyId)
        .update({'likes': FieldValue.increment(1)});
  }

  Future<void> unlikeStory(String storyId) {
    return _firestore
        .collection(FirebaseConfig.storiesCollection)
        .doc(storyId)
        .update({'likes': FieldValue.increment(-1)});
  }

  Future<void> deleteStory(String userId, String storyId) async {
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
  }

  Stream<List<TravelerStory>> getPublicStoriesStream({int limit = 50}) {
    return _firestore
        .collection(FirebaseConfig.storiesCollection)
        .orderBy(FirebaseConfig.createdAtField, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TravelerStory.fromFirestore(doc))
            .toList());
  }

  Stream<List<TravelerStory>> getUserStoriesStream(String userId) {
    return _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId)
        .collection(FirebaseConfig.storiesSubcollection)
        .orderBy(FirebaseConfig.createdAtField, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TravelerStory.fromFirestore(doc))
            .toList());
  }

  Future<List<TravelerStory>> searchStoriesByTitle(String query) async {
    final snapshot = await _firestore
        .collection(FirebaseConfig.storiesCollection)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: '${query}z')
        .get();

    return snapshot.docs
        .map((doc) => TravelerStory.fromFirestore(doc))
        .toList();
  }

  Future<List<TravelerStory>> searchStoriesByEmotion(String emotion) async {
    final snapshot = await _firestore
        .collection(FirebaseConfig.storiesCollection)
        .where('emotionalHighlights', arrayContains: emotion)
        .orderBy(FirebaseConfig.createdAtField, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TravelerStory.fromFirestore(doc))
        .toList();
  }

  Future<List<Comment>> getCommentsForStory(String storyId) async {
    final snapshot = await _firestore
        .collection(FirebaseConfig.storiesCollection)
        .doc(storyId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
  }

  Future<void> addComment(
      {required String storyId, required String content}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Debes iniciar sesión para comentar');

    await _firestore
        .collection(FirebaseConfig.storiesCollection)
        .doc(storyId)
        .collection('comments')
        .add({
      'storyId': storyId,
      'userId': user.uid,
      'userName': user.displayName ?? 'Viajero',
      'userAvatar': user.photoURL ?? '',
      'content': content,
      'reactions': [],
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
