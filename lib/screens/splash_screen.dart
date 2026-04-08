import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Orquestación de animaciones
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // 2. Ejecución del Bootstrap de la App
    _bootstrapApp();
  }

  Future<void> _bootstrapApp() async {
    // Espacio para inicializar lo que FeelTrip necesita:
    // - Isar/Hive para crónicas offline.
    // - Configuración de Local LLM si aplica.
    // - Verificación de sesión de usuario.
    
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 3200)),
      // _initializeDatabase(),
      // _checkCameraPermissions(),
    ]);

    if (!mounted) return;

    // Feedback físico al terminar la carga
    HapticFeedback.lightImpact();

    // Transición fluida al Login o Home
    context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colores corporativos FeelTrip (Teal Profundo)
    const primaryColor = Color(0xFF004D40);
    const accentColor = Color(0xFF00251A);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, accentColor],
          ),
        ),
        child: Stack(
          children: [
            // Contenido Principal
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeroIcon(),
                    const SizedBox(height: 32),
                    _buildBrandName(),
                    const SizedBox(height: 12),
                    _buildSlogan(),
                  ],
                ),
              ),
            ),
            
            // Footer de Marca (Ideal para el Pitch de Sercotec)
            _buildFooter(),
            
            // Indicador de progreso minimalista
            const Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroIcon() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: const Icon(
        Icons.auto_awesome_outlined, // Icono que evoca IA + Viajes
        size: 80,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBrandName() {
    return Text(
      'FeelTrip',
      style: GoogleFonts.playfairDisplay(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildSlogan() {
    return Text(
      'VIAJES QUE TRANSFORMAN',
      style: GoogleFonts.jetBrainsMono(
        color: Colors.white60,
        fontSize: 10,
        letterSpacing: 4,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildFooter() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            'EXPEDICIÓN DIGITAL • v1.0.0',
            style: GoogleFonts.jetBrainsMono(
              color: Colors.white24,
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'PROYECTO DESARROLLADO EN CHILE',
            style: GoogleFonts.jetBrainsMono(
              color: Colors.white10,
              fontSize: 8,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}