# 🗺️ MAPA INTEGRAL DE ARQUITECTURA - FeelTrip (Phases 1-5)

Este organigrama representa el ecosistema total de FeelTrip, consolidando los módulos sociales, de negocio, IoT e Inteligencia Agéntica.

```text
FEELTRIP GLOBAL ECOSYSTEM
│
├── 🎨 CAPA DE EXPERIENCIA (UI/UX - Flutter)
│   ├── 🏠 SOCIAL CORE:
│   │   ├── Feed & Discovery (Scroll infinito)
│   │   ├── Stories & Reels (Captura vivencial)
│   │   └── Comentarios & Reacciones (Real-time)
│   ├── 🤖 AGENTIC UI:
│   │   ├── Emotional Orbs (Visualización de intensidad AI)
│   │   └── Scout Dashboard (Recomendaciones validadas)
│   ├── 📈 BUSINESS (B2B):
│   │   ├── Agency Dashboard (KPIs de conversión)
│   │   └── Experience Impact (Métricas de usuario)
│   ├── ⌚ IOT / WEARABLE:
│   │   └── Wear OS Companion (Telemetría nativa)
│   └── 💳 ECO-SYSTEM:
│       ├── Onboarding (60s Flow)
│       ├── Referral System (Bonus Days)
│       └── Premium Access (RevenueCat)
│
├── 🧠 CAPA DE INTELIGENCIA (Agentic & Analytical Core)
│   ├── 🤖 AgentService (Orquestador Fase 5)
│   │   ├── 🛠️ Herramientas Autónomas (Tool Calling):
│   │   │   ├── Amadeus SDK (Vuelos Reales)
│   │   │   ├── Weather API (Pronóstico dinámico)
│   │   │   ├── EventScout (Actividades locales)
│   │   │   └── CalendarPush (Agenda automática)
│   │   └── 🧠 Motor: Gemini 1.5 Flash (Razonamiento)
│   └── ✍️ Analytical Engine (Legacy/Poetry):
│       ├── Crónicas Literarias (AI Novelist)
│       └── Sentiment Scoring (Métricas base)
│
├── ⚡ CAPA DE ESTADO (Reactive State - Riverpod)
│   ├── 💉 Inyección Global (ref.watch / ref.read)
│   ├── 🔄 Real-time Streams (Sync con Firestore)
│   └── 🚀 Notifiers (Lógica de interfaz segura)
│
├── 🏗️ CAPA DE INTEGRACIÓN (Services & Bridges)
│   ├── 🚢 Firebase: Auth, Messaging (FCM), Crashlytics.
│   ├── ⌚ WearBridge: MethodChannel Nativo.
│   ├── 💳 Payments: RevenueCat / Stripe / MercadoPago.
│   ├── 📊 Analytics: Firebase Analytics & Telemetría Pro.
│   └── 🌍 Mapping: Mapbox / OSM (Tiles Offline).
│
└── 💾 CAPA DE PERSISTENCIA (Hybrid Storage - Offline First)
    ├── ☁️ CLOUD (Firebase):
    │   ├── Firestore (Estructura NoSQL Jerárquica)
    │   └── Cloud Storage (Media & Assets)
    └── 🔌 LOCAL (On-Device):
        ├── Isar DB (Posts & Diario Offline)
        └── Hive (Configuración de Sesión & Cache)
```

---

### 🛣️ Evolución por Fases en el Mapa:
*   **Fase 1/2 (Social):** Estructura base de Feed, Stories y Auth.
*   **Fase 3 (B2B):** Integración de Dashboards y KPI Analytics.
*   **Fase 4 (Offline/IoT):** Migración a Isar/Riverpod y canal Wear OS.
*   **Fase 4.5 (E-Com):** Sistema de Referidos y RevenueCat.
*   **Fase 5 (Agentic):** AgentService y Tool Calling (Estado Actual).

---

**Arquitectura total proyectada para escala global y validación técnica ante Sercotec. 🏆**
