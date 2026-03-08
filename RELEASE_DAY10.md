# Dia 10 - Tablero Operativo de Release

Fecha: 2026-03-03

## Objetivo

Cerrar el ciclo release->medicion->decision con un tablero minimo accionable.

## Entregables

- Consultas SQL listas para BigQuery/GA4 export:
  - `ANALYTICS_KPI_QUERIES_DAY10.sql`
- Scorecard semanal con umbrales y criterio de decision:
  - `KPI_SCORECARD_DAY10.md`

## Uso recomendado

1. Activar export de Analytics a BigQuery en Firebase.
2. Ejecutar queries del archivo SQL por rango diario/semanal.
3. Poblar scorecard (semana actual vs semana anterior).
4. Tomar decision `GO/HOLD/ROLLBACK` segun umbrales.

## Criterio Done (Dia 10)

- Existe tablero reproducible con queries concretas (no solo narrativa).
- Hay umbrales cuantitativos para decidir release progression.
- Operacion dispone de lectura comun entre producto e ingenieria.
