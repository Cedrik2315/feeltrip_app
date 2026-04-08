import 'dart:math' as math;

/// [Sello FeelTrip]: Modelo de punto geográfico para telemetría
class GpsPoint {
  final double lat;
  final double lng;
  final double? altitudeM;
  final double accuracyM;
  final DateTime timestamp;

  const GpsPoint({
    required this.lat,
    required this.lng,
    this.altitudeM,
    required this.accuracyM,
    required this.timestamp,
  });

  double distanceTo(GpsPoint other) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((other.lat - lat) * p) / 2 +
        math.cos(lat * p) *
            math.cos(other.lat * p) *
            (1 - math.cos((other.lng - lng) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    if (altitudeM != null) 'altitudeM': altitudeM,
    'accuracyM': accuracyM,
    'timestamp': timestamp.toIso8601String(),
  };

  factory GpsPoint.fromJson(Map<String, dynamic> json) => GpsPoint(
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    altitudeM: json['altitudeM'] != null ? (json['altitudeM'] as num).toDouble() : null,
    accuracyM: (json['accuracyM'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

class WeatherSnapshot {
  final double temperatureCelsius;
  final String condition;
  final double? humidity;

  const WeatherSnapshot({
    required this.temperatureCelsius,
    required this.condition,
    this.humidity,
  });

  Map<String, dynamic> toJson() => {
    'temperatureCelsius': temperatureCelsius,
    'condition': condition,
    if (humidity != null) 'humidity': humidity,
  };

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) => WeatherSnapshot(
    temperatureCelsius: (json['temperatureCelsius'] as num).toDouble(),
    condition: json['condition'] as String,
    humidity: json['humidity'] != null ? (json['humidity'] as num).toDouble() : null,
  );
}

class RouteModel {
  final String id;
  final String placeName;
  final String region;
  final double? ambientTemperature;
  final List<GpsPoint> waypoints;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final double totalDistanceKm;
  final int durationMinutes;
  final double elevationGainMeters;
  final WeatherSnapshot? weatherSnapshot;
  final bool isCompleted;
  final String? linkedChronicleId;
  final String? pendingUniqueDetail;
  final String? explorerName;
  final String? pendingTone;

  const RouteModel({
    required this.id,
    required this.placeName,
    required this.region,
    this.ambientTemperature,
    this.waypoints = const [],
    this.startedAt,
    this.finishedAt,
    this.totalDistanceKm = 0.0,
    this.durationMinutes = 0,
    this.elevationGainMeters = 0.0,
    this.weatherSnapshot,
    this.isCompleted = false,
    this.linkedChronicleId,
    this.pendingUniqueDetail,
    this.explorerName,
    this.pendingTone,
  });

  RouteModel copyWith({
    String? id,
    String? placeName,
    String? region,
    double? ambientTemperature,
    List<GpsPoint>? waypoints,
    DateTime? startedAt,
    DateTime? finishedAt,
    double? totalDistanceKm,
    int? durationMinutes,
    double? elevationGainMeters,
    WeatherSnapshot? weatherSnapshot,
    bool? isCompleted,
    String? linkedChronicleId,
    String? pendingUniqueDetail,
    String? explorerName,
    String? pendingTone,
  }) =>
      RouteModel(
        id: id ?? this.id,
        placeName: placeName ?? this.placeName,
        region: region ?? this.region,
        ambientTemperature: ambientTemperature ?? this.ambientTemperature,
        waypoints: waypoints ?? this.waypoints,
        startedAt: startedAt ?? this.startedAt,
        finishedAt: finishedAt ?? this.finishedAt,
        totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
        weatherSnapshot: weatherSnapshot ?? this.weatherSnapshot,
        isCompleted: isCompleted ?? this.isCompleted,
        linkedChronicleId: linkedChronicleId ?? this.linkedChronicleId,
        pendingUniqueDetail: pendingUniqueDetail ?? this.pendingUniqueDetail,
        explorerName: explorerName ?? this.explorerName,
        pendingTone: pendingTone ?? this.pendingTone,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'placeName': placeName,
    'region': region,
    if (ambientTemperature != null) 'ambientTemperature': ambientTemperature,
    'waypoints': waypoints.map((w) => w.toJson()).toList(),
    if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
    if (finishedAt != null) 'finishedAt': finishedAt!.toIso8601String(),
    'totalDistanceKm': totalDistanceKm,
    'durationMinutes': durationMinutes,
    'elevationGainMeters': elevationGainMeters,
    if (weatherSnapshot != null) 'weatherSnapshot': weatherSnapshot!.toJson(),
    'isCompleted': isCompleted,
    if (linkedChronicleId != null) 'linkedChronicleId': linkedChronicleId,
    if (pendingUniqueDetail != null) 'pendingUniqueDetail': pendingUniqueDetail,
    if (explorerName != null) 'explorerName': explorerName,
    if (pendingTone != null) 'pendingTone': pendingTone,
  };

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
    id: json['id'] as String,
    placeName: json['placeName'] as String,
    region: json['region'] as String,
    ambientTemperature: json['ambientTemperature'] != null
        ? (json['ambientTemperature'] as num).toDouble()
        : null,
    waypoints: (json['waypoints'] as List<dynamic>? ?? [])
        .map((w) => GpsPoint.fromJson(w as Map<String, dynamic>))
        .toList(),
    startedAt: json['startedAt'] != null
        ? DateTime.parse(json['startedAt'] as String)
        : null,
    finishedAt: json['finishedAt'] != null
        ? DateTime.parse(json['finishedAt'] as String)
        : null,
    totalDistanceKm: (json['totalDistanceKm'] as num? ?? 0).toDouble(),
    durationMinutes: json['durationMinutes'] as int? ?? 0,
    elevationGainMeters: (json['elevationGainMeters'] as num? ?? 0).toDouble(),
    weatherSnapshot: json['weatherSnapshot'] != null
        ? WeatherSnapshot.fromJson(json['weatherSnapshot'] as Map<String, dynamic>)
        : null,
    isCompleted: json['isCompleted'] as bool? ?? false,
    linkedChronicleId: json['linkedChronicleId'] as String?,
    pendingUniqueDetail: json['pendingUniqueDetail'] as String?,
    explorerName: json['explorerName'] as String?,
    pendingTone: json['pendingTone'] as String?,
  );
}