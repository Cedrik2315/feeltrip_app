import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../core/result.dart';
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
  ApiService({http.Client? client})
      : _client = client ?? AuthTokenClient(http.Client());

  static const String _defaultBaseUrl = 'https://api.feeltrip.com/api';
  static const String _defaultCheckoutBaseUrl =
      'https://us-east1-feeltrip-app.cloudfunctions.net';
  static String get baseUrl {
    final fromEnv = dotenv.env['API_BASE_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return _defaultBaseUrl;
  }
  static String get checkoutBaseUrl {
    final fromEnv = dotenv.env['CHECKOUT_API_BASE_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return _defaultCheckoutBaseUrl;
  }
  static const Duration timeout = Duration(seconds: 30);

  final http.Client _client;

  Future<Result<List<Trip>>> getTrips({String? category, String? destination}) async {
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
        return Success(data.map((trip) => Trip.fromJson(trip)).toList());
      }
      return Failure(
        Exception('Error al obtener viajes: ${response.statusCode}'),
      );
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<Trip>> getTripDetails(String tripId) async {
    try {
      final uri = Uri.parse('$baseUrl/trips/$tripId');
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['trip'];
        return Success(Trip.fromJson(data));
      }
      return Failure(
        Exception('Error al obtener detalles: ${response.statusCode}'),
      );
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<List<Review>>> getTripReviews(String tripId) async {
    try {
      final uri = Uri.parse('$baseUrl/trips/$tripId/reviews');
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['reviews'];
        return Success(data.map((review) => Review.fromJson(review)).toList());
      }
      return Failure(
        Exception('Error al obtener reseñas: ${response.statusCode}'),
      );
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<Booking>> createBooking({
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
        return Success(Booking.fromJson(data));
      }
      return Failure(
        Exception('Error al crear reserva: ${response.statusCode}'),
      );
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<List<Booking>>> getUserBookings(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/bookings');
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['bookings'];
        return Success(data.map((booking) => Booking.fromJson(booking)).toList());
      }
      return Failure(
        Exception('Error al obtener reservas: ${response.statusCode}'),
      );
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<bool>> cancelBooking(String bookingId) async {
    try {
      final uri = Uri.parse('$baseUrl/bookings/$bookingId/cancel');
      final response = await _client.post(uri).timeout(timeout);

      if (response.statusCode == 200) {
        return const Success(true);
      }
      return Failure(
        Exception('Error al cancelar: ${response.statusCode}'),
      );
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<bool>> addReview({
    required String tripId,
    required double rating,
    required String comment,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/trips/$tripId/reviews');
      final body = {
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
        return const Success(true);
      }
      return Failure(
        Exception('Error al añadir reseña: ${response.statusCode}'),
      );
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<bool>> toggleFavorite(String userId, String tripId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/favorites/$tripId');
      final response = await _client.post(uri).timeout(timeout);

      if (response.statusCode == 200) {
        return const Success(true);
      }
      return Failure(
        Exception('Error al actualizar favoritos: ${response.statusCode}'),
      );
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<List<Trip>>> getFavoritedTrips(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/favorites');
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['trips'];
        return Success(data.map((trip) => Trip.fromJson(trip)).toList());
      }
      return Failure(
        Exception('Error al obtener favoritos: ${response.statusCode}'),
      );
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<bool>> processPayment({
    required String productId,
    required int quantity,
    required String currency,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/payments');
      final body = {
        'productId': productId,
        'quantity': quantity,
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
        return const Success(true);
      }
      return Failure(
        Exception('Error al procesar pago: ${response.statusCode}'),
      );
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<Map<String, dynamic>>> createCheckoutSession({
    required List<Map<String, dynamic>> items,
    required String currency,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final uri = Uri.parse('$checkoutBaseUrl/createCheckoutSession');
      final body = <String, dynamic>{
        'items': items,
        'currency': currency,
      };
      if (successUrl != null && successUrl.trim().isNotEmpty) {
        body['successUrl'] = successUrl.trim();
      }
      if (cancelUrl != null && cancelUrl.trim().isNotEmpty) {
        body['cancelUrl'] = cancelUrl.trim();
      }

      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return Success(decoded);
        }
        return Failure(Exception('Respuesta de checkout invalida'));
      }
      return Failure(
        Exception('Error al crear checkout: ${response.statusCode}'),
      );
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<Result<Map<String, dynamic>>> getCheckoutOrderStatus(String orderId) async {
    try {
      final uri = Uri.parse(
        '$checkoutBaseUrl/getCheckoutOrderStatus?orderId=${Uri.encodeQueryComponent(orderId)}',
      );

      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return Success(decoded);
        }
        return Failure(Exception('Respuesta de estado invalida'));
      }
      return Failure(
        Exception('Error consultando orden: ${response.statusCode}'),
      );
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  void dispose() {
    _client.close();
  }
}
