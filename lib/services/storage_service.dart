import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _boxName = 'user_prefs';

  /// Inicializa Hive para almacenamiento local rápido.
  static Future<void> initHive() async {
    try {
      await Hive.initFlutter();
      await Hive.openBox<dynamic>(_boxName);
      AppLogger.i('Hive inicializado correctamente');
    } catch (e) {
      AppLogger.e('Error inicializando Hive: $e');
    }
  }

  /// Guarda datos del usuario localmente para el radar y sesión.
  static void saveUserData(String name, String city) {
    final box = Hive.box<dynamic>(_boxName);
    box.put('userName', name);
    box.put('lastCity', city);
  }

  /// Obtiene el nombre del usuario guardado localmente.
  static String? getUserName() =>
      Hive.box<dynamic>(_boxName).get('userName') as String?;

  // Subir foto de perfil
  static Future<String?> uploadProfilePhoto(File file) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;
      final ref = _storage.ref().child('profiles/$uid/avatar.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Subir foto de diario
  static Future<String?> uploadDiaryPhoto(File file, String entryId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('diary/$uid/$entryId/$fileName');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Subir foto de historia
  static Future<String?> uploadStoryPhoto(File file, String storyId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('stories/$uid/$storyId/$fileName');
      await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Eliminar archivo
  static Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // Ignorar error si el archivo no existe
    }
  }
}
