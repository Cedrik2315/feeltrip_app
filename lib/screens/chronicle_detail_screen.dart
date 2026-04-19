import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:feeltrip_app/models/chronicle_model.dart';
import 'package:feeltrip_app/presentation/providers/subscription_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ChronicleDetailScreen extends ConsumerWidget {
  const ChronicleDetailScreen({super.key, required this.chronicle});
  final ChronicleModel chronicle;

  // Paleta Crónica (Estilo Papel/Expedición)
  static const Color paperBase = Color(0xFFEDE8DE);
  static const Color inkBlack = Color(0xFF1A1712);
  static const Color agedGold = Color(0xFFB89A5A);
  static const Color dustySilt = Color(0xFF8A7F6E);
  static const Color forestLine = Color(0xFF3D5A4A);
  static const Color borderBeige = Color(0xFFD4CBB9);

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: chronicle.fullText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Crónica copiada al portapapeles',
          style: GoogleFonts.jetBrainsMono(color: paperBase, fontSize: 12)),
        backgroundColor: inkBlack,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = chronicle.expeditionData;
    final expNum = chronicle.expeditionNumber.toString().padLeft(3, '0');
    final dateStr = _formatDate(chronicle.generatedAt);
    
    // Obtener código de referido del usuario
    final sub = ref.watch(subscriptionProvider).valueOrNull;
    final refCode = sub?.referralCode ?? '';

    return Scaffold(
      backgroundColor: paperBase,
      appBar: AppBar(
        backgroundColor: paperBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: inkBlack),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, size: 18, color: dustySilt),
            tooltip: 'Compartir en redes',
            onPressed: () {
              HapticFeedback.lightImpact();
              final cta = refCode.isNotEmpty 
                ? '\n🎁 Usa mi invitación $refCode para probar FeelTrip Pro.' 
                : '';
              Share.share(
                '🏔️ Lee mi última expedición: "${chronicle.title}"\n\n${chronicle.fullText}$cta\n\n#FeelTrip',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18, color: dustySilt),
            onPressed: () => _copyToClipboard(context),
            tooltip: 'Copiar crónica',
          ),
          const SizedBox(width: 16),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: Número de expedición
              Text(
                'EXPEDICIÓN · $expNum',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  letterSpacing: 2.5,
                  color: agedGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Metadatos Atmosféricos
              Text(
                '${data.placeName.toUpperCase()} · ${data.region.toUpperCase()}\n'
                '${data.arrivalTime} · ${data.temperature}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  letterSpacing: 0.5,
                  color: dustySilt,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              // Divisor Estético
              Container(
                width: double.infinity,
                height: 0.8,
                color: forestLine.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 32),

              // Título de la Crónica
              Text(
                chronicle.title,
                style: GoogleFonts.ebGaramond(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: inkBlack,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),

              // Imagen Generativa (Visual Metaphor)
              if (chronicle.imageUrl != null) ...[
                _AtmosphericArt(
                  imageUrl: chronicle.imageUrl!,
                  caption: chronicle.visualMetaphor,
                ),
                const SizedBox(height: 32),
              ],

              // Cuerpo del Relato
              ...chronicle.paragraphs.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      p,
                      style: GoogleFonts.ebGaramond(
                        fontSize: 18,
                        color: inkBlack.withValues(alpha: 0.9),
                        height: 1.8,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )),

              const SizedBox(height: 40),

              // Sello de Autenticidad Final
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 1,
                    color: borderBeige,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FEELTRIP · BITÁCORA DEL EXPLORADOR',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 8,
                          letterSpacing: 1.5,
                          color: dustySilt,
                        ),
                      ),
                      Text(
                        dateStr.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 8,
                          color: borderBeige,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Badge de Tono/Mood y Soundtrack
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MoodBadge(label: data.tone.displayName),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1DB954).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.library_music_rounded, size: 14, color: Color(0xFF1DB954)),
                        const SizedBox(width: 8),
                        Text(
                          'BANDA SONORA SYNC',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: const Color(0xFF1DB954),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const meses = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${dt.day} de ${meses[dt.month]} de ${dt.year}';
  }
}

class _AtmosphericArt extends StatelessWidget {
  final String imageUrl;
  final String? caption;

  const _AtmosphericArt({required this.imageUrl, this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD4CBB9), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A1712).withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(1),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: const Color(0xFFD4CBB9).withValues(alpha: 0.1),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 1),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: const Color(0xFFD4CBB9).withValues(alpha: 0.1),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                      SizedBox(height: 8),
                      Text('Imagen no disponible', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              'Metaforización visual: ${caption!.toLowerCase()}',
              style: GoogleFonts.ebGaramond(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF8A7F6E),
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _MoodBadge extends StatelessWidget {
  final String label;
  const _MoodBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD4CBB9), width: 0.8),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          letterSpacing: 2,
          color: const Color(0xFF8A7F6E),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
