import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:feeltrip_app/models/experience_model.dart';
import 'package:feeltrip_app/services/database_service.dart';

class MockDiaryService extends Mock implements DatabaseService {}

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DiaryEntry can be created from JSON', () {
    final json = {
      'id': 'test-id',
      'userId': 'user-123',
      'title': 'Test entry',
      'content': 'Test content',
      'emotions': ['Joy', 'Excitement'],
      'reflectionDepth': 3,
      'createdAt': '2024-01-01T00:00:00.000',
    };

    final entry = DiaryEntry.fromJson(json);

    expect(entry.id, 'test-id');
    expect(entry.userId, 'user-123');
    expect(entry.title, 'Test entry');
    expect(entry.content, 'Test content');
    expect(entry.emotions, ['Joy', 'Excitement']);
    expect(entry.reflectionDepth, 3);
  });

  test('DiaryEntry can convert to JSON', () {
    final entry = DiaryEntry(
      id: 'test-id',
      userId: 'user-123',
      imageUrl: '',
      title: 'Test entry',
      content: 'Test content',
      emotions: const ['Joy'],
      reflectionDepth: 3,
      createdAt: DateTime(2024, 1, 1),
    );

    final json = entry.toJson();

    expect(json['id'], 'test-id');
    expect(json['userId'], 'user-123');
    expect(json['title'], 'Test entry');
    expect(json['content'], 'Test content');
    expect(json['emotions'], ['Joy']);
    expect(json['reflectionDepth'], 3);
  });

  test('DiaryEntry can convert to Firestore map', () {
    final entry = DiaryEntry(
      id: 'test-id',
      userId: 'user-123',
      imageUrl: 'https://example.com/image.jpg',
      title: 'Test entry',
      content: 'Test content',
      emotions: const ['Joy'],
      reflectionDepth: 4,
      createdAt: DateTime(2024, 1, 1),
    );

    final map = entry.toMap();

    expect(map['userId'], 'user-123');
    expect(map['imageUrl'], 'https://example.com/image.jpg');
    expect(map['title'], 'Test entry');
    expect(map['content'], 'Test content');
    expect(map['emotions'], ['Joy']);
    expect(map['reflectionDepth'], 4);
  });
}
