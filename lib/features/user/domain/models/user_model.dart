import 'package:flutter_test/flutter_test.dart';
import 'package:feeltrip_app/features/auth/domain/models/auth_user.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.imageUrl,
  });

  factory UserModel.fromAuthUser(AuthUser authUser) {
    return UserModel(
      id: authUser.id,
      email: authUser.email,
      name: authUser.name ?? '',
      imageUrl: authUser.photoUrl ?? '',
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  final String id;
  final String email;
  final String name;
  final String imageUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}

void main() {
  group('UserModelTests', () {
    test('Debe crearse con los campos requeridos', () {
      final user = UserModel(
        id: 'user1',
        email: 'juan@test.com',
        name: 'Juan',
        imageUrl: 'https://foto.com/juan.jpg',
      );
      expect(user.id, 'user1');
      expect(user.name, 'Juan');
      expect(user.email, 'juan@test.com');
      expect(user.imageUrl, 'https://foto.com/juan.jpg');
    });

    test('toJson serializa correctamente para Firestore', () {
      final user = UserModel(
        id: 'user1',
        email: 'juan@test.com',
        name: 'Juan',
        imageUrl: '',
      );
      final json = user.toJson();
      expect(json['id'], 'user1');
      expect(json['email'], 'juan@test.com');
    });
  });
}
