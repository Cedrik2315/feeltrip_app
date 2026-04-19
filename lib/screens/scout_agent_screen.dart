import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/features/diario/presentation/providers/momento_provider.dart';
import 'package:feeltrip_app/services/emotional_engine_service.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScoutAgentScreen extends ConsumerStatefulWidget {
  const ScoutAgentScreen({super.key});

  @override
  ConsumerState<ScoutAgentScreen> createState() => _ScoutAgentScreenState();
}

class _ScoutAgentScreenState extends ConsumerState<ScoutAgentScreen> {
  final List<String> _logs = [];
  bool _isAnalyzing = false;
  EmotionalPrediction? _result;
  final ScrollController _scrollController = ScrollController();

  static const Color carbon = Color(0xFF0D0D0D);
  static const Color terminalGreen = Color(0xFF00FF41);
  static const Color amber = Color(0xFFFFB000);

  void _addLog(String message) {
    if (!mounted) return;
    setState(() {
      _logs.add('>[${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}] $message');
    });
    // Auto-scroll al final del log
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startScoutAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _logs.clear();
      _result = null;
    });
    HapticFeedback.mediumImpact();

    _addLog('INICIANDO PROTOCOLO SCOUT v2.0...');
    
    try {
      // 1. Recuperar historial de momentos del usuario
      final momentos = ref.read(momentoProvider).value ?? [];
      if (momentos.isEmpty) {
        _addLog('ERROR: Historial de bitácora insuficiente para triangulación.');
        setState(() => _isAnalyzing = false);
        return;
      }

      _addLog('Recuperados ${momentos.length} fragmentos de memoria...');
      final diaryHistory = momentos.map((m) => '${m.title}: ${m.description}').join('\n');

      // 2. Ejecutar Agente Scout con Tool Calling
      final agentService = ref.read(agentServiceProvider);
      
      final prediction = await agentService.scoutAgent(
        diaryHistory,
        onStatusUpdate: (status) => _addLog(status.toUpperCase()),
      );

      if (prediction != null) {
        _addLog('SÍNTESIS COMPLETADA CON ÉXITO.');
        
        // PERSISTENCIA REAL: Guardamos el análisis para el Dashboard de Impacto
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('scout_history')
              .add(prediction.toJson()..addAll({
                'timestamp': FieldValue.serverTimestamp(),
              }));
          _addLog('ANÁLISIS VINCULADO AL EXPEDIENTE REAL.');
        }

        setState(() {
          _result = prediction;
          _isAnalyzing = false;
        });
        HapticFeedback.heavyImpact();
      } else {
        throw Exception('IA_ORACLE_TIMEOUT');
      }
    } catch (e) {
      _addLog('FALLO CRÍTICO: $e');
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: carbon,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('SISTEMA SCOUT // NÚCLEO', 
          style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildTerminalHeader(),
          Expanded(
            child: _result != null ? _buildResultView() : _buildLogView(),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildTerminalHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white.withValues(alpha: 0.05),
      child: Row(
        children: [
          Icon(Icons.radar, color: _isAnalyzing ? terminalGreen : Colors.white24, size: 14),
          const SizedBox(width: 10),
          Text(_isAnalyzing ? 'ESCANEO ACTIVO' : 'SISTEMA EN ESPERA', 
            style: GoogleFonts.jetBrainsMono(color: _isAnalyzing ? terminalGreen : Colors.white24, fontSize: 10)),
          const Spacer(),
          Text('FEELTRIP_OS v5.1', style: GoogleFonts.jetBrainsMono(color: Colors.white24, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildLogView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _logs.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(_logs[index], 
          style: GoogleFonts.jetBrainsMono(color: terminalGreen.withValues(alpha: 0.8), fontSize: 11)),
      ),
    );
  }

  Widget _buildResultView() {
    if (_result == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EXPEDICIÓN TRIANGULADA', 
            style: GoogleFonts.jetBrainsMono(color: amber, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(_result!.suggestedDestination.toUpperCase(), 
            style: GoogleFonts.ebGaramond(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildInfoRow('ARQUETIPO', _result!.recommendedArchetype),
          _buildInfoRow('INTENSIDAD', '${(_result!.intensity * 100).toInt()}%'),
          _buildInfoRow('PATRÓN', _result!.moodPattern),
          const Divider(color: Colors.white10, height: 40),
          Text('RAZONAMIENTO DEL AGENTE:', 
            style: GoogleFonts.jetBrainsMono(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 12),
          Text(_result!.reasoning, 
            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.9), fontSize: 15, height: 1.5)),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/suggestions', extra: _result),
              style: ElevatedButton.styleFrom(
                backgroundColor: terminalGreen,
                foregroundColor: carbon,
                padding: const EdgeInsets.all(20),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text('REVISAR ITINERARIO VALIDADO', 
                style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('$label: ', style: GoogleFonts.jetBrainsMono(color: Colors.white24, fontSize: 10)),
          Text(value, style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    if (_result != null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: OutlinedButton(
          onPressed: _isAnalyzing ? null : _startScoutAnalysis,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _isAnalyzing ? Colors.white10 : terminalGreen),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: _isAnalyzing 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 2))
            : Text('INICIAR ESCANEO DE CONCIENCIA', 
                style: GoogleFonts.jetBrainsMono(
                  color: terminalGreen, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
                )),
        ),
      ),
    );
  }
}