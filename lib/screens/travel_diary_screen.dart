import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// --- MODELO OPTIMIZADO ---
class DiaryEntry {
  DiaryEntry({
    required this.id, 
    required this.date, 
    required this.content, 
    required this.location, 
    this.imageUrl
  });
  final String id;
  final DateTime date;
  final String content;
  final String location;
  final String? imageUrl;
}

// --- NOTIFIER PARA MANEJO DE ESTADO REAL ---
class DiaryNotifier extends StateNotifier<List<DiaryEntry>> {
  DiaryNotifier() : super([
    DiaryEntry(
      id: '1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      content: 'Increíble tarde en el Parque Nacional La Campana. El aire puro y la vista de las palmas chilenas me renovaron.',
      location: 'Olmué, Valparaíso',
      imageUrl: 'https://images.unsplash.com/photo-1580137197581-df2bb346a786',
    ),
  ]);

  void addEntry(String content, String location) {
    final newEntry = DiaryEntry(
      id: DateTime.now().toString(),
      date: DateTime.now(),
      content: content,
      location: location,
    );
    state = [newEntry, ...state];
  }
}

final diaryProvider = StateNotifierProvider<DiaryNotifier, List<DiaryEntry>>((ref) {
  return DiaryNotifier();
});

// --- UI OPTIMIZADA ---
class TravelDiaryScreen extends ConsumerStatefulWidget {
  const TravelDiaryScreen({super.key});

  @override
  ConsumerState<TravelDiaryScreen> createState() => _TravelDiaryScreenState();
}

class _TravelDiaryScreenState extends ConsumerState<TravelDiaryScreen> {
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(diaryProvider);
    const themeColor = Color(0xFF004D40); // Teal corporativo FeelTrip

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('MI BITÁCORA', 
          style: GoogleFonts.jetBrainsMono(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: themeColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: entries.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: entries.length,
              itemBuilder: (context, index) => _buildTimelineEntry(entries[index], themeColor),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntrySheet(context, themeColor),
        backgroundColor: themeColor,
        icon: const Icon(Icons.history_edu, color: Colors.white),
        label: Text('NUEVO RELATO', style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 80, color: Colors.teal.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text('Tu bitácora está esperando historias...', 
            style: GoogleFonts.playfairDisplay(color: Colors.grey, fontSize: 16, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildTimelineEntry(DiaryEntry entry, Color color) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline visual con gradiente sutil
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color, 
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4)],
                ),
              ),
              Expanded(
                child: Container(
                  width: 2, 
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0.05)],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Contenido de la Bitácora
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.imageUrl != null)
                      Image.network(entry.imageUrl!, height: 160, width: double.infinity, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                                style: GoogleFonts.jetBrainsMono(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 12, color: color.withValues(alpha: 0.5)),
                              const SizedBox(width: 4),
                              Text(entry.location.toUpperCase(), 
                                style: GoogleFonts.jetBrainsMono(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            entry.content,
                            style: GoogleFonts.playfairDisplay(fontSize: 16, height: 1.5, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEntrySheet(BuildContext context, Color color) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('NUEVA VIVENCIA', 
              style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 24),
            TextField(
              controller: _locationController,
              style: GoogleFonts.jetBrainsMono(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Ubicación',
                prefixIcon: Icon(Icons.near_me, color: color, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              style: GoogleFonts.playfairDisplay(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Relata lo que has descubierto...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_contentController.text.isNotEmpty) {
                  ref.read(diaryProvider.notifier).addEntry(
                    _contentController.text, 
                    _locationController.text
                  );
                  _contentController.clear();
                  _locationController.clear();
                  Navigator.pop(context);
                  HapticFeedback.mediumImpact();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color, 
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text('GUARDAR EN BITÁCORA', 
                style: GoogleFonts.jetBrainsMono(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}