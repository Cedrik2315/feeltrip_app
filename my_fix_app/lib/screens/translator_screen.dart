import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../user_preferences.dart';

const Color boneWhite = Color(0xFFF5F5DC);
const Color terminalGreen = Color(0xFF00FF41);

class TranslatorScreen extends ConsumerStatefulWidget {
  const TranslatorScreen({super.key, this.initialText});
  final String? initialText;

  @override
  ConsumerState<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends ConsumerState<TranslatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  
  String _translatedText = '';
  bool _isLoading = false;
  String _fromLang = 'es';
  String _toLang = 'en';
  String _error = '';

  // Pares de idiomas soportados (incluye PT-BR)
  final List<Map<String, String>> _langPairs = [
    {'code': 'es', 'label': 'ES'},
    {'code': 'en', 'label': 'EN'},
    {'code': 'pt', 'label': 'PT'},
    {'code': 'fr', 'label': 'FR'},
    {'code': 'de', 'label': 'DE'},
    {'code': 'ja', 'label': 'JA'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _inputController.text = widget.initialText!;
    }
  }

  Future<void> _translate() async {
    final query = _inputController.text.trim();
    if (query.isEmpty) return;
    setState(() { _isLoading = true; _error = ''; });

    try {
      final text = Uri.encodeComponent(query);
      final url = 'https://api.mymemory.translated.net/get?q=$text&langpair=$_fromLang|$_toLang';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic>? responseData = data['responseData'] as Map<String, dynamic>?;
        final translated = responseData?['translatedText']?.toString() ?? '';
        setState(() => _translatedText = translated);
        HapticFeedback.lightImpact();
      } else { throw Exception(); }
    } catch (e) {
      setState(() => _error = 'ERROR CONEXI\u00d3N: Reintenta.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('SISTEMA // TRADUCTOR', 
          style: GoogleFonts.jetBrainsMono(fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold, color: boneWhite)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: boneWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('MODULO DE IDIOMA INTERFAZ'),
            const SizedBox(height: 16),
            _buildSystemLanguageSelector(prefs),
            const SizedBox(height: 48),
            _sectionLabel('TRADUCCION DE CAMPO (UGC)'),
            const SizedBox(height: 16),
            _buildLanguageToggle(),
            const SizedBox(height: 16),
            _buildLangPairPicker(),
            const SizedBox(height: 16),
            _buildInputArea(),
            if (_translatedText.isNotEmpty) _buildResultCard(),
            if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _translate,
          style: ElevatedButton.styleFrom(
            backgroundColor: terminalGreen,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          ),
          child: Text('EJECUTAR TRADUCCION', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: terminalGreen, fontWeight: FontWeight.bold));
  }

  Widget _buildSystemLanguageSelector(UserPreferences prefs) {
    return Row(
      children: [
        _langOption('ES', prefs.language == 'es', () {
          ref.read(userPreferencesProvider.notifier).setLanguage('es');
        }),
        const SizedBox(width: 8),
        _langOption('EN', prefs.language == 'en', () {
          ref.read(userPreferencesProvider.notifier).setLanguage('en');
        }),
        const SizedBox(width: 8),
        _langOption('PT', prefs.language == 'pt', () {
          ref.read(userPreferencesProvider.notifier).setLanguage('pt');
        }),
      ],
    );
  }

  Widget _langOption(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? terminalGreen : Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: active ? terminalGreen : boneWhite.withValues(alpha: 0.1)),
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.jetBrainsMono(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: active ? Colors.black : boneWhite.withValues(alpha: 0.4)
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_fromLang.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: boneWhite)),
        IconButton(icon: const Icon(Icons.swap_horiz, color: terminalGreen), onPressed: () {
          setState(() {
            final temp = _fromLang; _fromLang = _toLang; _toLang = temp;
          });
        }),
        Text(_toLang.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: boneWhite)),
      ],
    );
  }

  Widget _buildLangPairPicker() {
    DropdownButton<String> picker(String current, void Function(String) onChange) {
      return DropdownButton<String>(
        value: current,
        dropdownColor: const Color(0xFF1A1A1A),
        style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 13),
        underline: Container(height: 1, color: terminalGreen.withValues(alpha: 0.4)),
        items: _langPairs.map((p) => DropdownMenuItem(
          value: p['code'],
          child: Text(p['label']!, style: GoogleFonts.jetBrainsMono(color: boneWhite, fontWeight: FontWeight.bold)),
        )).toList(),
        onChanged: (v) { if (v != null) setState(() => onChange(v)); },
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        picker(_fromLang, (v) => _fromLang = v),
        const SizedBox(width: 16),
        Text('→', style: GoogleFonts.jetBrainsMono(color: terminalGreen, fontSize: 18)),
        const SizedBox(width: 16),
        picker(_toLang, (v) => _toLang = v),
      ],
    );
  }

  Widget _buildInputArea() {
    return TextField(
      controller: _inputController,
      maxLines: 4,
      style: GoogleFonts.jetBrainsMono(color: boneWhite, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Ingresa texto para traducir...',
        hintStyle: GoogleFonts.jetBrainsMono(color: boneWhite.withValues(alpha: 0.2)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        border: OutlineInputBorder(borderSide: BorderSide(color: boneWhite.withValues(alpha: 0.1))),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(border: Border.all(color: terminalGreen.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SALIDA TRADUCCIÓN', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: terminalGreen)),
          const SizedBox(height: 12),
          Text(_translatedText, style: GoogleFonts.ebGaramond(fontSize: 20, color: boneWhite)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _tts.stop();
    super.dispose();
  }
}