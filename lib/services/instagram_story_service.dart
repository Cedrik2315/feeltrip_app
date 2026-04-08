import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:feeltrip_app/models/instagram_story_model.dart';
import 'package:feeltrip_app/services/storage_service.dart';

class InstagramStoryService {
  InstagramStoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<InstagramStory>> watchActiveStories() {
    return _firestore
        .collection('instagram_stories')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return InstagramStory.fromJson({
                ...doc.data(),
                'id': doc.id,
              });
            }).toList());
  }

  Future<void> createStory({
    required String userId,
    required File imageFile,
  }) async {
    final url = await StorageService.uploadStoryPhoto(imageFile, userId);
    if (url == null) {
      throw StateError('No se pudo subir la imagen de la story.');
    }

    await _firestore.collection('instagram_stories').add({
      'userId': userId,
      'imageUrl': url,
      'createdAt': Timestamp.now(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(hours: 24)),
      ),
    });
  }
}
