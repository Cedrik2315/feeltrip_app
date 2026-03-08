# Dia 3 - Flujo real end-to-end + reduccion de fallback mock

Fecha: 2026-03-03

## Objetivo

Consolidar el flujo productivo:

`search -> trip detail -> cart -> bookings -> profile`

y evitar fallback silencioso a datos mock en `staging/prod`.

## Cambios implementados

- `lib/repositories/app_data_repository.dart`
  - En `APP_ENV != dev` (mock desactivado):
    - `searchTrips`: ya no cae a `MockData` en errores de API.
    - `getCurrentUserBookings`: ya no devuelve `MockData` si falta sesion o falla API.
    - `getCurrentUserProfile`: ya no usa `MockData.testUser` en no-auth.
  - Operaciones de carrito en modo real ahora exigen sesion:
    - `addOrUpdateCartItem`
    - `updateCartItemQuantity`
    - `removeCartItem`
    - `clearCurrentUserCart`
    - En no-auth lanzan excepcion para evitar "falsos exitos".

- `lib/main.dart`
  - Rutas agregadas para flujo MVP:
    - `/search`
    - `/cart`
    - `/bookings`
    - `/profile`

- `lib/screens/home_screen.dart`
  - Acciones en `AppBar` para navegar directamente a:
    - Buscar
    - Carrito
    - Reservas
    - Perfil

## Verificacion

- `flutter analyze` -> OK
- `flutter build apk --debug --dart-define=APP_ENV=staging` -> OK

## Resultado

- En `staging/prod`, si el backend no responde o el usuario no esta autenticado,
  la app ya no sustituye datos reales por mock en los flujos principales de Dia 3.
