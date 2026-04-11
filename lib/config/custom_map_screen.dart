import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
// Se asume que destination_map_widget.dart ya existe en lib/widgets/
// import 'package:feeltrip_app/widgets/destination_map_widget.dart'; 

class CustomMapScreen extends StatelessWidget {
  const CustomMapScreen({super.key});

  // Paleta FeelTrip Oficial
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color carbonBlack = Color(0xFF1A1A1A);
  static const Color oxidizedEarth = Color(0xFFB35A38);
  static const Color mossGreen = Color(0xFF4A5D4E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: carbonBlack,
      body: Stack(
        children: [
          // 1. Capa de Visualización del Mapa
          // Aquí se integra el DestinationMapWidget que ya tienes listo.
          // DestinationMapWidget(),
          _buildMapPlaceholder(),

          // 2. Header de Terminal (UI Overlay)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(context),
          ),

          // 3. Panel Inferior de Sugerencias IA
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _buildAISuggestions(context),
          ),
          
          // 4. Controles Técnicos Flotantes
          Positioned(
            right: 20,
            bottom: 300,
            child: _buildMapControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    // Placeholder visual mientras se vincula el widget real
    return Container(
      color: const Color(0xFF121212),
      child: Opacity(
        opacity: 0.2,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 80, color: boneWhite),
              const SizedBox(height: 16),
              Text(
                'MAP_ENGINE: ACTIVE // WAITING_FOR_WIDGET_BINDING',
                style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [carbonBlack.withValues(alpha: 0.95), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: boneWhite),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CARTOGRAFÍA_IA',
                  style: GoogleFonts.jetBrainsMono(
                    color: boneWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'ESTADO: ESCANEANDO_VALLES_CENTRALES',
                  style: GoogleFonts.jetBrainsMono(
                    color: boneWhite.withValues(alpha: 0.4),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            'SUGERENCIAS_EN_ZONA',
            style: GoogleFonts.jetBrainsMono(
              color: oxidizedEarth,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCompactCard(context, 'Valle del Aconcagua', 'Inmersión Vitivinícola', '45km'),
              _buildCompactCard(context, 'Cerro La Campana', 'Trekking Meditativo', '12km'),
              _buildCompactCard(context, 'Humedal Mantagua', 'Silencio y Naturaleza', '28km'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactCard(BuildContext context, String title, String sub, String dist) {
    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: carbonBlack,
        border: Border.all(color: boneWhite.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => context.push('/trip-details/sample'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dist, style: GoogleFonts.jetBrainsMono(color: mossGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                const Icon(Icons.arrow_outward, color: boneWhite, size: 14),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: GoogleFonts.playfairDisplay(color: boneWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(sub, style: GoogleFonts.ebGaramond(color: boneWhite.withValues(alpha: 0.5), fontSize: 14, fontStyle: FontStyle.italic)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Container(
      decoration: BoxDecoration(
        color: carbonBlack,
        border: Border.all(color: boneWhite.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _ctrlIcon(Icons.add),
          Container(height: 1, width: 20, color: boneWhite.withValues(alpha: 0.1)),
          _ctrlIcon(Icons.remove),
          Container(height: 1, width: 20, color: boneWhite.withValues(alpha: 0.1)),
          _ctrlIcon(Icons.gps_fixed),
        ],
      ),
    );
  }

  Widget _ctrlIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Icon(icon, color: boneWhite, size: 18),
    );
  }
}