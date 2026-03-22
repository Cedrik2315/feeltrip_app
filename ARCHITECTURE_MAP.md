# ARCHITECTURE_MAP

## Inventario de Servicios

### lib/services/
- ✅ **affiliate_options_service.dart**: Manejo de opciones de programas de afiliados.
- ✅ **affiliate_service.dart**: Gestión de enlaces y tracking de afiliados.
- ✅ **analytics_service.dart**: Envío de eventos analíticos a servicios externos.
- ✅ **booking_service.dart**: Creación y gestión de reservas de viajes.
- ✅ **country_service.dart**: Obtención y caché de información de países.
- ✅ **currency_service.dart**: Conversión de monedas y tasas de cambio.
- ✅ **destination_service.dart**: Búsqueda y detalles de destinos de viaje.
- ✅ **mercado_pago_service.dart**: Pasarela de pagos Mercado Pago.
- ✅ **metrics_service.dart**: Métricas de app y rendimiento del negocio.
- ✅ **notification_service.dart**: Gestión de notificaciones push y locales.
- ✅ **revenuecat_service.dart**: Suscripciones y compras in-app via RevenueCat.
- ✅ **sharing_service.dart**: Compartir contenido en redes sociales.
- ✅ **story_service.dart**: Gestión de stories y contenido efímero.
- ✅ **weather_service.dart**: API de pronósticos meteorológicos.

### lib/core/
- ✅ **lib/core/di/injection.dart**: Configuración de inyección de dependencias.
- ✅ **lib/core/di/providers.dart**: Proveedores de Riverpod/DI.
- ✅ **lib/core/error/error_handler.dart**: Manejo centralizado de errores.
- ✅ **lib/core/error/failures.dart**: Tipos de fallos y errores personalizados.
- ✅ **lib/core/local_storage/isar_service.dart**: Base de datos local Isar.
- ✅ **lib/core/logger/app_logger.dart**: Logging estructurado de la app.
- ✅ **lib/core/network/sync_service.dart**: Sincronización de datos offline/online.
- ✅ **lib/core/router/app_router.dart**: Router principal de navegación GoRouter.
- ✅ **lib/core/router/route_names.dart**: Constantes de nombres de rutas.

## Estado de Salud
✅ Todos los servicios han pasado **flutter analyze** sin errores.

## Rutas Críticas
- **BookingService** → **MercadoPagoService** (procesamiento de pagos), **CurrencyService** (conversiones), **DestinationService** (detalles).
- **MetricsService** → **AnalyticsService** (envío de métricas).
- **RevenueCatService** → **IsarService** (persistencia local de estado premium).
- **NotificationService** → **IsarService** (almacenamiento local de notificaciones).
- **SyncService** → **IsarService** (sincronización DB local → Firestore).
- **AppRouter** → Todos los servicios (navegación contextual).

## Próximos Pasos

### Módulo OSINT (ProjectoInt)


