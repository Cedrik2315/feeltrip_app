import 'package:isar/isar.dart';

part 'app_schemas.g.dart';

@collection
class MomentoDb {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? firestoreId;

  String userId = '';
  String title = '';
  String? description;
  List<String> emotionTags = [];
  double? latitude;
  double? longitude;
  List<String> imageUrls = [];
  DateTime createdAt = DateTime.now();
  
  @Index()
  String syncStatus = 'local'; // local, pending, synced, error, deleted
  
  String? errorMessage;
  int retryCount = 0;
  DateTime? lastAttempt;
  DateTime updatedAt = DateTime.now();
}

@collection
class AiCacheDb {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String promptHash = '';

  String response = '';
  DateTime createdAt = DateTime.now();
  DateTime expiresAt = DateTime.now();
}

@collection
class ChronicleDb {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? localId; // El ID que venía de Hive

  String userId = '';
  String title = '';
  List<String> paragraphs = [];
  String? expeditionDataJson; // Guardamos como JSON string para simplicidad
  DateTime generatedAt = DateTime.now();
  int expeditionNumber = 0;
  String? imageUrl;
  String? visualMetaphor;
  
  @Index()
  String syncStatus = 'local';
}

@collection
class ProposalDb {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true, replace: true)
  String? firestoreId;
  
  String userId = '';
  String title = '';
  String? description;
  String destination = '';
  double budget = 0.0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String syncStatus = 'local';
}

@collection
class ItineraryDb {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true, replace: true)
  String? firestoreId;
  
  String userId = '';
  String title = '';
  String? proposalId;
  String contentJson = '{}';
  String syncStatus = 'local';
}

@collection
class BookingDb {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true, replace: true)
  String? firestoreId;
  
  String userId = '';
  String experienceId = '';
  String status = 'pending';
  double amount = 0.0;
  DateTime date = DateTime.now();
}
