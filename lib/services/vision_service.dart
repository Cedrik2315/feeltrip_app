import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/app_logger.dart';

class VisionService {
  // Asegúrate de tener GOOGLE_AI_API_KEY definida en tu archivo .env
  final String _apiKey = dotenv.env['GOOGLE_AI_API_KEY'] ?? '';

  /// Analiza una imagen y devuelve un mensaje poético generado por IA.
  Future<String?> getPoeticMessageFromImage(File imageFile) async {
    if (_apiKey.isEmpty) {
      AppLogger.debug('VisionService: GOOGLE_AI_API_KEY no encontrada en .env');
      return "Para descifrar el asombro, necesito una llave mágica (API Key) en tu configuración.";
    }

    try {
      // Usamos gemini-1.5-flash por ser rápido y multimodal (capaz de ver imágenes)
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final imageBytes = await imageFile.readAsBytes();
      final prompt = TextPart(
          "Actúa como un poeta viajero y filósofo. Analiza esta imagen y escribe un mensaje breve, "
          "inspirador y profundo (máximo 2 frases) sobre lo que ves, conectándolo con la experiencia "
          "de descubrir el mundo y el viaje interior.");
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      return response.text;
    } catch (e) {
      AppLogger.error('Error generando mensaje poético', error: e);
      return "El viento se llevó las palabras. Por favor, intenta capturar el momento de nuevo.";
    }
  }
}
