import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_response.dart';

final aiServiceProvider = Provider<AiService>((ref) => AiService());

class AiService {
  Future<AiResponse> completeChat(List<Map<String, String>> messages) async {
    // Stub — integrar con Gemini/OpenAI cuando corresponda
    await Future.delayed(Duration(seconds: 1));
    return AiResponse(
      extractedTitle: 'Título Generado',
      fullText: 'Respuesta completa de chat.',
    );
  }

  Future<String> generateChronicle(Map<String, dynamic> data) async {
    return 'Chronicle generated';
  }
}

