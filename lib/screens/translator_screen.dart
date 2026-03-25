import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _speak() async {
    if (_translatedText.isNotEmpty) {
      await _tts.speak(_translatedText);
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _translatedText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Texto copiado')),
      );
    }
  }

  Future<void> _swapLanguages() async {
    setState(() {
      final temp = _fromLang;
      _fromLang = _toLang;
      _toLang = temp;
      _translatedText = '';
    });
  }

  Future<void> _translate() async {
    if (_inputController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final text = Uri.encodeComponent(_inputController.text);
      final url = 'https://api.mymemory.translated.net/get?q=$text&langpair=$_fromLang|$_toLang';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data as Map<String, dynamic>;
        final String translatedText =
            (result['responseData'] as Map<String, dynamic>?)?['translatedText'] as String? ??
                'No translation received';
        setState(() {
          _translatedText = translatedText;
        });
        // Optional auto speak
        // await _speak();
      } else {
        setState(() {
          _error = 'Error de servidor: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al traducir: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getLangCode(String name) {
    return _languages[name]!;
  }

  String _getLangName(String code) {
    return _languages.keys.firstWhere((name) => _languages[name] == code, orElse: () => 'Español');
  }

  List<DropdownMenuItem<String>> _buildLangItems() {
    return _languages.keys
        .map((name) => DropdownMenuItem(
              value: name,
              child: Text(name),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traductor Completo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _getLangName(_fromLang),
                    decoration: const InputDecoration(
                      labelText: 'Desde',
                      border: OutlineInputBorder(),
                    ),
                    items: _buildLangItems(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _fromLang = _getLangCode(value));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _getLangName(_toLang),
                    decoration: const InputDecoration(
                      labelText: 'Hacia',
                      border: OutlineInputBorder(),
                    ),
                    items: _buildLangItems(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _toLang = _getLangCode(value));
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Input
            TextField(
              controller: _inputController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Ingresa el texto',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            // Translate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _translate,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : const Icon(Icons.translate),
                label: Text(_isLoading ? 'Traduciendo...' : 'Traducir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_translatedText.isNotEmpty) ...[
              const Text('Traducción:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_translatedText, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.volume_up),
                          onPressed: _speak,
                          tooltip: 'Hablar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: _copyToClipboard,
                          tooltip: 'Copiar',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: _swapLanguages,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Cambiar idiomas'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ),
          ],
        ),
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
