# PLAN DE PRODUCCION FEELTRIP

## Objetivo
Transformar FeelTrip de un "RC técnico" a un "producto lanzable con riesgo controlado" en un ciclo de 90 días. Foco: confiabilidad transaccional, coherencia arquitectónica y métricas reales.

## Estado base actual
- `flutter analyze`: limpio.
- Fase 2B (Firestore Integration) finalizada: Historias y Diarios operativos en tiempo real.
- Auth, router y notificaciones base funcionales.
- **Brecha Crítica:** Pagos en client-side (Mercado Pago), persistencia híbrida (Hive/Firestore) y métricas en stub.

## Hoja de Ruta: Ciclo de 90 Días

### Fase 1: 0–30 días (Estabilización Crítica)
**Criterio rector:** Eliminar vulnerabilidades transaccionales y duplicidad.
- **Pagos Server-Authoritative:** [COMPLETADO] Repositorio, Cloud Function y Webhook con notificaciones operativos.
- **Unificación de Persistencia:** [COMPLETADO] SyncService con soporte para momentos, propuestas e itinerarios + Backoff exponencial.
- **Contrato de Booking:** [COMPLETADO] Modelo robusto con trazabilidad implementado.
- **Métricas de Funnel:** [COMPLETADO] MetricsService implementado con Firebase Analytics.
- **Seguridad:** [COMPLETADO] Reglas de Firestore endurecidas para bookings.

### Fase 2: 31–60 días (Producto Confiable)
**Criterio rector:** Journey honesto y fin de los mocks.
- **Search Real:** [COMPLETADO] SearchNotifier e interfaz SearchScreen integrados con Firestore.
- **Eliminación de Mocks:** [COMPLETADO] HomeRepository y AgencyService conectados a datos reales de Firestore.
- **Refuerzo Offline:** [COMPLETADO] ConnectivityProvider y NoConnectionWidget integrados; SyncService proactivo.
- **Deep Links:** [COMPLETADO] NotificationService habilitado con Stream de navegación para flujos directos.
- **Monetización:** [COMPLETADO] PremiumNotifier (RevenueCat) y PaymentRepository (Mercado Pago) unificados y reactivos.

### Fase 3: 61–90 días (Base de Escala)
**Criterio rector:** Preparación para crecimiento (10K+ usuarios).
- **Search Dedicado:** [COMPLETADO] AlgoliaSearchService integrado en SearchNotifier.
- **Analytics BI:** [COMPLETADO] Cloud Function exportBookingToBI para pipeline de datos.
- **Control de Costos IA:** [COMPLETADO] Implementado AiCacheService con hashing de prompts.
- **Optimización Media:** [COMPLETADO] MediaService para transformación de URLs y optimización de carga.
- **Panel de Agencias:** [COMPLETADO] AgencyDashboardScreen y reglas de seguridad para leads implementadas.

## Priorización Ejecutiva (Orden de ejecución)
1. **Pagos y Bookings:** Seguridad financiera primero.
2. **Unificación Sync:** Limpieza de deuda técnica Hive vs Firestore.
3. **Reglas de Seguridad:** Cerrar accesos de escritura no autorizados.
4. **Analytics Real:** Medir para decidir.
5. **Search y Home:** Experiencia de usuario real, no mock.

## No prometer todavia
- 95% de coverage.
- readiness para 1M usuarios.
- Búsqueda semántica instantánea (v3).
- Offline-first total para media pesada.

## Gate de Lanzamiento (Checklist)
- [x] Los pagos pasan por Cloud Functions y webhooks.
- [x] Ningún `booking` se confirma sin correlación exacta de pago.
- [x] `SyncService` unificado maneja momentos, propuestas e itinerarios.
- [x] `firestore.rules` prohíbe acceso a datos de otros usuarios.
- [x] Search UI muestra resultados de Firestore, no estáticos.
- [x] Métricas emiten eventos verificables en Firebase Analytics.

## Supuestos y Defaults
- Equipo pequeño (1-2 devs): Se prioriza estabilización sobre nuevas features sociales.
- RevenueCat es el canal premium principal.
- Cualquier pantalla en estado "beta" se reduce o se endurece; no se maquilla.
- Si una iniciativa nueva compite con la estabilidad, gana la estabilidad.
