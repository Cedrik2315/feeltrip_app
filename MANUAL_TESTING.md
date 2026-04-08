# MANUAL TESTING

## Objetivo
Checklist corta para validar el release candidate real de FeelTrip.

## Smoke test core

### 1. Auth
- Abrir app.
- Verificar splash y ruta inicial.
- Login con email valido.
- Login con Google.
- Login con Facebook.
- Logout.
- Recovery / forgot password.

### 2. Navegacion
- Entrar a home.
- Navegar a search.
- Navegar a bookings.
- Navegar a notifications.
- Volver atras sin errores de routing.

### 3. Search
- Buscar por titulo.
- Buscar por destino.
- Confirmar que queries cortas no rompan la UI.
- Confirmar que la lista no duplique resultados.

### 4. Diario y momentos
- Crear momento.
- Confirmar guardado local.
- Ver estado `pending` o `synced`.
- Simular reconexion y reintento de sync.
- Confirmar que el momento reaparece al reabrir la app.

### 5. Premium
- Abrir paywall.
- Cargar offerings.
- Comprar si hay entorno disponible.
- Restaurar compra.
- Confirmar estado premium en UI.

### 6. Bookings
- Crear booking.
- Confirmar que aparece en la pantalla de reservas.
- Verificar estado local y cloud coherente.
- Confirmar que no hay duplicados.

### 7. Notifications
- Abrir centro de notificaciones.
- Ver contador.
- Abrir una notificacion.
- Confirmar marcado como leida.
- Confirmar navegacion al destino correcto.

### 8. Smart camera / IA (OCR/Visión - OSINT EXPERIMENTAL)
- [ ] Capturar o seleccionar imagen con Smart Camera.
- [ ] Ver análisis visión (labels/sentiment/OCR).
- [ ] Traducción OCR si texto detectado.
- [ ] OSINT/Trip proposal: EXPERIMENTAL (lib/experimental/osint_ai_service.dart)
- [ ] Confirmar errores claros si falla.

### 9. Observabilidad
- Confirmar que Sentry/Crashlytics inicializan.
- Revisar logs de auth, payments, sync y camera.

## Gate de aprobacion
El build queda aprobado si:
- no hay crashes en flujos core,
- auth funciona,
- search funciona,
- diario persiste,
- premium funciona o falla de manera clara,
- bookings son consistentes,
- notifications navegan bien.

## Resultado
Registrar para cada flujo:
- Pass
- Fail
- Notas
- Dispositivo
- Version probada

