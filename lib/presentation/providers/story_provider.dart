import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feeltrip_app/models/instagram_story_model.dart';
import 'package:feeltrip_app/models/experience_model.dart';
import 'package:feeltrip_app/services/instagram_story_service.dart';
import 'package:feeltrip_app/services/story_service.dart';

final storyServiceProvider = Provider<StoryService>((ref) {
  return StoryService();
});

final allStoriesProvider = StreamProvider<List<TravelerStory>>((ref) {
  return ref.watch(storyServiceProvider).getPublicStoriesStream();
});

final instagramStoryServiceProvider = Provider<InstagramStoryService>((ref) {
  return InstagramStoryService();
});

final instagramStoriesProvider = StreamProvider<List<InstagramStory>>((ref) {
  return ref.watch(instagramStoryServiceProvider).watchActiveStories();
});
