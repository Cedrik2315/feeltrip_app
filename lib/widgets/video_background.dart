import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class FeelTripVideoBackground extends StatefulWidget {
  const FeelTripVideoBackground({super.key});

  @override
  State<FeelTripVideoBackground> createState() =>
      _FeelTripVideoBackgroundState();
}

class _FeelTripVideoBackgroundState extends State<FeelTripVideoBackground> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Apuntamos al video configurado en pubspec.yaml
    _controller = VideoPlayerController.asset("assets/video/video_FeelTrip.mp4")
      ..initialize().then((_) {
        // Aseguramos que el video haga loop y no tenga sonido
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        // Refrescamos para mostrar el video con una transición suave
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    // Es importante detener y liberar el controlador para evitar fugas de memoria.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un Stack para superponer el video sobre un fondo negro.
    // Esto evita un parpadeo blanco durante la inicialización.
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fondo negro que se muestra mientras el video carga.
        Container(color: Colors.black),
        // El video aparece con un fundido suave una vez que está listo.
        AnimatedOpacity(
          opacity: _isInitialized ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1000),
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
      ],
    );
  }
}
