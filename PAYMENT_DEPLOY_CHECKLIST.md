# PAYMENT DEPLOY CHECKLIST

## Objetivo
Checklist corto para desplegar y validar el flujo de pago server-side sin sorpresas.

## 1. Configuración obligatoria de Functions
Ejecutar y confirmar estos valores antes del deploy:

```powershell
npx -y firebase-tools@latest functions:config:get
```

Debe existir como mínimo:
- `mercadopago.token`
- `app.base_url`

Opcional pero recomendado:
- `app.webhook_url`

Ejemplo:

```powershell
npx -y firebase-tools@latest functions:config:set mercadopago.token="TU_ACCESS_TOKEN"
npx -y firebase-tools@latest functions:config:set app.base_url="https://feeltrip.app"
npx -y firebase-tools@latest functions:config:set app.webhook_url="https://us-central1-<PROJECT_ID>.cloudfunctions.net/mercadopagoWebhook"
```

## 2. Validaciones locales antes de deploy
```powershell
node --check functions/index.js
npm --prefix functions run lint
flutter analyze lib/services/booking_service.dart test/payment_repository_test.dart test/services/booking_service_test.dart
flutter test test/payment_repository_test.dart test/services/booking_service_test.dart
```

## 3. Deploy
```powershell
npx -y firebase-tools@latest deploy --only functions
```

## 4. Validaci�n m�nima post deploy
- `createMercadoPagoPreference` existe en logs y responde sin `internal error`.
- `toggleStoryLike` sigue funcionando.
- El booking queda en `pending` antes de abrir checkout.
- El checkout devuelve `preferenceId` e `initPoint`.
- El webhook marca `bookings/{bookingId}.status = paid` tras pago aprobado.
- Se guarda `paymentId` y `paymentStatus = approved`.

## 5. Se�ales de No-Go
- `npm run lint` falla en predeploy.
- `functions.config().mercadopago.token` no existe.
- `createMercadoPagoPreference` responde payload incompleto.
- El monto enviado no coincide con el booking.
- El webhook no actualiza `bookings`.
