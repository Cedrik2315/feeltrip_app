import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:google_fonts/google_fonts.dart'; // Importante para las fuentes sugeridas

class AgencyDashboardScreen extends ConsumerWidget {
  const AgencyDashboardScreen({super.key, required this.agencyId});
  final String agencyId;

  // Colores de la paleta FeelTrip
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color boneWhite = Color(0xFFF5F2ED);
  static const Color mossGreen = Color(0xFF4A5D4E);
  static const Color oxidizedEarth = Color(0xFFB35A38);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agencyService = ref.watch(agencyServiceProvider);

    return Scaffold(
      backgroundColor: boneWhite, // Fondo tipo papel
      appBar: AppBar(
        backgroundColor: charcoal,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'LOG_FILE: AGENCY_DASHBOARD',
          style: GoogleFonts.jetBrainsMono(
            color: boneWhite,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: agencyService.getLeadsStream(agencyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: mossGreen));
          }

          final leads = snapshot.data ?? <Map<String, dynamic>>[];

          return CustomScrollView(
            slivers: [
              // Header con métricas estilizadas como "Terminal"
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: charcoal,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                  ),
                  child: _buildMetricsHeader(leads),
                ),
              ),
              
              // Título con estética editorial
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Correspondencia y Prospectos',
                    style: GoogleFonts.ebGaramond(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: charcoal,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

              // Lista de Prospectos
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final lead = leads[index];
                      return _buildLeadCard(lead);
                    },
                    childCount: leads.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricsHeader(List<Map<String, dynamic>> leads) {
    final int total = leads.length;
    final int news = leads.where((l) => (l['status'] as String?) == 'new').length;

    return Row(
      children: [
        _metricTile('TOTAL_LEADS', total.toString().padLeft(3, '0')),
        const SizedBox(width: 24),
        _metricTile('NEW_STATUS', news.toString().padLeft(3, '0'), color: oxidizedEarth),
      ],
    );
  }

  Widget _metricTile(String label, String value, {Color color = boneWhite}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '> $label',
          style: GoogleFonts.jetBrainsMono(color: mossGreen, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(color: color, fontSize: 32, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLeadCard(Map<String, dynamic> lead) {
    final String userId = lead['userId'] as String? ?? 'UNKNOWN_USR';
    final String message = lead['message'] as String? ?? 'No narrative provided.';
    final String status = (lead['status'] as String? ?? 'new').toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: oxidizedEarth, width: 2)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: $userId',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  '[$status]',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10, 
                    color: status == 'NEW' ? oxidizedEarth : mossGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.ebGaramond(fontSize: 18, height: 1.3, color: charcoal),
            ),
            const Divider(height: 24, thickness: 0.5, color: Colors.black12),
          ],
        ),
      ),
    );
  }
}