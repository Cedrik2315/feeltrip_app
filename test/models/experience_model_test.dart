import 'package:flutter_test/flutter_test.dart';
import 'package:feeltrip_app/models/experience_model.dart';

void main() {
  group('TravelerStory', () {
    test('fromJson crea objeto correctamente', () {
      final map = {
        'id': '123',
        'author': 'Test Author',
        'title': 'Mi viaje',
        'story': 'Historia...',
        'emotionalHighlights': ['Alegría'],
        'tags': ['aventura'],
        'rating': 4.5,
        'likes': 10,
        'likedBy': [],
        'reaction': '',
        'createdAt': DateTime.now().toIso8601String(),
      };
      final story = TravelerStory.fromJson(map);
      expect(story.id, '123');
      expect(story.author, 'Test Author');
      expect(story.likes, 10);
    });

    test('toJson serializa correctamente', () {
      final story = TravelerStory(
        id: '123',
        author: 'Test Author',
        title: 'Mi viaje',
        story: 'Historia...',
        emotionalHighlights: ['Alegría'],
        tags: ['aventura'],
        rating: 4.5,
        likes: 10,
        likedBy: [],
        reaction: '',
        createdAt: DateTime.now(),
      );
      final map = story.toJson();
      expect(map['id'], '123');
      expect(map['author'], 'Test Author');
    });
  });

  group('DiaryEntry', () {
    test('fromJson crea objeto correctamente', () {
      final json = {
        'id': 'entry1',
        'tripId': 'trip1',
        'userId': 'user1',
        'location': 'Madrid',
        'content': 'Hoy fue un día increíble',
        'emotions': ['Alegría', 'Gratitud'],
        'photos': [],
        'reflectionDepth': 4,
        'createdAt': DateTime.now().toIso8601String(),
      };
      final entry = DiaryEntry.fromJson(json);
      expect(entry.id, 'entry1');
      expect(entry.location, 'Madrid');
      expect(entry.reflectionDepth, 4);
    });
  });
}
