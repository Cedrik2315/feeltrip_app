import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../core/app_logger.dart';

class WeatherInfo {
  const WeatherInfo({
    required this.temperatureC,
    required this.description,
    required this.icon,
  });

  final double temperatureC;
  final String description;
  final String icon;
}

class CountryInfo {
  const CountryInfo({
    required this.languages,
    required this.currency,
    required this.capital,
    required this.flagEmoji,
    required this.region,
  });

  final List<String> languages;
  final String currency;
  final String capital;
  final String flagEmoji;
  final String region;
}

class CurrencyConversion {
  const CurrencyConversion({
    required this.convertedAmount,
    required this.exchangeRate,
  });

  final double convertedAmount;
  final double exchangeRate;
}

class NearbyRestaurant {
  const NearbyRestaurant({
    required this.name,
    required this.address,
    required this.category,
    this.rating,
  });

  final String name;
  final String address;
  final String category;
  final double? rating;
}

class DestinationService {
  static const Duration _timeout = Duration(seconds: 25);

  static String? _getKey(String keyName) {
    final value = dotenv.env[keyName]?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static String _safeBodySnippet(String body, {int maxChars = 400}) {
    if (body.length <= maxChars) return body;
    return '${body.substring(0, maxChars)}...';
  }

  static Future<Map<String, double>?> getCoordinates(String destination) async {
    try {
      final query = destination.trim();
      if (query.isEmpty) return null;

      final uri = Uri.parse('https://nominatim.openstreetmap.org/search')
          .replace(queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '1',
      });

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'FeelTrip/1.0',
        },
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        AppLogger.error(
            'Nominatim error ${response.statusCode}: ${_safeBodySnippet(response.body)}');
        return null;
      }

      final list = jsonDecode(response.body) as List<dynamic>;
      if (list.isEmpty) return null;

      final first = list.first as Map<String, dynamic>?;
      final latStr = first?['lat'] as String?;
      final lngStr = first?['lon'] as String?;

      if (latStr == null || lngStr == null) return null;

      final lat = double.tryParse(latStr);
      final lng = double.tryParse(lngStr);

      if (lat == null || lng == null) return null;

