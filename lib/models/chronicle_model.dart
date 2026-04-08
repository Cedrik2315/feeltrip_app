import 'package:hive/hive.dart';
import '../models/syncable_model.dart';
import '../models/expedition_data.dart';

part 'chronicle_model.g.dart';

@HiveType(typeId: 10)
class ChronicleModel extends HiveObject with SyncableModel {

  ChronicleModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.paragraphs,
    required ExpeditionData expeditionData,
    required this.generatedAt,
    this.syncStatus = SyncStatus.local,
    int? expeditionNumber,
    this.imageUrl,
    this.visualMetaphor,
  })  : expeditionDataJson = expeditionData.toJson(),
        expeditionNumber = expeditionNumber ?? 0;

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final List<String> paragraphs;

  @HiveField(4)
  final Map<String, dynamic> expeditionDataJson;

  @HiveField(5)
  final DateTime generatedAt;

  @HiveField(6)
  SyncStatus syncStatus;

  @HiveField(7)
  final int expeditionNumber;

  @HiveField(8)
  final String? imageUrl;

  @HiveField(9)
  final String? visualMetaphor;

  ExpeditionData get expeditionData => ExpeditionData.fromJson(expeditionDataJson);

  String get fullText {
    final buffer = StringBuffer();
    buffer.writeln(title);
    buffer.writeln();
    for (final p in paragraphs) {
      buffer.writeln(p);
      buffer.writeln();
    }
    buffer.write('— Expedición ${expeditionNumber.toString().padLeft(3, '0')} · FeelTrip');
    return buffer.toString();
  }

  String get teaser => paragraphs.isNotEmpty ? paragraphs.first : '';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'paragraphs': paragraphs,
    'expeditionData': expeditionDataJson,
    'generatedAt': generatedAt.toIso8601String(),
    'syncStatus': syncStatus.name,
    'expeditionNumber': expeditionNumber,
    'imageUrl': imageUrl,
    'visualMetaphor': visualMetaphor,
  };

  @override
  String toString() => 'ChronicleModel(id: $id, title: $title)';
}

