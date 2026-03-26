import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/models/vision_models.dart';

class VisionService extends StateNotifier<VisionState> {
  VisionService() : super(const VisionState.initial());

  Future<void> analyzeImage(File imageFile, {Position? position}) async {
    state = const VisionState.loading();
    try {
      final inputImage = InputImage.fromFile(imageFile);

      final faceDetector = FaceDetector(options: FaceDetectorOptions());
      final faces = await faceDetector.processImage(inputImage);
      double? sentimentScore;
      if (faces.isNotEmpty) {
        sentimentScore = faces.first.smilingProbability ?? 0.0;
      }
      faceDetector.close();

      final labeler = ImageLabeler(options: ImageLabelerOptions());
      final labels = await labeler.processImage(inputImage);
      final imageLabels = labels
          .where((label) => label.confidence > 0.5)
          .map((label) => label.label)
          .toList();
      labeler.close();

      final textRecognizer = TextRecognizer();
      final textResult = await textRecognizer.processImage(inputImage);
      final recognizedText = textResult.text;
      textRecognizer.close();

      state = VisionState.success(
        VisionResult(
          sentimentScore: sentimentScore,
          imageLabels: imageLabels,
          recognizedText: recognizedText.isNotEmpty ? recognizedText : null,
          topLabels: imageLabels.take(3).toList(),
          location: position,
        ),
      );
    } catch (error) {
      AppLogger.e('Vision analysis error: $error');
      state = VisionState.error('Error analyzing image: $error');
    }
  }

  void reset() {
    state = const VisionState.initial();
  }
}
