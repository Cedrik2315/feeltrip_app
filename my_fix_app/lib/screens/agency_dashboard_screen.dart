import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

// ── Paleta ──────────────────────────────────────────────────────
const Color _carbon = Color(0xFF1A1A1A);
const Color _boneWhite = Color(0xFFF5F5DC);
const Color _terminalGreen = Color(0xFF00FF41);
const Color _orange = Color(0xFFFF8F00);

class AgencyDashboardScreen extends ConsumerWidget {
  const AgencyDashboardScreen({super.key, required this.agencyId});
  final String agencyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agencyService = ref.watch(agencyServiceProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _boneWhite),
          onPressed: () => context.pop(),
        ),
        title: Text('AGENCIA // COMANDO',
            style: GoogleFonts.jetBrainsMono(color: _boneWhite, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: _boneWhite, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: agencyService.getLeadsStream(agencyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _terminalGreen, strokeWidth: 1));
          }

          final leads = snapshot.data ?? <Map<String, dynamic>>[];
          final newLeads = leads.where((l) => (l['status'] as String?) == 'new').length;
          final converted = leads.where((l) => (l['status'] as String?) == 'converted').length;
          final convRate = leads.isEmpty ? 0 : ((converted / leads.length) * 100).round();

          return CustomScrollView(
            slivers: [
              // ── Métricas KPI ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TELEMETRÍA DE CONVERSIÓN',
                          style: GoogleFonts.jetBrainsMono(color: _terminalGreen, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _kpi('${leads.length}', 'LEADS\nTOTALES', _boneWhite),
                          const SizedBox(width: 12),
                          _kpi('$newLeads', 'NUEVOS\nHOY', _orange),
                          const SizedBox(width: 12),
                          _kpi('$convRate%', 'TASA\nCONVERSIÓN', _terminalGreen),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── White-Label Panel ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MODO WHITE-LABEL',
                          style: GoogleFonts.jetBrainsMono(color: _terminalGreen, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          border: Border.all(color: _terminalGreen.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.business_outlined, color: _terminalGreen, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TU MARCA, NUESTRA TECNOLOGÍA',
                                      style: GoogleFonts.jetBrainsMono(color: _boneWhite, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Personaliza interfaz, logo y paleta para tus clientes.',
                                      style: GoogleFonts.ebGaramond(color: _boneWhite.withValues(alpha: 0.6), fontSize: 14)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: _carbon,
                                    content: Text('BRANDING // En desarrollo para v1.1', style: GoogleFonts.jetBrainsMono(color: _terminalGreen, fontSize: 11)),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Icon(Icons.arrow_forward_ios, color: _terminalGreen, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Acciones rápidas ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACCIONES RÁPIDAS',
                          style: GoogleFonts.jetBrainsMono(color: _terminalGreen, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _actionBtn(context, 'NUEVO GRUPO', Icons.group_add_outlined, () {}),
                          const SizedBox(width: 12),
                          _actionBtn(context, 'EXPORTAR CSV', Icons.download_outlined, () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Lista de Prospectos ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text('PROSPECTOS ACTIVOS',
                      style: GoogleFonts.jetBrainsMono(color: _terminalGreen, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
              ),

              leads.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyLeads())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildLeadCard(leads[index]),
                        childCount: leads.length,
                      ),
                    ),
                  ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _kpi(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: GoogleFonts.jetBrainsMono(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.jetBrainsMono(color: _boneWhite.withValues(alpha: 0.4), fontSize: 8)),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () { HapticFeedback.lightImpact(); onTap(); },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: _boneWhite.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _boneWhite, size: 16),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.jetBrainsMono(color: _boneWhite, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadCard(Map<String, dynamic> lead) {
    final String userId = lead['userId'] as String? ?? 'ID_DESCONOCIDO';
    final String message = lead['message'] as String? ?? 'Sin narrativa disponible.';
    final String status = (lead['status'] as String? ?? 'new').toUpperCase();
    final Color statusColor = status == 'NEW' ? _orange : (status == 'CONVERTED' ? _terminalGreen : _boneWhite);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border(left: BorderSide(color: statusColor, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ID: ${userId.substring(0, userId.length.clamp(0, 8))}...',
                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: _boneWhite.withValues(alpha: 0.4))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(status, style: GoogleFonts.jetBrainsMono(fontSize: 8, color: statusColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(message, style: GoogleFonts.ebGaramond(fontSize: 16, height: 1.4, color: _boneWhite.withValues(alpha: 0.8)), maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildEmptyLeads() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(border: Border.all(color: _boneWhite.withValues(alpha: 0.08))),
      child: Column(
        children: [
          const Icon(Icons.radar, color: _terminalGreen, size: 48),
          const SizedBox(height: 16),
          Text('ESCANEANDO RED...', style: GoogleFonts.jetBrainsMono(color: _boneWhite, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Aún no hay prospectos. Comparte tu enlace de agencia para empezar a capturar leads.',
              style: GoogleFonts.ebGaramond(color: _boneWhite.withValues(alpha: 0.5), fontSize: 15, height: 1.5),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}