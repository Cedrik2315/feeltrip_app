import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/experience_model.dart';

class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TravelerStory>> getPublicStoriesStream() {
    return _firestore
        .collection('stories')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data() as Map);
              data['id'] = doc.id;
              return TravelerStory.fromJson(data);
            }).toList());
  }

  Future<void> toggleLike(String storyId, String userId) async {
    final ref = _firestore.collection('stories').doc(storyId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final likedBy =
        List<String>.from((doc.data()?['likedBy'] as List<dynamic>?) ?? []);
    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
    } else {
      likedBy.add(userId);
    }
    await ref.update({
      'likedBy': likedBy,
      'likes': likedBy.length,
    });
  }

  Future<void> addReaction(String storyId, String userId, String emoji) async {
    await _firestore.collection('stories').doc(storyId).update({
      'reaction': emoji,
    });
  }
}
