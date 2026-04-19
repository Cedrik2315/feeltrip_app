import 'package:flutter/material.dart';
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
  bool _initialized = false;
  bool _showAction = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/Bienvenida.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _initialized = true);
        _controller.play();
        _controller.setLooping(false);
      }).catchError((_) {
        // Fallback robusto en caso de error de asset
        if (mounted) setState(() => _showAction = true);
      });

    _controller.addListener(_videoListener);

    // Timeout fallback (4 seg max)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_showAction) {
        setState(() => _showAction = true);
      }
    });
  }

  void _videoListener() {
    if (!mounted) return;
    
    // Mostramos la acción un poco antes de que termine el video para una transición fluida
    final bool videoFinished = _controller.value.position >= 
                               (_controller.value.duration - const Duration(milliseconds: 800));
    
    if (videoFinished && !_showAction) {
      setState(() => _showAction = true);
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
    const Color terminalColor = Color(0xFFF5F5DC);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Video de Fondo con Ajuste Dinámico
          if (_initialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),

          // 2. Overlay Gradiente (Para asegurar que el texto sea legible siempre)
          if (_showAction)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: SizedBox.expand(),
            ),

          // 3. Interfaz de Usuario
          AnimatedOpacity(
            opacity: _showAction ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeIn,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    const Spacer(flex: 4),
                    
                    // Texto con estilo de consola
                    Text(
                      'BIENVENIDO A TU NUEVA AVENTURA',
                      style: GoogleFonts.jetBrainsMono(
                        color: terminalColor.withValues(alpha: 0.7),
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Botón con borde estilizado
                    OutlinedButton(
                      onPressed: () => context.go('/'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: terminalColor, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        minimumSize: const Size(double.infinity, 60),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Look más industrial/cuadrado
                        ),
                      ),
                      child: Text(
                        'INGRESAR AL SISTEMA',
                        style: GoogleFonts.jetBrainsMono(
                          color: terminalColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    TextButton(
                      onPressed: () => context.push('/manifesto'),
                      child: Text(
                        'NUESTRA MISIÓN',
                        style: GoogleFonts.jetBrainsMono(
                          color: terminalColor.withValues(alpha: 0.4),
                          fontSize: 10,
                          letterSpacing: 1.5,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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