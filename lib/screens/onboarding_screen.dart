import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Colores del sistema FeelTrip_OS
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color carbon = Color(0xFF1A1A1A);

  final List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: 'EXPLORACIÓN_OFFLINE',
      description: 'Navega por rutas remotas sin depender de la red. FeelTrip mantiene tus mapas y diarios activos en todo momento.',
      icon: Icons.map_outlined,
      accent: Colors.blueGrey,
    ),
    OnboardingPageData(
      title: 'MEMORIA_VISUAL',
      description: 'Captura la esencia de cada destino. Un sistema diseñado para que tus recuerdos prevalezcan sobre la estética efímera.',
      icon: Icons.auto_awesome_mosaic_outlined,
      accent: Colors.brown,
    ),
    OnboardingPageData(
      title: 'GESTIÓN_DE_RUTA',
      description: 'Centraliza tus reservas y logística en una interfaz limpia, eliminando el ruido digital de tus vacaciones.',
      icon: Icons.architecture,
      accent: const Color(0xFF2C3E50),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: boneWhite,
      body: Stack(
        children: [
          // Fondo con degradado técnico sutil
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  pages[_currentPage].accent.withValues(alpha: 0.15),
                  boneWhite
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) => setState(() => _currentPage = value),
            itemCount: pages.length,
            itemBuilder: (context, index) => _buildPage(pages[index]),
          ),

          // Header: Logo o Label de sistema
          Positioned(
            top: 60,
            left: 40,
            child: Text(
              'FEELTRIP_INIT_v1.0',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10, 
                fontWeight: FontWeight.bold, 
                color: carbon.withValues(alpha: 0.4)
              ),
            ),
          ),

          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: Text('SALTAR_TUTORIAL', 
                style: GoogleFonts.jetBrainsMono(
                  color: carbon.withValues(alpha: 0.6), 
                  fontSize: 11,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
          ),

          // Controles inferiores
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Column(
              children: [
                _buildIndicators(),
                const SizedBox(height: 48),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 2,
          width: _currentPage == index ? 32 : 12,
          decoration: BoxDecoration(
            color: _currentPage == index ? carbon : carbon.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final bool isLastPage = _currentPage == pages.length - 1;

    return Row(
      children: [
        if (_currentPage > 0)
          IconButton(
            onPressed: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuart,
            ),
            icon: const Icon(Icons.arrow_back, color: carbon),
          ),
        const Spacer(),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (isLastPage) {
                _completeOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutQuart,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: carbon,
              foregroundColor: boneWhite,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLastPage ? 'CONFIGURAR_ACCESO' : 'CONTINUAR',
                  style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(page.icon, size: 80, color: carbon),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              color: carbon,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: GoogleFonts.ebGaramond(
              fontSize: 20, 
              color: carbon.withValues(alpha: 0.8), 
              height: 1.4,
              fontStyle: FontStyle.italic
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
  });
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
}