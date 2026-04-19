import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feeltrip_app/services/analytics_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color terminalGreen = Color(0xFF00FF41);

  // Solo 3 páginas ultraconcretas — máximo 20 segundos cada una
  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      tag: '01 // EXPLORA',
      title: 'Tu próxima\naventura\nempieza aquí.',
      description: 'Rutas generadas por IA basadas en tu estado emocional.',
      icon: Icons.explore_outlined,
    ),
    _OnboardingPageData(
      tag: '02 // REGISTRA',
      title: 'Cada momento\ncuenta.',
      description: 'Diario visual + crónicas automáticas de cada expedición.',
      icon: Icons.auto_stories_outlined,
    ),
    _OnboardingPageData(
      tag: '03 // CONECTA',
      title: 'Una comunidad\nde exploradores.',
      description: 'Comparte expediciones. Inspira. Sé inspirado.',
      icon: Icons.public_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    AnalyticsService().logOnboardingStarted();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    await AnalyticsService().logOnboardingCompleted();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    context.go('/login');
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo Forest Mist
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),

          // Contenido
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Skip Button
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'OMITIR →',
                        style: GoogleFonts.jetBrainsMono(
                          color: boneWhite.withValues(alpha: 0.4),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                  // Page View
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: _pages.length,
                      itemBuilder: (context, i) => _buildPage(_pages[i]),
                    ),
                  ),

                  // Indicadores + CTA
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                    child: Column(
                      children: [
                        // Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: i == _currentPage ? 24 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _currentPage
                                    ? terminalGreen
                                    : boneWhite.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // CTA Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentPage == _pages.length - 1
                                  ? terminalGreen
                                  : Colors.transparent,
                              foregroundColor: _currentPage == _pages.length - 1
                                  ? Colors.black
                                  : boneWhite,
                              side: BorderSide(
                                color: _currentPage == _pages.length - 1
                                    ? terminalGreen
                                    : boneWhite.withValues(alpha: 0.4),
                              ),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                              elevation: 0,
                            ),
                            child: Text(
                              _currentPage == _pages.length - 1
                                  ? 'INICIAR EXPEDICIÓN →'
                                  : 'CONTINUAR →',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            page.tag,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: terminalGreen,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Icon(page.icon, color: boneWhite, size: 48),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: GoogleFonts.ebGaramond(
              fontSize: 42,
              color: boneWhite,
              height: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: boneWhite.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final String tag;
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingPageData({
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
  });
}