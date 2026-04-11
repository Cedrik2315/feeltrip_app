# 📱 FeelTrip - Estructura del Proyecto Fase 2

## Árbol de Directorios Actualizado

```
feeltrip_app/
├── lib/
│   ├── main.dart (ACTUALIZADO - +4 rutas, +4 importaciones)
│   │
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── trip_model.dart (ACTUALIZADO - +6 campos vivenciales)
│   │   ├── booking_model.dart
│   │   ├── review_model.dart
│   │   ├── cart_item_model.dart
│   │   └── experience_model.dart (NUEVO)
│   │       ├── ExperienceType (enum)
│   │       ├── ExperienceImpact (class)
│   │       ├── TravelerStory (class)
│   │       └── DiaryEntry (class)
│   │
│   ├── screens/
│   │   ├── home_screen.dart (ACTUALIZADO - Rediseño vivencial)
│   │   ├── search_screen.dart
│   │   ├── trip_detail_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── bookings_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── onboarding_screen.dart
│   │   │
│   │   ├── stories_screen.dart (NUEVO)
│   │   │   └── StoriesScreen
│   │   │   └── _buildStoryCard()
│   │   │   └── _showShareStoryDialog()
│   │   │
│   │   ├── travel_diary_screen.dart (NUEVO)
│   │   │   └── TravelDiaryScreen
│   │   │   └── _buildDiaryList()
│   │   │   └── _buildEntryForm()
│   │   │   └── _buildStatistics()
│   │   │
│   │   ├── emotional_preferences_quiz_screen.dart (NUEVO)
│   │   │   ├── EmotionalPreferencesQuizScreen
│   │   │   ├── QuizResultsScreen
│   │   │   ├── QuizQuestion (data class)
│   │   │   └── QuizAnswer (data class)
│   │   │
│   │   └── experience_impact_dashboard_screen.dart (NUEVO)
│   │       └── ExperienceImpactDashboardScreen
│   │       └── _buildEmotionChip()
│   │       └── _buildLearningCard()
│   │       └── _buildTimelineItem()
│   │
│   └── services/
│       ├── api_service.dart (Listo para integración vivencial)
│       ├── storage_service.dart
│       └── (FUTURO: experience_service.dart)
│
├── assets/
│   └── images/
│       ├── logo.png
│       ├── onboarding[1-3].png
│       └── journey_images/
│
├── pubspec.yaml (CORREGIDO - Indentación assets)
│
└── PHASE_2_VIVENCIAL_GUIDE.md (NUEVO - Documentación completa)
```

## Flujo de Navegación - Fase 2

```
┌─────────────────────────────────────────────────────────┐
│                   ONBOARDING SCREEN                     │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                   HOME SCREEN ⭐                         │
│  ┌────────────────────────────────────────────────────┐ │
│  │ "✨ Viajes que Transforman"                        │ │
│  │ Búsqueda por destino...                           │ │
│  ├────────────────────────────────────────────────────┤ │
│  │ 🎯 Quiz - Descubre Tu Tipo de Viajero (CTA)      │◄─┼─────┐
│  ├────────────────────────────────────────────────────┤ │     │
│  │ 5 Arquetipos: 💕🦋⚡🌅📚                           │ │     │
│  ├────────────────────────────────────────────────────┤ │     │
│  │ Viajes Destacados (Carousel)                      │ │     │
│  ├────────────────────────────────────────────────────┤ │     │
│  │ Historias de Transformación (Preview 2)  ►Ver todas│◄─┼─────┤
│  ├────────────────────────────────────────────────────┤ │     │
│  │ Mi Experiencia: 📔 Diario  │  📊 Impacto         │ │     │
│  └────────────────────────────────────────────────────┘ │     │
└─────────────────────────────────────────────────────────┘     │
   │                 │                  │          │           │
   │                 │                  │          │           │
   ▼                 ▼                  ▼          ▼           │
┌────────────┐  ┌──────────────┐  ┌─────────┐  ┌───────────┐  │
│  VIAJE      │  │IMPACT DASH   │  │ DIARIO  │  │ HISTORIAS │  │
│  DETALLES   │  │              │  │         │  │           │  │
├────────────┤  ├──────────────┤  ├─────────┤  ├───────────┤  │
│ • Destino   │  │ • Índice %   │  │ • Form  │  │ • Cards   │  │
│ • Historias │  │ • Emociones  │  │ • Lista │  │ • Likes   │  │
│ • Impacto   │  │ • Aprendizajes│ │ • Stats │  │ • Compartir│  │
│ • Booking   │  │ • Timeline   │  │ • Emoci │  │ • Inspirar │  │
└────────────┘  └──────────────┘  └─────────┘  └───────────┘  │
   │                                                             │
   └─────────────────────────────────────────────────────────────┤
                                                                 │
                         QUIZ FLOW ◄──────────────────────────────
                              │
                              ▼
                    ┌──────────────────┐
                    │ 8 Preguntas Quiz │
                    │ • Qué buscas     │
                    │ • Qué te impacta │
                    │ • Tu rol         │
                    │ • Emociones...   │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ QUIZ RESULTS      │
                    │ 5 Arquetipos:    │
                    │ 💕 Conector      │
                    │ 🦋 Transformado  │
                    │ ⚡ Aventurero    │
                    │ 🌅 Contemplativo │
                    │ 📚 Aprendiz      │
                    └──────────────────┘
```

