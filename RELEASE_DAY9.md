# Dia 9 - Calidad de Datos + KPIs de Funnel

Fecha: 2026-03-03

## Objetivo

Estandarizar telemetria para medir conversion real del MVP y reducir ruido de datos en Analytics.

## Cambios implementados

- Catalogo de eventos centralizado:
  - `lib/services/analytics_events.dart`
- Normalizacion de eventos y parametros en `ObservabilityService`:
  - normaliza nombres (`[a-z0-9_]`, max 40 chars)
  - normaliza keys de parametros
  - recorta valores string largos (max 100)
- Eventos de funnel agregados:
  - `search_executed` (query, results_count, category, difficulty, max_price)
  - `trip_opened` (trip_id, source)
  - `add_to_cart` (trip_id, quantity, unit_price)
  - `checkout_completed` (item_count, total)
- AI events migrados a catalogo:
  - `ai_cache_hit`, `ai_request_start`, `ai_request_success`, `ai_request_error`

## KPI minimos recomendados

1. `Search->Trip Open Rate` = `trip_opened / search_executed`
2. `Trip->Add to Cart Rate` = `add_to_cart / trip_opened`
3. `Cart->Checkout Rate` = `checkout_completed / add_to_cart`
4. `Checkout per Session` = `checkout_completed / app_startup`
5. `AI Success Rate` = `ai_request_success / ai_request_start`

## Criterio Done (Dia 9)

- Eventos core de funnel disponibles y consistentes.
- Telemetria resistente a payloads invalidos/largos.
- KPI base definido para decisiones de producto y operacion.
