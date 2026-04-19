# 📂 ESTRUCTURA DEL PROYECTO - FeelTrip (Fase 5)

Esta es la organización del código fuente de FeelTrip, optimizada para un sistema mult-agente y escalabilidad global.

```text
lib/
├── config/                 # Configuración de Firebase y Entorno
│   ├── firebase_config.dart
│   └── firebase_options.dart
│
├── core/                   # Núcleo de la Aplicación
│   ├── di/                 # Inyección de Dependencias (Riverpod Providers)
│   │   └── providers.dart
│   ├── theme/              # Cyber-Organic Design System
│   └── utils/              # Helpers y Extensiones
│
├── models/                 # Modelos de Datos (Type-Safe)
│   ├── agency_model.dart
│   ├── comment_model.dart
│   ├── diary_model.dart
│   └── emotional_prediction.dart
│
├── screens/                # UI Layer (Consumers de Riverpod)
│   ├── home_screen.dart
│   ├── emotional_prediction_screen.dart # Agentic UI
│   ├── diary_screen.dart
│   ├── agency_dashboard_screen.dart
│   └── ... 30+ pantallas adicionales
│
├── services/               # Infrastructure Layer
│   ├── agent_service.dart  # 🤖 EL CEREBRO: Agentic Loop & Reasoning
│   ├── amadeus_service.dart # ✈️ Vuelos Reales
│   ├── auth_service.dart
│   ├── storage_service.dart (Isar / Hive)
│   └── wear_sync_service.dart # IoT IoT Companion
│
└── main.dart               # Punto de entrada y Bootstrap
```

---

## 🛠️ Convenciones de Código
1. **Providers:** Todo el estado debe ser accedido vía `ref.watch()` o `ref.read()` de Riverpod.
2. **Servicios:** Los servicios deben ser inyectados vía providers para facilitar el mofcking en tests.
3. **Agentes:** El `AgentService` es el único responsable del razonamiento autónomo. Las herramientas (Tools) deben ser métodos privados dentro del servicio o servicios dedicados inyectados.
4. **Offline-First:** Siempre que sea posible, leer primero de Isar/Hive antes que de Firestore.

---

**Estructura mantenible, testeable y orientada a Agentes. ✅**
