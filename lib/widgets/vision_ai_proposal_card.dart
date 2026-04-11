import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/services/vision_service.dart';

class VisionAiProposalCard extends ConsumerWidget {
  const VisionAiProposalCard({
    super.key,
    required this.labels,
    this.proposalText,
  });

  final List<String> labels;
  final String? proposalText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topLabels = labels.take(3).toList();
    final text = proposalText ?? 'ANÁLISIS COMPLETADO. IDENTIFICANDO RUTAS COMPATIBLES...';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFFF8F00).withValues(alpha: 0.5), width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de Procesamiento
          Row(
            children: [
              const Icon(Icons.lens_blur_rounded, color: Color(0xFFFF8F00), size: 18),
              const SizedBox(width: 8),
              Text(
                'VISION_ENGINE_V3: TAGS DETECTADOS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF8F00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Etiquetas de Visión
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: topLabels.map((label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
              ),
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            )).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Texto de la Propuesta (Estilo Playfair para el contraste "Travel")
          Text(
            text,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.3,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botones de Acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    final query = labels.take(3).join(' ');
                    context.go('/search?q=$query');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF8F00)),
                    foregroundColor: const Color(0xFFFF8F00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: Text(
                    'EXPLORAR DESTINOS',
                    style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined),
                onPressed: () => ref.read(visionServiceProvider.notifier).reset(),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}