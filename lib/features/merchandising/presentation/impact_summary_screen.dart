import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ImpactSummaryScreen extends ConsumerWidget {
  final int viajeId;
  const ImpactSummaryScreen({super.key, required this.viajeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color carbonBlack = Color(0xFF1A1A1A);
    const Color terminalGreen = Color(0xFF00FF41);
    const Color boneWhite = Color(0xFFF5F5DC);
    const Color blueprintBlue = Color(0xFF002FA7);

    return Scaffold(
      backgroundColor: carbonBlack,
      body: CustomScrollView(
        slivers: [
          // HEADER CON EL ARTE DEL ARTEFACTO (Parallax)
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: carbonBlack,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: carbonBlack,
                child: Icon(Icons.arrow_back, color: boneWhite, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                   // Imagen del Artefacto (Concepto Técnico)
                  Image.network(
                    'https://images.unsplash.com/photo-1550745165-9bc0b252726f?q=80&w=1000&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          carbonBlack.withValues(alpha: 0.8),
                          carbonBlack,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXPEDICIÓN #$viajeId', 
                          style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text('RESUMEN DE IMPACTO', 
                          style: GoogleFonts.ebGaramond(color: boneWhite, fontSize: 32, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CONTENIDO DE LA TRANSFORMACIÓN
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'ANÁLISIS DE EXISTENCIA', color: terminalGreen),
                  const SizedBox(height: 16),
                  Text(
                    'Tu paso por Quillota no fue una simple transición geográfica. Los datos indican un aumento del 15% en tu asombro contemplativo al cruzar el Cerro Mayaca. Has logrado silenciar el ruido digital para conectar con la resonancia histórica del terreno.',
                    style: GoogleFonts.inter(color: boneWhite.withValues(alpha: 0.8), fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  
                  // GRILLA DE DATOS TÉCNICOS
                  Row(
                    children: [
                      Expanded(child: _DataTile(label: 'DISTANCIA', value: '12.4 KM', icon: Icons.map_outlined)),
                      const SizedBox(width: 16),
                      Expanded(child: _DataTile(label: 'ASOMBRO PEAK', value: '114 BPM', icon: Icons.favorite_border)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _DataTile(label: 'ALTITUD MAX', value: '245 MSN', icon: Icons.terrain)),
                      const SizedBox(width: 16),
                      Expanded(child: _DataTile(label: 'MOOD', value: 'ZEN', icon: Icons.psychology_outlined)),
                    ],
                  ),

                  const SizedBox(height: 48),
                  
                  // REPRODUCTOR DE LA CANCIÓN GENERATIVA
                  _SectionHeader(title: 'SONIDO ENDÉMICO', color: blueprintBlue),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: blueprintBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: blueprintBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: blueprintBlue,
                          child: Icon(Icons.play_arrow, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('The Echo of Quillota', style: GoogleFonts.jetBrainsMono(color: boneWhite, fontWeight: FontWeight.bold)),
                              Text('Generative Indie Folk', style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.4), fontSize: 10)),
                            ],
                          ),
                        ),
                        const Icon(Icons.equalizer, color: terminalGreen),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // BOTÓN PARA VOLVER A LA BIBLIOTECA
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: boneWhite,
                        side: BorderSide(color: boneWhite.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('VOLVER A LA BIBLIOTECA', style: GoogleFonts.jetBrainsMono()),
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 20, height: 2, color: color),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.jetBrainsMono(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ],
    );
  }
}

class _DataTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _DataTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFF5F5DC).withValues(alpha: 0.4), size: 16),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.jetBrainsMono(color: const Color(0xFFF5F5DC).withValues(alpha: 0.3), fontSize: 8)),
          Text(value, style: GoogleFonts.jetBrainsMono(color: const Color(0xFFF5F5DC), fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
