import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../core/di/providers.dart';
import '../core/logger/app_logger.dart';
import '../services/isar_service.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../services/emotional_engine_service.dart';
import '../models/itinerary_model.dart';
import '../models/proposal_model.dart';

class TravelSuggestionsScreen extends ConsumerStatefulWidget {
  final EmotionalPrediction? prediction;
  const TravelSuggestionsScreen({super.key, this.prediction});

  @override
  ConsumerState<TravelSuggestionsScreen> createState() => _TravelSuggestionsScreenState();
}

class _TravelSuggestionsScreenState extends ConsumerState<TravelSuggestionsScreen> with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  ProposalModel? _currentProposal;
  bool _isLoading = false;
  bool _isAccepting = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _blinkController;

  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color terminalGreen = Color(0xFF00FF41);

  @override
  void initState() {
    super.initState();
    // Aseguramos que Isar y los servicios de datos estén listos en esta pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user != null) {
        // Esto dispara la inicialización de Isar a través del provider
        ref.read(isarServiceProvider);
        
        // Si llegamos con una predicción del Scout Agent, disparamos la síntesis automáticamente
        if (widget.prediction != null) {
          _generateProposal();
        }
      }
    });
    _initSpeech();
    
    // Inicializamos el controlador para el parpadeo de alerta
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => AppLogger.i('STT Status: $val'),
        onError: (val) => AppLogger.e('STT Error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _inputController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _scanWithOcr(Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('La integración con cámara se activará en la próxima actualización.')),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _audioPlayer.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> _generateProposal() async {
    if (_inputController.text.isEmpty && _currentProposal == null) {
      _showErrorSnackBar('Dime algo sobre tus deseos de viaje primero.');
      return;
    }
    
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final authState = ref.read(authNotifierProvider);
      final String? userId = authState.value?.id;

      if (userId == null) throw Exception('Sesión no encontrada.');

      // Llamada al servicio de IA usando el input real del usuario o la predicción del agente
      final proposal = await ref.read(geminiServiceProvider).generateProposalFromProfile(
            archetype: widget.prediction?.recommendedArchetype ?? 'Explorador',
            emotions: widget.prediction != null 
              ? [widget.prediction!.moodPattern] 
              : ['Curiosidad', 'Asombro'],
            lastReflection: _inputController.text.isEmpty 
              ? (widget.prediction?.reasoning ?? 'Deseo una ruta inspiradora en la naturaleza') 
              : _inputController.text,
          );

      final proposalModel = ProposalModel(
        id: const Uuid().v4(),
        userId: userId,
        content: proposal,
        createdAt: DateTime.now(),
      );

      await ref.read(isarServiceProvider).putProposal(proposalModel);

      setState(() {
        _currentProposal = proposalModel;
        _isLoading = false;
      });
      
    } catch (e) {
      AppLogger.e('Error IA: $e');
      setState(() => _isLoading = false);
      _showErrorSnackBar('FALLO SISTEMA: Conexión con IA interrumpida.');
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
      
      // Sincronización en segundo plano usando providers
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
        backgroundColor: const Color(0xFF1A1A1A),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('SISTEMA ACTUALIZADO', style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 14)),
        content: Text('Tu bitácora ahora contiene una nueva misión estratégica.', 
          style: GoogleFonts.inter(color: boneWhite, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/home');
            }, 
            child: Text('ENTENDIDO', style: GoogleFonts.jetBrainsMono(color: terminalGreen))
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color archColor = _getArchetypeColor(widget.prediction?.recommendedArchetype ?? 'EXPLORADOR');

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [archColor.withValues(alpha: 0.1), theme.colorScheme.surface, theme.colorScheme.surface],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text('SINTETIZADOR // IA', 
                style: GoogleFonts.jetBrainsMono(fontSize: 12, letterSpacing: 2, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
            ),
            _buildTelemetryHeader(theme, archColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _isLoading 
                  ? _buildLoadingState(archColor)
                  : (_currentProposal != null ? _buildProposalCard(theme, archColor) : _buildInputState(theme, archColor)),
              ),
            ),
            if (!_isLoading) _buildBottomAction(archColor),
          ],
        ),
      ),
    );
  }

  void _showTechnicalDetails() async {
    if (widget.prediction == null) return;
    
    // Disparamos el efecto de sonido de radar
    try {
      await _audioPlayer.play(AssetSource('sounds/radar_ping.mp3'));
    } catch (e) {
      AppLogger.w('No se pudo reproducir el sonido de telemetría: $e');
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D0D0D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RadarScanner(color: terminalGreen),
            const SizedBox(height: 16),
            Text('LOGS DE TELEMETRÍA AGÉNTICA', 
              style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            // Estos campos provienen de la respuesta JSON del Scout Agent en AgentService
            _buildTechRow('CLIMA DETECTADO', widget.prediction!.weatherInfo ?? 'No disponible'),
            _buildTechRow('LOGÍSTICA (DESPEGAR/GOOGLE)', widget.prediction!.flightInfo?.toString() ?? 'No disponible'),
            _buildTechRow('ACTIVIDADES FILTRADAS', widget.prediction!.activityInfo?.join(', ') ?? 'No disponible'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('CERRAR TERMINAL', 
                  style: GoogleFonts.jetBrainsMono(color: terminalGreen.withValues(alpha: 0.5), fontSize: 10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechRow(String label, String value) {
    // Regex para detectar enlaces (Google Flights, etc)
    final urlRegex = RegExp(r'(https?://[^\s]+)');
    final matches = urlRegex.allMatches(value);

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Texto antes del enlace
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: value.substring(lastMatchEnd, match.start),
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
        ));
      }
      
      // El enlace clickable
      final url = match.group(0)!;
      spans.add(TextSpan(
        text: ' [VER VUELOS] ',
        style: GoogleFonts.jetBrainsMono(
          color: terminalGreen, 
          fontSize: 11, 
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline
        ),
        recognizer: TapGestureRecognizer()..onTap = () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ));
      lastMatchEnd = match.end;
    }

    // Texto restante
    if (lastMatchEnd < value.length) {
      spans.add(TextSpan(
        text: value.substring(lastMatchEnd),
        style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.jetBrainsMono(color: Colors.white24, fontSize: 9)),
          const SizedBox(height: 4),
          RichText(text: TextSpan(children: spans)),
        ],
      ),
    );
  }

  Widget _buildTelemetryHeader(ThemeData theme, Color archColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
        color: archColor.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          const SizedBox(width: 48), // Espaciador para centrar el texto
          const Spacer(),
          Icon(Icons.psychology, color: archColor, size: 14),
          const SizedBox(width: 8),
          Text('COGNITIVE SYNC: ${widget.prediction != null ? "VERIFIED" : "ACTIVE"}', 
            style: GoogleFonts.jetBrainsMono(color: archColor, fontSize: 10, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (widget.prediction != null)
            IconButton(
              icon: Icon(Icons.analytics_outlined, color: archColor, size: 18),
              onPressed: _showTechnicalDetails,
              tooltip: 'Ver telemetría técnica',
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildInputState(ThemeData theme, Color archColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text('¿HACIA DÓNDE FLUYE TU CURIOSIDAD?', 
          style: GoogleFonts.jetBrainsMono(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Describe un sentimiento, un paisaje o una idea vaga. La IA triangulará tu próxima expedición.', 
          style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13)),
        const SizedBox(height: 32),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            TextField(
              controller: _inputController,
              maxLines: 5,
              style: GoogleFonts.jetBrainsMono(color: archColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Ej: Busco un bosque nuboso donde el tiempo parezca detenerse...',
                hintStyle: GoogleFonts.jetBrainsMono(color: archColor.withValues(alpha: 0.3), fontSize: 14),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: archColor, width: 2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'ocr_suggestions',
                    onPressed: () => _scanWithOcr(archColor),
                    backgroundColor: archColor.withValues(alpha: 0.8),
                    child: const Icon(Icons.document_scanner_outlined, color: Colors.black, size: 18),
                  ),
                  FloatingActionButton.small(
                    heroTag: 'mic_suggestions',
                    onPressed: _listen,
                    backgroundColor: _isListening ? Colors.redAccent : archColor,
                    child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState(Color archColor) {
    return Column(
      children: [
        const SizedBox(height: 120),
        CircularProgressIndicator(color: archColor, strokeWidth: 1),
        const SizedBox(height: 32),
        Text('SINTETIZANDO RUTAS...', 
          style: GoogleFonts.jetBrainsMono(fontSize: 10, color: archColor, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildProposalCard(ThemeData theme, Color archColor) {
    // Lógica para ocultar el botón si no hay vuelos
    // El Scout Agent devuelve links de Despegar/Google si la búsqueda es exitosa
    final bool hasFlights = widget.prediction == null || 
        (widget.prediction!.flightInfo != null && 
         widget.prediction!.flightInfo!.toString().contains('BÚSQUEDA DE VUELOS INICIADA'));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: archColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: archColor, size: 16),
              const SizedBox(width: 8),
              Text('PROPUESTA GENERADA', 
                style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: archColor)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface, size: 18),
                onPressed: () => setState(() => _currentProposal = null),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          Text(
            _currentProposal!.content,
            style: GoogleFonts.ebGaramond(fontSize: 19, height: 1.5, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 40),
          if (_isAccepting)
            Center(child: CircularProgressIndicator(color: archColor))
          else if (hasFlights)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _acceptProposal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: archColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                ),
                child: Text('ACTIVAR ESTE DESTINO', 
                  style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )
          else
            Column(
              children: [
                FadeTransition(
                  opacity: _blinkController,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.block, color: Colors.redAccent, size: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('LOGÍSTICA NO DISPONIBLE: No se detectaron rutas aéreas válidas para este destino.', 
                            style: GoogleFonts.jetBrainsMono(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.radar, size: 16),
                    label: Text('REINTENTAR ESCANEO AGÉNTICO', 
                      style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: archColor,
                      side: BorderSide(color: archColor.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(Color archColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: archColor.withValues(alpha: 0.1), blurRadius: 20)
          ],
        ),
        child: ElevatedButton(
          onPressed: _generateProposal,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: archColor,
            minimumSize: const Size(double.infinity, 60),
            side: BorderSide(color: archColor, width: 2),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text(_currentProposal == null ? 'INICIAR SÍNTESIS' : 'RE-SINTETIZAR', 
            style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ),
      ),
    );
  }

  Color _getArchetypeColor(String archetype) {
    final a = archetype.toUpperCase();
    if (a.contains('EXPLORADOR')) return Colors.orange;
    if (a.contains('ALQUIMISTA')) return Colors.purpleAccent;
    if (a.contains('CONECTOR')) return Colors.redAccent;
    if (a.contains('ERMITAÑO')) return Colors.cyanAccent;
    if (a.contains('ACADÉMICO')) return Colors.greenAccent;
    return const Color(0xFFFF2D55); // Default primary
  }
}

/// Widget que dibuja un radar de escaneo circular animado
class _RadarScanner extends StatefulWidget {
  final Color color;
  const _RadarScanner({required this.color});

  @override
  State<_RadarScanner> createState() => _RadarScannerState();
}

class _RadarScannerState extends State<_RadarScanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 3)
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: CustomPaint(painter: _RadarPainter(_controller, widget.color)),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _RadarPainter(this.animation, this.color) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2;
    final paint = Paint()..color = color.withValues(alpha: 0.1)..style = PaintingStyle.stroke..strokeWidth = 1.0;

    canvas.drawCircle(center, radius * 0.4, paint);
    canvas.drawCircle(center, radius * 0.7, paint);
    canvas.drawCircle(center, radius * 0.9, paint);

    final sweepPaint = Paint()..shader = SweepGradient(
      colors: [color.withValues(alpha: 0), color.withValues(alpha: 0.5)],
      stops: const [0.8, 1.0],
      transform: GradientRotation(animation.value * 2 * 3.14159),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.9, sweepPaint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}