import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DiarySaveStrategy {
  cloudOnly,
  localOnly,
  cloudWithLocalFallback,
}

class DiarioRegistro {
  DiarioRegistro({
    required this.texto,
    required this.emociones,
    required this.fecha,
  });

  final String texto;
  final List<String> emociones;
  final DateTime fecha;

  Map<String, dynamic> toJson() {
    return {
      'texto': texto,
      'emociones': emociones,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory DiarioRegistro.fromJson(Map<String, dynamic> json) {
    return DiarioRegistro(
      texto: (json['texto'] ?? '').toString(),
      emociones: List<String>.from(json['emociones'] ?? const <String>[]),
      fecha: DateTime.tryParse((json['fecha'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  factory DiarioRegistro.fromFirestore(Map<String, dynamic> data) {
    return DiarioRegistro(
      texto: (data['texto'] ?? '').toString(),
      emociones: List<String>.from(data['emociones'] ?? const <String>[]),
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
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

  FirebaseFirestore get _firestore => _db ?? FirebaseFirestore.instance;

  Future<void> guardarEntrada({
    required String texto,
    required List<String> emociones,
  }) async {
    final user = _auth.currentUser;

    try {
      if (strategy == DiarySaveStrategy.localOnly) {
        await _guardarEntradaLocal(user?.uid, texto, emociones, DateTime.now());
        return;
      }

      if (user == null) {
        if (strategy == DiarySaveStrategy.cloudOnly) {
          throw Exception('Debes iniciar sesion para guardar en la nube.');
        }
        await _guardarEntradaLocal(null, texto, emociones, DateTime.now());
        return;
      }

      await _firestore.collection('users').doc(user.uid).collection('diaryEntries').add({
        'texto': texto,
        'emociones': emociones,
        'fecha': FieldValue.serverTimestamp(),
      });

      // Mantiene un cache local minimo para continuidad offline.
      await _guardarEntradaLocal(user.uid, texto, emociones, DateTime.now());
    } catch (e, st) {
      developer.log(
        'Error en DatabaseService.guardarEntrada',
        name: 'DatabaseService',
        error: e,
        stackTrace: st,
      );

      if (strategy == DiarySaveStrategy.cloudWithLocalFallback) {
        await _guardarEntradaLocal(user?.uid, texto, emociones, DateTime.now());
        return;
      }

      rethrow;
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
          .map((doc) => DiarioRegistro.fromFirestore(doc.data()))
          .toList();
      _guardarSnapshotLocal(user.uid, registros);
      return registros;
    });
  }

  Future<void> _guardarSnapshotLocal(String? uid, List<DiarioRegistro> registros) async {
    final prefs = await _prefsFactory();
    final payload = registros.map((e) => e.toJson()).toList();
    await prefs.setString('$_localDiaryPrefix${uid ?? 'anon'}', jsonEncode(payload));
  }

  Future<void> _guardarEntradaLocal(
    String? uid,
    String texto,
    List<String> emociones,
    DateTime fecha,
  ) async {
    final prefs = await _prefsFactory();
    final key = '$_localDiaryPrefix${uid ?? 'anon'}';
    final currentRaw = prefs.getString(key);
    final currentList = currentRaw == null
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(jsonDecode(currentRaw));

    currentList.insert(0, {
      'texto': texto,
      'emociones': emociones,
      'fecha': fecha.toIso8601String(),
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
}
