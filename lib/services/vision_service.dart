import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';

part 'vision_service.freezed.dart';

@freezed
class VisionState with _$VisionState {
  const factory VisionState.initial() = _Initial;
  const factory VisionState.loading() = _Loading;
  const factory VisionState.success(VisionResult result) = _Success;
  const factory VisionState.error(String message) = _Error;
}

@freezed
class VisionResult with _$VisionResult {
  const factory VisionResult({
    double? sentimentScore, // 0.0 sad - 1.0 happy
    List<String>? imageLabels,
    String? recognizedText,
    List<String>? topLabels,
  }) = _VisionResult;
}

class VisionService extends StateNotifier<VisionState> {
  VisionService() : super(const VisionState.initial());

  Future<void> analyzeImage(XFile imageFile) async {
    state = const VisionState.loading();
    try {
      final file = File(imageFile.path);
      final inputImage = InputImage.fromFile(file);

      // Face Detection for sentiment
      final faceDetector = FaceDetector(options: FaceDetectorOptions());
      final faces = await faceDetector.processImage(inputImage);
      double? sentimentScore;
      if (faces.isNotEmpty) {
        final smilingProb = faces.first.smilingProbability ?? 0.0;
        sentimentScore = smilingProb;
        AppLogger.i('Face sentiment: $smilingProb');
      }
      faceDetector.close();

      // Image Labeling
      final labeler = ImageLabeler(options: ImageLabelerOptions());
      final labels = await labeler.processImage(inputImage);
      final imageLabels =
          labels.where((l) => l.confidence > 0.5).map((l) => l.label).toList();
      labeler.close();

      // Text Recognition
      final textRecognizer = TextRecognizer();
      final textResult = await textRecognizer.processImage(inputImage);
      final recognizedText = textResult.text;
      textRecognizer.close();

      final result = VisionResult(
        sentimentScore: sentimentScore,
        imageLabels: imageLabels,
        recognizedText: recognizedText.isNotEmpty ? recognizedText : null,
        topLabels: imageLabels.take(3).toList(),
      );

      state = VisionState.success(result);

      // Update UserMood
      await _updateUserMood(result);
    } catch (e) {
      AppLogger.e('Vision analysis error: $e');
      state = VisionState.error('Error analyzing image: $e');
    }
  }

  Future<void> _updateUserMood(VisionResult result) async {
    // Fetch current or create default
    // Assume IsarService has getCurrentUserMood and save
    // For now, mock update
    AppLogger.i(
        'Updating UserMood with vision: sentiment=${result.sentimentScore}, labels=${result.imageLabels}');
    // isar.saveUserMood(updatedMood); // Implement in IsarService if needed
  }
}