      return {
        'lat': lat,
        'lng': lng,
      };
    } catch (e, st) {
      AppLogger.error('Error en getCoordinates($destination)',
          error: e, stackTrace: st);
      return null;
    }
  }

  /// OpenWeatherMap
  static Future<WeatherInfo?> getWeather(String city) async {
    try {
      final apiKey = _getKey('OPENWEATHER_API_KEY');
      if (apiKey == null) {
        AppLogger.error('OPENWEATHER_API_KEY no configurada');
        return null;
      }

      final normalizedCity = city.trim();
      if (normalizedCity.isEmpty) return null;

      final uri =
          Uri.parse('https://api.openweathermap.org/data/2.5/weather').replace(
        queryParameters: {
          'q': normalizedCity,
          'appid': apiKey,
          'units': 'metric',
          'lang': 'es',
        },
      );

      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        AppLogger.error(
          'OpenWeatherMap error ${response.statusCode}: ${_safeBodySnippet(response.body)}',
        );
        return null;
      }

      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final main = (jsonBody['main'] as Map?) ?? const {};
      final weatherArr = (jsonBody['weather'] as List?) ?? const [];
      final first = weatherArr.isNotEmpty ? weatherArr.first as Map : const {};

      final temp = (main['temp'] as num?)?.toDouble();
      final description = (first['description'] as String?)?.trim() ?? '';
      final icon = (first['icon'] as String?)?.trim() ?? '';

      if (temp == null) return null;
      return WeatherInfo(
        temperatureC: temp,
        description: description,
        icon: icon,
      );
    } catch (e, st) {
      AppLogger.error('Error en getWeather($city)', error: e, stackTrace: st);
      return null;
    }
  }

  /// RestCountries
  static Future<CountryInfo?> getCountryInfo(String countryName) async {
    try {
      final name = countryName.trim();
      if (name.isEmpty) return null;

      final uri = Uri.parse(
              'https://restcountries.com/v3.1/name/${Uri.encodeComponent(name)}')
          .replace(queryParameters: {
        'fields': 'languages,currencies,capital,flag,region',
      });

      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        AppLogger.error(
          'RestCountries error ${response.statusCode}: ${_safeBodySnippet(response.body)}',
        );
        return null;
      }

      final list = jsonDecode(response.body) as List<dynamic>;
      if (list.isEmpty) return null;
      final data = list.first as Map<String, dynamic>;

      final languagesMap = (data['languages'] as Map?) ?? const {};
      final languages = languagesMap.values
          .whereType<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);

      final currencies = (data['currencies'] as Map?) ?? const {};
      String currencyLabel = '';
      if (currencies.isNotEmpty) {
        final firstCurrency = currencies.entries.first;
        final code = firstCurrency.key.toString();
        final info = firstCurrency.value as Map?;
        final currencyName = (info?['name'] as String?)?.trim() ?? '';
        final symbol = (info?['symbol'] as String?)?.trim() ?? '';
        currencyLabel = [
          if (code.isNotEmpty) code,
          if (currencyName.isNotEmpty) currencyName,
          if (symbol.isNotEmpty) '($symbol)',
        ].join(' ');
      }

      final capitalList = (data['capital'] as List?) ?? const [];
      final capital =
          capitalList.isNotEmpty ? (capitalList.first as String?) ?? '' : '';

      final flagEmoji = (data['flag'] as String?)?.trim() ?? '';
      final region = (data['region'] as String?)?.trim() ?? '';

      return CountryInfo(
        languages: languages,
        currency: currencyLabel,
        capital: capital,
        flagEmoji: flagEmoji,
        region: region,
      );
    } catch (e, st) {
      AppLogger.error(
        'Error en getCountryInfo($countryName)',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Exchange Rates
  static Future<CurrencyConversion?> convertCurrency(
    String from,
    String to,
    double amount,
  ) async {
    try {
      final apiKey = _getKey('EXCHANGE_RATE_API_KEY');
      if (apiKey == null) {
        AppLogger.error('EXCHANGE_RATE_API_KEY no configurada');
        return null;
      }

      final f = from.trim().toUpperCase();
      final t = to.trim().toUpperCase();
      if (f.isEmpty || t.isEmpty) return null;

      final uri = Uri.parse(
        'https://v6.exchangerate-api.com/v6/$apiKey/pair/$f/$t/$amount',
      );

      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        AppLogger.error(
          'ExchangeRate-API error ${response.statusCode}: ${_safeBodySnippet(response.body)}',
        );
        return null;
      }

      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final converted = (jsonBody['conversion_result'] as num?)?.toDouble();
      final rate = (jsonBody['conversion_rate'] as num?)?.toDouble();
      if (converted == null || rate == null) return null;

      return CurrencyConversion(convertedAmount: converted, exchangeRate: rate);
    } catch (e, st) {
      AppLogger.error(
        'Error en convertCurrency($from,$to,$amount)',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Unsplash
  static Future<List<String>> getDestinationPhotos(
    String destination, {
    int count = 5,
  }) async {
    try {
      final accessKey = _getKey('UNSPLASH_ACCESS_KEY');
      if (accessKey == null) {
        AppLogger.error('UNSPLASH_ACCESS_KEY no configurada');
        return const [];
      }

      final query = destination.trim();
      if (query.isEmpty) return const [];

      final safeCount = count.clamp(1, 30);
      final uri = Uri.parse('https://api.unsplash.com/search/photos').replace(
        queryParameters: {
          'query': query,
          'per_page': '$safeCount',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Client-ID $accessKey',
        },
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        AppLogger.error(
          'Unsplash error ${response.statusCode}: ${_safeBodySnippet(response.body)}',
        );
        return const [];
      }

      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final results = (jsonBody['results'] as List?) ?? const [];
      final urls = <String>[];

      for (final item in results) {
        final map = item as Map?;
        final urlsMap = (map?['urls'] as Map?) ?? const {};
        final url = (urlsMap['regular'] as String?) ??
            (urlsMap['small'] as String?) ??
            (urlsMap['thumb'] as String?);
        if (url != null && url.trim().isNotEmpty) {
          urls.add(url.trim());
        }
      }

      return urls;
    } catch (e, st) {
      AppLogger.error(
        'Error en getDestinationPhotos($destination)',
        error: e,
        stackTrace: st,
      );
      return const [];
    }
  }

  /// Foursquare (restaurantes)
  static Future<List<NearbyRestaurant>> getNearbyRestaurants(
    double lat,
    double lng, {
    String query = 'restaurant',
  }) async {
    try {
      final apiKey = _getKey('FOURSQUARE_API_KEY');
      if (apiKey == null) {
        AppLogger.error('FOURSQUARE_API_KEY no configurada');
        return const [];
      }

      final q = query.trim().isEmpty ? 'restaurant' : query.trim();
      final uri = Uri.parse('https://api.foursquare.com/v3/places/search')
          .replace(queryParameters: {
        'll': '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}',
        'categories': '13065',
        'limit': '10',
        'query': q,
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': apiKey,
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        AppLogger.error(
          'Foursquare error ${response.statusCode}: ${_safeBodySnippet(response.body)}',
        );
        return const [];
      }

      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final results = (jsonBody['results'] as List?) ?? const [];

      final restaurants = <NearbyRestaurant>[];
      for (final item in results) {
        final map = item as Map?;
        if (map == null) continue;

        final name = (map['name'] as String?)?.trim() ?? '';
        final location = (map['location'] as Map?) ?? const {};
        final formatted = (location['formatted_address'] as String?)?.trim();
        final address = formatted ??
            [
              location['address'],
              location['locality'],
              location['region'],
              location['country'],
            ]
                .whereType<String>()
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .join(', ');

        final categories = (map['categories'] as List?) ?? const [];
        final firstCategory =
            categories.isNotEmpty ? (categories.first as Map?) : null;
        final categoryName = (firstCategory?['name'] as String?)?.trim() ?? '';

        final rating = (map['rating'] as num?)?.toDouble();

        if (name.isEmpty) continue;
        restaurants.add(
          NearbyRestaurant(
            name: name,
            address: address,
            category: categoryName,
            rating: rating,
          ),
        );
      }

      return restaurants;
    } catch (e, st) {
      AppLogger.error(
        'Error en getNearbyRestaurants($lat,$lng)',
        error: e,
        stackTrace: st,
      );
      return const [];
    }
  }
}
