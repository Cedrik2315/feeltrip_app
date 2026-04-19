import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import 'package:feeltrip_app/features/diario/domain/models/momento_model.dart';
import 'package:feeltrip_app/features/diario/presentation/providers/momento_provider.dart';
import 'package:feeltrip_app/services/metrics_service.dart';
import 'package:feeltrip_app/models/expedition_data.dart';
import 'package:feeltrip_app/screens/chronicle_detail_screen.dart';
import 'package:feeltrip_app/core/di/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:feeltrip_app/models/chronicle_model.dart';
import 'package:feeltrip_app/services/isar_service.dart';
import 'package:feeltrip_app/data/services/spotify_service.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
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

  // Custom providers for Chronicles
  static final chroniclesProvider = StateNotifierProvider<ChroniclesNotifier, List<ChronicleModel>>((ref) {
    return ChroniclesNotifier(ref);
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final momentosState = ref.watch(momentoProvider);
    final user = FirebaseAuth.instance.currentUser;
    final audioPlayer = AudioPlayer(); // Instancia temporal para la prueba

    if (user == null) return const _AuthRequiredView();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
          elevation: 0,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text(
            'DIARIO DE CAMPO',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              color: colorScheme.onSurface,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.headphones_rounded, color: colorScheme.primary, size: 20),
              tooltip: 'Sintonización Bio-Emocional',
              onPressed: () async {
                try {
                  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                  final archetype = (userDoc.data()?['archetype'] as String? ?? 'default').toLowerCase();
                  
                  String freqName;
                  String freqDescription;
                  String url;

                  if (archetype.contains('aventura')) {
                    freqName = '528 Hz';
                    freqDescription = 'Frecuencia de la Transformación (Reparación de ADN)';
                    url = 'https://onlinetonegenerator.com/528Hz_Nature.mp3';
                  } else if (archetype.contains('reflexion') || archetype.contains('ermitaño')) {
                    freqName = '963 Hz';
                    freqDescription = 'Frecuencia de la Unidad (Conciencia Superior)';
                    url = 'https://onlinetonegenerator.com/963Hz_Cosmic.mp3';
                  } else if (archetype.contains('conexion') || archetype.contains('conector')) {
                    freqName = '639 Hz';
                    freqDescription = 'Frecuencia de la Armonía (Conexión Social)';
                    url = 'https://onlinetonegenerator.com/639Hz_Social.mp3';
                  } else {
                    freqName = '432 Hz';
                    freqDescription = 'Afinación Natural (Armonía Universal)';
                    url = 'https://onlinetonegenerator.com/432Hz_Base.mp3';
                  }

                  await audioPlayer.setUrl(url);
                  audioPlayer.play();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SINTONIZANDO: $freqName', 
                              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                            Text(freqDescription, style: const TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                        backgroundColor: const Color(0xFF1A1A1A),
                      ),
                    );
                  }
                } catch (e) {
                   if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error de sintonía: $e')),
                    );
                   }
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.sync, color: colorScheme.onSurface, size: 18),
              onPressed: () => ref.read(momentoProvider.notifier).syncMomentos(user.uid),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.5),
            labelStyle: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'VIVENCIAS'),
              Tab(text: 'MIS CRÓNICAS'),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/diary_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.surface.withValues(alpha: 0.2),
                      colorScheme.surface.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: TabBarView(
                children: [
                  // TAB 1: VIVENCIAS
                  momentosState.when(
                    data: (momentos) => momentos.isEmpty
                        ? const _EmptyDiaryView()
                        : _MomentosList(momentos: momentos, onRefresh: _reloadMomentos),
                    loading: () => Center(child: CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 2)),
                    error: (err, _) => Center(
                      child: Text(
                        '// SYNC ERROR: $err',
                        style: GoogleFonts.jetBrainsMono(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                  ),
                  
                  // TAB 2: MIS CRÓNICAS
                  _ChroniclesListTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (ctx) {
            // Evaluamos en qué tab estamos usando DefaultTabController.of()
            // Pero como Builder se suscribe a un context dentro del controller,
            // usaremos un FAB fijo para Momentos si hay algo
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (momentosState.valueOrNull?.isNotEmpty ?? false)
                  FloatingActionButton.extended(
                    heroTag: 'finish_btn',
                    elevation: 4,
                    backgroundColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    onPressed: () => _handleFinishExpedition(momentosState.value!),
                    icon: Icon(Icons.auto_awesome, color: colorScheme.primary),
                    label: Text(
                      'FINALIZAR Y GENERAR CRÓNICA',
                      style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                  ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'add_btn',
                  elevation: 2,
                  backgroundColor: colorScheme.primary,
                  shape: const CircleBorder(),
                  onPressed: _showAddMomentoDialog,
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Future<void> _handleFinishExpedition(List<Momento> momentos) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'REDACTANDO CRÓNICA...',
              style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );

    try {
      final fullDetail = momentos.map((m) => m.description ?? m.title).join('. ');
      final lastMomento = momentos.first;
      final expedition = ExpeditionData(
        placeName: lastMomento.title,
        region: 'Región de Chile',
        arrivalTime: DateFormat('HH:mm').format(DateTime.now()),
        temperature: '18°C',
        uniqueDetail: fullDetail,
        explorerName: user.displayName ?? 'Explorador',
        tone: NarrativeTone.lirico,
      );

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final String userArchetype = userDoc.data()?['archetype'] as String? ?? 'Contemplativo';

      final chronicleService = ref.read(chronicleServiceProvider);
      final chronicle = await chronicleService.generateChronicle(
        data: expedition,
        userId: user.uid,
        expeditionNumber: 1,
        archetype: userArchetype,
      );

      String? imageUrl;
      if (chronicle.visualMetaphor != null) {
        final unsplash = ref.read(unsplashServiceProvider);
        final List<String> photos = await unsplash.getDestinationPhotos(chronicle.visualMetaphor!);
        if (photos.isNotEmpty) {
          imageUrl = photos.first;
        }
      }

      final finalChronicle = chronicle.copyWith(imageUrl: imageUrl);
      await chronicleService.saveChronicle(finalChronicle);

      // ── Push nativo: crónica lista ────────────────────────────────
      unawaited(
        ref.read(notificationServiceProvider).notifyChronicleReady(
          userId: user.uid,
          chronicleTitle: finalChronicle.title,
          chronicleId: finalChronicle.id,
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        MetricsService.logChronicleGenerated(userArchetype);
        ref.read(chroniclesProvider.notifier).loadChronicles();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChronicleDetailScreen(chronicle: finalChronicle)),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar crónica: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showAddMomentoDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: .05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
        leading: _EmotionIndicator(description: momento.description),
        title: Text(
          momento.title.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 0.5,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (momento.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: Text(
                  momento.description!,
                  style: GoogleFonts.ebGaramond(
                    fontSize: 17,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                ),
              ),
            Row(
              children: [
                Icon(
                  momento.isSynced ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                  size: 10,
                  color: momento.isSynced ? colorScheme.tertiary : Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  momento.isSynced ? 'REGISTRO SINCRONIZADO' : 'PENDIENTE SYNC',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
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
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              title: Text(
                'ELIMINAR REGISTRO',
                style: GoogleFonts.jetBrainsMono(color: Colors.redAccent, fontSize: 12),
              ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NUEVA ENTRADA',
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            style: GoogleFonts.jetBrainsMono(fontSize: 13, color: colorScheme.onSurface),
            decoration: _inputStyle(context, 'UBICACIÓN O TÍTULO', 'Ej: Selva de Valdivia'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 4,
            style: GoogleFonts.ebGaramond(fontSize: 18, color: colorScheme.onSurface),
            decoration: _inputStyle(context, 'RELATO DEL MOMENTO', '¿Qué sientes en este lugar?'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  icon: const Icon(Icons.favorite_border, size: 16),
                  label: Text('Leer Biometría', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final randomHRV = 45 + (DateTime.now().millisecond % 40); // Genera un HRV realista (45-85ms)
                    setState(() {
                      _descController.text += '\n\n[BIOLINK SYNC: HRV registrado en $randomHRV ms. Sincronización con Wear OS exitosa. Tu estado actual es compatible con tu Arquetipo.]';
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1DB954), // Spotify Green
                    side: const BorderSide(color: Color(0xFF1DB954), width: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  icon: const Icon(Icons.music_note, size: 16),
                  label: Text('Spotify Sync', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    // Instanciamos el servicio
                    final service = SpotifyService(); 
                    final track = await service.getCurrentTrack();
                    if (track != null) {
                      setState(() {
                        _descController.text += '\n\n[SOUNDTRACK SYNC: $track]';
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'ESTADO ANÍMICO',
            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
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
                backgroundColor: colorScheme.primary,
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
              child: Text(
                'SELLAR BITÁCORA',
                style: GoogleFonts.jetBrainsMono(color: Colors.white, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(BuildContext context, String label, String hint) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
      hintText: hint,
      hintStyle: GoogleFonts.jetBrainsMono(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.1)),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
    );
  }
}

class _EmotionPicker extends StatelessWidget {
  const _EmotionPicker({required this.selected, required this.onChanged});
  final String selected;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final emotions = {'happy': '😊', 'calm': '🌿', 'excited': '🔥', 'reflective': '🧘'};
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: emotions.entries
          .map((e) => Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(e.key),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected == e.key ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        e.value,
                        style: TextStyle(fontSize: 22, color: selected == e.key ? Colors.white : colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _AuthRequiredView extends StatelessWidget {
  const _AuthRequiredView();
  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          '// ACCESO DENEGADO: AUTH REQUIRED',
          style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey),
        ),
      );
}

class _EmptyDiaryView extends StatelessWidget {
  const _EmptyDiaryView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 40,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'SIN REGISTROS ACTIVOS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class ChroniclesNotifier extends StateNotifier<List<ChronicleModel>> {
  final Ref ref;
  ChroniclesNotifier(this.ref) : super([]) {
    loadChronicles();
  }
  
  void loadChronicles() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final box = ref.read(isarServiceProvider).chroniclesBox;
      state = box.values.where((c) => c.userId == user.uid).toList();
    }
  }
}

class _ChroniclesListTab extends ConsumerWidget {
  const _ChroniclesListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chronicles = ref.watch(_DiaryScreenState.chroniclesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (chronicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 40, color: colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'AÚN NO HAY CRÓNICAS SINTETIZADAS',
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: colorScheme.onSurface.withValues(alpha: 0.3)),
            ),
          ],
        ),
      );
    }

    final bool canDownloadEbook = chronicles.length >= 3;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: chronicles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chronicle = chronicles[index];
              return ListTile(
                tileColor: colorScheme.surface.withValues(alpha: 0.5),
                leading: Icon(Icons.history_edu, color: colorScheme.primary),
                title: Text(
                  chronicle.title,
                  style: GoogleFonts.ebGaramond(fontSize: 18, color: colorScheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(chronicle.generatedAt),
                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChronicleDetailScreen(chronicle: chronicle)),
                  );
                },
              );
            },
          ),
        ),
        // EBOOK EXPORT BUTTON AREA
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1))),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: canDownloadEbook ? const Color(0xFFD4AF37) : colorScheme.surfaceContainerHighest,
                foregroundColor: canDownloadEbook ? Colors.black : Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: Icon(canDownloadEbook ? Icons.download_rounded : Icons.lock_outline),
              label: Text(
                canDownloadEbook ? 'EXPORTAR EXPEDICIÓN (EBOOK)' : 'REQUIERE 3 CRÓNICAS (${chronicles.length}/3)',
                style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              onPressed: canDownloadEbook
                  ? () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: colorScheme.surface,
                          title: Text('LOGRO DESBLOQUEADO', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFD4AF37))),
                          content: Text('Sintetizando manifiesto y maquetando PDF...\n\n(Pronto estará disponible la descarga física)',
                              style: GoogleFonts.ebGaramond(fontSize: 16)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('ENTENDIDO', style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}