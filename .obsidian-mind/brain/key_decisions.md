# 🧠 Key Architectural Decisions

## Decisiones Críticas que Definen FeelTrip

### 1. ✅ Migración Completa a Riverpod (Fase 4 → 5)
**Decisión:** Abandonar GetX y Provider en favor de Riverpod puro  
**Razón:** Type-safe, compile-time validation, mejor composability para agentes complejos

**Status:** ✅ Completo, probado en producción

---

### 2. 🤖 Scout Agent v2.0 - Tool Calling Autónomo
**Decisión:** Implementar razonamiento multi-turno con Gemini 1.5 Flash  
**Razón:** 70% más barato que Claude/GPT-4, native tool calling, context window 1M tokens

**Status:** ✅ MVP funcional, en hardening

---

### 3. 📱 Offline-First con Isar + Hive
**Decisión:** Dual persistencia local (Isar para datos complejos, Hive para config)  
**Razón:** Isar = SQLite performance con tipo-safety, Hive = lightning-fast key-value

**Status:** 🟡 Sync bidireccional en validación

---

### 4. 🔄 Freezed + JSON Serialization para Models
**Decisión:** Code generation para immutability + serialization  
**Razón:** Type-safe copy() methods, automatic hashCode/equality, ideal para Riverpod + Firestore

**Status:** ✅ Estándar en toda la codebase

---

### 5. 🌍 Amadeus API para Vuelos Reales
**Decisión:** Integrar endpoint real de Amadeus en lugar de mock data  
**Razón:** Datos actualizados, precios en tiempo real, base para future checkout

**Status:** 🟠 Awaiting sandbox credentials

---

### 6. 💳 RevenueCat para Suscripciones
**Decisión:** Usar RevenueCat como intermediario (no SDKs de Apple/Google directamente)  
**Razón:** Abstracción de IAP differences, webhook centralizados, easiest path a Mercado Pago

**Status:** ✅ Integrada, probada en emulador

---

### 7. 🎬 Social Layer - Stories + Reels
**Decisión:** TikTok-like feed con Firestore subcollections  
**Razón:** Engagement driver para retención, B2B opportunity, real-time updates

**Status:** ✅ Completo + comentarios con reacciones

---

### 8. 📊 Wear OS Companion App
**Decisión:** Flutter para Wear OS (no Kotlin nativo)  
**Razón:** Code sharing, faster development, smaller APK

**Status:** 🟡 Ready para testing en hardware real

---

### 9. 🔐 Encriptación de Datos Sensibles
**Decisión:** Encrypt at rest en Hive/Isar para diarios + diálogos con agente  
**Razón:** Privacy, GDPR prep, datos personales nunca en plaintext local

**Status:** ⚠️ Planned pero no implementado aún

---

### 10. 🧪 Testing Strategy
**Decisión:** Unit tests + Integration tests, NO E2E automation (manual only)  
**Razón:** E2E flaky en emuladores, manual testing más confiable con dispositivos reales

**Status:** 🟡 ~60% coverage, improving

---

**Última Actualización:** 2026-05-26