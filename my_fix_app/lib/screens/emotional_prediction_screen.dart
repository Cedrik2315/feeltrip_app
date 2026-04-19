import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feeltrip_app/services/emotional_engine_service.dart';
import 'package:feeltrip_app/core/di/providers.dart';

// ── Paleta ──────────────────────────────────────────────────────
const Color _bone = Color(0xFFF5F5DC);
const Color _green = Color(0xFF00FF41);
const Color _carbon = Color(0xFF1A1A1A);
const Color _cyberBlue = Color(0xFF00E5FF);

// Provider para el estado del agente en tiempo real
final agentStatusProvider = StateProvider<String>((ref) => 'Iniciando escaneo...');

// ── Provider que obtiene entradas recientes y predice (Genkit Agent) ──
final emotionalPredictionProvider = FutureProvider.autoDispose<EmotionalPrediction?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  final uid = user?.uid;
  if (uid == null) {
    debugPrint('EmotionalPrediction: No hay usuario autenticado.');
    return null;
  }

  try {
    final snap = await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('momentos')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    if (snap.docs.isEmpty) {
      debugPrint('EmotionalPrediction: No se encontraron momentos para el usuario $uid');
      return null;
    }

    final entries = snap.docs
        .map((d) => (d.data()['description'] as String?) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
        
    if (entries.isEmpty) return null;

    // Usa el Servicio de Agentes Autónomos
    final agentService = ref.watch(agentServiceProvider);

    // 1. Invoca el Agente pasándole el historial completo
    final EmotionalPrediction? agentPrediction = await agentService.scoutAgent(
      entries.join('\n'),
      onStatusUpdate: (status) {
        if (ref.exists(agentStatusProvider)) {
          ref.read(agentStatusProvider.notifier).state = status;
        }
      },
    );
    
    if (agentPrediction == null) return null;
    
    return agentPrediction;
  } on FirebaseException catch (e) {
    debugPrint('EmotionalPrediction Firestore Error: [${e.code}] ${e.message}');
    debugPrint('Contexto: UserID=$uid');
    rethrow;
  } catch (e) {
    debugPrint('Scout Agent Error: $e');
    ref.read(agentStatusProvider.notifier).state = 'Error en el núcleo agéntico';
    rethrow;
  }
});

class EmotionalPredictionScreen extends ConsumerStatefulWidget {
  const EmotionalPredictionScreen({super.key});

  @override
  ConsumerState<EmotionalPredictionScreen> createState() => _EmotionalPredictionScreenState();
}

