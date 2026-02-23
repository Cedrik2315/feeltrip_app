import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/app_logger.dart';
import 'admob_service.dart';

/// Servicio de consentimiento de GDPR para anuncios
/// Maneja el formulario de consentimiento de usuarios en la UE
class ConsentService {
  static bool _adsInitialized = false;
  static bool _canRequestAds = true; // Default true para simplificar
  static bool _privacyOptionsRequired = false;

  static bool get canRequestAds => _canRequestAds;
  static bool get privacyOptionsRequired => _privacyOptionsRequired;

  /// Inicializa los anuncios si está permitido
  static Future<bool> initializeAdsIfPermitted() async {
    if (!AdMobService.isSupported || _adsInitialized) {
      return _adsInitialized;
    }

    try {
      // Verificar estado de consentimiento
      await _checkConsentStatus();

      if (!_canRequestAds) {
        AppLogger.info(
          'Consentimiento no disponible; se omite inicialización de anuncios.',
          name: 'ConsentService',
        );
        return false;
      }

      await MobileAds.instance.initialize();
      _adsInitialized = true;
      AppLogger.info('Anuncios inicializados correctamente',
          name: 'ConsentService');
      return true;
    } catch (e) {
      AppLogger.error(
        'Error inicializando anuncios',
        error: e.toString(),
        name: 'ConsentService',
      );
      return false;
    }
  }

  /// Muestra las opciones de privacidad
  static Future<void> showPrivacyOptions() async {
    if (!AdMobService.isSupported) return;

    AppLogger.info('Mostrando opciones de privacidad', name: 'ConsentService');
    // En producción, mostrarías el formulario de GDPR aquí
  }

  /// Verifica el estado del consentimiento
  static Future<void> _checkConsentStatus() async {
    try {
      // Verificar si se puede solicitar anuncios
      _canRequestAds = await ConsentInformation.instance.canRequestAds();

      // Obtener estado de consentimiento
      final status = ConsentInformation.instance.getConsentStatus();
      _privacyOptionsRequired = status == ConsentStatus.required;

      AppLogger.info(
        'Consent status: $_canRequestAds, Privacy required: $_privacyOptionsRequired',
        name: 'ConsentService',
      );
    } catch (e) {
      AppLogger.error(
        'Error verificando consentimiento',
        error: e.toString(),
        name: 'ConsentService',
      );
      // Por defecto permitir anuncios
      _canRequestAds = true;
    }
  }
}
