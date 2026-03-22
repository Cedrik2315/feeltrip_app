import '../../models/experience_model.dart';
import '../../services/story_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allStoriesProvider = StreamProvider<List<TravelerStory>>((ref) {
  return StoryService().getPublicStoriesStream();
});
