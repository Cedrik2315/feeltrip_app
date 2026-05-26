# 🏔️ FeelTrip - Autonomous Travel Agent Ecosystem

## 📋 Resumen Ejecutivo
**FeelTrip** es una aplicación móvil de diario de viaje emocional que utiliza **orquestación de agentes de IA** (Scout Agent v2.0) y un sistema de monetización híbrido. El proyecto está en **Fase 5 (Revolución Agéntica)** e integra razonamiento autónomo con operaciones del mundo real (vuelos, clima, calendario).

---

## 🛠️ Stack Tecnológico Actual

| Componente | Tecnología | Versión | Estado |
|-----------|-----------|---------|--------|
| **Framework Mobile** | Flutter | 3.3.0+ | ✅ Activa |
| **State Management** | Riverpod | 2.5.1 | ✅ Migración Completa |
| **Backend** | Firebase Suite | Multi | ✅ Productivo |
| **IA / Agentes** | Google Gemini | 1.5 Flash | ✅ Integrada |
| **Local DB** | Isar + Hive | 3.1.0 / 1.1.0 | ✅ Offline-First |
| **Enrutamiento** | GoRouter | 17.2.0 | ✅ Activa |
| **Code Generation** | Freezed + Riverpod Gen | 2.4.6 / 2.4.0 | ✅ Activa |
| **Monetización** | RevenueCat + Mercado Pago | 10.0 / Beta | ⚠️ Beta |
| **Observabilidad** | Sentry + Firebase Crashlytics | 9.18.0 | ✅ Activa |

### Dependencias Clave
- **Geolocalización:** Geolocator, Geocoding, Google Maps
- **IA Multimodal:** ML Kit (Face, Text Recognition, Image Labeling)
- **Media:** Camera, Video Player, Chewie, Lottie
- **Audio/Música:** Just Audio, Spotify API, Flutter TTS
- **Pagos:** Flutter Stripe, Google Mobile Ads (AdMob)
- **Notificaciones:** Firebase Messaging, Flutter Local Notifications
- **Búsqueda:** Algolia
- **Persistencia Avanzada:** Drift (SQLite), Hive, Isar

---

## 🎯 Objetivos del Sprint Actual (Fase 5)

### Sprint Focus: Estabilización Agéntica
1. **Scout Agent v2.0 Hardening** → Loop multi-turno robusto
2. **Integración Amadeus** → Vuelos reales en recomendaciones
3. **Offline-First Garantizado** → Isar sincronización bidireccional
4. **Optimización de Costos de Tokens** → Reducir consumo de IA en 30%
5. **Testing en Dispositivos Físicos** → Moto G35+ para debug real

### Hitos Completados ✅
- [x] Migración completa a Riverpod
- [x] Sistema de Comentarios con Reacciones
- [x] Compartir en Redes Sociales (Deep Links)
- [x] Perfiles de Agencias (B2B)
- [x] Scout Agent Loop Básico
- [x] Firebase Crashlytics Integrada

---

## 📁 Estructura de Conocimiento

### Notas de Decisiones [[brain/key_decisions]]
Decisiones arquitectónicas críticas, tradeoffs, y patrones adoptados.

### Registro de Incidentes [[work/incidents]]
Bugs complejos, gotchas de Gradle/Android, soluciones permanentes.

### Backlog Activo [[work/active_backlog]]
Tareas pendientes, blockers, dependencias, estado de sprint.

---

## 🚀 Acciones Inmediatas

### En Progreso 🟡
1. **Bug: GoogleSignIn Duplicate API** → [RESUELTO]
   - Migrado a singleton pattern en `auth_repository_impl.dart`
   - Provider actualizado en `providers.dart`

2. **Optimización Agente** → En validación
   - Limitar iteraciones a max 5 turnos
   - Cache de búsquedas en Hive

### Próximos 🔜
1. **Integración Amadeus Real** → Pendiente aprobación API
2. **Wear OS Sync** → Ready para testing
3. **Cleanup de Análisis** → 100+ warnings por revisar

---

## 📊 Estado de Compilación
- **Build Status:** ✅ Success
- **Lint Warnings:** ⚠️ ~120+ (Categorizar y priorizar)
- **Tests:** ✅ Básicos pasando
- **Firebase:** ✅ Conectada

---

**Última Actualización:** 2026-05-26  
**Fase:** 5 (Revolución Agéntica)  
**Status General:** 🟢 Productivo + En Evolución