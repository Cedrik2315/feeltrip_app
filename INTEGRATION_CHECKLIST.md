# Checklist de Cumplimiento de Integracion

## Router y navegacion
- [x] Unificar la navegacion activa en un solo `GoRouter`.
- [x] Alinear `main.dart` con el router unificado via `routerProvider`.
- [x] Exponer rutas clave: `/`, `/home`, `/login`, `/register`, `/bookings`, `/comments/:storyId`, `/notifications`.
- [x] Reconciliar el diario con dos entradas: `/diary` para listado y `/diary/capture` para captura asistida.
- [x] Mantener accesibles las rutas vivenciales ya usadas por otras pantallas: `/suggestions`, `/premium`, `/my-itineraries`, `/transformation-history`, `/quiz`.

## Flujos base
- [x] Login navega a una ruta real (`/home`).
- [x] Home navega a rutas reales para diario y reservas.
- [x] Notificaciones navegan a rutas reales para comentarios, reservas y centro de notificaciones.
- [x] Itinerarios e historial siguen resolviendo sus rutas en el mismo router.

## Pantallas conectadas
- [x] Reemplazar placeholder de recuperacion por `ForgotPasswordScreen`.
- [x] Reemplazar placeholder de agencia por `AgencyProfileScreen`.
- [x] Reemplazar placeholder de busqueda por `SearchScreen`.
- [x] Reemplazar placeholder de historias por `StoriesScreen`.
- [x] Reemplazar placeholder de impacto por `MetricsDashboardScreen`.
- [x] Reemplazar placeholder de feed por `FeedScreen`.
- [x] Exponer detalle de viaje real por `/trip-details/:tripId`.
- [x] Conectar `TripCard` a la ruta real de detalle con `tripId`.

## Verificacion
- [x] `flutter analyze` sin issues.
- [x] `flutter test` verde.
- [ ] Verificar en runtime que `AgencyProfileScreen`, `FeedScreen` y `StoriesScreen` carguen datos reales sin regresiones.