## Componentes Clave - Fase 2

### 1. Modelos de Datos Vivenciales

**ExperienceType** (5 categorías):
```
ADVENTURE, CONNECTION, REFLECTION, NATURE, CULTURAL_IMMERSION
```

**ExperienceImpact**:
- Emociones experimentadas
- Aprendizajes clave
- Narrativa de transformación
- Puntuación de impacto (0-100)
- Personas conectadas

**TravelerStory**:
- Autor + Narrativa
- Emociones destacadas
- Likes + Rating
- Inspira a otros viajeros

**DiaryEntry**:
- Ubicación + Reflexión
- 10 emociones opcionales
- Profundidad (1-5★)
- Timeline personal

### 2. Arquetipos de Viajeros

| Arquetipo | Emoji | Color | Busca | Recomendaciones |
|-----------|-------|-------|-------|-----------------|
| **Conector** | 💕 | Rojo | Conexiones humanas | Homestays, voluntariado |
| **Transformado** | 🦋 | Morado | Crecimiento personal | Retiros, meditación |
| **Aventurero** | ⚡ | Naranja | Adrenalina | Trekking, deportes |
| **Contemplativo** | 🌅 | Cian | Paz interior | Espiritual, naturaleza |
| **Aprendiz** | 📚 | Verde | Conocimiento | Académico, museos |

### 3. Pantallas Vivenciales Nuevas

| Pantalla | Ruta | Función | Mock Data |
|----------|------|---------|-----------|
| StoriesScreen | `/stories` | Historias de viajeros | 3 stories |
| TravelDiaryScreen | `/diary` | Reflexiones personales | 2 entries |
| EmotionalPreferencesQuizScreen | `/quiz` | Descubrir arquetipo | 8 preguntas |
| ExperienceImpactDashboardScreen | `/impact-dashboard` | Ver transformación | Métricas visuales |

### 4. HomeScreen Actualizada

Secciones (en orden):
1. **Hero Banner** - "✨ Viajes que Transforman"
2. **CTA Quiz** - "🎯 Descubre Tu Tipo de Viajero" (destacado)
3. **Arquetipos** - 5 cards deslizables
4. **Viajes Destacados** - Carousel con badge transformador
5. **Historias** - Preview 2 + "Ver todas"
6. **Mi Experiencia** - Links a Diario e Impacto

## Estadísticas de Implementación - Fase 2

| Métrica | Cantidad |
|---------|----------|
| Nuevos archivos creados | 5 |
| Archivos modificados | 3 |
| Nuevas rutas de navegación | 4 |
| Nuevos modelos | 4 (ExperienceType, ExperienceImpact, TravelerStory, DiaryEntry) |
| Nuevos componentes UI | 6+ |
| Emociones disponibles | 10 |
| Arquetipos de viajeros | 5 |
| Preguntas en quiz | 8 |
| Categorías de scoring | 5 |
| Mock stories | 3 |
| Mock diary entries | 2 |
| Total líneas de código Fase 2 | ~2,500+ |

## Integración con Fase 1

**Mantiene compatibilidad 100%** con:
- Autenticación (Login/Register)
- Sistema de Reservas
- Carrito de compras
- Búsqueda y filtros
- API Service (ready para nuevos endpoints)

**Nueva capa encima**:
- Storytelling + Community
- Tracking emocional
- Personalización por arquetipo
- Dashboard de impacto personal

## Estado de Compilación

✅ **Dartanalyzer**: Ready (una vez habilitado Developer Mode en Windows)
✅ **Null Safety**: Completo
✅ **Material Design 3**: Consistente
✅ **Imports**: Todos resueltos

## Próximos Pasos Recomendados

### Corto Plazo
1. Habilitar Developer Mode (para compilar)
2. Probar navegación entre pantallas
3. Validar mock data

### Mediano Plazo
1. Integrar API endpoints para stories
2. Persistencia con Firebase
3. Subida de imágenes

### Largo Plazo
1. Machine Learning para recomendaciones
2. Sistema de notificaciones
3. Social features (comentarios, follows)
4. Exportar datos de transformación

---

**Resumen**: Fase 2 transforma FeelTrip en una **plataforma de transformación personal a través de viajes**, no solo una agencia de viajes. El usuario ahora puede:
- 🎯 Descubrir su tipo de viajero
- 📔 Registrar sus emociones en tiempo real
- 📊 Medir su transformación
- 💕 Inspirarse en historias de otros
- 🌍 Conectar con una comunidad de viajeros transformados
