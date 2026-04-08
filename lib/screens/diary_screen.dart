import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:feeltrip_app/features/diario/domain/models/momento_model.dart';
import 'package:feeltrip_app/features/diario/presentation/providers/momento_provider.dart';
import 'package:feeltrip_app/services/metrics_service.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  static const Color boneWhite = Color(0xFFF5F5DC);
  static const Color mossGreen = Color(0xFF4B5320);
  static const Color carbon = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadMomentos());
  }

  Future<void> _reloadMomentos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await ref.read(momentoProvider.notifier).loadMomentos(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final momentosState = ref.watch(momentoProvider);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const _AuthRequiredView();

    return Scaffold(
      backgroundColor: boneWhite,
      appBar: AppBar(
        backgroundColor: carbon,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text('DIARIO_DE_CAMPO', 
          style: GoogleFonts.jetBrainsMono(fontSize: 13, color: boneWhite, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: boneWhite, size: 18),
            onPressed: () => ref.read(momentoProvider.notifier).syncMomentos(user.uid),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: momentosState.when(
        data: (momentos) => momentos.isEmpty 
          ? const _EmptyDiaryView() 
          : _MomentosList(momentos: momentos, onRefresh: _reloadMomentos),
        loading: () => const Center(child: CircularProgressIndicator(color: mossGreen, strokeWidth: 2)),
        error: (err, _) => Center(
          child: Text('// SYNC_ERROR: $err', 
            style: GoogleFonts.jetBrainsMono(color: Colors.red.shade900, fontSize: 12))
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        backgroundColor: carbon,
        onPressed: _showAddMomentoDialog,
        child: const Icon(Icons.add_rounded, color: boneWhite, size: 28),
      ),
    );
  }

  void _showAddMomentoDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: boneWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _NewMomentoSheet(
        onSave: (newMomento) async {
          await ref.read(momentoProvider.notifier).addMomento(newMomento);
          MetricsService.logSaveMoment();
        },
      ),
    );
  }
}

class _MomentosList extends StatelessWidget {
  const _MomentosList({required this.momentos, required this.onRefresh});
  final List<Momento> momentos;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF4B5320),
      backgroundColor: const Color(0xFFF5F5DC),
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: momentos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) => _MomentoCard(momento: momentos[index]),
      ),
    );
  }
}

class _MomentoCard extends ConsumerWidget {
  const _MomentoCard({required this.momento});
  final Momento momento;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withValues(alpha: .05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
        leading: _EmotionIndicator(description: momento.description),
        title: Text(momento.title.toUpperCase(), 
          style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (momento.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: Text(momento.description!, 
                  style: GoogleFonts.ebGaramond(fontSize: 17, color: Colors.black87, height: 1.3)),
              ),
            Row(
              children: [
                Icon(
                  momento.isSynced ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                  size: 10,
                  color: momento.isSynced ? const Color(0xFF4B5320) : Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  momento.isSynced ? 'REGISTRO_SINCRONIZADO' : 'PENDIENTE_SYNC',
                  style: GoogleFonts.jetBrainsMono(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
          onPressed: () => _showOptions(context, ref),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined, color: Color(0xFFF5F5DC)),
              title: Text('ELIMINAR_REGISTRO', style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 12)),
              onTap: () {
                ref.read(momentoProvider.notifier).deleteMomento(momento);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmotionIndicator extends StatelessWidget {
  const _EmotionIndicator({this.description});
  final String? description;

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      width: 4,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
      ),
    );
  }

  Color _getColor() {
    final lower = description?.toLowerCase() ?? '';
    if (lower.contains('calm')) return const Color(0xFF4B5320);
    if (lower.contains('reflect')) return const Color(0xFF4682B4);
    if (lower.contains('happy')) return const Color(0xFFFFD700);
    if (lower.contains('excited')) return const Color(0xFFFF4500);
    return Colors.grey.shade300;
  }
}

class _NewMomentoSheet extends StatefulWidget {
  const _NewMomentoSheet({required this.onSave});
  final Function(Momento) onSave;

  @override
  State<_NewMomentoSheet> createState() => _NewMomentoSheetState();
}

class _NewMomentoSheetState extends State<_NewMomentoSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedEmotion = 'calm';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NUEVA_ENTRADA', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            style: GoogleFonts.jetBrainsMono(fontSize: 13),
            decoration: _inputStyle('UBICACIÓN_O_TÍTULO', 'Ej: Selva de Valdivia'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 4,
            style: GoogleFonts.ebGaramond(fontSize: 18),
            decoration: _inputStyle('RELATO_DEL_MOMENTO', '¿Qué sientes en este lugar?'),
          ),
          const SizedBox(height: 24),
          Text('ESTADO_ANÍMICO', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _EmotionPicker(
            selected: _selectedEmotion,
            onChanged: (val) => setState(() => _selectedEmotion = val),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () {
                if (_titleController.text.isEmpty) return;
                final momento = Momento(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: FirebaseAuth.instance.currentUser!.uid,
                  title: _titleController.text,
                  description: '[$_selectedEmotion] ${_descController.text}',
                  createdAt: DateTime.now(),
                );
                widget.onSave(momento);
                Navigator.pop(context);
              },
              child: Text('SELLAR_BITÁCORA', style: GoogleFonts.jetBrainsMono(color: Colors.white, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
      hintText: hint,
      hintStyle: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.black12),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4B5320))),
    );
  }
}

class _EmotionPicker extends StatelessWidget {
  const _EmotionPicker({required this.selected, required this.onChanged});
  final String selected;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final emotions = {'happy': '😊', 'calm': '🌿', 'excited': '🔥', 'reflective': '🧘'};
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: emotions.entries.map((e) => Expanded(
        child: GestureDetector(
          onTap: () => onChanged(e.key),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected == e.key ? const Color(0xFF1A1A1A) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(e.value, style: TextStyle(fontSize: 22, color: selected == e.key ? Colors.white : Colors.black)),
            ),
          ),
        ),
      )).toList(),
    );
  }
}

class _AuthRequiredView extends StatelessWidget {
  const _AuthRequiredView();
  @override
  Widget build(BuildContext context) => Center(
    child: Text('// ACCESO_DENEGADO: AUTH_REQUIRED', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey)),
  );
}

class _EmptyDiaryView extends StatelessWidget {
  const _EmptyDiaryView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined, 
            size: 40, 
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'SIN_REGISTROS_ACTIVOS', 
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11, 
              color: Colors.grey.withValues(alpha: 0.3), 
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}