# TODO.md - Plan de Corrección de Errores de Analyzer
Estado: En progreso (✓ completado, - pendiente, ! crítico)

## Bloque 1: mock_data.dart & Services Dynamics (70% errores)
- [ ] 1.1 lib/mock_data.dart: Fix todos dynamic casts (String?, double?, List<String>)
- ✓ 1.2 lib/services/country_service.dart, destination_service.dart, weather_service.dart: Casts en JSON responses (parcial - country_service.dart attempted, analyzer shows remaining)

- [ ] 1.3 Ejecutar `flutter analyze` y verificar reducción

## Bloque 2: Screens Críticas
- [ ] 2.1 lib/screens/login_screen.dart: Fix loginWithGoogle/Facebook calls
- [ ] 2.2 lib/screens/stories_screen.dart: Definir ExperienceController methods
- [ ] 2.3 lib/screens/premium_subscription_screen.dart: Dynamic en packages/offers

## Bloque 3: Generated Code & Models
- [ ] 3.1 `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] 3.2 lib/models/booking_model.dart: Regenerar .g.dart

## Bloque 4: Tests
- [ ] 4.1 test/services/booking_service_test.dart, sync_service_test.dart: Fix static/instance mocks

## Final
- [ ] `flutter analyze --no-fatal-infos` → 0 errors
- [ ] Update TODO_FIX_ALL_ERRORS.md
- [ ] Runtime tests per ERROR_CHECKLIST.md

Próximo paso: Bloque 1.1 mock_data.dart

