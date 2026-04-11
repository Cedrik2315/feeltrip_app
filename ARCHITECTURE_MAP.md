# ARCHITECTURE_MAP

## Inventario de servicios

### lib/services/
- `affiliate_options_service.dart`: opciones de afiliacion.
- `affiliate_service.dart`: tracking y enlaces de afiliados.
- `analytics_service.dart`: eventos y analitica.
- `booking_service.dart`: reservas y estado operativo de bookings.
- `country_service.dart`: informacion y cache de paises.
- `currency_service.dart`: conversion de monedas.
- `destination_service.dart`: busqueda y detalle de destinos.
- `mercado_pago_service.dart`: integracion Mercado Pago en modo beta client-side.
- `metrics_service.dart`: metricas internas; requiere validacion para uso ejecutivo.
- `notification_service.dart`: push e in-app notifications.
- `osint_ai_service.dart`: recomendacion contextual; ya no debe describirse como OSINT real.
- `revenuecat_service.dart`: suscripciones e in-app purchases.
- `sharing_service.dart`: compartir contenido.
- `story_service.dart`: stories y contenido efimero.
- `vision_service.dart`: OCR y analisis visual basico.
- `weather_service.dart`: clima.

### lib/core/
- `lib/core/di/injection.dart`: wiring de dependencias heredado.
- `lib/core/di/providers.dart`: providers principales de Riverpod.
- `lib/core/error/error_handler.dart`: manejo centralizado de errores.
- `lib/core/error/failures.dart`: tipificacion de fallos.
- `lib/core/local_storage/isar_service.dart`: persistencia local actual sobre Hive; pendiente renombre tecnico.
- `lib/core/logger/app_logger.dart`: logging estructurado.
- `lib/core/network/sync_service.dart`: sync minimo de momentos.
- `lib/core/router/app_router.dart`: navegacion principal.
- `lib/core/router/route_names.dart`: nombres de rutas.

## Estado de salud
- `flutter analyze`: limpio.
- Base tecnica mas estable que al inicio de la auditoria.
- Persisten mejoras pendientes en backend de pagos, sync avanzado y cobertura de tests.

## Rutas criticas
- `BookingService` -> `MercadoPagoService` y persistencia local/cloud.
- `RevenueCatService` -> estado premium y restore flow.
- `NotificationService` -> push handling y centro de notificaciones.
- `SyncService` -> cola local de momentos y sincronizacion.
- `VisionService` + `osint_ai_service.dart` -> OCR y propuesta contextual.
- `AppRouter` -> entrypoints principales de auth y home.

## Riesgos abiertos
- `isar_service.dart` aun conserva nombre legacy aunque hoy usa Hive.
- Mercado Pago requiere backend para cierre production-grade.
- Search y sync necesitan una siguiente iteracion para escalar.

