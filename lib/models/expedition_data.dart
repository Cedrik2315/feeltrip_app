/// Tonos narrativos disponibles para la crónica poética.
enum NarrativeTone {
  contemplativo,
  lirico,
  urgente,
  intimo,
  epico;

  String get label {
    switch (this) {
      case NarrativeTone.contemplativo: return 'contemplativo';
      case NarrativeTone.lirico:        return 'lírico';
      case NarrativeTone.urgente:       return 'urgente';
      case NarrativeTone.intimo:        return 'íntimo';
      case NarrativeTone.epico:         return 'épico';
    }
  }

  String get displayName {
    switch (this) {
      case NarrativeTone.contemplativo: return 'Contemplativo';
      case NarrativeTone.lirico:        return 'Lírico';
      case NarrativeTone.urgente:       return 'Urgente';
      case NarrativeTone.intimo:        return 'Íntimo';
      case NarrativeTone.epico:         return 'Épico';
    }
  }
}

/// Matices detectados por el motor de audio (Whisper integration)
enum AudioNuance {
  agitado,   // Adrenalina/Exploración física
  susurrado, // Intimidad/Secretos
  pausado,   // Reflexión profunda/Asombro
  neutro
}

/// Datos capturados durante la expedición, usados como input del prompt.
class ExpeditionData {
  final String placeName;
  final String region;
  final String arrivalTime;   // ej. "16:42"
  final String temperature;   // ej. "19°C"
  final String uniqueDetail;  // el detalle sensorial que solo el explorador notó
  final String explorerName;
  final NarrativeTone tone;
  final AudioNuance audioNuance;

  // Telemetría de ruta
  final double distanceKm;
  final int durationMinutes;
  final double elevationGainM;

  const ExpeditionData({
    required this.placeName,
    required this.region,
    required this.arrivalTime,
    required this.temperature,
    required this.uniqueDetail,
    required this.explorerName,
    this.tone = NarrativeTone.contemplativo,
    this.audioNuance = AudioNuance.neutro,
    this.distanceKm = 0.0,
    this.durationMinutes = 0,
    this.elevationGainM = 0.0,
  });

  factory ExpeditionData.fromJson(Map<String, dynamic> json) => ExpeditionData(
    placeName:      json['placeName'] as String,
    region:         json['region'] as String,
    arrivalTime:    json['arrivalTime'] as String,
    temperature:    json['temperature'] as String,
    uniqueDetail:   json['uniqueDetail'] as String,
    explorerName:   json['explorerName'] as String,
    tone: NarrativeTone.values.firstWhere(
      (t) => t.name == json['tone'],
      orElse: () => NarrativeTone.contemplativo,
    ),
    audioNuance: AudioNuance.values.firstWhere(
      (a) => a.name == json['audioNuance'],
      orElse: () => AudioNuance.neutro,
    ),
    distanceKm:     (json['distanceKm'] as num? ?? 0).toDouble(),
    durationMinutes: json['durationMinutes'] as int? ?? 0,
    elevationGainM: (json['elevationGainM'] as num? ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'placeName':      placeName,
    'region':         region,
    'arrivalTime':    arrivalTime,
    'temperature':    temperature,
    'uniqueDetail':   uniqueDetail,
    'explorerName':   explorerName,
    'tone':           tone.name,
    'audioNuance':    audioNuance.name,
    'distanceKm':     distanceKm,
    'durationMinutes': durationMinutes,
    'elevationGainM': elevationGainM,
  };
}