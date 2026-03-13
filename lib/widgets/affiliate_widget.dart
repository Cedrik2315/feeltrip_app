import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../services/affiliate_service.dart';

class AffiliateWidget extends StatelessWidget {
  final String destination;

  const AffiliateWidget({Key? key, required this.destination})
      : super(key: key);

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
            height: 160, // Adjusted for 2 rows
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: options.map((option) {
                return GestureDetector(
                  onTap: () {
                    AnalyticsService.logAffiliateClick(
                        option.name, destination);
                    AffiliateService.openAffiliateLink(option.url);
                  },
                  child: Container(
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
