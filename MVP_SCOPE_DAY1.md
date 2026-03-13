# Dia 1 - Alcance MVP + Flags de Produccion

Fecha: 2026-03-03

## Objetivo cerrado

Definir el alcance navegable del MVP, ocultar senales demo fuera de desarrollo e introducir entornos `dev|staging|prod`.

## Alcance MVP activo

- Onboarding: `OnboardingScreen`
- Auth: `LoginScreen`, `RegisterScreen`, `AuthGate`
- Home y discovery: `HomeScreen`, `TripDetailScreen`, `SearchScreen`
- Experiencia vivencial: `DiarioScreen`, `StoriesScreen`, `CommentsScreen`, `ExperienceImpactDashboardScreen`, `QuizScreen`, `ResultsScreen`
- Commerce MVP: `CartScreen`, `BookingsScreen`
- Cuenta: `ProfileScreen`

## Fuera de alcance MVP (oculto/no principal)

- Flujo legacy de entrada post-login: `MainNavigationScreen` (ya no es destino principal despues de login)
- Pantallas experimentales/no enlazadas al flujo principal:
  - `ReelsScreen`
  - `TravelDiaryScreen`
  - `EmotionalPreferencesQuizScreen`
  - `AgencyProfileScreen` (sin acceso en shell principal)

## Politica de entornos

Archivo: `lib/config/app_flags.dart`

- `APP_ENV=dev|staging|prod`
- `USE_MOCK_DATA=true|false` (override explicito)

Reglas:

- `dev`: usa mock por defecto.
- `staging`: usa datos reales por defecto.
- `prod`: usa datos reales por defecto.
- Indicadores visuales demo (`DEMO`, banners mock) solo se muestran en `dev`.

## Comandos de build recomendados

- Dev:
  - `flutter run --dart-define=APP_ENV=dev`
- Staging:
  - `flutter run --dart-define=APP_ENV=staging`
  - `flutter build apk --dart-define=APP_ENV=staging`
- Prod:
  - `flutter build appbundle --dart-define=APP_ENV=prod`

## Criterio Done (Dia 1)

- Alcance MVP documentado y cerrado: `MVP_SCOPE_DAY1.md`.
- `staging/prod` sin banners demo en UI.
- Login redirige al flujo MVP principal (`/home`) y no al flujo legacy.
