import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Siente cada kilómetro',
      description:
          "No solo guardes coordenadas. Captura cómo te sientes, graba mensajes para tu 'yo' del futuro y crea un mapa emocional de tu vida.",
      image: 'assets/images/Onboarding1.png',
      gradientColors: [const Color(0xFF0D47A1), const Color(0xFF7B1FA2)],
    ),
    OnboardingPage(
      title: 'Tu Oráculo Personal',
      description:
          "Apunta tu cámara y deja que nuestra IA te cuente historias secretas. Traduce voces, identifica monumentos y nunca vuelvas a ser un extraño en tierra ajena.",
      image: 'assets/images/Onboarding2.png',
      gradientColors: [const Color(0xFF7B1FA2), const Color(0xFFFF5722)],
    ),
    OnboardingPage(
      title: 'Forja tu Legado',
      description:
          "Gana XP por cada descubrimiento, protege tu racha con tu tribu y desbloquea reliquias que solo los verdaderos exploradores poseen.",
      image: 'assets/images/Onboarding3.png',
      gradientColors: [const Color(0xFFFF5722), const Color(0xFFFFD700)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = index == pages.length - 1;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return _buildPage(pages[index]);
            },
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: pages.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.white38,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 4,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isLastPage) {
                        Navigator.pushReplacementNamed(context, '/login');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      _isLastPage ? 'COMENZAR AVENTURA' : 'SIGUIENTE',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: page.gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen con sombra para efecto "pop"
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                page.image,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback si no hay imagen
                  return const Icon(Icons.travel_explore,
                      size: 150, color: Colors.white54);
                },
              ),
            ),
            const SizedBox(height: 40),
            Text(
              page.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              page.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80), // Espacio para controles inferiores
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final List<Color> gradientColors;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.gradientColors,
  });
}
