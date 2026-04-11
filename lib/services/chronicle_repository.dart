import 'package:feeltrip_app/models/chronicle_model.dart';
import 'package:feeltrip_app/models/expedition_data.dart';

/// Abstract interface for Chronicle repository.
/// Handles offline-first persistence with Hive.
abstract class ChronicleRepository {
  /// Returns all chronicles for current user, sorted by generatedAt DESC.
  List<ChronicleModel> getAll();

  /// Deletes chronicle by ID.
  Future<void> delete(String id);

  /// Generates chronicle via API and saves locally.
  Future<ChronicleModel> generateAndSave({
    required ExpeditionData data,
    required String userId,
  });
}

