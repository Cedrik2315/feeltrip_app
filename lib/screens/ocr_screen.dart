import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  File? _image;
  bool _isProcessing = false;
  late final TextEditingController _extractedTextController;

  // Paleta FeelTrip_OS
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color carbon = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _extractedTextController = TextEditingController();
  }

  @override
  void dispose() {
    _extractedTextController.dispose();
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

      if (!mounted) return;

      setState(() {
        _extractedTextController.text = recognizedText.text;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        title: Text('SCAN_MODULE_V1', 
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
        Text('OPTICAL_CHARACTER_RECOGNITION', 
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
            Text('RUNNING_OCR_ALGORITHM...', 
              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: carbon.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.terminal, size: 14, color: carbon),
            const SizedBox(width: 8),
            Text('DATA_OUTPUT:', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _extractedTextController,
          maxLines: 10,
          style: GoogleFonts.inter(fontSize: 14, height: 1.4),
          decoration: InputDecoration(
            filled: true,
            fillColor: carbon.withValues(alpha: 0.03),
border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: carbon)),
focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: carbon, width: 2)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _extractedTextController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('DATA_COPIED_TO_BUFFER', style: GoogleFonts.jetBrainsMono(fontSize: 10))));
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
          ],
        ),
      ],
    );
  }
}