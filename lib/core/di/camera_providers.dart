import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final cameraProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return availableCameras();
});

final currentCameraIdProvider =
    StateNotifierProvider<CameraIdNotifier, String?>((ref) {
  return CameraIdNotifier(ref);
});

class CameraIdNotifier extends StateNotifier<String?> {
  CameraIdNotifier(this.ref) : super(null);

  final Ref ref;

  void selectCamera(String cameraId) {
    state = cameraId;
  }

  Future<void> switchCamera(List<CameraDescription> cameras) async {
    final current = state;
    final currentControllerAsync =
        current != null ? ref.read(cameraControllerProvider(current)) : null;
    final currentLens =
        currentControllerAsync?.valueOrNull?.description.lensDirection;
    final next = cameras.firstWhere(
      (camera) => camera.lensDirection != currentLens,
      orElse: () => cameras.first,
    );
    state = next.name;
  }
}

final flashModeProvider =
    StateNotifierProvider<FlashNotifier, FlashMode>((ref) {
  return FlashNotifier();
});

class FlashNotifier extends StateNotifier<FlashMode> {
  FlashNotifier() : super(FlashMode.off);

  void toggle() {
    state = state == FlashMode.off ? FlashMode.torch : FlashMode.off;
  }
}

final captureAnimatingProvider = StateProvider<bool>((ref) => false);

final cameraControllerProvider = AsyncNotifierProvider.family<
    CameraControllerNotifier, CameraController?, String>(
  CameraControllerNotifier.new,
);

class CameraControllerNotifier
    extends FamilyAsyncNotifier<CameraController?, String> {
  @override
  FutureOr<CameraController?> build(String cameraId) async {
    final cameras = await ref.read(cameraProvider.future);
    final camera = cameras.firstWhere(
      (item) => item.name == cameraId,
      orElse: () => cameras.first,
    );

    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      return null;
    }

    final controller = CameraController(camera, ResolutionPreset.high);
    await controller.initialize();
    ref.onDispose(controller.dispose);
    return controller;
  }
}
