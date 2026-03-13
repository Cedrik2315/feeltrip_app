import '../config/app_flags.dart';
import '../core/result.dart';
import '../models/review_model.dart';
import '../models/trip_model.dart';
import '../services/api_service.dart';
import '../mock_data.dart';

class TripRepository {
  TripRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<Result<List<Trip>>> getTrips(
      {String? category, String? destination}) async {
    if (useMockData) {
      return Success(MockData.mockTrips);
    }
    return _apiService.getTrips(category: category, destination: destination);
  }

  Future<Result<Trip>> getTripById(String tripId) async {
    if (useMockData) {
      final trip = MockData.mockTrips.where((t) => t.id == tripId).firstOrNull;
      if (trip != null) {
        return Success(trip);
      }
      return Failure(Exception('Viaje no encontrado'));
    }
    return _apiService.getTripDetails(tripId);
  }

  Future<Result<List<Trip>>> getFeaturedTrips() async {
    final result = await getTrips();
    return result.fold(
      onFailure: (error, stackTrace) => Failure(error, stackTrace),
      onSuccess: (trips) {
        final featured = trips.where((t) => t.isFeatured).take(5).toList();
        return Success(featured);
      },
    );
  }

  Future<Result<List<Trip>>> searchTrips({
    String? query,
    String? category,
    String? difficulty,
    double? maxPrice,
  }) async {
    final normalizedQuery = (query ?? '').trim().toLowerCase();

    final result = await getTrips(category: category);

    return result.fold(
      onFailure: (error, stackTrace) => Failure(error, stackTrace),
      onSuccess: (trips) {
        final filtered = trips.where((trip) {
          final matchesQuery = normalizedQuery.isEmpty ||
              trip.title.toLowerCase().contains(normalizedQuery) ||
              trip.destination.toLowerCase().contains(normalizedQuery) ||
              trip.country.toLowerCase().contains(normalizedQuery);

          final matchesCategory = category == null ||
              category == 'Todos' ||
              trip.category.toLowerCase() == category.toLowerCase();

          final matchesDifficulty = difficulty == null ||
              difficulty == 'Todos' ||
              trip.difficulty.toLowerCase() == difficulty.toLowerCase();

          final matchesPrice = maxPrice == null || trip.price <= maxPrice;

          return matchesQuery &&
              matchesCategory &&
              matchesDifficulty &&
              matchesPrice;
        }).toList();
        return Success(filtered);
      },
    );
  }

  Future<Result<List<Review>>> getTripReviews(String tripId) async {
    if (useMockData) {
      return const Success([]);
    }
    return _apiService.getTripReviews(tripId);
  }

  Future<Result<bool>> addReview({
    required String tripId,
    required double rating,
    required String comment,
  }) async {
    if (useMockData) {
      return const Success(true);
    }
    return _apiService.addReview(
        tripId: tripId, rating: rating, comment: comment);
  }
}
