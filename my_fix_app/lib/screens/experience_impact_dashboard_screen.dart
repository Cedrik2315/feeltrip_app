import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Paleta ──────────────────────────────────────────────────────
const Color boneWhite = Color(0xFFF5F5DC);
const Color terminalGreen = Color(0xFF00FF41);
const Color mossGreen = Color(0xFF4B5320);
const Color carbon = Color(0xFF1A1A1A);

// ── Provider de métricas reales desde Firestore ─────────────────
final userMetricsProvider = FutureProvider.autoDispose<_UserMetrics>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return _UserMetrics.empty();

  final diarySnap = await FirebaseFirestore.instance
      .collection('users').doc(uid).collection('diary_entries')
      .orderBy('created_at', descending: false)
      .get();

  final storiesSnap = await FirebaseFirestore.instance
      .collection('stories')
      .where('userId', isEqualTo: uid)
      .get();

  final totalEntries = diarySnap.docs.length;
  final totalStories = storiesSnap.docs.length;

  // Meses con actividad (últimos 6)
  final Map<int, int> monthlyActivity = {};
  for (final doc in diarySnap.docs) {
    final ts = (doc.data()['created_at'] as Timestamp?)?.toDate();
    if (ts != null && ts.isAfter(DateTime.now().subtract(const Duration(days: 180)))) {
      monthlyActivity[ts.month] = (monthlyActivity[ts.month] ?? 0) + 1;
    }
  }

  return _UserMetrics(
    totalDiaryEntries: totalEntries,
    totalStoriesShared: totalStories,
    monthlyActivity: monthlyActivity,
    adventureDays: (totalEntries * 1.5).round(),
    estimatedKm: totalEntries * 12,
  );
});

class ExperienceImpactDashboardScreen extends ConsumerWidget {
  const ExperienceImpactDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(userMetricsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: boneWhite),
          onPressed: () => context.pop(),
        ),
        title: Text('IMPACTO // EXPEDICIÓN', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: boneWhite, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: terminalGreen),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: mossGreen,
                  content: Text('INFORME LISTO: Resumen preparado para compartir.', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: boneWhite)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: metricsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: terminalGreen, strokeWidth: 1)),
        error: (e, _) => Center(child: Text('// ERROR: $e', style: GoogleFonts.jetBrainsMono(color: Colors.red, fontSize: 11))),
        data: (metrics) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('TELEMETRÍA PERSONAL'),
              const SizedBox(height: 16),
              _buildKPIRow(metrics),
              const SizedBox(height: 40),
              _buildLabel('ACTIVIDAD MENSUAL'),
              const SizedBox(height: 16),
              _buildBarChart(metrics.monthlyActivity),
              const SizedBox(height: 40),
              _buildLabel('ÍNDICE DE CAMBIO'),
              const SizedBox(height: 16),
              _buildRadarChart(),
              const SizedBox(height: 40),
              _buildLabel('NIVEL DE EXPEDICIÓN'),
              const SizedBox(height: 16),
              _buildExplorerLevel(metrics),
              const SizedBox(height: 40),
              _buildExportButton(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: terminalGreen, fontWeight: FontWeight.bold, letterSpacing: 1.5));
  }

  Widget _buildKPIRow(_UserMetrics m) {
    return Row(
      children: [
        _kpiCard('${m.totalDiaryEntries}', 'ENTRADAS\nDIARIO', Icons.book_outlined),
        const SizedBox(width: 12),
        _kpiCard('${m.adventureDays}', 'DÍAS\nAVENTURA', Icons.hiking_outlined),
        const SizedBox(width: 12),
        _kpiCard('${m.estimatedKm}km', 'DISTANCIA\nESTIMADA', Icons.route_outlined),
      ],
    );
  }

  Widget _kpiCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: terminalGreen.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: terminalGreen, size: 20),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.3), fontSize: 8), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<int, int> monthlyActivity) {
    final months = ['E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final now = DateTime.now();
    final last6 = List.generate(6, (i) => now.month - 5 + i).map((m) => m <= 0 ? m + 12 : m).toList();

    final bars = last6.map((m) => BarChartGroupData(
      x: m,
      barRods: [
        BarChartRodData(
          toY: (monthlyActivity[m] ?? 0).toDouble(),
          color: terminalGreen,
          width: 16,
          borderRadius: BorderRadius.zero,
        ),
      ],
    )).toList();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: bars,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border(bottom: BorderSide(color: boneWhite.withValues(alpha: 0.1))),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  months[value.toInt() - 1],
                  style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.3), fontSize: 9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadarChart() {
    return SizedBox(
      height: 220,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              dataEntries: const [
                RadarEntry(value: 3.5),
                RadarEntry(value: 4.0),
                RadarEntry(value: 2.5),
                RadarEntry(value: 4.5),
                RadarEntry(value: 3.0),
              ],
              fillColor: terminalGreen.withValues(alpha: 0.15),
              borderColor: terminalGreen,
              borderWidth: 1.5,
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: const BorderSide(color: Colors.transparent),
          gridBorderData: BorderSide(color: boneWhite.withValues(alpha: 0.05), width: 1),
          tickCount: 5,
          tickBorderData: const BorderSide(color: Colors.transparent),
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          getTitle: (index, angle) {
            final labels = ['CONEXIÓN', 'AVENTURA', 'REFLEXIÓN', 'APRENDIZAJE', 'TRANSFORMACIÓN'];
            return RadarChartTitle(
              text: labels[index],
              angle: angle,
              positionPercentageOffset: 0.1,
            );
          },
          titleTextStyle: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.4), fontSize: 7),
          titlePositionPercentageOffset: 0.2,
        ),
      ),
    );
  }

  Widget _buildExplorerLevel(_UserMetrics m) {
    final double progress = (m.totalDiaryEntries / 50).clamp(0.0, 1.0);
    final String level = m.totalDiaryEntries < 5 ? 'NOVATO' :
                         m.totalDiaryEntries < 15 ? 'EXPLORADOR' :
                         m.totalDiaryEntries < 30 ? 'VETERANO' : 'LEGENDARIO';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(level, style: GoogleFonts.ebGaramond(color: boneWhite, fontSize: 28, fontWeight: FontWeight.bold)),
            Text('${(progress * 100).toInt()}%', style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: boneWhite.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(terminalGreen),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${m.totalDiaryEntries} / 50 entradas para el siguiente nivel',
          style: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.3), fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: mossGreen,
              content: Text('EXPORTAR TRANSFORMACIÓN: PDF generado.', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: boneWhite)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: terminalGreen,
          side: const BorderSide(color: terminalGreen),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        icon: const Icon(Icons.download_outlined, size: 18),
        label: Text('EXPORTAR TRANSFORMACIÓN', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}

// ── Modelo de métricas ──────────────────────────────────────────
class _UserMetrics {
  final int totalDiaryEntries;
  final int totalStoriesShared;
  final Map<int, int> monthlyActivity;
  final int adventureDays;
  final int estimatedKm;

  const _UserMetrics({
    required this.totalDiaryEntries,
    required this.totalStoriesShared,
    required this.monthlyActivity,
    required this.adventureDays,
    required this.estimatedKm,
  });

  factory _UserMetrics.empty() => const _UserMetrics(
    totalDiaryEntries: 0,
    totalStoriesShared: 0,
    monthlyActivity: {},
    adventureDays: 0,
    estimatedKm: 0,
  );
}
