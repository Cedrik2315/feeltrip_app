import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/app_logger.dart';
import '../models/experience_model.dart';
import '../services/database_service.dart';
import '../services/emotion_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

class DiaryController extends ChangeNotifier {
  DiaryController({
    required EmotionService emotionService,
    required DatabaseService databaseService,
    required LocationService locationService,
    required StorageService storageService,
  })  : _emotionService = emotionService,
        _databaseService = databaseService,
        _locationService = locationService,
        _storageService = storageService;

  final EmotionService _emotionService;
  final DatabaseService _databaseService;
  final LocationService _locationService;
  final StorageService _storageService;

  // Estado
  bool _isLoading = false;
  List<String> _detectedEmotions = [];
  AnalisisResultado? _aiResult;
  final Set<Marker> _markers = {};
  final List<ParadaViaje> _stops = [];

  // Getters
  bool get isLoading => _isLoading;
  List<String> get detectedEmotions => _detectedEmotions;
  AnalisisResultado? get aiResult => _aiResult;
  Set<Marker> get markers => _markers;
  List<ParadaViaje> get stops => _stops;

  Future<void> analyzeText(String texto) async {
    final limpio = texto.trim();
    if (limpio.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final resultado = await _emotionService.analizarTexto(limpio);
      _detectedEmotions = resultado?.emociones ?? [];
      _aiResult = resultado;

      // Reiniciar mapa y paradas
      _markers.clear();
      _stops.clear();

      if (resultado != null) {
        // Agregar destino principal
        if (resultado.lat != null && resultado.lng != null) {
          final pos = LatLng(resultado.lat!, resultado.lng!);
          _addStopInternal(resultado.destino, pos, isMain: true);
        }
        // Agregar ruta sugerida
        for (var stop in resultado.ruta) {
          final pos = LatLng(stop.lat, stop.lng);
          _addStopInternal(stop.nombre, pos, description: stop.descripcion);
        }
      }
    } catch (e) {
      AppLogger.debug('Error analizando texto: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addStopInternal(String nombre, LatLng pos,
      {String? description, bool isMain = false}) {
    _stops.add(
        ParadaViaje(nombre: nombre, posicion: pos, descripcion: description));
    _markers.add(Marker(
      markerId: MarkerId(nombre),
      position: pos,
      infoWindow: InfoWindow(title: nombre, snippet: description),
      icon: BitmapDescriptor.defaultMarkerWithHue(
          isMain ? BitmapDescriptor.hueRed : BitmapDescriptor.hueViolet),
    ));
  }

  Future<void> addStopFromSearch(String query) async {
    final lugares = await _locationService.buscarLugares(query);
    if (lugares.isNotEmpty) {
      final lugar = lugares.first;
      final pos = LatLng(lugar['lat'], lugar['lng']);
      _addStopInternal(lugar['nombre'], pos);
      notifyListeners();
    } else {
      throw Exception('Lugar no encontrado');
    }
  }

  void removeStop(int index) {
    if (index >= 0 && index < _stops.length) {
      final stop = _stops.removeAt(index);
      _markers.removeWhere((m) => m.markerId.value == stop.nombre);
      notifyListeners();
    }
  }

  void updateStopImage(int index, String path) {
    if (index >= 0 && index < _stops.length) {
      _stops[index].imagePath = path;
      notifyListeners();
    }
  }

  Future<void> saveDiary(String texto) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Map<String, dynamic>> rutaDetallada = [];

      for (var parada in _stops) {
        String? imageUrl;
        if (parada.imagePath != null) {
          imageUrl = await _storageService.subirFotoParada(
              File(parada.imagePath!), parada.nombre);
        }
        rutaDetallada.add({
          'nombre': parada.nombre,
          'lat': parada.posicion.latitude,
          'lng': parada.posicion.longitude,
          'descripcion': parada.descripcion,
          'fotoUrl': imageUrl,
        });
      }

      await _databaseService.guardarEntrada(
        texto: texto,
        emociones: _detectedEmotions,
        destino: _aiResult?.destino,
        lat: _aiResult?.lat,
        lng: _aiResult?.lng,
        explicacion: _aiResult?.explicacion,
        rutaDetallada: rutaDetallada,
      );

      // Limpiar estado después de guardar
      _aiResult = null;
      _detectedEmotions = [];
      _stops.clear();
      _markers.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
