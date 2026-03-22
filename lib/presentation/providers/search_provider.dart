import '../../../shared/models/trip_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripService {
  Future<List<Trip>> searchTrips(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return <Trip>[];
  }
}

final tripServiceProvider = Provider<TripService>((ref) {
  return TripService();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final debouncedSearchProvider =
    FutureProvider.autoDispose<List<Trip>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return <Trip>[];
  await Future<void>.delayed(const Duration(milliseconds: 300));
  return ref.read(tripServiceProvider).searchTrips(query);
});
