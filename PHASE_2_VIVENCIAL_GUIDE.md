# FeelTrip - Fase 2: Adaptación a Viajes Vivenciales

## Visión General
La Fase 2 transforma FeelTrip de una aplicación transaccional de agencias de viajes a una **plataforma de experiencias transformadoras**. El cambio fundamental es que los viajes ya no son solo destinos o actividades, sino **experiencias emocionales y vivenciales que cambian la perspectiva de vida de los viajeros**.

## Cambios Implementados

### 1. Nuevos Modelos de Datos (experience_model.dart)

#### ExperienceType (Enum)
Define los tipos de experiencias transformadoras disponibles:
- `ADVENTURE` - Experiencias de aventura y adrenalina
- `CONNECTION` - Conexiones humanas y culturales
- `REFLECTION` - Reflexión y crecimiento personal
- `NATURE` - Conexión con la naturaleza
- `CULTURAL_IMMERSION` - Inmersión cultural profunda

#### ExperienceImpact
Captura el impacto de una experiencia post-viaje:
- `emotions`: Lista de emociones experimentadas
- `learnings`: Aprendizajes clave obtenidos
- `transformationStory`: Narrativa de la transformación personal
- `impactScore`: Puntuación de impacto (0-100)
- `connectedSouls`: Personas con quienes se conectó

#### TravelerStory
Representa una historia real de transformación compartida por un viajero:
- Autor, título, narrativa completa
- `emotionalHighlights`: Emociones clave en la historia
- Calificación y cantidad de likes
- Facilita que otros viajeros se inspiren

#### DiaryEntry
Entrada de diario personal durante/después del viaje:
- `location`: Ubicación donde se escribió
- `content`: Reflexión personal
- `emotions`: Emociones experimentadas (10 opciones: Alegría, Asombro, Gratitud, Transformación, Miedo, Paz, Conexión, Nostalgia, Esperanza, Reflexión)
- `reflectionDepth`: Profundidad de reflexión (1-5 estrellas)

### 2. Modelo Trip Actualizado

Se agregaron campos vivenciales a la clase `Trip`:
```dart
String? experienceType;           // Tipo de experiencia (enum)
List<String> emotions = [];        // Emociones asociadas al viaje
List<String> learnings = [];       // Aprendizajes que genera
String? transformationMessage;     // Mensaje sobre transformación
List<String> culturalConnections = []; // Conexiones culturales
bool isTransformative = false;    // ¿Es una experiencia transformadora?
```

### 3. Nuevas Pantallas

#### StoriesScreen
**Propósito**: Exhibir historias reales de viajeros transformados

**Características**:
- Listado de `TravelerStory` en cards atractivas
- Cada card muestra: avatar del autor, título, extracto de la historia, emociones destacadas, calificación y likes
- Botón "Compartir mi Historia" que abre un diálogo para que usuarios agreguen sus propias narrativas
- Mock data: 3 historias (María - auroras boreales, Juan - conexión cultural, Isabella - identidad familiar)

#### TravelDiaryScreen
**Propósito**: Captura personal de emociones y reflexiones durante viajes

**Características**:
- Formulario para agregar nuevas entradas con:
  - Ubicación actual
  - Contenido de reflexión (texto libre)
  - Selección de hasta 5 emociones de 10 opciones disponibles
  - Profundidad de reflexión (1-5 estrellas)
- Lista de entradas con timeline layout
- Dashboard de estadísticas:
  - Total de entradas registradas
  - Profundidad promedio de reflexión
  - Emociones únicas rastreadas
- Mock data: 2 entradas mostrando progresión emocional

#### EmotionalPreferencesQuizScreen
**Propósito**: Identificar el tipo de viajero y personalizar recomendaciones

**Características**:
- Quiz de 8 preguntas sobre: qué buscan, qué les impacta, cómo miden éxito, emociones deseadas, miedos, rol en grupo, recuerdos ideales, preferencias de aprendizaje
- Scoring system que rastrea 5 categorías: conexión, transformación, aventura, reflexión, aprendizaje
- `QuizResultsScreen` que muestra el arquetipo del viajero con:

**5 Arquetipos de Viajeros**:
1. **Conector** (💕 Rojo) - Busca conexiones humanas
   - Recomendaciones: Homestays, trabajos voluntarios, talleres locales
2. **Transformado** (🦋 Morado) - Busca crecimiento personal
   - Recomendaciones: Retiros de reflexión, yoga, mindfulness
3. **Aventurero** (⚡ Naranja) - Busca adrenalina y emociones fuertes
   - Recomendaciones: Trekking, deportes extremos, expediciones
4. **Contemplativo** (🌅 Cian) - Busca paz interior y naturaleza
   - Recomendaciones: Retiros espirituales, fotografía, meditación
5. **Aprendiz** (📚 Verde) - Busca conocimiento y descubrimiento
   - Recomendaciones: Viajes académicos, museos, especializados

#### ExperienceImpactDashboardScreen
**Propósito**: Visualizar la transformación personal acumulada

**Características**:
- Índice de Transformación Visual (gauge 0-100%)
- Emociones Experimentadas con percentiles de ocurrencia
- Aprendizajes Clave categorizado (Aceptación, Compasión, Propósito, Fortaleza, etc.)
- Personas que Impactaste (amigos nuevos, mentores, historias compartidas)
- Línea de Tiempo de Transformación mostrando viajes pasados con impacto individual
- Recomendaciones de Próximos Pasos basadas en patrón de transformación
- Botón "Compartir Mi Transformación" para redes sociales

### 4. HomeScreen Rediseñada

