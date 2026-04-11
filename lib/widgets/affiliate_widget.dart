import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/affiliate_options_service.dart';
import '../services/analytics_service.dart';

class AffiliateWidget extends StatelessWidget {
  const AffiliateWidget({super.key, required this.destination});
  final String destination;

  @override
  Widget build(BuildContext context) {
    final options = AffiliateOptionsService.getAffiliateOptions(destination);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título con el sello visual de la app
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 18, color: Color(0xFFFF8F00)),
              const SizedBox(width: 8),
              Text(
                'LOGÍSTICA DE EXPEDICIÓN',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    AnalyticsService.logAffiliateClick(option.name, destination);
                    AffiliateOptionsService.openAffiliateLink(option.url);
                  },
                  borderRadius: BorderRadius.zero, // Estilo industrial
                  child: Container(
                    decoration: BoxDecoration(
                      color: option.color.withValues(alpha: 0.9),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Indicador visual sutil
                        PositionImage(
                          right: -5,
                          bottom: -5,
                          child: Text(option.emoji, 
                            style: TextStyle(fontSize: 24, color: Colors.white.withValues(alpha: 0.2))),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(option.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(
                                option.name.toUpperCase(),
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para el decorativo del emoji
class PositionImage extends StatelessWidget {
  final double? right, bottom;
  final Widget child;
  const PositionImage({this.right, this.bottom, required this.child});

  @override
  Widget build(BuildContext context) => Positioned(right: right, bottom: bottom, child: child);
}