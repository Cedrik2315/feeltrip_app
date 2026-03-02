import 'dart:developer' as developer;
import 'dart:io';
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
}
