import 'package:isar/isar.dart';

part 'diary_entry_model.g.dart';

@collection
class DiaryEntry {
  Id id = Isar.autoIncrement;
  String content = '';
  DateTime date = DateTime.now();

  // Campos para el Motor Emocional (Gemini)
  double? sentimentScore;
  List<String>? emotions;
  List<String>? tags;

  // Indica si el análisis se completó con éxito
  bool analyzed = false;
}