import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class TravelProviderOption {
  final String id;
  final String label;

  const TravelProviderOption({
    required this.id,
    required this.label,
  });
}

class TravelService {
  static const TravelProviderOption airbnb = TravelProviderOption(
    id: 'airbnb',
    label: 'Airbnb',
  );
  static const TravelProviderOption booking = TravelProviderOption(
    id: 'booking',
    label: 'Booking.com',
  );
  static const TravelProviderOption getYourGuide = TravelProviderOption(
    id: 'getyourguide',
    label: 'GetYourGuide',
  );
  static const TravelProviderOption viator = TravelProviderOption(
    id: 'viator',
    label: 'Viator',
  );

  static const List<TravelProviderOption> supportedProviders =
      <TravelProviderOption>[
    airbnb,
    booking,
    getYourGuide,
    viator,
  ];

  Future<void> openProvider({
    required String providerId,
    required String destination,
  }) async {
    final url = buildProviderUri(
      providerId: providerId,
      destination: destination,
    );
    await _openExternal(url);
  }

  Uri buildProviderUri({
    required String providerId,
    required String destination,
  }) {
    return _buildProviderUrl(
      providerId: providerId,
      destination: destination,
    );
  }

  Future<void> buscarEnAirbnb(String destino) async {
    final query = Uri.encodeComponent(destino);
    final url = Uri.parse('https://www.airbnb.com/s/$query/homes');
    await _openExternal(url);
  }

  Uri _buildProviderUrl({
    required String providerId,
    required String destination,
  }) {
    final query = Uri.encodeComponent(destination.trim());
    final normalized = providerId.trim().toLowerCase();

    if (normalized == booking.id) {
      final aid =
          (dotenv.env['BOOKING_AID'] ?? dotenv.env['AWIN_PUBLISHER_ID'] ?? '')
              .trim();
      final aidParam = aid.isEmpty ? '' : '&aid=$aid';
      return Uri.parse(
        'https://www.booking.com/searchresults.html?ss=$query$aidParam',
      );
    }

    if (normalized == getYourGuide.id) {
      final partnerId = (dotenv.env['GETYOURGUIDE_PARTNER_ID'] ?? '').trim();
      final partnerParam = partnerId.isEmpty ? '' : '&partner_id=$partnerId';
      return Uri.parse(
        'https://www.getyourguide.com/s/?q=$query$partnerParam',
      );
    }

    if (normalized == viator.id) {
      final partnerId = (dotenv.env['VIATOR_PARTNER_ID'] ?? '').trim();
      final partnerParam = partnerId.isEmpty ? '' : '&pid=$partnerId';
      return Uri.parse(
        'https://www.viator.com/searchResults/all?text=$query$partnerParam',
      );
    }

    return Uri.parse('https://www.airbnb.com/s/$query/homes');
  }

  Future<void> _openExternal(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return;
    }
    throw Exception('No se pudo abrir el proveedor seleccionado');
  }
}
