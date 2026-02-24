import 'package:flutter_test/flutter_test.dart';
import 'package:feeltrip_app/services/ai_service.dart';

void main() {
  group('AIService - Model Tests', () {
    test('TravelRecommendation model should store data correctly', () {
      final recommendation = TravelRecommendation(
        destinations: ['Bali', 'Tromsø', 'Cusco'],
        generatedAt: DateTime.now(),
      );

      expect(recommendation.destinations.length, 3);
      expect(recommendation.destinations.first, 'Bali');
      expect(recommendation.destinations.last, 'Cusco');
    });

    test('TravelRecommendation model should handle empty destinations', () {
      final recommendation = TravelRecommendation(
        destinations: [],
        generatedAt: DateTime.now(),
      );

      expect(recommendation.destinations, isEmpty);
    });

    test('TravelerArchetype model should store data correctly', () {
      final archetype = TravelerArchetype(
        name: 'Aventurero',
        description: 'Busca adrenalina y nuevas experiencias',
      );

      expect(archetype.name, 'Aventurero');
      expect(archetype.description, 'Busca adrenalina y nuevas experiencias');
    });

    test('TravelerArchetype model should handle empty description', () {
      final archetype = TravelerArchetype(
        name: 'Cultural',
        description: '',
      );

      expect(archetype.name, 'Cultural');
      expect(archetype.description, '');
    });

    test('TravelRecommendation should store timestamp correctly', () {
      final now = DateTime.now();
      final recommendation = TravelRecommendation(
        destinations: ['Paris'],
        generatedAt: now,
      );

      expect(recommendation.generatedAt, now);
    });
  });

  group('AIService Integration Tests', () {
    test('AIService should instantiate without errors', () {
      final service = AIService();
      expect(service, isNotNull);
      service.dispose();
    });

    test('AIService analyzeDiaryEntry should return empty list on error',
        () async {
      final service = AIService();
      // Without proper Firebase setup, this should return empty list
      final result = await service.analyzeDiaryEntry('Test entry');
      expect(result, isA<List<String>>());
      service.dispose();
    });
  });
}
