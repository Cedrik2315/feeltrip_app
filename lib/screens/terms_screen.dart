import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color terminalGreen = Color(0xFF00FF41);
  static const Color carbon = Color(0xFF0D0D0D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: carbon,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: boneWhite),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'TÉRMINOS DE SERVICIO',
          style: GoogleFonts.jetBrainsMono(
            color: boneWhite,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 48),
              _buildSection(
                '01 // PROTOCOLO DE ACCESO',
                'Al utilizar FeelTrip, el usuario acepta voluntariamente los términos del "Ecosistema de Exploración". El sistema recopila telemetría emocional y biométrica para optimizar las rutas sugeridas por la IA Scout.',
              ),
              _buildSection(
                '02 // PROPIEDAD DE CRÓNICAS',
                'Las crónicas generadas por el usuario son de su propiedad, otorgando a FeelTrip una licencia de uso para fines de comunidad y entrenamiento del motor emocional. Los datos personales están protegidos bajo la Ley N° 19.628.',
              ),
              _buildSection(
                '03 // RESPONSABILIDAD DE CAMPO',
                'FeelTrip actúa como un copiloto digital. La seguridad física en expediciones es responsabilidad única del Explorador. Las sugerencias de IA no reemplazan el juicio humano ante peligros naturales.',
              ),
              _buildSection(
                '04 // DERECHOS ARCO',
                'Garantizamos el Acceso, Rectificación, Cancelación y Oposición. Puedes purgar tus datos permanentemente desde el panel de Configuración > Zona de Peligro.',
              ),
              _buildSection(
                '05 // JURISDICCIÓN SANTIAGO',
                'Este contrato se rige por las leyes de la República de Chile. Cualquier controversia será resuelta ante los tribunales de la ciudad de Santiago.',
              ),
              const SizedBox(height: 80),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTRATO DEL\nEXPLORADOR',
          style: GoogleFonts.ebGaramond(
            fontSize: 40,
            color: boneWhite,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '> VERSIÓN 1.0.0 STABLE // FEB 2024',
          style: GoogleFonts.jetBrainsMono(
            color: terminalGreen,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.jetBrainsMono(
              color: terminalGreen.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              color: boneWhite.withValues(alpha: 0.6),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'EOF // FEELTRIP_OS TRANSMISSION END',
        style: GoogleFonts.jetBrainsMono(
          color: boneWhite.withValues(alpha: 0.2),
          fontSize: 9,
          letterSpacing: 2,
        ),
      ),
    );
  }
}