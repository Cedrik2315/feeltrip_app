import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/models/travel_proposal.dart';
import 'package:feeltrip_app/models/vision_models.dart';
import 'package:feeltrip_app/services/location_service.dart';
import 'package:feeltrip_app/services/osint_ai_service.dart';
import 'package:feeltrip_app/widgets/vision_ai_proposal_card.dart';

class SmartCameraScreen extends ConsumerWidget {
  const SmartCameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameras = ref.watch(cameraProvider);
    final currentCameraId = ref.watch(currentCameraIdProvider);
    final visionState = ref.watch(visionServiceProvider);
    final osintState = ref.watch(osintAiServiceProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: cameras.when(
        data: (camList) {
          if (camList.isEmpty) {
            return const Center(child: Text('No cameras available'));
          }

          if (currentCameraId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final notifier = ref.read(currentCameraIdProvider.notifier);
              if (ref.read(currentCameraIdProvider) == null &&
                  camList.isNotEmpty) {
                notifier.selectCamera(camList.first.name);
              }
            });
          }

          return SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (currentCameraId != null)
                  ref.watch(cameraControllerProvider(currentCameraId)).when(
                        data: (controller) {
                          if (controller == null) {
                            return const Center(
                              child: Text(
                                'Camera permissions are required',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          return CameraPreview(controller);
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) =>
                            Center(child: Text('Error: $error')),
                      )
                else
                  const Center(child: CircularProgressIndicator()),
                Center(
                  child: Container(
                    width: 250,
                    height: 350,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const FaIcon(
                          FontAwesomeIcons.xmark,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                      Row(
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final flashMode = ref.watch(flashModeProvider);
                              return IconButton(
                                onPressed: () => ref
                                    .read(flashModeProvider.notifier)
                                    .toggle(),
                                icon: Icon(
                                  flashMode == FlashMode.torch
                                      ? Icons.flash_on
                                      : Icons.flash_off,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => ref
                                .read(currentCameraIdProvider.notifier)
                                .switchCamera(camList),
                            child: const FaIcon(
                              FontAwesomeIcons.cameraRotate,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTapDown: (_) => ref
                          .read(captureAnimatingProvider.notifier)
                          .state = true,
                      onTapUp: (_) {
                        ref.read(captureAnimatingProvider.notifier).state =
                            false;
                        _onCapture(context, ref);
                      },
                      onTapCancel: () => ref
                          .read(captureAnimatingProvider.notifier)
                          .state = false,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final animating = ref.watch(captureAnimatingProvider);
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: animating ? 10 : 0,
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  right: 30,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    onPressed: () => ref
                        .read(osintAiServiceProvider.notifier)
                        .analyzeScene(),
                    child: const FaIcon(FontAwesomeIcons.rocket, size: 20),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 160,
                  child: _buildBottomPanel(visionState, osintState),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildBottomPanel(VisionState visionState, OsintState osintState) {
    return osintState.maybeWhen(
      loading: () => _buildStatusPanel('Generando propuesta vivencial...'),
      success: (TravelProposal proposal) => VisionAiProposalCard(
        labels: proposal.destinations,
        proposalText: proposal.generatedText,
      ),
      error: (String message) => _buildErrorPanel(message),
      orElse: () {
        return visionState.maybeWhen(
          initial: () => const SizedBox.shrink(),
          loading: () => _buildStatusPanel('Analizando imagen...'),
          success: (result) {
            final labels = result.topLabels ?? result.imageLabels ?? <String>[];
            if (labels.isEmpty) {
              return const SizedBox.shrink();
            }
            return VisionAiProposalCard(labels: labels);
          },
          error: (message) => _buildErrorPanel(message),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildStatusPanel(String message) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPanel(String message) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Error: $message',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _onCapture(BuildContext context, WidgetRef ref) async {
    final cameraId = ref.read(currentCameraIdProvider);
    if (cameraId == null) {
      return;
    }

    final controllerAsync = ref.read(cameraControllerProvider(cameraId));
    final controller = controllerAsync.valueOrNull;

    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    try {
      ref.read(visionServiceProvider.notifier).reset();
      ref.read(osintAiServiceProvider.notifier).reset();

      final flashMode = ref.read(flashModeProvider);
      await controller.setFlashMode(flashMode);

      final picture = await controller.takePicture();
      final imageFile = File(picture.path);
      AppLogger.i('Photo captured: ${imageFile.path}');

      final position = await ref.read(locationProvider.future);
      final gpsEnabled = await LocationService.isLocationServiceEnabled();
      if (!gpsEnabled && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Capturando sin ubicacion. Activa GPS para mejores resultados.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }

      await ref
          .read(visionServiceProvider.notifier)
          .analyzeImage(imageFile, position: position);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto guardada: ${picture.name}')),
        );
      }
    } catch (error) {
      AppLogger.e('Error capturing photo: $error');
    }
  }
}
