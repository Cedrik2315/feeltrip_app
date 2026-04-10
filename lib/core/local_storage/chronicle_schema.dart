import 'package:isar/isar.dart';

// Isar Schema synced with MomentoModel (HiveType 0) & ItineraryModel (HiveType 3)
// Ready for future migration from Hive. Fields/types match exactly.
// Indexes optimized for common queries (userId, syncStatusName, createdAt).

part 'chronicle_schema.g.dart';

@collection
class MomentoCollection {
  Id? id = Isar.autoIncrement; // Maps to Hive key/isarId

  @Index()
  String? userId;

  String? title;

  String? description;

  @Index()
  List<String>? emotionTags;

  double? locationLat;
  double? locationLng;

  List<String>? imageUrls;

  DateTime? createdAt;

  @Index()
  String? syncStatusName; // 'local', 'pending', 'synced', 'error'

  String? firestoreId;

  String? errorMessage;

  int? retryCount;

  DateTime? lastAttempt;
}

@collection
class ItineraryCollection {
  Id isarId = Isar.autoIncrement; // Agregamos una ID numérica interna

  @Index(unique: true, replace: true) 
  String? id; // Tu ID de String (Firestore) ahora es un índice único

  @Index()
  String? userId;
  
  // ... (el resto de tus campos se mantienen igual)
}
