import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:feeltrip_app/models/syncable_model.dart';
import 'package:feeltrip_app/features/diario/domain/models/momento_model.dart';

part 'momento_model.g.dart';



// MIGRACIÓN: Isar 3.x → Hive
// Isar 3.1.0 es incompatible con Dart 3.x / analyzer 6.x.
// Hive ya estaba en el proyecto — se mantiene la misma API pública.



@HiveType(typeId: 0)
class MomentoModel extends HiveObject {
  MomentoModel({
    required this.userId,
    required this.title,
    this.description,
    this.emotionTags = const [],
    this.locationLat,
    this.locationLng,
    this.imageUrls = const [],
    required this.createdAt,
    SyncStatus syncStatus = SyncStatus.local,
    this.firestoreId,
    this.errorMessage,
    this.retryCount = 0,
    this.lastAttempt,
  }): syncStatusName = syncStatus.name; 

  factory MomentoModel.fromJson(Map<String, dynamic> json) => MomentoModel(
        userId: json['userId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        emotionTags: List<String>.from(json['emotionTags'] as Iterable? ?? []),
        locationLat: json['location'] != null
            ? (json['location'] as Map<String, dynamic>)['latitude'] as double?
            : null,
        locationLng: json['location'] != null
            ? (json['location'] as Map<String, dynamic>)['longitude'] as double?
            : null,
        imageUrls: List<String>.from(json['imageUrls'] as Iterable? ?? []),
        createdAt: DateTime.parse(json['createdAt'] as String),
        syncStatus:
            SyncStatus.values.byName(json['syncStatus'] as String? ?? 'local'),
        firestoreId: json['firestoreId'] as String?,
        errorMessage: json['errorMessage'] as String?,
        retryCount: json['retryCount'] as int? ?? 0,
        lastAttempt: json['lastAttempt'] != null
            ? DateTime.parse(json['lastAttempt'] as String)
            : null,
      );

  factory MomentoModel.fromFirestore(String id, Map<String, dynamic> data) {
    return MomentoModel(
      firestoreId: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      emotionTags: List<String>.from(data['emotionTags'] as Iterable? ?? []),
      locationLat: data['location'] != null
          ? ((data['location'] as Map<String, dynamic>)['latitude'] as num)
              .toDouble()
          : null,
      locationLng: data['location'] != null
          ? ((data['location'] as Map<String, dynamic>)['longitude'] as num)
              .toDouble()
          : null,
      imageUrls: List<String>.from(data['imageUrls'] as Iterable? ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      syncStatus:
          SyncStatus.values.byName(data['syncStatus'] as String? ?? 'synced'),
      errorMessage: data['errorMessage'] as String?,
      retryCount: data['retryCount'] as int? ?? 0,
      lastAttempt: data['lastAttempt'] != null
          ? (data['lastAttempt'] as Timestamp).toDate()
          : null,
    );
  }

  @HiveField(0)
  String userId;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<String> emotionTags;

  @HiveField(4)
  double? locationLat;

  @HiveField(5)
  double? locationLng;

  @HiveField(6)
  List<String> imageUrls;

  @HiveField(7)
  DateTime createdAt;

  // Hive no soporta enums directamente — se persiste como String
  @HiveField(8)
  String syncStatusName = SyncStatus.local.name;

  SyncStatus get syncStatus => SyncStatus.values.byName(syncStatusName);
  set syncStatus(SyncStatus value) => syncStatusName = value.name;

  @HiveField(9)
  String? firestoreId;

  @HiveField(10)
  String? errorMessage;

  @HiveField(11)
  int retryCount;

  @HiveField(12)
  DateTime? lastAttempt;

  // Getter/setter de conveniencia para LatLng (no persiste en Hive)
  LatLng? get location {
    if (locationLat != null && locationLng != null) {
      return LatLng(locationLat!, locationLng!);
    }
    return null;
  }

  set location(LatLng? value) {
    locationLat = value?.latitude;
    locationLng = value?.longitude;
  }

  // Hive usa la key del box como ID — compatible con el isarId anterior
  int get isarId => key as int? ?? -1;

  /// Identificador único. Prioriza el ID remoto.
  String get id => (firestoreId != null && firestoreId!.isNotEmpty) 
      ? firestoreId! 
      : (key != null ? key.toString() : '');

  /// Convierte este modelo de persistencia al modelo de dominio.
  Momento toDomain() {
    return Momento(
      id: id,
      userId: userId,
      title: title,
      description: description,
      createdAt: createdAt,
      isSynced: syncStatus == SyncStatus.synced,
    );
  }

  /// Crea un modelo de persistencia desde el modelo de dominio.
  static MomentoModel fromDomain(Momento domain) {
    final model = MomentoModel(
      userId: domain.userId,
      title: domain.title,
      description: domain.description,
      createdAt: domain.createdAt,
      syncStatus: domain.isSynced ? SyncStatus.synced : SyncStatus.local,
      // Si el ID del dominio parece un ID de Firestore, lo asignamos
      firestoreId: (domain.id.startsWith('remote_') || domain.id.length > 15) 
          ? domain.id 
          : null,
    );
    
    // Si el ID es numérico (de Hive), intentamos restaurar la key
    if (int.tryParse(domain.id) != null) {
      // Nota: La key se asignará al guardar en el box si es null
    }
    return model;
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MomentoModel &&
        other.key == key &&
        other.userId == userId &&
        other.title == title &&
        other.firestoreId == firestoreId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(key, userId, title, firestoreId, createdAt);

  MomentoModel copyWith({
    String? userId,
    String? title,
    String? description,
    List<String>? emotionTags,
    LatLng? location,
    List<String>? imageUrls,
    DateTime? createdAt,
    SyncStatus? syncStatus,
    String? firestoreId,
    String? errorMessage,
    int? retryCount,
    DateTime? lastAttempt,
  }) {
    final copy = MomentoModel(
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      emotionTags: emotionTags ?? this.emotionTags,
      locationLat: location?.latitude ?? this.locationLat,
      locationLng: location?.longitude ?? this.locationLng,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      firestoreId: firestoreId ?? this.firestoreId,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      lastAttempt: lastAttempt ?? this.lastAttempt,
    );
    copy.syncStatus = syncStatus ?? this.syncStatus;
    return copy;
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'title': title,
        'description': description,
        'emotionTags': emotionTags,
        'location': location != null
            ? {'latitude': locationLat, 'longitude': locationLng}
            : null,
        'imageUrls': imageUrls,
        'createdAt': createdAt.toIso8601String(),
        'syncStatus': syncStatus.name,
        'firestoreId': firestoreId,
        'errorMessage': errorMessage,
        'retryCount': retryCount,
        'lastAttempt': lastAttempt?.toIso8601String(),
      };

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        'description': description,
        'emotionTags': emotionTags,
        'location': location != null
            ? {'latitude': locationLat, 'longitude': locationLng}
            : null,
        'imageUrls': imageUrls,
        'createdAt': Timestamp.fromDate(createdAt),
        'syncStatus': syncStatus.name,
        'errorMessage': errorMessage,
        'retryCount': retryCount,
        'lastAttempt': lastAttempt != null ? Timestamp.fromDate(lastAttempt!) : null,
      };
}