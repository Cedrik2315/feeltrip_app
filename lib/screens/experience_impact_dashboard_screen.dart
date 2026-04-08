import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Importaciones corregidas a rutas de paquete
import '../presentation/providers/story_provider.dart';
import '../models/impact_model.dart';
import '../widgets/impact_widgets.dart';

class ExperienceImpactDashboardScreen extends ConsumerWidget {
  const ExperienceImpactDashboardScreen({super.key});

  // Paleta de marca FeelTrip
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color mossGreen = Color(0xFF4B5320);
  static const Color carbon = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(allStoriesProvider);

    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: carbon,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'IMPACT_REPORT.sys',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12, 
            color: boneWhite, 
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold
          ),
        ),
        iconTheme: const IconThemeData(color: boneWhite),
      ),
      body: storiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: mossGreen)),
        error: (err, _) => Center(
          child: Text('// ERROR_CALCULATING_IMPACT: $err', 
            style: GoogleFonts.jetBrainsMono(fontSize: 12))
        ),
        data: (stories) {
          return CustomScrollView(
            slivers: [
              _buildHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainScore(stories.length),
                      const SizedBox(height: 32),
                      Text(
                        'EMOCIONES_REGISTRADAS',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold,
                          color: carbon.withValues(alpha: 0.5)
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildEmotionsWrap(),
                      const SizedBox(height: 48),
                      _buildShareButton(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: carbon,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TU TRANSFORMACIÓN',
              style: GoogleFonts.ebGaramond(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: boneWhite,
                height: 1.1
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Métricas de crecimiento personal basadas en tu bitácora de viaje.',
              style: GoogleFonts.inter(color: boneWhite.withValues(alpha: 0.6), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScore(int totalStories) {
    double score = (totalStories * 0.1).clamp(0.0, 1.0);
    if (totalStories == 0) score = 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: carbon.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ÍNDICE_DE_CAMBIO', 
                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Text(
                  score > 0.7 ? 'ALQUIMISTA' : score > 0.4 ? 'EN_TRANSICIÓN' : 'INICIANDO_VIAJE',
                  style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.w800, color: carbon),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalStories EXPERIENCIAS REGISTRADAS', 
                  style: GoogleFonts.jetBrainsMono(fontSize: 9, color: mossGreen, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
          _CircularScore(score: score.toDouble()),
        ],
      ),
    );
  }

  Widget _buildEmotionsWrap() {
    // Mantengo tus datos representativos como solicitaste
    final List<ImpactData> emotions = [
      const ImpactData(label: 'Asombro', emoji: '😲', percentage: 45),
      const ImpactData(label: 'Gratitud', emoji: '🙏', percentage: 38, color: Colors.orange),
      const ImpactData(label: 'Conexión', emoji: '💕', percentage: 52, color: Colors.red),
      const ImpactData(label: 'Reflexión', emoji: '💭', percentage: 56, color: Colors.blue),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: emotions.map((e) => EmotionChip(data: e)).toList(),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () => _showShareSuccess(context),
        icon: const Icon(Icons.share_rounded, size: 18),
        label: Text(
          'EXPORTAR_TRANSFORMACIÓN',
          style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: carbon,
          foregroundColor: boneWhite,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }

  void _showShareSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: mossGreen,
        content: Text(
          'INFORME_LISTO: Resumen preparado para compartir.',
          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: boneWhite),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _CircularScore extends StatelessWidget {
  const _CircularScore({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 64,
          width: 64,
          child: CircularProgressIndicator(
            value: score,
            strokeWidth: 4,
            backgroundColor: Colors.black.withValues(alpha: 0.05),
            color: const Color(0xFF4B5320), // mossGreen
          ),
        ),
        Text(
          '${(score * 100).toInt()}%',
          style: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.w900, 
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
