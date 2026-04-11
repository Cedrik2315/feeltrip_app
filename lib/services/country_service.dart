import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CountryService {
  static const String restCountriesApi = 'https://restcountries.com/v3.1';

  /// Get countries by continent or name
  static Future<List<Map<String, dynamic>>> getCountries({
    String? name,
    String? continent,
    int limit = 20,
  }) async {
    try {
      Uri uri;
      if (name != null) {
        uri = Uri.parse('$restCountriesApi/name/$name?fields=name,cca2,capital,flags,region');
      } else if (continent != null) {
        uri =
            Uri.parse('$restCountriesApi/region/$continent?fields=name,cca2,capital,flags,region');
      } else {
        uri = Uri.parse('$restCountriesApi/all?fields=name,cca2,capital,flags,region&limit=$limit');
      }

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        AppLogger.i('Loaded ${data.length} countries');
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Countries API error');
    } catch (e) {
      AppLogger.e('Countries error: $e');
      // Mock popular countries
      return [
        {
          'name': {'common': 'España'},
          'cca2': 'ES',
          'capital': ['Madrid'],
          'flags': {'png': 'https://flagcdn.com/es.svg'},
          'region': 'Europe',
        },
        {
          'name': {'common': 'México'},
          'cca2': 'MX',
          'capital': ['Ciudad de México'],
          'flags': {'png': 'https://flagcdn.com/mx.svg'},
          'region': 'Americas',
        },
        {
          'name': {'common': 'Argentina'},
          'cca2': 'AR',
          'capital': ['Buenos Aires'],
          'flags': {'png': 'https://flagcdn.com/ar.svg'},
          'region': 'Americas',
        },
      ];
    }
  }

  /// Get country details
  static Future<Map<String, dynamic>> getCountryInfo(String code) async {
    try {
      final response = await http.get(Uri.parse('$restCountriesApi/alpha/$code'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data[0] as Map<String, dynamic>;
      }
      throw Exception('Country not found');
    } catch (e) {
      AppLogger.e('Country details error: $e');
      return {
        'name': {'common': 'Unknown'},
        'cca2': code
      };
    }
  }

  /// Search countries
  static Future<List<Map<String, dynamic>>> searchCountries(String query) async {
    return getCountries(name: query);
  }
}
