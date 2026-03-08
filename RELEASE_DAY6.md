# Dia 6 - Release Candidate + Rollback

Fecha: 2026-03-03

## Objetivo

Estandarizar la salida a produccion con versionado, build firmado y procedimiento de rollback.

## Cambios implementados

- Script de release candidate:
  - `release_candidate.ps1` (Windows)
  - `release_candidate.sh` (macOS/Linux)
- Template de firma:
  - `android/key.properties.example`
- Hardening de secretos:
  - `.gitignore` ahora ignora `android/key.properties`, `*.jks`, `*.keystore`

## Flujo RC

1. Definir version semver y build number.
2. Verificar `android/key.properties` y existencia de keystore.
3. Actualizar `pubspec.yaml` (`version: X.Y.Z+N`).
4. Ejecutar gate de Dia 5 (`preflight_release`).
5. Generar AAB prod firmado:
   - `build/app/outputs/bundle/release/app-release.aab`

## Comandos

- Windows:
  - `./release_candidate.ps1 -VersionName 1.0.1 -BuildNumber 2`
- macOS/Linux:
  - `./release_candidate.sh 1.0.1 2`

## Rollback operativo

1. En Google Play Console, detener despliegue del release actual (si esta en rollout).
2. Promover el ultimo release estable con mayor `versionCode` ya aprobado.
3. Si no existe release estable reciente, publicar hotfix con:
   - incremento de `BuildNumber`
   - `APP_ENV=prod`
   - fix minimo y re-ejecucion de `preflight_release`
4. Verificar Crashlytics/Analytics en los primeros 30-60 minutos post rollback.

## Criterio Done (Dia 6)

- Existe un comando reproducible para generar RC firmado.
- Versionado queda trazable en `pubspec.yaml`.
- Secretos de firma no quedan expuestos por defecto en git.
- Procedimiento de rollback documentado para operacion.
