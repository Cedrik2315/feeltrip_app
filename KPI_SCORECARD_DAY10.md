# KPI Scorecard - Dia 10

Fecha base: 2026-03-03

## Objetivo

Definir una lectura semanal unica para decisiones de release (go/hold/rollback).

## KPIs de producto (funnel MVP)

1. `Search -> Trip Open Rate`
- Formula: `users_trip_opened / users_search`
- Alerta: < 0.35

2. `Trip -> Add to Cart Rate`
- Formula: `users_add_to_cart / users_trip_opened`
- Alerta: < 0.20

3. `Cart -> Checkout Rate`
- Formula: `users_checkout / users_add_to_cart`
- Alerta: < 0.25

## KPIs de salud tecnica

1. `Auth timeout ratio`
- Señal: `auth_gate_state=timeout_waiting_auth / auth_gate_state total`
- Alerta: > 2%

2. `Auth stream error ratio`
- Señal: `auth_gate_state=error_auth_stream / auth_gate_state total`
- Alerta: > 1%

3. `AI success rate`
- Formula: `ai_request_success / ai_request_start`
- Alerta: < 0.97

4. `AI latency p95`
- Señal: p95 de `duration_ms` en `ai_request_success`
- Alerta: > 4500ms

## Decision semanal

1. `GO`: ninguna alerta roja y 2+ semanas estables.
2. `HOLD`: una alerta roja o dos amarillas consecutivas.
3. `ROLLBACK/HOTFIX`: degradacion critica de conversion o errores auth/crash.

## Fuente de datos

- Consultas base: `ANALYTICS_KPI_QUERIES_DAY10.sql`
- Telemetria app: eventos definidos en `lib/services/analytics_events.dart`
