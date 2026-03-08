# Checklist de Publicacion - Play Console

Fecha base: 2026-03-03

## Pre-subida

1. Confirmar version en `pubspec.yaml` (`X.Y.Z+N`).
2. Ejecutar `./release_candidate.ps1 -VersionName X.Y.Z -BuildNumber N`.
3. Verificar artefacto:
   - `build/app/outputs/bundle/release/app-release.aab`
4. Confirmar que `APP_ENV=prod` fue usado en el build.

## Subida en Play Console

1. Ir a `Production` (o `Open testing` si aplica).
2. Crear release y subir `app-release.aab`.
3. Revisar warnings de Play (SDK, permisos, policy).
4. Completar notas de version (ES/EN).
5. Guardar y revisar diff de dispositivos afectados.

## Publicacion

1. Iniciar rollout controlado (ej. 5%-10%).
2. Monitorear 30-60 min:
   - Crashlytics (crashes/fatals)
   - Analytics (sesiones y eventos clave)
3. Si hay regresion critica:
   - detener rollout
   - ejecutar rollback definido en `RELEASE_DAY6.md`

## Cierre

1. Aumentar rollout progresivamente hasta 100%.
2. Marcar release como estable.
3. Registrar post-mortem breve (incidentes, metricas, aprendizaje).
