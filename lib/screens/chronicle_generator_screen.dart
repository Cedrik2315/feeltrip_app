import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/expedition_data.dart';
import '../../services/chronicle_repository_impl.dart';

class ChronicleGeneratorScreen extends ConsumerStatefulWidget {
  const ChronicleGeneratorScreen({super.key});

  @override
  ConsumerState<ChronicleGeneratorScreen> createState() =>
      _ChronicleGeneratorScreenState();
}

class _ChronicleGeneratorScreenState
    extends ConsumerState<ChronicleGeneratorScreen> {
  final _placeCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  NarrativeTone _tone = NarrativeTone.contemplativo;

  // Colores de marca FeelTrip (Naturaleza & Editorial)
  static const Color boneWhite = Color(0xFFF9F6EE);
  static const Color carbonBlack = Color(0xFF1A1A1B);
  static const Color rustyEarth = Color(0xFFB85C38);
  static const Color mossGreen = Color(0xFF4A5D23);
  static const Color dustySilt = Color(0xFF8A7F6E);
  static const Color softBorder = Color(0xFFD4CBB9);

  @override
  void dispose() {
    for (var ctrl in [_placeCtrl, _regionCtrl, _timeCtrl, _tempCtrl, _detailCtrl, _nameCtrl]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _generate() async {
    final place = _placeCtrl.text.trim();
    final detail = _detailCtrl.text.trim();

    if (place.isEmpty || detail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('// ERROR: DATOS_INCOMPLETOS', style: GoogleFonts.jetBrainsMono()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFA52A2A),
        ),
      );
      return;
    }

    final data = ExpeditionData(
      placeName: place,
      region: _regionCtrl.text.trim().isEmpty ? 'Chile' : _regionCtrl.text.trim(),
      arrivalTime: _timeCtrl.text.trim().isEmpty ? _currentTime() : _timeCtrl.text.trim(),
      temperature: _tempCtrl.text.trim().isEmpty ? '—' : _tempCtrl.text.trim(),
      uniqueDetail: detail,
      explorerName: _nameCtrl.text.trim().isEmpty ? 'El Explorador' : _nameCtrl.text.trim(),
      tone: _tone,
    );

    await ref.read(chronicleGeneratorProvider.notifier).generate(data);
  }

  String _currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final genState = ref.watch(chronicleGeneratorProvider);
    final isLoading = genState.isLoading;

    ref.listen(chronicleGeneratorProvider, (previous, next) {
      next.whenOrNull(
        data: (chronicle) {
          if (chronicle != null) {
            context.push('/chronicle-detail', extra: chronicle);
            ref.read(chronicleGeneratorProvider.notifier).reset();
          }
        },
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SYS_FAIL: $e'), backgroundColor: Colors.redAccent),
        ),
      );
    });

    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        backgroundColor: boneWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: carbonBlack, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('NUEVA ENTRADA', 
          style: GoogleFonts.jetBrainsMono(fontSize: 12, letterSpacing: 2, color: carbonBlack)),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('REGISTRO DE EXPEDICIÓN', 
                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: dustySilt, letterSpacing: 1.5)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: softBorder, thickness: 0.5),
              ),
              const SizedBox(height: 16),

              _FieldInput(controller: _placeCtrl, label: 'LOCALIZACIÓN', hint: 'Ej. Torres del Paine...'),
              const SizedBox(height: 24),
              _FieldInput(controller: _regionCtrl, label: 'REGIÓN / TERRITORIO', hint: 'Magallanes, Chile'),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: _FieldInput(controller: _timeCtrl, label: 'HORA', hint: _currentTime())),
                  const SizedBox(width: 32),
                  Expanded(child: _FieldInput(controller: _tempCtrl, label: 'TEMP', hint: '12°C')),
                ],
              ),
              const SizedBox(height: 24),

              _FieldInput(
                controller: _detailCtrl,
                label: 'OBSERVACIÓN ÚNICA (EL ALMA DEL RELATO)',
                hint: 'Describe ese olor, ese sonido o esa luz particular...',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              Text('ATMÓSFERA NARRATIVA', 
                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: dustySilt, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: NarrativeTone.values.map((t) {
                  final active = _tone == t;
                  return _ToneChip(
                    label: t.displayName, 
                    isActive: active, 
                    onTap: () => setState(() => _tone = t)
                  );
                }).toList(),
              ),

              const SizedBox(height: 48),

              _GenerateButton(
                isLoading: isLoading, 
                onTap: _generate
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldInput extends StatelessWidget {
  const _FieldInput({required this.controller, required this.label, required this.hint, this.maxLines = 1});
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 9, color: _ChronicleGeneratorScreenState.dustySilt, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.ebGaramond(fontSize: 20, color: _ChronicleGeneratorScreenState.carbonBlack),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.ebGaramond(color: _ChronicleGeneratorScreenState.softBorder, fontSize: 20),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _ChronicleGeneratorScreenState.softBorder, width: 0.5)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _ChronicleGeneratorScreenState.rustyEarth, width: 1.0)),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }
}

class _ToneChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToneChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _ChronicleGeneratorScreenState.mossGreen.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(color: isActive ? _ChronicleGeneratorScreenState.mossGreen : _ChronicleGeneratorScreenState.softBorder, width: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(label.toUpperCase(), 
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11, 
            color: isActive ? _ChronicleGeneratorScreenState.carbonBlack : _ChronicleGeneratorScreenState.dustySilt,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal
          )),
      ),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _GenerateButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: isLoading ? 60 : 40,
            height: 1,
            color: _ChronicleGeneratorScreenState.carbonBlack,
          ),
          const SizedBox(width: 16),
          isLoading 
            ? Text('IA PROCESANDO PAISAJE...', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontStyle: FontStyle.italic))
            : Text('>> TRANSCRIBIR_CRÓNICA', 
                style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }
}