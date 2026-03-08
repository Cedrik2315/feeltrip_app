import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class QuickTranslatorSheet extends StatefulWidget {
  const QuickTranslatorSheet({super.key});

  @override
  State<QuickTranslatorSheet> createState() => _QuickTranslatorSheetState();
}

class _QuickTranslatorSheetState extends State<QuickTranslatorSheet> {
  final GoogleTranslator _translator = GoogleTranslator();
  String _textoTraducido = "Traducción aparecerá aquí...";
  final TextEditingController _controller = TextEditingController();

  String _sourceLang = 'es';
  String _targetLang = 'en';
  String _sourceLabel = 'Español';
  String _targetLabel = 'Inglés';
  bool _isTranslating = false;

  void _swapLanguages() {
    setState(() {
      final tempLang = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = tempLang;

      final tempLabel = _sourceLabel;
      _sourceLabel = _targetLabel;
      _targetLabel = tempLabel;

      _controller.clear();
      _textoTraducido = "Traducción aparecerá aquí...";
    });
  }

  Future<void> _translate() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isTranslating = true);
    try {
      final translation = await _translator.translate(_controller.text,
          from: _sourceLang, to: _targetLang);
      if (!mounted) return;
      setState(() => _textoTraducido = translation.text);
    } catch (e) {
      if (!mounted) return;
      setState(
          () => _textoTraducido = "Error de conexión. Intenta nuevamente.");
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _languageChip(_sourceLabel, true),
              IconButton(
                icon: const Icon(Icons.swap_horiz, color: Colors.deepPurple),
                onPressed: _swapLanguages,
              ),
              _languageChip(_targetLabel, false),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Escribe algo para traducir...",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              suffixIcon: IconButton(
                icon: _isTranslating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.translate, color: Colors.deepPurple),
                onPressed: _isTranslating ? null : _translate,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _textoTraducido,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple[900]),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _languageChip(String label, bool isSource) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.deepPurple,
    );
  }
}
