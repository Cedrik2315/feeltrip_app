import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:go_router/go_router.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/services/location_service.dart';
import 'package:feeltrip_app/features/profile/presentation/profile_controller.dart';

import 'package:feeltrip_app/features/diario/domain/models/momento_model.dart';
import 'package:feeltrip_app/features/diario/presentation/providers/momento_provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';

// --- UI OPTIMIZADA ---
class TravelDiaryScreen extends ConsumerStatefulWidget {
  const TravelDiaryScreen({super.key});

  @override
  ConsumerState<TravelDiaryScreen> createState() => _TravelDiaryScreenState();
}

class _TravelDiaryScreenState extends ConsumerState<TravelDiaryScreen> {
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isLoadingLocation = false;
  bool _isSaving = false;
  String? _aiInspiration;
  bool _isFetchingAi = false;

  @override
  void initState() {
    super.initState();
    // Aseguramos que los servicios y datos se carguen al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDiaryData());
    _initSpeech();
  }

  Future<void> _loadDiaryData() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user != null) {
      await ref.read(momentoProvider.notifier).loadMomentos(user.uid);
    }
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Servicio de ubicación desactivado';
      if (!mounted) return;
      final granted = await LocationService.requestPermissionWithDisclosure(context);
      if (!granted) throw 'Permiso denegado por el usuario o permanentemente';

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _locationController.text = '${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      AppLogger.e('Error obteniendo ubicación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _fetchAiInspiration(Color themeColor) async {
    setState(() => _isFetchingAi = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 3),
        ),
      );
      
      final profile = ref.read(profileControllerProvider).value;
      final historyService = ref.read(historicalContextServiceProvider);
      
      final inspiration = await historyService.getHistoryForLocation(
        position.latitude, 
        position.longitude, 
        archetype: profile?.archetype
      );
      
      setState(() => _aiInspiration = inspiration);
    } catch (e) {
      AppLogger.e('Error obteniendo inspiración: $e');
    } finally {
      setState(() => _isFetchingAi = false);
    }
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
            _contentController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _scanWithOcr(Color themeColor) async {
    HapticFeedback.lightImpact();
    // Navegamos a la pantalla de OCR esperando un resultado de texto
    final String? scannedText = await context.push<String>('/ocr');
    
    if (scannedText != null && scannedText.isNotEmpty) {
      _contentController.text = '${_contentController.text} $scannedText'.trim();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final momentosState = ref.watch(momentoProvider);
    const themeColor = Color(0xFF004D40); // Teal corporativo FeelTrip

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('MI BITÁCORA', 
          style: GoogleFonts.jetBrainsMono(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: themeColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.radar, color: Colors.white),
            onPressed: () => context.push('/emotional-prediction'),
            tooltip: 'SISTEMA SCOUT AI',
          ),
        ],
      ),
      body: momentosState.when(
        data: (entries) => entries.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: entries.length,
                itemBuilder: (context, index) => _buildTimelineEntry(entries[index], themeColor),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntrySheet(context, themeColor),
        backgroundColor: themeColor,
        icon: const Icon(Icons.history_edu, color: Colors.white),
        label: Text('NUEVO RELATO', style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 80, color: Colors.teal.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text('Tu bitácora está esperando historias...', 
            style: GoogleFonts.playfairDisplay(color: Colors.grey, fontSize: 16, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildTimelineEntry(Momento entry, Color color) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline visual con gradiente sutil
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color, 
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4)],
                ),
              ),
              Expanded(
                child: Container(
                  width: 2, 
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0.05)],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Contenido de la Bitácora
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.photoUrl != null)
                      CachedNetworkImage(
                        imageUrl: entry.photoUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: color.withValues(alpha: 0.05)),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(entry.createdAt),
                                style: GoogleFonts.jetBrainsMono(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 12, color: color.withValues(alpha: 0.5)),
                              const SizedBox(width: 4),
                              Text(entry.title.toUpperCase(), 
                                style: GoogleFonts.jetBrainsMono(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 16),
                           Text(
                            entry.description ?? '',
                            style: GoogleFonts.playfairDisplay(fontSize: 16, height: 1.5, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEntrySheet(BuildContext context, Color color) {
    HapticFeedback.heavyImpact();
    _aiInspiration = null; // Reset para nueva entrada
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('NUEVA VIVENCIA', 
              style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 24),
            TextField(
              controller: _locationController,
              style: GoogleFonts.jetBrainsMono(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Ubicación',
                prefixIcon: Icon(Icons.near_me, color: color, size: 20),
                suffixIcon: IconButton(
                  icon: _isLoadingLocation 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : Icon(Icons.gps_fixed, color: color),
                  onPressed: _getCurrentLocation,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 16),
            // --- SECCIÓN DE INSPIRACIÓN IA (Cápsula del Tiempo) ---
            if (_aiInspiration != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 14, color: color),
                        const SizedBox(width: 8),
                        Text('INSPIRACIÓN HISTÓRICA', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_aiInspiration!, style: GoogleFonts.playfairDisplay(fontSize: 13, height: 1.4, fontStyle: FontStyle.italic)),
                  ],
                ),
              )
            else
              TextButton.icon(
                onPressed: _isFetchingAi ? null : () => _fetchAiInspiration(color),
                icon: _isFetchingAi 
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.psychology_outlined, size: 18, color: color),
                label: Text('DESBLOQUEAR ARCHIVO HISTÓRICO (IA)', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: color)),
              ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  style: GoogleFonts.playfairDisplay(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Relata lo que has descubierto...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    alignLabelWithHint: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'ocr_btn',
                        onPressed: () => _scanWithOcr(color),
                        backgroundColor: color.withValues(alpha: 0.8),
                        child: const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 18),
                      ),
                      FloatingActionButton.small(
                        heroTag: 'mic_btn',
                        onPressed: _listen,
                        backgroundColor: _isListening ? Colors.redAccent : color,
                        child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : () async {
                if (_contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, relata tu descubrimiento antes de guardar.')),
                  );
                  return;
                }

                setState(() => _isSaving = true);
                try {
                  final user = ref.read(firebaseAuthProvider).currentUser;
                  if (user == null) {
                    throw Exception('Debes estar autenticado para guardar en la bitácora.');
                  }

                  // Obtenemos ubicación de forma no bloqueante o con timeout estricto
                  Position? position;
                  try {
                    position = await Geolocator.getLastKnownPosition().timeout(const Duration(milliseconds: 500), onTimeout: () => null);
                    position ??= await Geolocator.getCurrentPosition(
                      locationSettings: const LocationSettings(
                        accuracy: LocationAccuracy.low,
                        timeLimit: Duration(seconds: 2),
                      ),
                    ).timeout(const Duration(seconds: 2));
                  } catch (e) {
                    AppLogger.w('Ubicación omitida para agilizar el guardado: $e');
                  }

                  final newMomento = Momento(
                    id: const Uuid().v4(),
                    userId: user.uid,
                    title: _locationController.text.isEmpty ? 'Nueva Ubicación' : _locationController.text,
                    description: _contentController.text,
                    createdAt: DateTime.now(),
                    latitude: position?.latitude,
                    longitude: position?.longitude,
                    isSynced: false, // Forzamos local primero
                  );
                  
                  // Si el usuario desbloqueó la inspiración, guardarla como cápsula independiente
                  if (_aiInspiration != null) {
                    final capsule = ref.read(historicalContextServiceProvider).createHistoricalCapsule(
                      userId: user.uid,
                      content: _aiInspiration!,
                      lat: position?.latitude ?? 0.0,
                      lng: position?.longitude ?? 0.0,
                      locationName: _locationController.text,
                    );
                    
                    try {
                      await ref.read(momentoProvider.notifier).addMomento(capsule);
                    } catch (e) {
                      AppLogger.w('Error guardando cápsula IA: $e');
                    }
                  }

                  // Intentamos guardar en Isar (Local). 
                  // Si Firestore falla, al menos queda en el teléfono.
                  try {
                    await ref.read(momentoProvider.notifier).addMomento(newMomento);
                  } catch (syncError) {
                    AppLogger.w('Error de sincronización inmediata (se guardará local): $syncError');
                  }
                  
                  _contentController.clear();
                  _locationController.clear();
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('¡Vivencia sellada con éxito!'),
                        backgroundColor: color,
                      ),
                    );
                  }
                  HapticFeedback.mediumImpact();
                } catch (e) {
                  AppLogger.e('Error al guardar en bitácora: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isSaving = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color, 
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isSaving 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('GUARDAR EN BITÁCORA', 
                    style: GoogleFonts.jetBrainsMono(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}