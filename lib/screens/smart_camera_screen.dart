import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class SmartCameraScreen extends StatefulWidget {
  const SmartCameraScreen({super.key});

  @override
  State<SmartCameraScreen> createState() => _SmartCameraScreenState();
}

class _SmartCameraScreenState extends State<SmartCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  int _cameraIndex = 0;
  bool _flashOn = false;
  bool _aiMode = true;
  bool _isCapturing = false;
  bool _showFlash = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestCameraPermission();
  }

  Future<void> _checkAndRequestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      await _setupCamera();
    } else if (status.isDenied) {
      Get.dialog(
        AlertDialog(
          title: const Text('Permiso requerido'),
          content: const Text(
              'La cámara es necesaria para capturar momentos especiales de tu viaje.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _checkAndRequestCameraPermission();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    } else if (status.isPermanentlyDenied) {
      Get.dialog(
        AlertDialog(
          title: const Text('Permiso denegado'),
          content:
              const Text('Por favor habilita el permiso de cámara en Ajustes.'),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Abrir Ajustes'),
            ),
          ],
        ),
      );
    }
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

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    setState(() => _flashOn = !_flashOn);
    await _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
  }

  Future<void> _toggleCamera() async {
    if (cameras == null || cameras!.length < 2) return;
    await _controller?.dispose();
    setState(() => _cameraIndex = _cameraIndex == 0 ? 1 : 0);
    _controller =
        CameraController(cameras![_cameraIndex], ResolutionPreset.high);
    await _controller!.initialize();
    setState(() {});
  }

  void _toggleAIMode() {
    setState(() => _aiMode = !_aiMode);
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
        fit: StackFit.expand,
        children: [
          // 1. Preview cámara pantalla completa
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
          // Flash overlay
          AnimatedOpacity(
            opacity: _showFlash ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              color: Colors.white,
            ),
          ),
          // Top overlay degradado
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC000000),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 30),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: _toggleFlash,
                      child: Icon(
                        _flashOn ? Icons.flash_on : Icons.flash_off,
                        color: _flashOn ? Colors.amber : Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios,
                          color: Colors.white, size: 30),
                      onPressed: _toggleCamera,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // IA Badge
          if (_aiMode)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '✨ IA Activo',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Bottom overlay degradado
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xCC000000),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.photo_library,
                            color: Colors.black),
                        onPressed: () {}, // Implementar navegación galería
                      ),
                    ),
                    // Capture central
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isCapturing = true),
                      onTapUp: (_) => setState(() => _isCapturing = false),
                      onTapCancel: () => setState(() => _isCapturing = false),
                      onTap: () async {
                        setState(() => _isCapturing = true);
                        final image = await _controller!.takePicture();
                        setState(() {
                          _showFlash = true;
                          _isCapturing = false;
                        });
                        Get.toNamed('/preview-entry', arguments: image.path);
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (mounted) {
                          setState(() => _showFlash = false);
                        }
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: AnimatedScale(
                          scale: _isCapturing ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // IA Mode button
                    GestureDetector(
                      onTap: _toggleAIMode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _aiMode
                              ? Colors.amber
                              : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '✨ IA',
                              style: TextStyle(
                                color: _aiMode ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
