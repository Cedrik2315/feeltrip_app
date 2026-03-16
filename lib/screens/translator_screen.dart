import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class TranslatorScreen extends StatefulWidget {
  final String? initialText;
  const TranslatorScreen({super.key, this.initialText});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  String _translation = '';
  String _fromLang = 'es';
  String _toLang = 'en';
  bool _isLoading = false;
  String _error = '';

  final List<String> languages = ['es', 'en', 'fr', 'de', 'it', 'pt'];

  @override
  void initState() {
    super.initState();
    _initTts();
    if (widget.initialText != null) {
      _inputController.text = widget.initialText!;
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _translate() async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final url =
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(_inputController.text.trim())}&langpair=$_fromLang|$_toLang';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _translation = data['responseData']['translatedText'];
        });
        await _flutterTts.speak(_translation);
      } else {
        setState(() {
          _error = 'Error en traducción';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traductor'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Language selection
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _fromLang,
                    decoration: const InputDecoration(
                      labelText: 'De',
                      border: OutlineInputBorder(),
                    ),
                    items: languages
                        .map((lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(_getLangName(lang)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromLang = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _toLang,
                    decoration: const InputDecoration(
                      labelText: 'A',
                      border: OutlineInputBorder(),
                    ),
                    items: languages
                        .map((lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(_getLangName(lang)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _toLang = value!;
                      });
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
              decoration: InputDecoration(
                labelText: 'Texto a traducir',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () {}, // Add speech_to_text later
                ),
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
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : const Icon(Icons.translate),
                label: Text(_isLoading ? 'Traduciendo...' : 'Traducir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Output
            if (_translation.isNotEmpty) ...[
              const Text(
                'Traducción',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_translation),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.volume_up),
                          onPressed: () => _flutterTts.speak(_translation),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: _translation));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Traducción copiada')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (_error.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error)),
                  ],
                ),
              ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    final temp = _fromLang;
                    _fromLang = _toLang;
                    _toLang = temp;
                  });
                },
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Invertir idiomas'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLangName(String code) {
    final map = {
      'es': 'Español',
      'en': 'Inglés',
      'fr': 'Francés',
      'de': 'Alemán',
      'it': 'Italiano',
      'pt': 'Portugués',
    };
    return map[code] ?? code.toUpperCase();
  }
}
