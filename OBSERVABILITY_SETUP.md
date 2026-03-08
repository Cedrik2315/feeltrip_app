# Observabilidad Productiva

## 1) Crashlytics
- Firebase Console -> Crashlytics -> Enable.
- Verificar eventos por versión de app.
- Confirmar que los errores fatales aparecen con `app version` y `build number`.

## 2) Analytics
- Firebase Console -> Analytics -> Enable Google Analytics.
- Verificar eventos base:
  - `screen_view`
  - eventos custom de negocio (ej. `diary_saved`, `login_success`).

## 3) Performance Traces
- Firebase Console -> Performance -> Enable.
- Revisar trazas custom emitidas por `ObservabilityService.trace(...)`.

## 4) Alertas
- Firebase Console -> Crashlytics -> Alerts:
  - Nueva regresión
  - Aumento brusco de crashes
- Enviar notificaciones a:
  - Email del equipo
  - Slack (vía integración de Google Cloud Monitoring o webhook bridge)

## 5) Dashboard operativo recomendado
- Crash-free users (%)
- Crashes por versión
- Latencia de función `analyzeDiaryEntry`
- Tasa de error (`invalid-argument`, `resource-exhausted`, `internal`)
- Conversión de flujo diario: login -> guardar -> historial

## 6) Kit operativo de release (Dia 10)
- Queries KPI listas: `ANALYTICS_KPI_QUERIES_DAY10.sql`
- Scorecard y umbrales: `KPI_SCORECARD_DAY10.md`
- Cierre de fase: `RELEASE_DAY10.md`

## 7) Dashboard visual (Dia 11)
- Setup de vistas BigQuery: `DAY11_LOOKER_SETUP.sql`
- Guia de Looker Studio: `LOOKER_DASHBOARD_DAY11.md`
- Cierre de fase: `RELEASE_DAY11.md`
