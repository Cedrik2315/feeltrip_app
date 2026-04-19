# 🛣️ ROADMAP FEELTRIP - Evolución Agéntica

Roadmap enfocado en convertir FeelTrip en el líder de **Viajes Autónomos (Travel-Agentic)**, integrando IA de razonamiento con operaciones del mundo real.

---

## ✅ Fase 1-4: Estabilización y Crecimiento (COMPLETADA)
- **Fase 1/2:** Foundation, Auth, Social Layer (Stories/Reels).
- **Fase 3:** Dashboards B2B y Metrics para agencias.
- **Fase 4:** Migración a Riverpod, Isar Offline y soporte para Wear OS.
- **Fase 4.5:** Sistema de Referidos y RevenueCat estable.

---

## 🚀 Fase 5: Revolución Agéntica (ACTUAL - En Despliegue)
- **Scout Agent v2.0:** Razonamiento autónomo basado en Gemini 1.5.
- **Real-World Tooling:** 
  - Vuelos reales vía **Amadeus API**.
  - Clima y Actividades dinámicas.
  - Agenda automática en Calendario.
- **Arquitectura de Agentes:** Orquestación centralizada en `AgentService` con loop multi-turno.
- **Hardening de IA:** Limitación de iteraciones y manejo de errores proactivo.

---

## 🏗️ Fase 6: Transacciones & Enterprise (Próximo Semestre)
- **Booking Directo:** Integración de checkout para vuelos y actividades sugeridas por el agente.
- **Backend de Pagos:** Implementación de webhooks para Mercado Pago y confirmación de transacciones en la nube (FCM).
- **IA Multimodal B2B:** El agente podrá analizar fotos enviadas por agencias para generar crónicas automáticas en el feed.
- **Escala de Datos:** Optimización de consultas en Firestore y caché agresiva para reducir costos de IA.

---

## 🎯 Prioridades de Negocio
1. **Retención via Agente:** Que el Scout Agent motive al usuario a descubrir su próximo destino basado en su salud mental/emocional.
2. **Conversión Pro:** Venta de acceso a herramientas premium del agente (Vuelos reales, Agenda proactiva).
3. **Alianzas B2B:** Integración de inventarios de terceros directamente en el flujo del agente.

---

## 🛡️ Riesgos & Desafíos
- **Costos de Tokens:** El loop agéntico consume más tokens que prompts simples. Requiere optimización.
- **Precisión de Herramientas:** La API de Amadeus debe estar siempre disponible y sincronizada.
- **Privacidad:** Asegurar que los datos del diario (entrada para la IA) se manejen con encriptación de extremo a extremo en el futuro.

---

**FeelTrip está transformando la planificación pasiva en descubrimiento proactivo. ✅**
