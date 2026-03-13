import 'package:flutter/material.dart';
import '../services/affiliate_service.dart';

class AffiliateWidget extends StatelessWidget {
  final String destination;

  const AffiliateWidget({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final options = AffiliateService.getAffiliateOptions(destination);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🤝 Reserva tu viaje',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: Row(
              children: options.map((option) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => AffiliateService.openAffiliateLink(option.url),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: option.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            option.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          Text(
                            option.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '* Links de afiliado - FeelTrip recibe una comisión',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
