import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/experience_model.dart';

class StoryService {
  StoryService({FirebaseFirestore? firestore, FirebaseFunctions? functions})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

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
    await _functions.httpsCallable('toggleStoryLike').call({
      'storyId': storyId,
      'userId': userId,
    });
  }

  Future<void> addReaction(String storyId, String userId, String emoji) async {
    await _firestore.collection('stories').doc(storyId).update({
      'reaction': emoji,
    });
  }
}
