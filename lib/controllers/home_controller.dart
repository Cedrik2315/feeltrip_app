import '../core/result.dart';
import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';

class HomeController {
  HomeController(this._tripRepository);

  final TripRepository _tripRepository;

  Future<Result<List<Trip>>> loadFeaturedTrips() async {
    return _tripRepository.getFeaturedTrips();
  }
}
