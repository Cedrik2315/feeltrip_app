import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// --- MODELO & PROVIDER (Simulados) ---
class Trip {
  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.description,
    required this.price,
    required this.duration,
    required this.rating,
    required this.imageUrl,
    this.difficulty = 'Moderada',
    this.maxGroupSize = 12,
  });
  final String id;
  final String title;
  final String destination;
  final String description;
  final double price;
  final int duration;
  final double rating;
  final String imageUrl;
  final String difficulty;
  final int maxGroupSize;
}

final tripDetailProvider = FutureProvider.family<Trip, String>((ref, id) async {
  await Future.delayed(const Duration(milliseconds: 800));
  return Trip(
    id: id,
    title: 'Aventura en el Cerro La Campana',
    destination: 'Olmué / Quillota',
    description: 'Explora la reserva de la biosfera en una caminata guiada por senderos rodeados de palmas chilenas milenarias. Una experiencia diseñada para desconectar de la ciudad y reconectar con la biodiversidad del valle central.',
    price: 45000.0,
    duration: 1,
    rating: 4.8,
    imageUrl: 'https://images.unsplash.com/photo-1596324268112-78a3c89d90d8?q=80&w=1200',
  );
});

// --- UI REFINADA ---
class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  bool _isFavorite = false;
  final Color brandColor = const Color(0xFF00695C); // Teal Naturaleza
  final Color accentColor = const Color(0xFFFF8F00); // Ámbar Tierra

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailProvider(widget.tripId));

    return tripAsync.when(
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator(color: brandColor))),
      error: (error, _) => _buildErrorState(),
      data: (trip) => Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(trip),
            SliverToBoxAdapter(child: _buildBody(trip)),
          ],
        ),
        bottomNavigationBar: _buildBookingBar(trip),
      ),
    );
  }

  Widget _buildSliverAppBar(Trip trip) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      stretch: true,
      backgroundColor: brandColor,
      leading: _buildCircleButton(Icons.arrow_back, () => Navigator.pop(context)),
      actions: [
        _buildCircleButton(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          () => setState(() => _isFavorite = !_isFavorite),
          iconColor: _isFavorite ? Colors.redAccent : Colors.white,
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(trip.imageUrl, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black45, Colors.transparent, Colors.black87],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(20)),
                    child: Text('RECOMENDADO', style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Text(trip.title, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {Color iconColor = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: Colors.black26,
        child: IconButton(icon: Icon(icon, color: iconColor, size: 20), onPressed: onTap),
      ),
    );
  }

  Widget _buildBody(Trip trip) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: accentColor),
                const SizedBox(width: 4),
                Text(trip.destination.toUpperCase(), style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                const Spacer(),
                _buildRatingBadge(trip.rating),
              ],
            ),
            const SizedBox(height: 32),
            _buildQuickStats(trip),
            const SizedBox(height: 32),
            Text('La Experiencia', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(trip.description, style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800])),
            const SizedBox(height: 32),
            _buildMapPreview(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(Trip trip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statItem(Icons.timer_outlined, '${trip.duration} DÍA'),
        _statItem(Icons.terrain_outlined, trip.difficulty),
        _statItem(Icons.group_outlined, 'MÁX ${trip.maxGroupSize}'),
      ],
    );
  }

  Widget _statItem(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(backgroundColor: brandColor.withValues(alpha: 0.1), child: Icon(icon, color: brandColor, size: 20)),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
      ],
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Row(
      children: [
        Icon(Icons.star, color: accentColor, size: 18),
        const SizedBox(width: 4),
        Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(' (42 reseñas)', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Widget _buildMapPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Punto de Encuentro', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=-32.99,-71.18&zoom=13&size=600x300&key=YOUR_KEY_STUB'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(child: Icon(Icons.location_pin, color: brandColor, size: 40)),
        ),
      ],
    );
  }

  Widget _buildBookingBar(Trip trip) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey)),
              Text('\$${trip.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                // Lógica de Checkout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('RESERVAR AHORA', style: GoogleFonts.jetBrainsMono(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      body: Center(
        child: Text('No pudimos conectar con la montaña.', style: GoogleFonts.playfairDisplay(fontSize: 18)),
      ),
    );
  }
}