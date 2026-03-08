import 'package:firebase_auth/firebase_auth.dart';

import '../config/app_flags.dart';
import '../core/result.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';
import '../mock_data.dart';

class BookingRepository {
  BookingRepository({
    ApiService? apiService,
    FirebaseAuth? auth,
  })  : _apiService = apiService ?? ApiService(),
        _auth = auth ?? FirebaseAuth.instance;

  final ApiService _apiService;
  final FirebaseAuth _auth;

  String? get _userId => _auth.currentUser?.uid;

  Future<Result<List<Booking>>> getUserBookings() async {
    final uid = _userId;
    
    if (useMockData) {
      return Success(MockData.mockBookings);
    }

    if (uid == null || uid.isEmpty) {
      return const Success([]);
    }

    return _apiService.getUserBookings(uid);
  }

  Future<Result<Booking>> createBooking({
    required String tripId,
    required int numberOfPeople,
    required List<String> passengers,
  }) async {
    final uid = _userId;

    if (uid == null || uid.isEmpty) {
      return Failure(Exception('Debes iniciar sesión para reservar'));
    }

    if (useMockData) {
      final mockBooking = Booking(
        id: 'mock_booking_${DateTime.now().millisecondsSinceEpoch}',
        tripId: tripId,
        userId: uid,
        tripTitle: 'Viaje Mock',
        numberOfPeople: numberOfPeople,
        totalPrice: 0,
        status: 'pending',
        bookingDate: DateTime.now(),
        startDate: DateTime.now(),
        passengers: passengers,
      );
      return Success(mockBooking);
    }

    return _apiService.createBooking(
      userId: uid,
      tripId: tripId,
      numberOfPeople: numberOfPeople,
      passengers: passengers,
    );
  }

  Future<Result<bool>> cancelBooking(String bookingId) async {
    if (useMockData) {
      return const Success(true);
    }
    return _apiService.cancelBooking(bookingId);
  }

  Future<Result<List<Map<String, dynamic>>>> getBookingIntents() async {
    if (useMockData) {
      return const Success([]);
    }

    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      return const Success([]);
    }

    return Failure(Exception('No implementado en API'));
  }
}
