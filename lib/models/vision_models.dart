import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';

part 'vision_models.freezed.dart';

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
    double? sentimentScore,
    List<String>? imageLabels,
    String? recognizedText,
    List<String>? topLabels,
    Position? location,
  }) = _VisionResult;
}
