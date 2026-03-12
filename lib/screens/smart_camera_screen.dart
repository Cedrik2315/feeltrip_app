import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SmartCameraScreen extends StatefulWidget {
  const SmartCameraScreen({super.key});

  @override
  State<SmartCameraScreen> createState() => _SmartCameraScreenState();
}

class _SmartCameraScreenState extends State<SmartCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  final int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    cameras = await availableCameras();
    if (cameras == null || cameras!.isEmpty) {
      Get.snackbar('Error', 'No se encontraron cámaras disponibles.');
      return;
    }
    _controller =
        CameraController(cameras![_cameraIndex], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. VISTA PREVIA DE CÁMARA (Pantalla Completa)
          Center(
            child: CameraPreview(_controller!),
          ),

          // 2. INTERFAZ "FEELTRIP" SOBREPUESTA
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.flash_off,
                      color: Colors.white, size: 30),
                  onPressed: () {},
                ),
                // BOTÓN DE DISPARO
                GestureDetector(
                  onTap: () async {
                    final image = await _controller!.takePicture();
                    Get.toNamed('/preview-entry', arguments: image.path);
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.flip_camera_android,
                      color: Colors.white, size: 30),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // BOTÓN CERRAR
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }
}
