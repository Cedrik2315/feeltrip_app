import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:feeltrip_app/features/diario/presentation/providers/momento_provider.dart';

class OCRScreen extends ConsumerStatefulWidget {
  const OCRScreen({super.key});

  @override
  ConsumerState<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends ConsumerState<OCRScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final GlobalKey _boundaryKey = GlobalKey();
  
  File? _image;
  bool _isProcessing = false;
  late final TextEditingController _extractedTextController;
  String? _detectedLanguageCode;

  // Paleta FeelTrip_OS
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color terminalGreen = Color(0xFF00FF41);
  static const Color carbon = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _extractedTextController = TextEditingController();
  }

  @override
  void dispose() {
    _extractedTextController.dispose();
    _languageIdentifier.close();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200, 
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _image = File(image.path);
          _extractedTextController.clear();
        });
        await _processImage();
      }
    } catch (e) {
      _showError('SYSTEM_ERROR: Fallo en captura -> $e');
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;
    setState(() => _isProcessing = true);

    try {
      final inputImage = InputImage.fromFilePath(_image!.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      String? langCode;
      if (recognizedText.text.isNotEmpty) {
        langCode = await _languageIdentifier.identifyLanguage(recognizedText.text);
      }

      if (!mounted) return;

      setState(() {
        _extractedTextController.text = recognizedText.text;
        _detectedLanguageCode = (langCode == 'und' || langCode == null) ? null : langCode;
      });
      if (recognizedText.text.isEmpty) {
        _showError('OCR_STATUS: No se detectaron caracteres.');
      }
    } catch (e) {
      _showError('PROCESS_CRITICAL: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.jetBrainsMono(fontSize: 11)),
        backgroundColor: Colors.red[900],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveAsCapsule() async {
    if (_extractedTextController.text.isEmpty) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) throw 'SISTEMA: Sesión requerida para el sellado.';

      // Protocolo de geolocalización para el sellado de la cápsula
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      String? locationName;
      try {
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) locationName = placemarks.first.locality;
      } catch (_) {}

      final capsule = ref.read(historicalContextServiceProvider).createHistoricalCapsule(
        userId: user.uid,
        content: _extractedTextController.text,
        lat: position.latitude,
        lng: position.longitude,
        locationName: locationName,
      );

      // Persistencia en Isar/Firestore a través del provider
      await ref.read(momentoProvider.notifier).addMomento(capsule);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PROTOCOLO COMPLETADO: Cápsula sellada en coordenadas GPS.', 
              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: boneWhite)),
            backgroundColor: carbon,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('GEOSYNC_FAILURE: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _shareAsPostcard() async {
    setState(() => _isProcessing = true);
    HapticFeedback.lightImpact();

    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final String path = '${directory.path}/postal_feeltrip_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = await File(path).create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(path)], text: '📜 He descubierto una evidencia histórica en FeelTrip.');
    } catch (e) {
      _showError('SHARE_ERROR: No se pudo generar la postal -> $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        title: Text('SCAN MODULE V1', 
          style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: carbon,
        foregroundColor: boneWhite,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTerminalHeader(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 32),
            _buildImagePreview(),
            if (_isProcessing) _buildLoader(),
            if (_extractedTextController.text.isNotEmpty && !_isProcessing) _buildResultView(),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('OPTICAL CHARACTER RECOGNITION', 
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10, 
            color: carbon.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 4),
        Text('Digitaliza evidencias de tu ruta.', 
          style: GoogleFonts.ebGaramond(fontSize: 24, fontWeight: FontWeight.bold, color: carbon)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: Icons.camera_enhance_outlined,
            label: 'CÁMARA',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: Icons.grid_view_rounded,
            label: 'ARCHIVO',
          ),
        ),
      ],
    );
  }

  Widget _actionButton({required VoidCallback onPressed, required IconData icon, required String label}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        foregroundColor: carbon,
        side: const BorderSide(color: carbon),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_image == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        border: Border.all(color: carbon, width: 0.5),
      ),
      child: Image.file(_image!, height: 220, width: double.infinity, fit: BoxFit.cover),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const CircularProgressIndicator(color: carbon, strokeWidth: 1),
            const SizedBox(height: 16),
            Text('RUNNING OCR ALGORITHM...', 
              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: carbon.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslateSuggestion() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[900]?.withValues(alpha: 0.1),
        border: Border.all(color: Colors.blue[900]!.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Se ha detectado contenido en un idioma extranjero (${_detectedLanguageCode?.toUpperCase()}). ¿Ejecutar traducción del sistema?',
              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: carbon),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/translator', extra: _extractedTextController.text),
            child: Text('EJECUTAR', 
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blue[900])),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.terminal, size: 14, color: carbon),
                const SizedBox(width: 8),
                Text('DATA OUTPUT:', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            if (_detectedLanguageCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: carbon,
                child: Text('LANG: ${_detectedLanguageCode!.toUpperCase()}', 
                  style: GoogleFonts.jetBrainsMono(fontSize: 9, color: terminalGreen, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        RepaintBoundary(
          key: _boundaryKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF5E6), // Old paper color
              border: Border.all(color: carbon.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(5, 5))
              ],
            ),
            child: Column(
              children: [
                if (_detectedLanguageCode != null && _detectedLanguageCode != 'es')
                  _buildTranslateSuggestion(),
                TextField(
                  controller: _extractedTextController,
                  maxLines: null,
                  style: GoogleFonts.ebGaramond(fontSize: 18, height: 1.4, fontStyle: FontStyle.italic, color: carbon),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'PROCESANDO TEXTO...',
                  ),
                ),
                const SizedBox(height: 12),
                Align(alignment: Alignment.bottomRight, child: Text('FEELTRIP // ARCHIVO HISTÓRICO', style: GoogleFonts.jetBrainsMono(fontSize: 8, color: carbon.withValues(alpha: 0.4)))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.pop(_extractedTextController.text),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text('USAR TEXTO', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: boneWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _extractedTextController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('DATA COPIED TO BUFFER', style: GoogleFonts.jetBrainsMono(fontSize: 10))));
                },
                icon: const Icon(Icons.copy_all, size: 18, color: carbon),
                label: Text('COPIAR', style: GoogleFonts.jetBrainsMono(color: carbon, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/translator', extra: _extractedTextController.text),
                icon: const Icon(Icons.translate_rounded, size: 18),
                label: Text('TRADUCIR', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: carbon,
                  foregroundColor: boneWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareAsPostcard,
                icon: const Icon(Icons.share, size: 18),
                label: Text('POSTAL', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513), // Saddle Brown for antique feel
                  foregroundColor: boneWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : _saveAsCapsule,
            icon: const Icon(Icons.push_pin_outlined, size: 18),
            label: Text('SELLAR CÁPSULA HISTÓRICA EN MAPA', 
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 11)),
            style: OutlinedButton.styleFrom(
              foregroundColor: terminalGreen,
              backgroundColor: carbon,
              side: const BorderSide(color: terminalGreen, width: 1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          ),
        ),
      ],
    );
  }
}