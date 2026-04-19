import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManifestoScreen extends StatelessWidget {
  const ManifestoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandGold = Color(0xFFFFBF00);
    const Color boneWhite = Color(0xFFF5F5DC);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: boneWhite,
            elevation: 0,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'MANIFESTO DEL VIAJERO',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: brandGold,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildPoemLine('No viajamos para escapar de la vida,', 0),
                _buildPoemLine('sino para que la vida no se nos escape.', 1),
                const SizedBox(height: 60),
                _buildManifestoPoint(
                  '1. EL FINAL DEL TURISMO',
                  'El turismo consume lugares; el explorador los habita. En FeelTrip, no buscamos el "check" en la lista, buscamos el latido del destino.',
                ),
                _buildManifestoPoint(
                  '2. LA IA COMO ALMA, NO COMO CÁLCULO',
                  'Nuestra tecnología no solo organiza datos; traduce el asombro. Cada crónica generada es un espejo de tu transformación personal.',
                ),
                _buildManifestoPoint(
                  '3. LO INVISIBLE ES LO ESENCIAL',
                  'Los mejores viajes ocurren en los silencios entre destinos. Somos el guía que te susurra cuándo detenerte y simplemente mirar.',
                ),
                const SizedBox(height: 80),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: brandGold.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'FEELTRIP',
                          style: GoogleFonts.jetBrainsMono(
                            color: brandGold,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'VIAJA PARA RECORDAR',
                          style: GoogleFonts.jetBrainsMono(
                            color: boneWhite.withValues(alpha: 0.5),
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoemLine(String text, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildManifestoPoint(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFFFFBF00),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: GoogleFonts.inter(
              color: const Color(0xFFF5F5DC).withValues(alpha: 0.7),
              fontSize: 15,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}