class _EmotionalPredictionScreenState extends ConsumerState<EmotionalPredictionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _breathController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final predictionAsync = ref.watch(emotionalPredictionProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: _bone), onPressed: () => context.pop()),
        title: Text('PREDICCIÓN EMOCIONAL', style: GoogleFonts.jetBrainsMono(color: _bone, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: predictionAsync.when(
        loading: () => _buildScanning(),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_outlined, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text('ERROR DE SINCRONIZACIÓN', style: GoogleFonts.jetBrainsMono(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('$e', 
                  style: GoogleFonts.jetBrainsMono(color: _bone.withValues(alpha: 0.5), fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => ref.invalidate(emotionalPredictionProvider),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: _green)),
                  child: Text('REINTENTAR ESCANEO', style: GoogleFonts.jetBrainsMono(color: _green)),
                ),
              ],
            ),
          ),
        ),
        data: (prediction) {
          if (prediction == null) return _buildNoData();
          return _buildResult(prediction, context);
        },
      ),
    );
  }

  Widget _buildScanning() {
    final status = ref.watch(agentStatusProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (_, __) => Opacity(
              opacity: _breathAnimation.value,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _green.withValues(alpha: 0.5), width: 2),
                  boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.2), blurRadius: 30)],
                ),
                child: const Icon(Icons.psychology_outlined, color: _green, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(status.toUpperCase(), 
            style: GoogleFonts.jetBrainsMono(color: _green, fontSize: 11, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            width: 200, height: 2,
            color: _green.withValues(alpha: 0.1),
            child: LinearProgressIndicator(backgroundColor: Colors.transparent, color: _green, minHeight: 1),
          ),
          const SizedBox(height: 24),
          Text('Leyendo tus últimas 10 entradas de diario.', style: GoogleFonts.ebGaramond(color: _bone.withValues(alpha: 0.4), fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_note_outlined, color: _green, size: 64),
            const SizedBox(height: 24),
            Text('DATOS INSUFICIENTES', style: GoogleFonts.jetBrainsMono(color: _bone, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Necesitamos al menos una entrada en tu diario para analizar tus patrones emocionales y recomendarte una expedición.',
              style: GoogleFonts.ebGaramond(color: _bone.withValues(alpha: 0.5), fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/diary/capture'),
              style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.black, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              child: Text('CREAR PRIMERA ENTRADA', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(EmotionalPrediction p, BuildContext context) {
    final intensityPercent = (p.intensity * 100).round();
    
    // 🔥 Lógica de Color por Arquetipo
    final Color archColor = _getArchetypeColor(p.recommendedArchetype);
    final Color moodColor = p.intensity > 0.7 ? Colors.redAccent : (p.intensity > 0.4 ? Colors.orange : _green);
    final Color intensityColor = moodColor;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [archColor.withValues(alpha: 0.15), Colors.black],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Orbe central dinámico ─────────────
            Center(
              child: AnimatedBuilder(
                animation: _breathAnimation,
                builder: (_, __) => Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _carbon.withValues(alpha: 0.8),
                    border: Border.all(color: archColor.withValues(alpha: _breathAnimation.value * 1.0), width: 2),
                    boxShadow: [
                      BoxShadow(color: archColor.withValues(alpha: _breathAnimation.value * 0.4), blurRadius: 50, spreadRadius: 5),
                      BoxShadow(color: moodColor.withValues(alpha: 0.2), blurRadius: 20),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$intensityPercent%', style: GoogleFonts.jetBrainsMono(color: archColor, fontSize: 42, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(p.recommendedArchetype, style: GoogleFonts.jetBrainsMono(color: _bone, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
            _label('PATRÓN DETECTADO'),
            const SizedBox(height: 8),
          Text(p.moodPattern.toUpperCase(), style: GoogleFonts.ebGaramond(color: _bone, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _intensityBar(p.intensity, intensityColor),

          const SizedBox(height: 40),
          _label('ARQUETIPO RECOMENDADO'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              border: Border.all(color: _green.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _green.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.explore_outlined, color: _green, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.recommendedArchetype, style: GoogleFonts.jetBrainsMono(color: _green, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('Basado en tu historial reciente.', style: GoogleFonts.inter(color: _bone.withValues(alpha: 0.4), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          _label('DESTINO SUGERIDO'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [intensityColor.withValues(alpha: 0.1), Colors.transparent],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              border: Border.all(color: intensityColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.suggestedDestination.toUpperCase(), style: GoogleFonts.ebGaramond(color: _bone, fontSize: 28, fontWeight: FontWeight.bold)),
                if (p.weatherInfo != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny_outlined, color: Colors.orangeAccent, size: 16),
                      const SizedBox(width: 8),
                      Text(p.weatherInfo!, style: GoogleFonts.jetBrainsMono(color: Colors.orangeAccent, fontSize: 11)),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(p.reasoning, style: GoogleFonts.ebGaramond(color: _bone.withValues(alpha: 0.7), fontSize: 16, height: 1.5, fontStyle: FontStyle.italic)),
              ],
            ),
          ),

          if (p.flightInfo != null) ...[
            const SizedBox(height: 32),
            _label('VUELO ENCONTRADO POR AGENTE'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cyberBlue.withValues(alpha: 0.05),
                border: Border.all(color: _cyberBlue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.flightInfo!['airline']?.toString() ?? 'Aerolínea', style: GoogleFonts.jetBrainsMono(color: _cyberBlue, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('${p.flightInfo!['price']} ${p.flightInfo!['currency']}', style: GoogleFonts.jetBrainsMono(color: _bone, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Salida: ${p.flightInfo!['departure']}', style: GoogleFonts.inter(color: _bone.withValues(alpha: 0.6), fontSize: 12)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {}, // Abrir link real
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: _cyberBlue), foregroundColor: _cyberBlue),
                      child: const Text('RESERVAR AHORA'),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (p.activityInfo != null && p.activityInfo!.isNotEmpty) ...[
            const SizedBox(height: 32),
            _label('ACTIVIDADES PLANIFICADAS'),
            const SizedBox(height: 12),
            ...p.activityInfo!.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: _green, size: 14),
                  const SizedBox(width: 12),
                  Text(a, style: GoogleFonts.inter(color: _bone, fontSize: 14)),
                ],
              ),
            )),
          ],

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.push('/suggestions', extra: p);
              },
              style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.black, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              child: Text('GENERAR RUTA IA →', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}

  Widget _label(String text) {
    return Text(text, style: GoogleFonts.jetBrainsMono(color: _green, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5));
  }

  Widget _intensityBar(double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INTENSIDAD: ${(value * 100).round()}%', style: GoogleFonts.jetBrainsMono(color: _bone.withValues(alpha: 0.4), fontSize: 9)),
        const SizedBox(height: 6),
        ClipRRect(
          child: LinearProgressIndicator(
            value: value,
            minHeight: 3,
            backgroundColor: _bone.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Color _getArchetypeColor(String archetype) {
    final a = archetype.toUpperCase();
    if (a.contains('EXPLORADOR')) return Colors.orange;
    if (a.contains('ALQUIMISTA')) return Colors.purpleAccent;
    if (a.contains('CONECTOR')) return Colors.redAccent;
    if (a.contains('ERMITAÑO')) return Colors.cyanAccent;
    if (a.contains('ACADÉMICO')) return Colors.greenAccent;
    return _green;
  }
}
