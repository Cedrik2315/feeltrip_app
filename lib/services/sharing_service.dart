import 'package:share_plus/share_plus.dart';

import 'package:feeltrip_app/models/travel_agency_model.dart';
import 'package:feeltrip_app/services/metrics_service.dart';

class SharingService {
  static Future<void> shareMomento(String content, String imageUrl) async {
    MetricsService.logShare('momento');
    final shareText = [content, if (imageUrl.isNotEmpty) imageUrl].join('\n\n');
    await Share.share(shareText);
  }

  static Future<void> shareAgency(TravelAgency agency) async {
    MetricsService.logShare('agency');

    final shareText = '''
${agency.name}
${agency.city}, ${agency.country}

"${agency.description}"

Rating: ${agency.rating.toStringAsFixed(1)}
Followers: ${agency.followers}
${agency.website}

Descubre experiencias unicas con ${agency.name}. #FeelTrip #TravelAgency
''';

    await Share.share(shareText);
  }
}
