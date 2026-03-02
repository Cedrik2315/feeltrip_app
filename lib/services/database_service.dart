import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum DiarySaveStrategy {
  cloudOnly,
  localOnly,
  cloudWithLocalFallback,
}

class DiarioRegistro {
  DiarioRegistro({
    required this.id,
    required this.texto,
    required this.emociones,
    required this.fecha,
    this.destino,
    this.explicacion,
    this.lat,
    this.lng,
    this.rutaDetallada,
  });

  final String id;
  final String texto;
  final List<String> emociones;
  final DateTime fecha;
  final String? destino;
  final String? explicacion;
  final double? lat;
  final double? lng;
  final List<Map<String, dynamic>>? rutaDetallada;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'texto': texto,
      'emociones': emociones,
      'fecha': fecha.toIso8601String(),
      'destino': destino,
      'explicacion': explicacion,
      'lat': lat,
      'lng': lng,
      'rutaDetallada': rutaDetallada,
    };
  }

  factory DiarioRegistro.fromJson(Map<String, dynamic> json) {
    return DiarioRegistro(
      id: (json['id'] ?? '').toString(),
      texto: (json['texto'] ?? '').toString(),
      emociones: List<String>.from(json['emociones'] ?? const <String>[]),
      fecha:
          DateTime.tryParse((json['fecha'] ?? '').toString()) ?? DateTime.now(),
      destino: json['destino']?.toString(),
      explicacion: json['explicacion']?.toString(),
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      rutaDetallada: json['rutaDetallada'] != null
          ? List<Map<String, dynamic>>.from(json['rutaDetallada'])
          : null,
    );
  }

  factory DiarioRegistro.fromFirestore(Map<String, dynamic> data, String id) {
    return DiarioRegistro(
      id: id,
      texto: (data['texto'] ?? '').toString(),
      emociones: List<String>.from(data['emociones'] ?? const <String>[]),
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      destino: data['destino']?.toString(),
      explicacion: data['explicacion']?.toString(),
      lat: data['lat']?.toDouble(),
      lng: data['lng']?.toDouble(),
      rutaDetallada: data['rutaDetallada'] != null
          ? List<Map<String, dynamic>>.from(data['rutaDetallada'])
          : null,
    );
  }
}

class DatabaseService {
  DatabaseService({
    this.strategy = DiarySaveStrategy.cloudWithLocalFallback,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Future<SharedPreferences> Function()? prefsFactory,
  })  : _db = firestore,
        _auth = auth ?? FirebaseAuth.instance,
        _prefsFactory = prefsFactory ?? SharedPreferences.getInstance;

  final FirebaseFirestore? _db;
  final FirebaseAuth _auth;
  final Future<SharedPreferences> Function() _prefsFactory;
  final DiarySaveStrategy strategy;

  static const String _localDiaryPrefix = 'diary_entries_';

  static const String _pendingSyncKey = 'pending_sync_entries';

  FirebaseFirestore get _firestore => _db ?? FirebaseFirestore.instance;

  Future<void> guardarEntrada({
    required String texto,
    required List<String> emociones,
    String? destino,
    String? explicacion,
    double? lat,
    double? lng,
    List<Map<String, dynamic>>? rutaDetallada,
  }) async {
    final user = _auth.currentUser;

    // Verificar conectividad
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool isOnline = connectivityResult != ConnectivityResult.none;

    // Si no hay internet y la estrategia permite local, guardar para sync
    bool forceLocal = !isOnline && strategy != DiarySaveStrategy.cloudOnly;

    try {
      if (strategy == DiarySaveStrategy.localOnly || forceLocal) {
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        await _guardarEntradaLocal(user?.uid, tempId, texto, emociones,
            DateTime.now(), destino, explicacion, lat, lng, rutaDetallada);

        if (forceLocal && user != null) {
          await _marcarParaSincronizacion(user.uid, {
            'id': tempId,
            'texto': texto,
            'emociones': emociones,
            'fecha': DateTime.now().toIso8601String(),
            'destino': destino,
            'explicacion': explicacion,
            'lat': lat,
            'lng': lng,
            'rutaDetallada': rutaDetallada,
          });
        }
        return;
      }

      if (user == null) {
        if (strategy == DiarySaveStrategy.cloudOnly) {
          throw Exception('Debes iniciar sesion para guardar en la nube.');
        }
        await _guardarEntradaLocal(
            null,
            DateTime.now().millisecondsSinceEpoch.toString(),
            texto,
            emociones,
            DateTime.now(),
            destino,
            explicacion,
            lat,
            lng,
            rutaDetallada);
        return;
      }

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('diaryEntries')
          .doc();

      await docRef.set({
        'id': docRef.id,
        'texto': texto,
        'emociones': emociones,
        'fecha': FieldValue.serverTimestamp(),
        'destino': destino,
        'explicacion': explicacion,
        'lat': lat,
        'lng': lng,
        'rutaDetallada': rutaDetallada,
      });

      // Mantiene un cache local minimo para continuidad offline.
      await _guardarEntradaLocal(user.uid, docRef.id, texto, emociones,
          DateTime.now(), destino, explicacion, lat, lng, rutaDetallada);
    } catch (e, st) {
      developer.log(
        'Error en DatabaseService.guardarEntrada',
        name: 'DatabaseService',
        error: e,
        stackTrace: st,
      );

      if (strategy == DiarySaveStrategy.cloudWithLocalFallback) {
        await _guardarEntradaLocal(
            user?.uid,
            DateTime.now().millisecondsSinceEpoch.toString(),
            texto,
            emociones,
            DateTime.now(),
            destino,
            explicacion,
            lat,
            lng,
            rutaDetallada);
        return;
      }

      rethrow;
    }
  }

