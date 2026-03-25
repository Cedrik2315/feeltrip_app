import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../diario/domain/models/momento_model.dart';
import '../../../../core/local_storage/isar_service.dart';

final momentoProvider = StateNotifierProvider<MomentoNotifier, List<Momento>>((ref) {
  return MomentoNotifier(IsarService());
});

class MomentoNotifier extends StateNotifier<List<Momento>> {
  MomentoNotifier(this._isarService) : super([]);
  final IsarService _isarService;

  Future<void> loadMomentos(String userId) async {
    final data = await _isarService.getMomentos(userId);
    state = data.map((e) => Momento.fromJson(e)).toList();
  }

  Future<void> addMomento(Momento momento) async {
    await _isarService.saveMomento(momento);
    state = [...state, momento];
  }
}