**Cambios principales**:
- Hero banner actualizado: "✨ Viajes que Transforman" (no solo destinos)
- **CTA prominente**: "🎯 Descubre Tu Tipo de Viajero" con enlace al quiz
- **Sección de Arquetipos**: 5 cards horizontales deslizables mostrando los tipos de viajeros
- **Historias de Transformación**: Preview de 2 historias destacadas con "Ver todas"
- **Mi Experiencia**: Acceso rápido a:
  - 📔 Mi Diario (TravelDiaryScreen)
  - 📊 Mi Impacto (ExperienceImpactDashboardScreen)
- Badge "Experiencia Transformadora" en viajes que cumplen ese criterio

### 5. Sistema de Routing (main.dart)

Nuevas rutas agregadas:
```dart
'/stories': (context) => StoriesScreen(),
'/diary': (context) => TravelDiaryScreen(),
'/quiz': (context) => EmotionalPreferencesQuizScreen(),
'/impact-dashboard': (context) => ExperienceImpactDashboardScreen(),
```

### 6. Correcciones Técnicas

- **pubspec.yaml**: Reparada indentación en sección `assets`
- Importaciones agregadas para nuevos modelos en `main.dart` y `home_screen.dart`

## Arquitectura de Datos

### Flow de Aplicación Vivencial

1. **Onboarding** → Usuario entra a app
2. **HomeScreen** → Ve 5 arquetipos de viajeros + CTA de Quiz
3. **Quiz** → Completa 8 preguntas
4. **Quiz Results** → Ve su arquetipo personalizado + recomendaciones de viajes
5. **Trip Details** → Lee historias de otros viajeros + impacto de la experiencia
6. **Durante Viaje**:
   - Usa **Travel Diary** para registrar emociones diarias
   - Ve **Stories** de otros viajeros en tiempo real
7. **Post-Viaje**:
   - Accede **Impact Dashboard** para ver transformación acumulada
   - Comparte su propia historia
   - Recibe recomendaciones para próximos viajes

## Mock Data Incluido

### Stories Mock Data
- **María García**: Auroras boreales en Tromsø (347 likes, 5.0★)
- **Juan López**: Conexión cultural en Perú (512 likes, 5.0★)
- **Isabella Romano**: Identidad familiar en Italia (289 likes, 4.8★)

### Diary Entries Mock Data
- Entrada 1: Conexión emocional inicial (emociones: Asombro, Gratitud)
- Entrada 2: Transformación personal (emociones: Paz, Reflexión, Transformación)

### Quiz Results
- 40 opciones de respuesta distribuidas en 8 preguntas
- Scoring automático en 5 categorías
- Perfil personalizado generado

## Próximos Pasos para Integración Backend

1. **API Endpoints Necesarios**:
   - `GET /api/stories` - Cargar historias de otros viajeros
   - `POST /api/stories` - Crear nueva historia
   - `GET /api/diary/:userId` - Cargar diario del usuario
   - `POST /api/diary` - Crear entrada de diario
   - `GET /api/impact/:userId` - Cargar métricas de impacto
   - `PUT /api/trips/:tripId` - Actualizar campos vivenciales

2. **Persistencia**:
   - Firebase Firestore para historias y diarios (con timestamp)
   - SharedPreferences para quiz results locales
   - Cloud Storage para imágenes de historias

3. **Notificaciones**:
   - Alertar cuando alguien comenta en tu historia
   - Sugerir viajes basados en tu arquetipo
   - Recordar escribir en diario si estás en un viaje activo

4. **Machine Learning (Futuro)**:
   - Recomendar viajes según emociones buscadas
   - Clustering de viajeros similares para networking
   - Predicción de impacto basada en histórico

## Filosofía de Diseño

El cambio de "travel agency app" a "transformative experience platform" se refleja en:

1. **Lenguaje**: Cambio de "Destinos" a "Transformaciones"
2. **Métricas**: De "mejor precio" a "impacto personal"
3. **Narrativa**: De "qué hacer" a "quién seré después"
4. **Comunidad**: Storytelling de otros viajeros como inspiración
5. **Reflexión**: El diario como herramienta de captura emocional

## Archivo Summary

| Archivo | Tipo | Cambio |
|---------|------|--------|
| `experience_model.dart` | Nuevo | Modelos ExperienceImpact, TravelerStory, DiaryEntry, ExperienceType |
| `trip_model.dart` | Modificado | +6 campos vivenciales |
| `stories_screen.dart` | Nuevo | Exhibición de historias de viajeros |
| `travel_diary_screen.dart` | Nuevo | Captura de reflexiones y emociones |
| `emotional_preferences_quiz_screen.dart` | Nuevo | Quiz de 8 preguntas + 5 arquetipos |
| `experience_impact_dashboard_screen.dart` | Nuevo | Dashboard de transformación |
| `home_screen.dart` | Modificado | Rediseño vivencial + nuevas secciones |
| `main.dart` | Modificado | +4 nuevas rutas + importaciones |
| `pubspec.yaml` | Modificado | Corrección de indentación |

## Notas Importantes

- Todas las nuevas pantallas usan **mock data** para demostración
- Los emoticonos (🎯, 💕, 🦋, etc.) son parte del branding vivencial
- El sistema es **extensible**: Se pueden agregar más arquetipos o categorías de aprendizaje
- Null-safety completo: Todos los campos opcionales están tipados correctamente
- Compatible con Material Design 3 del proyecto

---

**Fase 2 Completada**: La app ahora enfatiza experiencias transformadoras en lugar de transacciones de viajes.
