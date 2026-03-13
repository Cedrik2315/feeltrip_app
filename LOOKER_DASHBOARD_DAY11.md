# Dia 11 - Dashboard Looker Studio (Release Ops)

Fecha: 2026-03-03

## Objetivo

Montar un dashboard único de operación release con datos de GA4 exportado a BigQuery.

## Prerrequisitos

1. Export de Firebase Analytics (GA4) activo hacia BigQuery.
2. Permisos de lectura al dataset de analytics.
3. Ejecutar `DAY11_LOOKER_SETUP.sql` en BigQuery (ajustando `<PROJECT_ID>` y `<DATASET_ID>`).

## Fuentes de datos en Looker Studio

1. `vw_release_funnel_daily`
2. `vw_release_auth_daily`
3. `vw_release_ai_daily`

## Layout recomendado (1 página)

1. Fila superior (scorecards):
- `users_search`
- `users_trip_opened`
- `users_add_to_cart`
- `users_checkout`
- `rate_cart_to_checkout`

2. Fila media:
- Serie temporal de `rate_search_to_trip`, `rate_trip_to_cart`, `rate_cart_to_checkout`
- Barras apiladas de `auth_state` por día

3. Fila inferior:
- Serie temporal de `ai_success_rate`
- Serie temporal de `ai_duration_p95_ms`

## Umbrales (condicionales)

1. `rate_trip_to_cart < 0.20` -> rojo
2. `rate_cart_to_checkout < 0.25` -> rojo
3. `ai_success_rate < 0.97` -> rojo
4. `ai_duration_p95_ms > 4500` -> rojo

## Rutina operativa semanal

1. Revisar lunes AM (últimos 7 días vs 7 días previos).
2. Si hay 1 métrica roja:
- estado `HOLD`
- abrir ticket de diagnóstico.
3. Si hay 2+ métricas rojas o caída fuerte de checkout:
- estado `SEV-2` o `SEV-1`
- ejecutar runbook de `INCIDENT_RUNBOOK_DAY8.md`.
