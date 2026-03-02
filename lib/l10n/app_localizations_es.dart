// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FeelTrip App';

  @override
  String get homeTitle => 'FeelTrip - Viajes transformadores';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get loginButton => 'Entrar';

  @override
  String get diaryTitle => 'FeelTrip - Diario IA';

  @override
  String get diaryPrompt => '¿Qué descubriste hoy?';

  @override
  String get diaryHint => 'Escribe tus pensamientos aquí...';

  @override
  String get diaryAnalyze => 'Analizar y guardar en la nube';

  @override
  String get diarySaved => 'Viaje guardado en tu historial privado';

  @override
  String get historyTitle => 'Mis viajes emocionales';

  @override
  String get historyEmpty => 'Aún no tienes registros de viaje.';
}
