import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DestinationCard extends StatelessWidget {
  const DestinationCard({
    required this.title,
    required this.destination,
    this.imageUrl,
    this.onTap,
    super.key,
  });

  final String title;
  final String destination;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveImageUrl = imageUrl ?? 'https://images.unsplash.com/photo-1518005020250-6859b2827c6d?q=80&w=600';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151515) : Colors.white,
        // Borde minimalista en lugar de elevación pronunciada
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con AspectRatio controlado
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    effectiveImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
                  ),
                  // Overlay sutil para el tag de ubicación
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: const Color(0xFFFF8F00),
                      child: Text(
                        'LAT: -32.88 / LON: -71.24', // Ejemplo de data técnica
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 8,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFFF8F00)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : Colors.grey[700],
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      // Indicador de "Sistema"
                      Text(
                        'ENTRY_ID: ${title.hashCode.toString().substring(0, 4)}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}