  Future<void> _marcarParaSincronizacion(
      String uid, Map<String, dynamic> entry) async {
    final prefs = await _prefsFactory();
    final key = '${_pendingSyncKey}_$uid';
    final currentRaw = prefs.getString(key);
    final currentList = currentRaw == null
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(jsonDecode(currentRaw));

    currentList.add(entry);
    await prefs.setString(key, jsonEncode(currentList));
  }

  Future<void> sincronizarPendientes() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final prefs = await _prefsFactory();
    final key = '${_pendingSyncKey}_${user.uid}';
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return;

    final pendingList = List<Map<String, dynamic>>.from(jsonDecode(raw));
    if (pendingList.isEmpty) return;

    final batch = _firestore.batch();
    final collection =
        _firestore.collection('users').doc(user.uid).collection('diaryEntries');

    for (var entry in pendingList) {
      final docRef = collection.doc();
      // Convertir fecha string a Timestamp si es necesario o dejar que Firestore lo maneje
      // Aquí asumimos que guardamos como serverTimestamp al sincronizar
      batch.set(docRef, {
        ...entry,
        'id': docRef.id,
        'fecha': FieldValue.serverTimestamp(), // Actualizamos fecha al subir
      });
    }

    try {
      await batch.commit();
      // Limpiar pendientes tras éxito
      await prefs.remove(key);
      developer.log(
          'Sincronización completada: ${pendingList.length} entradas subidas.');
    } catch (e) {
      developer.log('Error en sincronización: $e');
      // No borramos la lista para reintentar luego
    }
  }

  Stream<List<DiarioRegistro>> obtenerEntradas() {
    final user = _auth.currentUser;

    if (strategy == DiarySaveStrategy.localOnly) {
      return _obtenerEntradasLocal(user?.uid);
    }

    if (user == null) {
      if (strategy == DiarySaveStrategy.cloudOnly) {
        return const Stream<List<DiarioRegistro>>.empty();
      }
      return _obtenerEntradasLocal(null);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('diaryEntries')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      final registros = snapshot.docs
          .map((doc) => DiarioRegistro.fromFirestore(doc.data(), doc.id))
          .toList();
      _guardarSnapshotLocal(user.uid, registros);
      return registros;
    });
  }

  Future<void> _guardarSnapshotLocal(
      String? uid, List<DiarioRegistro> registros) async {
    final prefs = await _prefsFactory();
    final payload = registros.map((e) => e.toJson()).toList();
    await prefs.setString(
        '$_localDiaryPrefix${uid ?? 'anon'}', jsonEncode(payload));
  }

  Future<void> _guardarEntradaLocal(
    String? uid,
    String id,
    String texto,
    List<String> emociones,
    DateTime fecha,
    String? destino,
    String? explicacion,
    double? lat,
    double? lng,
    List<Map<String, dynamic>>? rutaDetallada,
  ) async {
    final prefs = await _prefsFactory();
    final key = '$_localDiaryPrefix${uid ?? 'anon'}';
    final currentRaw = prefs.getString(key);
    final currentList = currentRaw == null
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(jsonDecode(currentRaw));

    currentList.insert(0, {
      'id': id,
      'texto': texto,
      'emociones': emociones,
      'fecha': fecha.toIso8601String(),
      'destino': destino,
      'explicacion': explicacion,
      'lat': lat,
      'lng': lng,
      'rutaDetallada': rutaDetallada,
    });

    await prefs.setString(key, jsonEncode(currentList));
  }

  Stream<List<DiarioRegistro>> _obtenerEntradasLocal(String? uid) async* {
    final prefs = await _prefsFactory();
    final key = '$_localDiaryPrefix${uid ?? 'anon'}';
    final raw = prefs.getString(key);

    if (raw == null || raw.isEmpty) {
      yield <DiarioRegistro>[];
      return;
    }

    final decoded = List<Map<String, dynamic>>.from(jsonDecode(raw));
    yield decoded.map(DiarioRegistro.fromJson).toList();
  }

  Future<Map<String, int>> obtenerEstadisticasSemanales() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    DateTime haceUnaSemana = DateTime.now().subtract(const Duration(days: 7));

    // Consultamos Firestore filtrando por fecha
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('diaryEntries')
        .where('fecha', isGreaterThan: haceUnaSemana)
        .get();

    Map<String, int> conteoEmociones = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      List emociones = data['emociones'] ?? [];
      for (var emocion in emociones) {
        final key = emocion.toString();
        conteoEmociones[key] = (conteoEmociones[key] ?? 0) + 1;
      }
    }
    return conteoEmociones;
  }
}
