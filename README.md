# FeelTrip

Aplicacion mobile de travel-tech construida con Flutter, Firebase y Riverpod.

## Estado actual
- Release candidate tecnico, no release final.
- `flutter analyze`: limpio.
- Arquitectura: transicion de legacy a Clean Architecture parcial.
- Offline: soporte local honesto para momentos y cola minima de sync.
- Monetizacion: RevenueCat funcional; Mercado Pago en modo beta client-side.
- IA: OCR y recomendacion contextual; no se presenta como OSINT real.

## Stack principal
- Flutter
- Riverpod
- GoRouter
- Firebase Auth / Firestore / Storage / Messaging / Analytics
- Hive para persistencia local actual
- RevenueCat
- Mercado Pago
- Gemini AI + ML Kit
- Sentry + Crashlytics

## Notas de Configuración
- **Analyzer**: Se utiliza la versión 6.4.1 del analyzer. Si experimentas conflictos de dependencias en local, 
  revisa las `dependency_overrides` en el `pubspec.yaml`.
- **Variables de Entorno**: Requiere un archivo `.env` con las llaves de MercadoPago, Gemini y Sentry.

## Lo que hoy si funciona
- Auth con email y social login
- Navegacion base con GoRouter
- Search funcional con filtros basicos y busqueda por titulo/destino
- Diario y momentos con persistencia local y estado de sync
- Premium con RevenueCat
- Bookings unificados con source of truth consistente
- Notificaciones in-app y contador real
- Smart camera con OCR y propuesta contextual

## Lo que sigue en beta o incompleto
- Mercado Pago sin backend/webhooks completos
- Sync offline-first avanzado
- Cobertura de tests todavia lejos de un nivel enterprise
- Search avanzado con ranking dedicado
- Automatizacion fuerte de growth y BI

## Definicion honesta de release
FeelTrip esta listo para demos, validacion con usuarios y hardening final de lanzamiento.
No debe presentarse como sistema listo para 1M usuarios ni como plataforma con backend financiero completo.

## Comandos utiles
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Prioridades inmediatas
1. Hardening de pagos y webhooks.
2. Mejorar cobertura de tests en flujos criticos.
3. Refinar sync y conflicto offline/online.
4. Ajustar docs operativas y checklist de release.

## Referencias
- [ARCHITECTURE_MAP.md](./ARCHITECTURE_MAP.md)
- [PLAN_PRODUCCION.md](./PLAN_PRODUCCION.md)
- [ROADMAP.md](./ROADMAP.md)
- [MANUAL_TESTING.md](./MANUAL_TESTING.md)
