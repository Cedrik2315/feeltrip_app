import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/booking_model.dart';
import '../models/review_model.dart';
import '../models/trip_model.dart';

class AuthTokenClient extends http.BaseClient {
  AuthTokenClient(
    this._inner, {
    Future<String?> Function()? tokenProvider,
  }) : _tokenProvider = tokenProvider ?? _defaultTokenProvider;

  final http.Client _inner;
  final Future<String?> Function() _tokenProvider;

  static Future<String?> _defaultTokenProvider() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _tokenProvider();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? AuthTokenClient(http.Client());

  static const String baseUrl = 'https://api.feeltrip.com/api';
  static const Duration timeout = Duration(seconds: 30);

  final http.Client _client;

  Future<List<Trip>> getTrips({String? category, String? destination}) async {
    try {
      final params = <String, String>{};
      if (category != null) params['category'] = category;
      if (destination != null) params['destination'] = destination;

      final uri = Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}/trips',
        queryParameters: params.isNotEmpty ? params : null,
      );

      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['trips'];
        return data.map((trip) => Trip.fromJson(trip)).toList();
      }
      throw Exception('Error al obtener viajes: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Trip> getTripDetails(String tripId) async {
    try {
      final uri = Uri.parse('$baseUrl/trips/$tripId');
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['trip'];
        return Trip.fromJson(data);
      }
      throw Exception('Error al obtener detalles: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Review>> getTripReviews(String tripId) async {
    try {
      final uri = Uri.parse('$baseUrl/trips/$tripId/reviews');
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['reviews'];
        return data.map((review) => Review.fromJson(review)).toList();
      }
      throw Exception('Error al obtener reseñas: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Booking> createBooking({
    required String userId,
    required String tripId,
    required int numberOfPeople,
    required List<String> passengers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/bookings');
      final body = {
        'userId': userId,
        'tripId': tripId,
        'numberOfPeople': numberOfPeople,
        'passengers': passengers,
        'bookingDate': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 201) {
        final data = json.decode(response.body)['booking'];
        return Booking.fromJson(data);
      }
      throw Exception('Error al crear reserva: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/bookings');
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['bookings'];
        return data.map((booking) => Booking.fromJson(booking)).toList();
      }
      throw Exception('Error al obtener reservas: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      final uri = Uri.parse('$baseUrl/bookings/$bookingId/cancel');
      final response = await _client.post(uri).timeout(timeout);

      if (response.statusCode == 200) {
        return true;
      }
      throw Exception('Error al cancelar: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> addReview({
    required String tripId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/trips/$tripId/reviews');
      final body = {
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 201) {
        return true;
      }
      throw Exception('Error al añadir reseña: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> toggleFavorite(String userId, String tripId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/favorites/$tripId');
      final response = await _client.post(uri).timeout(timeout);

      if (response.statusCode == 200) {
        return true;
      }
      throw Exception('Error al actualizar favoritos: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Trip>> getFavoritedTrips(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/favorites');
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['trips'];
        return data.map((trip) => Trip.fromJson(trip)).toList();
      }
      throw Exception('Error al obtener favoritos: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> processPayment({
    required String userId,
    required double amount,
    required String currency,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/payments');
      final body = {
        'userId': userId,
        'amount': amount,
        'currency': currency,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return true;
      }
      throw Exception('Error al procesar pago: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}

