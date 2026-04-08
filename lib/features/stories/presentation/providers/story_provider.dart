import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/features/stories/domain/models/instagram_story_model.dart';

final instagramStoryServiceProvider = Provider<InstagramStoryService>((ref) {
  return InstagramStoryService();
});

final instagramStoriesProvider = FutureProvider<List<InstagramStory>>((ref) async {
  final service = ref.read(instagramStoryServiceProvider);
  return service.fetchStories();
});

class InstagramStoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<InstagramStory>> fetchStories() async {
    final snapshot = await _firestore
        .collection('stories')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => InstagramStory.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> createStory({
    required String userId,
    required String mediaUrl,
    String? thumbnailUrl,
    int durationSeconds = 5,
  }) async {
    final file = File(mediaUrl);
    final ref = _storage.ref().child('stories/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    
    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    await _firestore.collection('stories').add({
      'userId': userId,
      'mediaUrl': downloadUrl,
      'thumbnailUrl': thumbnailUrl,
      'durationSeconds': durationSeconds,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
