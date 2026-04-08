import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:feeltrip_app/models/vision_models.dart';

import 'package:feeltrip_app/core/di/camera_providers.dart';
import 'package:feeltrip_app/core/di/location_providers.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/services/vision_service.dart';
import 'package:feeltrip_app/widgets/vision_ai_proposal_card.dart';

class SmartCameraScreen extends ConsumerStatefulWidget {
  const SmartCameraScreen({super.key});

  @override
  ConsumerState<SmartCameraScreen> createState() => _SmartCameraScreenState();
}

class _SmartCameraScreenState extends ConsumerState<SmartCameraScreen> {
  
  @override
  Widget build(BuildContext context) {
    final cameras = ref.watch(cameraProvider);
    final currentCameraId = ref.watch(currentCameraIdProvider);
    final visionState = ref.watch(visionServiceProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: cameras.when(
        data: (camList) {
          if (camList.isEmpty) return _buildNoCameraState();

          // Autoselección de cámara inicial si es nula
          if (currentCameraId == null) {
            _autoSelectCamera(camList);
          }

          return SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. PREVISUALIZACIÓN CON CORRECCIÓN DE RATIO
                if (currentCameraId != null)
                  _buildCameraPreview(currentCameraId)
                else
                  const Center(child: CircularProgressIndicator()),

                // 2. OVERLAY DE ENFOQUE "EDITORIAL"
                _buildFocusOverlay(),

                // 3. BOTONES SUPERIORES (Cerrar, Flash, Rotar)
                _buildTopBar(cameras),

                // 4. PANEL DE RESULTADOS IA (Con lógica de estados)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 140,
                  child: _buildBottomPanel(visionState),
                ),

                // 5. BOTÓN DE CAPTURA HÁPTICO
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildCaptureButton()),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.teal)),
        error: (error, _) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  // --- COMPONENTES OPTIMIZADOS ---

  Widget _buildCameraPreview(String cameraId) {
    return ref.watch(cameraControllerProvider(cameraId)).when(
      data: (controller) {
        if (controller == null) return const Center(child: Text('Sin permisos', style: TextStyle(color: Colors.white)));
        
        // Mejora: Ajuste de AspectRatio para evitar estiramientos
        return Center(
          child: CameraPreview(controller),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.teal)),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildFocusOverlay() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(seconds: 2),
        width: 280,
        height: 380,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            // Pequeñas esquinas de enfoque
            _buildCorner(top: 0, left: 0, isTop: true, isLeft: true),
            _buildCorner(top: 0, right: 0, isTop: true, isLeft: false),
            _buildCorner(bottom: 0, left: 0, isTop: false, isLeft: true),
            _buildCorner(bottom: 0, right: 0, isTop: false, isLeft: false),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right, required bool isTop, required bool isLeft}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Colors.teal, width: 3) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Colors.teal, width: 3) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Colors.teal, width: 3) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Colors.teal, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    final animating = ref.watch(captureAnimatingProvider);

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact(); // Feedback al tocar
        ref.read(captureAnimatingProvider.notifier).state = true;
      },
      onTapUp: (_) {
        ref.read(captureAnimatingProvider.notifier).state = false;
        _onCapture();
      },
      child: AnimatedScale(
        scale: animating ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 80, height: 80,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.camera_alt, color: Colors.black, size: 30),
          ),
        ),
      ),
    );
  }

  // --- LÓGICA DE CAPTURA CON HÁPTICA ---

  Future<void> _onCapture() async {
    final cameraId = ref.read(currentCameraIdProvider);
    if (cameraId == null) return;

    final controller = ref.read(cameraControllerProvider(cameraId)).valueOrNull;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      HapticFeedback.mediumImpact(); // Vibración de "obturador"
      
      final picture = await controller.takePicture();
      final imageFile = File(picture.path);

      // Reset de IA anterior
      ref.read(visionServiceProvider.notifier).reset();

      Position? pos;
      try { pos = await ref.read(userLocationProvider.future); } catch (_) {}

      // Envío al Observatorio IA
      await ref.read(visionServiceProvider.notifier).analyzeImage(imageFile, position: pos);

    } catch (e) {
      AppLogger.e('Captura fallida: $e');
    }
  }

  // --- MÉTODOS DE APOYO ---

  void _autoSelectCamera(List<CameraDescription> camList) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentCameraIdProvider.notifier).selectCamera(camList.first.name);
    });
  }

  Widget _buildTopBar(AsyncValue<List<CameraDescription>> cameras) {
    return Positioned(
      top: 20, left: 20, right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(icon: FontAwesomeIcons.xmark, onPressed: () => context.pop()),
          _buildCircleButton(
            icon: FontAwesomeIcons.cameraRotate, 
            onPressed: () => _switchCamera(cameras)
          ),
        ],
      ),
    );
  }

  void _switchCamera(AsyncValue<List<CameraDescription>> cameras) {
    final currentId = ref.read(currentCameraIdProvider);
    cameras.whenData((list) {
      final idx = list.indexWhere((c) => c.name == currentId);
      final nextIdx = (idx + 1) % list.length;
      ref.read(currentCameraIdProvider.notifier).switchCamera(nextIdx);
      HapticFeedback.selectionClick();
    });
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black45),
      child: IconButton(onPressed: onPressed, icon: FaIcon(icon, color: Colors.white, size: 18)),
    );
  }

  Widget _buildBottomPanel(VisionState visionState) {
    return visionState.when(
      initial: () => const SizedBox.shrink(),
      loading: () => _buildStatusPanel('Analizando vestigios...'),
      error: (msg) => _buildErrorPanel(msg),
      success: (result) {
        final labels = result.imageLabels ?? result.topLabels ?? [];
        if (labels.isEmpty) return const SizedBox.shrink();
        return VisionAiProposalCard(labels: labels);
      },
    );
  }

  Widget _buildStatusPanel(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal)),
          const SizedBox(width: 16),
          Text(msg, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'serif', fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildErrorPanel(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(15)),
      child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
    );
  }

  Widget _buildNoCameraState() => const Center(child: Text('Cámara no detectada', style: TextStyle(color: Colors.white)));
}