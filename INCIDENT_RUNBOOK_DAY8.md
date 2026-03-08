# Incident Runbook - Dia 8

Fecha: 2026-03-03

## Severidades

- `SEV-1`: app inutilizable, crash masivo o bloqueo de login/pago.
- `SEV-2`: degradacion parcial de funciones core (search/cart/bookings).
- `SEV-3`: errores acotados con workaround disponible.

## Triage inicial (primeros 15 min)

1. Confirmar version afectada (`app_version`) y entorno (`app_env`) en Crashlytics.
2. Revisar `crash-free users` y tendencia de fatales/no fatales.
3. Correlacionar con eventos Analytics:
   - `app_startup`
   - `auth_gate_state`
4. Identificar alcance:
   - todos los usuarios o segmento puntual
   - Android version / dispositivo / region

## Mitigacion

1. Si hay rollout activo en Play: pausar rollout.
2. Si la regresion es critica: rollback segun `RELEASE_DAY6.md`.
3. Si existe fix rapido (<2h): hotfix con incremento de build number.

## Comunicacion operativa

1. Abrir incidente con severidad y hora UTC.
2. Publicar update cada 30 min con:
   - estado
   - impacto
   - ETA de mitigacion
3. Cierre con RCA breve y acciones preventivas.

## Postmortem minimo

1. Causa raiz tecnica.
2. Por que no fue detectado antes (gap de tests/monitoreo).
3. Acciones concretas con responsable y fecha.
