import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/services/emotional_engine_service.dart';

/// Pantalla que visualiza la "huella emocional" detectada por la IA
/// tras el análisis de una crónica o diario de viaje.
class EmotionalResultsScreen extends StatelessWidget {
  final EmotionalAnalysis analysis;

  const EmotionalResultsScreen({super.key, required this.analysis});

  // Identidad visual de FeelTrip (basada en SettingsScreen)
  static const Color brandTeal = Color(0xFF00695C);
  static const Color accentAmber = Color(0xFFFF8F00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'ANÁLISIS_EMOCIONAL.sys',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        backgroundColor: brandTeal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. INDICADOR DE SENTIMIENTO GLOBAL
            _buildSectionHeader('SENTIMIENTO_GLOBAL'),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    _getSentimentLabel(analysis.sentimentScore),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _getSentimentColor(analysis.sentimentScore),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 10,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: SliderComponentShape.noThumb,
                        overlayShape: SliderComponentShape.noOverlay,
                        disabledActiveTrackColor: _getSentimentColor(analysis.sentimentScore),
                        disabledInactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: analysis.sentimentScore,
                        min: -1.0,
                        max: 1.0,
                        onChanged: null, // Deshabilitado: solo lectura visual
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // 2. NUBE DE EMOCIONES DOMINANTES
            _buildSectionHeader('EMOCIONES_DETECTADAS'),
            const SizedBox(height: 16),
            ...analysis.dominantEmotions.map((emotion) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              color: Colors.white,
              child: ListTile(
                title: Text(
                  emotion.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.bar_chart, color: accentAmber),
              ),
            )),
            const SizedBox(height: 48),

            // 3. MOSAICO DE TAGS (Chip Layout)
            _buildSectionHeader('TEMAS_CLAVE'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: analysis.travelTags.map((tag) => Chip(
                label: Text(
                  '#$tag',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: brandTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: brandTeal.withValues(alpha: 0.1),
                side: BorderSide.none,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      '> $title',
      style: GoogleFonts.jetBrainsMono(
        fontSize: 12,
        color: brandTeal,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  String _getSentimentLabel(double score) {
    if (score > 0.4) return 'MUY POSITIVO';
    if (score > 0.1) return 'POSITIVO';
    if (score < -0.4) return 'MUY NEGATIVO';
    if (score < -0.1) return 'NEGATIVO';
    return 'BALANCEADO';
  }

  Color _getSentimentColor(double score) {
    if (score > 0.1) return Colors.teal[700]!;
    if (score < -0.1) return Colors.red[700]!;
    return Colors.blueGrey;
  }
}