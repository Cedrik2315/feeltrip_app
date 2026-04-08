import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key, this.initialText});
  final String? initialText;

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  
  String _translatedText = '';
  bool _isLoading = false;
  String _fromLang = 'es';
  String _toLang = 'en';
  String _error = '';

  final Map<String, String> _languages = {
    'Español': 'es',
    'Inglés': 'en',
    'Francés': 'fr',
    'Portugués': 'pt',
    'Italiano': 'it',
    'Alemán': 'de',
    'Japonés': 'ja',
    'Chino': 'zh',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _inputController.text = widget.initialText!;
    }
  }

  // --- LÓGICA DE TRADUCCIÓN ---

  Future<void> _translate() async {
    final query = _inputController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final text = Uri.encodeComponent(query);
      final url = 'https://api.mymemory.translated.net/get?q=$text&langpair=$_fromLang|$_toLang';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final responseData = data['responseData'] as Map<String, dynamic>?;
        final translated = responseData?['translatedText']?.toString() ?? '';
        setState(() => _translatedText = translated);
        HapticFeedback.lightImpact();
      } else {
        throw Exception();
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión. Verifica tu internet.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _speak() async {
    if (_translatedText.isEmpty) return;
    
    // Mapeo dinámico para voces TTS
    String ttsLang = _toLang;
    if (_toLang == 'en') ttsLang = 'en-US';
    if (_toLang == 'es') ttsLang = 'es-ES';

    await _tts.setLanguage(ttsLang);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(_translatedText);
  }

  void _swapLanguages() {
    setState(() {
      final temp = _fromLang;
      _fromLang = _toLang;
      _toLang = temp;
      final tempText = _inputController.text;
      _inputController.text = _translatedText;
      _translatedText = tempText;
    });
    HapticFeedback.mediumImpact();
  }

  // --- UI COMPONENTS ---

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF004D40); // Teal FeelTrip

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Fondo papel
      appBar: AppBar(
        title: Text('TRADUCTOR VIVENCIAL', 
          style: GoogleFonts.jetBrainsMono(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _buildLanguageHeader(primaryColor),
            const SizedBox(height: 24),
            _buildInputArea(primaryColor),
            const SizedBox(height: 20),
            _buildActionButtons(primaryColor),
            if (_translatedText.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildResultCard(primaryColor),
            ],
            if (_error.isNotEmpty) _buildErrorLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageHeader(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLanguageButton(_fromLang),
          IconButton(
            icon: Icon(Icons.swap_horizontal_circle, color: color, size: 32),
            onPressed: _swapLanguages,
          ),
          _buildLanguageButton(_toLang),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String code) {
    final name = _languages.entries.firstWhere((e) => e.value == code).key;
    return Text(
      name.toUpperCase(),
      style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
    );
  }

  Widget _buildInputArea(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        controller: _inputController,
        maxLines: 6,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: 'Ingresa texto aquí...',
          hintStyle: TextStyle(color: Colors.grey[300]),
          contentPadding: const EdgeInsets.all(24),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _translate,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
          : const Text('TRADUCIR AHORA', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildResultCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TRADUCCIÓN', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(_translatedText, style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildCircleTool(Icons.copy, () {
                Clipboard.setData(ClipboardData(text: _translatedText));
                HapticFeedback.selectionClick();
              }),
              const SizedBox(width: 12),
              _buildCircleTool(Icons.volume_up, _speak),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCircleTool(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.black12)),
        child: Icon(icon, size: 20, color: const Color(0xFF004D40)),
      ),
    );
  }

  Widget _buildErrorLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(_error, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _tts.stop();
    super.dispose();
  }
}