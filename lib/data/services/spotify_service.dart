import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify/spotify.dart' as sp;
import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';

class SpotifyService {
  final _logger = Logger();
  late final String _clientId;
  late final String _clientSecret;

  SpotifyService() {
    _clientId = dotenv.get('SPOTIFY_CLIENT_ID');
    _clientSecret = dotenv.get('SPOTIFY_CLIENT_SECRET');
  }

  /// Abre Spotify con una búsqueda o canción específica
  Future<void> openInSpotify(String trackName) async {
    try {
      final query = Uri.encodeComponent(trackName);
      final url = Uri.parse('spotify:search:$query');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // Backup: Abrir en navegador
        final webUrl = Uri.parse('https://open.spotify.com/search/$query');
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _logger.e('FT_SPOTIFY_ERROR: No se pudo abrir Spotify: $e');
    }
  }

  /// Obtiene la canción 'sugerida' según el momento (Simulación de canción actual)
  Future<String?> getCurrentTrack() async {
    // Sin SDK nativo, devolveremos un placeholder robusto.
    return 'Sincronizado con FeelTrip Soundtrack Network';
  }

  /// Busca canciones sugeridas para el arquetipo usando la API de Dart (Web)
  Future<List<String>> getSuggestedTracks(String archetype) async {
    try {
      final credentials = sp.SpotifyApiCredentials(_clientId, _clientSecret);
      final api = sp.SpotifyApi(credentials);
      
      String query = 'travel exploration';
      if (archetype == 'aventura') query = 'epic adventure rock';
      if (archetype == 'reflexion') query = 'meditation nature ambient';
      
      final search = await api.search.get(query, types: [sp.SearchType.track]).first(5);
      final tracks = <String>[];
      
      for (var pages in search) {
        if (pages.items != null) {
          for (var item in pages.items!) {
            final track = item as sp.Track;
            tracks.add('${track.name} - ${track.artists?.first.name}');
          }
        }
      }
      return tracks;
    } catch (e) {
      _logger.e('FT_SPOTIFY_ERROR: Error en búsqueda API: $e');
      return ['Exploration Theme - FeelTrip AI'];
    }
  }
}
