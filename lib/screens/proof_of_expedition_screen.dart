import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:feeltrip_app/presentation/providers/subscription_provider.dart';

// ── Paleta ──────────────────────────────────────────────────────
const Color _bone = Color(0xFFF5F5DC);
const Color _green = Color(0xFF00FF41);
const Color _carbon = Color(0xFF1A1A1A);
const Color _gold = Color(0xFFD4AF37);

// ── Modelo de Proof of Expedition ───────────────────────────────
class ExpeditionProof {
  final String id;
  final String destination;
  final DateTime completedAt;
  final String archetype;
  final int durationDays;
  final double distanceKm;

  const ExpeditionProof({
    required this.id,
    required this.destination,
    required this.completedAt,
    required this.archetype,
    required this.durationDays,
    required this.distanceKm,
  });
}

// ── Provider de pruebas de expedición ───────────────────────────
final expeditionProofsProvider = FutureProvider.autoDispose<List<ExpeditionProof>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return [];

  final snap = await FirebaseFirestore.instance
      .collection('users').doc(uid).collection('expedition_proofs')
      .orderBy('completed_at', descending: true)
      .get();

  return snap.docs.map((doc) {
    final d = doc.data();
    return ExpeditionProof(
      id: doc.id,
      destination: (d['destination'] as String?) ?? 'Desconocido',
      completedAt: ((d['completed_at'] as Timestamp?) ?? Timestamp.now()).toDate(),
      archetype: (d['archetype'] as String?) ?? 'EXPLORADOR',
      durationDays: (d['duration_days'] as int?) ?? 1,
      distanceKm: ((d['distance_km'] as num?) ?? 0).toDouble(),
    );
  }).toList();
});

class ProofOfExpeditionScreen extends ConsumerWidget {
  const ProofOfExpeditionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proofsAsync = ref.watch(expeditionProofsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: _bone), onPressed: () => context.pop()),
        title: Text('PROOF OF EXPEDITION', style: GoogleFonts.jetBrainsMono(color: _bone, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: proofsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _green, strokeWidth: 1)),
        error: (e, _) => Center(child: Text('ERROR: $e', style: GoogleFonts.jetBrainsMono(color: Colors.red, fontSize: 11))),
        data: (proofs) {
          if (proofs.isEmpty) return _buildEmptyState(context);
          return _buildProofsList(proofs, context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _gold.withValues(alpha: 0.3), width: 2),
              ),
              child: const Icon(Icons.military_tech_outlined, color: _gold, size: 48),
            ),
            const SizedBox(height: 32),
            Text('TU VITRINA ESTÁ VACÍA', style: GoogleFonts.jetBrainsMono(color: _bone, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Completa tu primera expedición para obtener un certificado verificado e intransferible.',
              style: GoogleFonts.ebGaramond(color: _bone.withValues(alpha: 0.5), fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/suggestions'),
              style: ElevatedButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.black, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              child: Text('INICIAR EXPEDICIÓN', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofsList(List<ExpeditionProof> proofs, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Resumen ──────────────────────────────────────────
          Text('COLECCIÓN VERIFICADA', style: GoogleFonts.jetBrainsMono(color: _green, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard('${proofs.length}', 'EXPEDICIONES', _gold),
              const SizedBox(width: 12),
              _statCard('${proofs.fold(0, (sum, p) => sum + p.durationDays)}', 'DÍAS TOTALES', _green),
              const SizedBox(width: 12),
              _statCard('${proofs.fold(0.0, (sum, p) => sum + p.distanceKm).round()}km', 'DISTANCIA', _bone),
            ],
          ),

          const SizedBox(height: 40),
          Text('CERTIFICADOS', style: GoogleFonts.jetBrainsMono(color: _green, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),

          // ── Certificados ────────────────────────────────────
          ...proofs.map((proof) => _buildProofCard(proof, context)),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.jetBrainsMono(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.jetBrainsMono(color: _bone.withValues(alpha: 0.3), fontSize: 7), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildProofCard(ExpeditionProof proof, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _carbon,
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // ── Header dorado ─────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_gold.withValues(alpha: 0.15), Colors.transparent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: _gold, size: 16),
                    const SizedBox(width: 8),
                    Text('PROOF OF EXPEDITION', style: GoogleFonts.jetBrainsMono(color: _gold, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
                Text('#${proof.id.substring(0, 8).toUpperCase()}', style: GoogleFonts.jetBrainsMono(color: _bone.withValues(alpha: 0.3), fontSize: 8)),
              ],
            ),
          ),

          // ── Contenido ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(proof.destination.toUpperCase(),
                    style: GoogleFonts.ebGaramond(color: _bone, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _proofDetail(Icons.calendar_today, '${proof.completedAt.day}/${proof.completedAt.month}/${proof.completedAt.year}'),
                    const SizedBox(width: 20),
                    _proofDetail(Icons.schedule, '${proof.durationDays} días'),
                    const SizedBox(width: 20),
                    _proofDetail(Icons.route, '${proof.distanceKm.round()}km'),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.1),
                    border: Border.all(color: _green.withValues(alpha: 0.3)),
                  ),
                  child: Text('ARQUETIPO: ${proof.archetype}', style: GoogleFonts.jetBrainsMono(color: _green, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // ── Acciones ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: _bone.withValues(alpha: 0.05)))),
            child: Row(
              children: [
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      return TextButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          final sub = ref.read(subscriptionProvider).valueOrNull;
                          final code = sub?.referralCode ?? '';
                          final refText = code.isNotEmpty ? '\n🎁 Usa mi invitación $code para probar FeelTrip Pro.' : '';
                          Share.share(
                            '🏔️ Completé la expedición "${proof.destination}" con FeelTrip.\n${proof.durationDays} días · ${proof.distanceKm.round()}km · Arquetipo: ${proof.archetype}$refText\n#ProofOfExpedition #FeelTrip',
                          );
                        },
                        icon: const Icon(Icons.share_outlined, size: 16, color: _bone),
                        label: Text('COMPARTIR', style: GoogleFonts.jetBrainsMono(color: _bone, fontSize: 9)),
                      );
                    },
                  ),
                ),
                Container(width: 1, height: 40, color: _bone.withValues(alpha: 0.05)),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _carbon,
                          content: Text('PDF GENERADO // Listo para descargar.', style: GoogleFonts.jetBrainsMono(color: _green, fontSize: 11)),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_outlined, size: 16, color: _gold),
                    label: Text('CERTIFICADO', style: GoogleFonts.jetBrainsMono(color: _gold, fontSize: 9)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _proofDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: _bone.withValues(alpha: 0.3), size: 12),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.jetBrainsMono(color: _bone.withValues(alpha: 0.5), fontSize: 10)),
      ],
    );
  }
}
