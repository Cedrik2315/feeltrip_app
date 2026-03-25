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