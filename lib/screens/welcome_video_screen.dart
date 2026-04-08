import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showUI = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/bienvenida.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _isInitialized = true);
        _controller.setVolume(0); // Protocolo silencioso
        _controller.play();
      });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (!mounted) return;
    // Disparamos la UI 800ms antes del final para un fade-in elegante
    if (_controller.value.position >= 
        (_controller.value.duration - const Duration(milliseconds: 800))) {
      if (!_showUI) {
        setState(() => _showUI = true);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color boneWhite = Color(0xFFF5F5DC);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Capa de Video con Fade-in inicial
          AnimatedOpacity(
            opacity: _isInitialized ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 1000),
            child: _isInitialized 
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const SizedBox.shrink(),
          ),

          // Interfaz de Usuario (Capa Superior)
          AnimatedOpacity(
            opacity: _showUI ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutQuart,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'FEELTRIP_PROTOCOL: ONLINE',
                        style: GoogleFonts.jetBrainsMono(
                          color: boneWhite.withValues(alpha: 0.5),
                          fontSize: 10,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: _showUI ? () {
                          HapticFeedback.heavyImpact(); // Feedback táctil "industrial"
                          context.go('/home');
                        } : null,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: boneWhite, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          minimumSize: const Size(double.infinity, 64),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        child: Text(
                          'INICIAR EXPEDICIÓN',
                          style: GoogleFonts.jetBrainsMono(
                            color: boneWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}