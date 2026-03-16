import 'package:flutter_test/flutter_test.dart';
import 'package:feeltrip_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('se crea con campos requeridos', () {
      final user = User(
        id: 'user1',
        email: 'juan@test.com',
        name: 'Juan',
        phone: '+123456789',
        createdAt: DateTime.now(),
      );
      expect(user.id, 'user1');
      expect(user.name, 'Juan');
      expect(user.email, 'juan@test.com');
    });

    test('fromJson crea correctamente', () {
      final json = {
        'id': 'user1',
        'email': 'juan@test.com',
        'name': 'Juan',
        'phone': '+123456789',
        'profileImage': '',
        'preferences': '',
        'createdAt': DateTime.now().toIso8601String(),
        'favoriteTrips': [],
      };
      final user = User.fromJson(json);
      expect(user.id, 'user1');
      expect(user.name, 'Juan');
    });

    test('toJson serializa correctamente', () {
      final user = User(
        id: 'user1',
        email: 'juan@test.com',
        name: 'Juan',
        phone: '+123456789',
        createdAt: DateTime.now(),
      );
      final json = user.toJson();
      expect(json['id'], 'user1');
      expect(json['name'], 'Juan');
    });
  });
}
