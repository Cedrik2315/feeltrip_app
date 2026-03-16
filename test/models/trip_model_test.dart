import 'package:flutter_test/flutter_test.dart';
import 'package:feeltrip_app/models/trip_model.dart';

void main() {
  group('TripModel', () {
    test('se crea correctamente', () {
      final trip = Trip(
        id: 'trip1',
        title: 'Test Trip',
        description: 'Description',
        destination: 'Paris',
        country: 'France',
        price: 100.0,
        duration: 5,
        difficulty: 'Easy',
        images: [],
        highlights: [],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 5)),
        maxParticipants: 10,
        category: 'Adventure',
        guide: 'Guide Name',
        experienceType: 'adventure',
        emotions: [],
        learnings: [],
        transformationMessage: '',
        culturalConnections: [],
      );
      expect(trip.id, 'trip1');
      expect(trip.title, 'Test Trip');
      expect(trip.price, 100.0);
    });

    test('fromJson crea correctamente', () {
      final json = {
        'id': 'trip1',
        'title': 'Test Trip',
        'description': 'Description',
        'destination': 'Paris',
        'country': 'France',
        'price': 100.0,
        'duration': 5,
        'difficulty': 'Easy',
        'images': [],
        'highlights': [],
        'startDate': DateTime.now().toIso8601String(),
        'endDate': DateTime.now().add(Duration(days: 5)).toIso8601String(),
        'maxParticipants': 10,
        'category': 'Adventure',
        'guide': 'Guide Name',
        'experienceType': 'adventure',
        'emotions': [],
        'learnings': [],
        'transformationMessage': '',
        'culturalConnections': [],
        'isTransformative': false,
      };
      final trip = Trip.fromJson(json);
      expect(trip.id, 'trip1');
      expect(trip.destination, 'Paris');
    });

    test('toJson serializa correctamente', () {
      final trip = Trip(
        id: 'trip1',
        title: 'Test Trip',
        description: 'Description',
        destination: 'Paris',
        country: 'France',
        price: 100.0,
        duration: 5,
        difficulty: 'Easy',
        images: [],
        highlights: [],
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        maxParticipants: 10,
        category: 'Adventure',
        guide: 'Guide Name',
      );
      final json = trip.toJson();
      expect(json['id'], 'trip1');
      expect(json['title'], 'Test Trip');
    });
  });
}
