import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/models/vision_models.dart';

final visionServiceProvider =
    StateNotifierProvider.autoDispose<VisionService, VisionState>((ref) {
  return VisionService();
});

class VisionService extends StateNotifier<VisionState> {
  VisionService() : super(const VisionState.initial()) {
    _labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.7),
    );
  }

  late final ImageLabeler _labeler;

  Future<void> analyzeImage(File imageFile, {Position? position}) async {
    state = const VisionState.loading();

    final labels = await _analyzeLabelsFromPath(imageFile.path);
    if (labels.isEmpty) {
      state = const VisionState.error('No se detectaron elementos en la imagen.');
      return;
    }

    state = VisionState.success(
      VisionResult(
        imageLabels: labels,
        topLabels: labels.take(5).toList(),
        location: position,
      ),
    );
  }

  Future<List<String>> analyzeMoodFromImage(String filePath) async {
    final labels = await _analyzeLabelsFromPath(filePath);
    return getSuggestedEmotions(labels);
  }

  List<String> getSuggestedEmotions(List<String> labels) {
    final suggested = <String>{};
    final lowerLabels = labels.map((label) => label.toLowerCase()).toList();

    if (lowerLabels.any(
      (label) =>
          label.contains('nature') ||
          label.contains('mountain') ||
          label.contains('tree'),
    )) {
      suggested.addAll(['Paz', 'Asombro']);
    }
    if (lowerLabels.any(
      (label) =>
          label.contains('sunset') ||
          label.contains('sunrise') ||
          label.contains('horizon'),
    )) {
      suggested.addAll(['Gratitud', 'Esperanza', 'Paz']);
    }
    if (lowerLabels.any(
      (label) =>
          label.contains('food') ||
          label.contains('restaurant') ||
          label.contains('dish'),
    )) {
      suggested.addAll(['Alegria', 'Conexion']);
    }
    if (lowerLabels.any(
      (label) =>
          label.contains('people') ||
          label.contains('crowd') ||
          label.contains('smile') ||
          label.contains('face'),
    )) {
      suggested.addAll(['Alegria', 'Conexion']);
    }
    if (lowerLabels.any(
      (label) =>
          label.contains('ancient') ||
          label.contains('monument') ||
          label.contains('museum'),
    )) {
      suggested.addAll(['Reflexion', 'Nostalgia']);
    }
    if (lowerLabels.any(
      (label) =>
          label.contains('adventure') ||
          label.contains('sport') ||
          label.contains('climbing'),
    )) {
      suggested.addAll(['Transformacion', 'Miedo']);
    }
    if (lowerLabels.any(
      (label) =>
          label.contains('water') ||
          label.contains('sea') ||
          label.contains('ocean') ||
          label.contains('beach'),
    )) {
      suggested.add('Paz');
    }

    const officialEmotions = [
      'Alegria',
      'Asombro',
      'Gratitud',
      'Transformacion',
      'Miedo',
      'Paz',
      'Conexion',
      'Nostalgia',
      'Esperanza',
      'Reflexion',
    ];

    return suggested.where(officialEmotions.contains).toList();
  }

  void reset() {
    state = const VisionState.initial();
  }

  Future<List<String>> _analyzeLabelsFromPath(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);

    try {
      final labels = await _labeler.processImage(inputImage);
      final result = labels.map((label) => label.label).toList(growable: false);
      AppLogger.i('VisionService: Analisis completado. Labels: $result');
      return result;
    } catch (e) {
      AppLogger.e('VisionService: Error en analisis MLKit: $e');
      return const [];
    }
  }

  @override
  void dispose() {
    _labeler.close();
    super.dispose();
  }
}
