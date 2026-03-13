// storage_service.dart
import 'dart:io';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  static Future<bool> setInt(String key, int value) async {
    await init();
    return _prefs!.setInt(key, value);
  }

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> subirFotoParada(File imageFile, String nombreParada) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Creamos una ruta única: users/ID_USUARIO/diarios/TIMESTAMP_NOMBRE.jpg
      // Limpiamos el nombre de la parada para evitar caracteres raros en la URL
      final nombreLimpio =
          nombreParada.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$nombreLimpio.jpg';
      final ref = _storage.ref().child('users/${user.uid}/diarios/$fileName');

      // Subimos el archivo
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;

      // Retornamos la URL pública
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      developer.log("Error subiendo a Storage: $e", name: 'StorageService');
      return null;
    }
  }

  /// Sube una imagen de historia al storage y devuelve la URL
  Future<String> uploadStoryImage(File image, String userId) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      // Organiza las imágenes en una carpeta 'stories' por usuario
      final Reference ref = _storage.ref().child('stories/$userId/$fileName');

      final UploadTask uploadTask = ref.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir imagen de historia: $e');
    }
  }

  /// Sube un avatar de usuario al storage y devuelve la URL.
  /// Sobrescribe el avatar anterior si existe.
  Future<String> uploadUserAvatar(File image, String userId) async {
    try {
      // Usamos un nombre de archivo constante para que el avatar siempre se sobrescriba.
      const String fileName = 'avatar.jpg';
      final Reference ref = _storage.ref().child('users/$userId/$fileName');

      final UploadTask uploadTask = ref.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir el avatar del usuario: $e');
    }
  }
}
