import 'package:feeltrip_app/services/country_service.dart';
import 'package:feeltrip_app/services/currency_service.dart';
import 'package:feeltrip_app/services/restaurant_service.dart';
import 'package:feeltrip_app/services/unsplash_service.dart';
import 'package:feeltrip_app/services/weather_service.dart';

/// Servicio fachada que coordina las llamadas a servicios externos especializados.
class DestinationService {
  static final _unsplashService = UnsplashService();
  static final _restaurantService = RestaurantService();
  static final _weatherService = WeatherService();

  /// Get current weather for a location (OpenWeatherMap)
  static Future<Map<String, dynamic>?> getWeather(
      double lat, double lng) async {
    return _weatherService.getWeather(lat, lng);
  }

  /// Get 5-period forecast for a city
  static Future<List<Map<String, dynamic>>> getForecast(String city) async {
    return _weatherService.getForecast(city);
  }

  /// Get country info: currency, flag, capital (RestCountries)
  static Future<Map<String, dynamic>> getCountryInfo(String countryName) async {
    final countries = await CountryService.searchCountries(countryName);
    if (countries.isNotEmpty) {
      final code = countries.first['cca2'] as String?;
      if (code != null) {
        // searchCountries returns partial data, getCountryInfo gets the full details
        return await CountryService.getCountryInfo(code);
      }
    }
    return {};
  }

  /// Convert currency amount (ExchangeRate-API)
  static Future<double> convertCurrency(
    String from,
    String to,
    double amount,
  ) async {
    final result = await CurrencyService.convertCurrency(
      from: from,
      to: to,
      amount: amount,
    );
    return result;
  }

  /// Get destination photos (Unsplash)
  static Future<List<String>> getDestinationPhotos(String destination) async {
    return _unsplashService.getDestinationPhotos(destination);
  }

  /// Get nearby restaurants (Foursquare)
  static Future<List<Map<String, dynamic>>> getNearbyRestaurants(
    double lat,
    double lng,
  ) async {
    return _restaurantService.getNearbyRestaurants(lat, lng);
  }

  /// Get destinations by archetype (Mock for OsintAiService)
  static Future<List<Map<String, dynamic>>> getDestinationsByArchetype({
    required String archetype,
  }) async {
    // Mock data for compatibility
    return [
      {'name': 'Bali'},
      {'name': 'Kyoto'},
      {'name': 'Tulum'},
    ];
  }
}
