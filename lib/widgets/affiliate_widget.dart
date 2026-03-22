import 'package:flutter/material.dart';
import '../services/affiliate_options_service.dart';
import '../services/analytics_service.dart';

class AffiliateWidget extends StatelessWidget {
  const AffiliateWidget({super.key, required this.destination});
  final String destination;

  @override
  Widget build(BuildContext context) {
    final options = AffiliateOptionsService.getAffiliateOptions(destination);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reserva tu viaje',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.5,
            children: options
                .map((option) => GestureDetector(
                      onTap: () {
                        AnalyticsService.logAffiliateClick(
                            option.name, destination);
                        AffiliateOptionsService.openAffiliateLink(option.url);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: option.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(option.emoji,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text(option.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
