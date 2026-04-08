import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

// Importaciones corregidas según tu estructura
import '../core/logger/app_logger.dart';
import '../services/isar_service.dart';
import '../services/sync_service.dart';
import '../services/gemini_service.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../models/itinerary_model.dart';
import '../models/proposal_model.dart';

class TravelSuggestionsScreen extends ConsumerStatefulWidget {
  const TravelSuggestionsScreen({super.key});

  @override
  ConsumerState<TravelSuggestionsScreen> createState() => _TravelSuggestionsScreenState();
}

class _TravelSuggestionsScreenState extends ConsumerState<TravelSuggestionsScreen> {
  ProposalModel? _currentProposal;
  bool _isLoading = false;
  bool _isAccepting = false;

  Future<void> _generateProposal() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final authState = ref.read(authNotifierProvider);
      final String? userId = authState.value?.id;

      if (userId == null) throw Exception('Sesión no encontrada.');

      // Llamada al servicio de IA optimizada
      final proposal = await ref.read(geminiServiceProvider).generateProposalFromProfile(
            archetype: 'Aventurero',
            emotions: ['Asombro', 'Gratitud'],
            lastReflection: 'Siento que necesito un cambio de aire y conectar con la naturaleza.',
          );

      final proposalModel = ProposalModel(
        id: const Uuid().v4(),
        userId: userId,
        content: proposal,
        createdAt: DateTime.now(),
      );

      // Guardado local preventivo
      await ref.read(isarServiceProvider).putProposal(proposalModel);

      setState(() {
        _currentProposal = proposalModel;
        _isLoading = false;
      });
      
    } catch (e) {
      AppLogger.e('Error IA: $e');
      setState(() => _isLoading = false);
      _showErrorSnackBar('Nuestras brújulas de IA fallaron. Intenta de nuevo.');
    }
  }

  Future<void> _acceptProposal() async {
    if (_currentProposal == null) return;
    setState(() => _isAccepting = true);

    try {
      final itinerary = ItineraryModel(
        id: const Uuid().v4(),
        userId: _currentProposal!.userId,
        proposalId: _currentProposal!.id,
        content: _currentProposal!.content,
        createdAt: DateTime.now(),
      );

      await ref.read(isarServiceProvider).putItinerary(itinerary);
      
      // Sincronización en segundo plano
      ref.read(syncServiceProvider).syncUserEntries(itinerary.userId);

      HapticFeedback.mediumImpact();
      if (mounted) _showSuccessDialog();
      
    } catch (e) {
      AppLogger.e('Error activación: $e');
      _showErrorSnackBar('No pudimos activar tu ruta. Revisa tu conexión.');
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¡Ruta Activada!'),
        content: const Text('Tu bitácora ahora tiene una nueva misión. Comienza cuando estés listo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ENTENDIDO'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF673AB7); // Deep Purple FeelTrip

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF),
      appBar: AppBar(
        title: Text('SINTETIZADOR DE RUTAS', 
          style: GoogleFonts.jetBrainsMono(fontSize: 14, letterSpacing: 2, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _isLoading 
                ? _buildLoadingState(primaryColor)
                : (_currentProposal != null ? _buildProposalCard(primaryColor) : _buildEmptyState()),
            ),
          ),
          _buildBottomAction(primaryColor),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF673AB7),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_fix_high, color: Colors.white70, size: 20),
          SizedBox(width: 10),
          Text('IA VIVENCIAL GENERATIVA', style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Icon(Icons.map_outlined, size: 100, color: Colors.grey[200]),
        const SizedBox(height: 20),
        Text(
          '¿Hacia dónde fluye tu curiosidad hoy?',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(fontSize: 20, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildLoadingState(Color color) {
    return Column(
      children: [
        const SizedBox(height: 100),
        CircularProgressIndicator(color: color, strokeWidth: 2),
        const SizedBox(height: 24),
        Text('Sincronizando con tus emociones...', 
          style: GoogleFonts.jetBrainsMono(fontSize: 12, color: color)),
      ],
    );
  }

  Widget _buildProposalCard(Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: .1)),
            boxShadow: [BoxShadow(color: color.withValues(alpha: .05), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.explore, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text('PROPUESTA PERSONALIZADA', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              const Divider(height: 32),
              Text(
                _currentProposal!.content,
                style: GoogleFonts.playfairDisplay(fontSize: 17, height: 1.6, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_isAccepting)
          CircularProgressIndicator(color: Colors.green)
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _acceptProposal,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('ACTIVAR ESTE ITINERARIO'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomAction(Color color) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _generateProposal,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: const Text('GENERAR NUEVO CAMINO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }
}