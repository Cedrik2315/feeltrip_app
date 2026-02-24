# 💰 Guía del Sistema de Ventas Automático

## Resumen
Hemos implementado un sistema que "vende" la aplicación automáticamente a los usuarios basándose en su comportamiento.

## Componentes

1. **`PricingPlan`**: Define qué vendemos (Basic vs Pro).
2. **`PremiumSubscriptionScreen`**: La "Landing Page" dentro de la app.
3. **`SalesAutomationController`**: El "Vendedor Robot" que decide cuándo mostrar la oferta.

## 🚀 Cómo Activar el Sistema

### Paso 1: Inicializar el Controlador
En tu `main.dart` o `home_screen.dart`, inyecta el controlador:

```dart
final salesController = Get.put(SalesAutomationController());
```

### Paso 2: Colocar los "Sensores" (Triggers)

**En `main.dart` (al iniciar):**
```dart
salesController.trackAppOpen();
```

**En `stories_screen.dart` (cuando ven una historia):**
```dart
salesController.trackStoryView();
```

### Paso 3: Proteger Funcionalidades (Premium Lock)

Si quieres que una función sea solo de pago (ej. Analytics en `agency_profile_screen.dart`):

```dart
if (!salesController.isPremium) {
  Get.to(() => PremiumSubscriptionScreen());
  return;
}
// ... mostrar analytics
```

## ☁️ Automatización Backend (Opcional)

Para automatizar emails de venta, crea una Cloud Function en `functions/src/sales_triggers.ts`:

```typescript
export const onUserSignup = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
     const user = snap.data();
     // Enviar email de bienvenida con descuento del 20%
     // Usar SendGrid o Firebase Extensions
  });
```

## 📊 Estrategia de Precios

- **Starter (Gratis):** Para atraer usuarios (Acquisition).
- **Agency Pro ($29.99/mes):** Para monetizar negocios (Revenue).
- **Traveler Premium ($4.99/mes):** Para monetizar usuarios finales (Volume).

¡El sistema ahora trabajará por ti las 24 horas! 🤖💸