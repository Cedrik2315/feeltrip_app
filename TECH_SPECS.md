# 🛠️ ESPECIFICACIONES TÉCNICAS - FeelTrip (Fase 5: Agentic Era)

## 📋 Resumen Ejecutivo
FeelTrip es un ecosistema agéntico de Travel-Tech que utiliza modelos avanzados de lenguaje (LLMs) y orquestación de herramientas para automatizar el descubrimiento y la planificación de viajes.

**Stack Tecnológico Actual:**
- **Framework:** Flutter 3.19+ (Canal Estable).
- **Lenguaje:** Dart 3.3+.
- **Arquitectura:** Reactive Functional Architecture (Riverpod 2.5).
- **IA Core:** Google Generative AI (Gemini 1.5 Flash) con **Autonomous Tool Calling**.

---

## 🏗️ Arquitectura del Sistema

### Capas de Responsabilidad (Fase 5)
```
┌─────────────────────────────────┐
│     UI Layer (Riverpod Consumers)│
│  (Modern Reactive Orbs & Dash)   │
├─────────────────────────────────┤
│     AgentCore (Autonomous Logic) │
│  (Scout Agent / Tool Orchestrator)│
├─────────────────────────────────┤
│     Infrastructure (Services)    │
│  (Amadeus, Firebase, Wear Sync)  │
├─────────────────────────────────┤
│     Data Layer (Hybrid Sync)     │
│  (Isar Offline / Firestore Cloud)│
└─────────────────────────────────┘
```

---

## 🦾 Especificaciones de IA (Scout Agent)

### Capacidades Agénticas
- **Razonamiento:** Loop multi-turno de hasta 5 iteraciones.
- **Herramientas (Tools):**
    - `searchFlights`: Conexión real via **Amadeus API**.
    - `getWeather`: Validación de condiciones climáticas proactiva.
    - `addCalendarEvent`: Integración con calendarios nativos.
    - `searchActivities`: Búsqueda de eventos locales según arquetipo.

---

## 🔌 Integraciones Principales

| Categoría | Solución | Propósito |
|---------|---------|-----------|
| **Estado** | `flutter_riverpod` | Gestión reactiva e inmutable. |
| **Persistencia** | `isar` / `hive` | Almacenamiento Offline-First de alta velocidad. |
| **Vuelos** | `Amadeus REST API` | Búsqueda y cotización de vuelos en vivo. |
| **IA** | `google_generative_ai` | Razonamiento y procesamiento natural. |
| **Suscripciones** | `purchases_flutter` | Gestión de Pro-access via RevenueCat. |
| **IoT** | `wear` SDK | Canal nativo con smartwatches. |

---

## 📊 Especificaciones de Dispositivos

| Requisito | Android | iOS |
|-----------|---------|-----|
| **OS Mínimo** | 5.0 (API 21) | 12.0 |
| **RAM Recomendada** | 3GB+ | 3GB+ |
| **Almacenamiento** | 150MB | 150MB |
| **IoT** | Wear OS 3.0+ | Apple Watch (Projected) |

---

## 🔐 Seguridad & Datos
- **Autenticación:** Firebase Auth (JWT Tokens).
- **Seguridad en IA:** Límites de iteración forzados por código para evitar recursion infinita.
- **Privacidad:** Los diarios personales se procesan como entradas temporales para el prompt agéntico, no se almacenan como texto plano en logs externos.

---

## ⚡ Rendimiento (Target Metriz)
- **Agent Reasoning:** < 5 segundos para itinerario completo.
- **Cold Boot:** < 2.5 segundos.
- **Offline Sync:** Latencia < 500ms al recuperar conexión.
- **Frame Rate:** 120 FPS (DisplayMode optimizado).

---

**Documento versión**: 2.0 (Fase 5) | **Status**: ✅ Active Product Development
