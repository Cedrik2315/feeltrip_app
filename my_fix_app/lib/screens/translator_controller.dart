import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/features/profile/presentation/profile_controller.dart';
import 'package:feeltrip_app/services/translation_service.dart';

/// Estado de la pantalla de traducción
class TranslatorState {
  final String translatedText;
  final String? detectedLanguage;
  final bool isLoading;
  final String? error;

  TranslatorState({
    this.translatedText = '',
    this.detectedLanguage,
    this.isLoading = false,
    this.error,
  });

  TranslatorState copyWith({
    String? translatedText,
    String? detectedLanguage,
    bool? isLoading,
    String? error,
  }) {
    return TranslatorState(
      translatedText: translatedText ?? this.translatedText,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier para gestionar la lógica de traducción y detección.
class TranslatorNotifier extends StateNotifier<TranslatorState> {
  final Ref _ref;

  TranslatorNotifier(this._ref) : super(TranslatorState());

  Future<void> processTranslation(String text) async {
    if (text.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = _ref.read(translationServiceProvider);
      final profile = _ref.read(profileControllerProvider).value;
      final archetype = profile?.archetype ?? 'Explorador';

      // 1. Detección Local (Ahorro de Tokens)
      final lang = await service.detectLanguage(text);
      
      // Si el idioma detectado es español ('es'), evitamos el gasto de tokens de IA
      // ya que no requiere traducción al idioma base de la app.
      if (lang == 'es') {
        state = state.copyWith(
          isLoading: false,
          detectedLanguage: 'es',
          translatedText: text, 
        );
        return;
      }

      // 2. Traducción vía IA con Arquetipo
      final result = await service.translate(text, targetLanguage: 'es', archetype: archetype);

      state = state.copyWith(
        isLoading: false,
        translatedText: result,
        detectedLanguage: lang,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Fallo en la sincronización del traductor.');
    }
  }
}

final translatorControllerProvider = StateNotifierProvider<TranslatorNotifier, TranslatorState>((ref) {
  return TranslatorNotifier(ref);
});