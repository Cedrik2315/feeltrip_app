# Dia 8 - Alertas y Respuesta Operativa

Fecha: 2026-03-03

## Objetivo

Reducir tiempo de deteccion y respuesta ante incidentes post-release.

## Cambios implementados

- Observabilidad reforzada en runtime:
  - `setReleaseContext(env, version)` en Crashlytics custom keys.
  - `recordNonFatal(error, stack, reason)` para inicializaciones fallidas.
  - Integrado en `main.dart` para fallas de observabilidad/consent.
- Runbook operativo:
  - `INCIDENT_RUNBOOK_DAY8.md`

## Alertas recomendadas

1. Crash-free users < 99.5% (rolling 1h) -> `SEV-1`.
2. Aumento > 3x en `auth_gate_state=error_auth_stream` (rolling 30m) -> `SEV-2`.
3. `auth_gate_state=timeout_waiting_auth` > 2% de sesiones (rolling 30m) -> `SEV-2`.
4. Picos de no-fatales con mismo `reason` y `app_version` -> `SEV-3` o `SEV-2` segun impacto.

## Criterio Done (Dia 8)

- Cada error no-fatal importante queda etiquetado por `app_env` y `app_version`.
- Existe runbook de triage/mitigacion con severidades.
- Hay umbrales claros para disparar respuesta operativa.
