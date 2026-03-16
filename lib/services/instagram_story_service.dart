import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/instagram_story.dart';
import 'storage_service.dart';

class InstagramStoryService {
  static final InstagramStoryService _instance =
      InstagramStoryService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  factory InstagramStoryService() => _instance;

  InstagramStoryService._internal();

  // Stream de stories activas (expiresAt > now)
  Stream<List<InstagramStory>> getActiveStoriesStream() {
    return _firestore
        .collection('instagram_stories')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InstagramStory.fromFirestore(doc))
            .toList());
  }

  // Crear nueva story
  Future<String> createStory(String destination) async {
    try {
      // Pick image
      final XFile? imageFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (imageFile == null) throw Exception('No image selected');

      final storyId = const Uuid().v4();
      final file = File(imageFile.path);

      // Upload image
      final imageUrl = await StorageService.uploadStoryPhoto(file, storyId);
      if (imageUrl == null) throw Exception('Upload failed');

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // Save to Firestore
      final story = InstagramStory(
        id: storyId,
        userId: user.uid,
        userName: user.displayName ?? user.email ?? 'Anonymous',
        imageUrl: imageUrl,
        destination: destination,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      await _firestore
          .collection('instagram_stories')
          .doc(storyId)
          .set(story.toFirestore());

      return storyId;
    } catch (e) {
      throw Exception('Failed to create story: $e');
    }
  }
}
