# Dia 5 - Gate de Release (CI + Preflight)

Fecha: 2026-03-03

## Objetivo

Agregar una barrera automatizada antes de publicar para reducir riesgo de regresiones en staging/prod.

## Cambios implementados

- CI reforzado en `.github/workflows/ci.yml`:
  - `flutter pub get`
  - validacion de llaves Firebase en `.env.example`
  - `flutter analyze`
  - `flutter test` sobre suite de release estable:
    - `test/services/*`
    - `test/unit/admob_service_test.dart`
    - `test/unit/auth_controller_test.dart`
    - `test/unit/auth_service_test.dart`
    - `test/unit/database_service_test.dart`
    - `test/unit/diary_controller_test.dart`
    - `test/unit/experience_controller_test.dart`
    - `test/widget_test.dart`
  - build APK debug `staging`
  - build APK debug `prod`

- Script local de preflight:
  - `preflight_release.ps1` (Windows/PowerShell)
  - `preflight_release.sh` (macOS/Linux)

## Comandos

- Windows:
  - `./preflight_release.ps1`
- macOS/Linux:
  - `./preflight_release.sh`

## Criterio Done (Dia 5)

- Toda PR/push valida lint + tests + builds de staging/prod.
- El gate evita smoke tests dependientes de Firebase runtime para no introducir falsos negativos en CI.
- Existe comando local unico para correr el mismo gate antes de deploy.
- Resultado esperado: solo se publica cuando el gate completo esta en verde.
