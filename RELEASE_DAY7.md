# Dia 7 - Operacion Post-Release

Fecha: 2026-03-03

## Objetivo

Tener visibilidad de la salud del release en las primeras horas y un protocolo de reaccion rapido.

## Cambios implementados

- Instrumentacion de startup y auth:
  - Evento `app_startup` con:
    - `env`
    - `version`
    - `firebase_ready`
  - Evento `auth_gate_state` con estados:
    - `timeout_waiting_auth`
    - `error_auth_stream`
    - `authenticated`
    - `anonymous`
- Metadata de version por `dart-define`:
  - `APP_VERSION` (default `dev-local`)
  - Fuente: `lib/config/release_metadata.dart`
- RC actualizado para incluir version en build:
  - `release_candidate.ps1`
  - `release_candidate.sh`

## Monitoreo recomendado (T+60 min)

1. Crashlytics:
   - `crash-free users`
   - nuevos fatales por version
2. Analytics:
   - volumen de `app_startup` por `version`
   - tasa de `auth_gate_state=error_auth_stream` y `timeout_waiting_auth`
3. Backend:
   - errores de Firestore/Auth en consola Firebase

## Criterio Done (Dia 7)

- Cada release en prod reporta `version` en evento de arranque.
- Existe senal temprana para detectar degradacion de autenticacion.
- Playbook de monitoreo post-release definido para la primera hora.
