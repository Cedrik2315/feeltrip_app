# 📚 Guía de Uso - Pantallas Vivenciales

## 1. Stories Screen (Historias de Transformación)

### Acceso
```dart
Navigator.of(context).pushNamed('/stories');
```

### Qué Muestra
Una lista scrolleable de historias reales de viajeros transformados.

### Interfaz
```
┌─────────────────────────────────────┐
│ Historias de Transformación         │
├─────────────────────────────────────┤
│ ┌────────────────────────────────┐  │
│ │ 👤 María García                │  │
│ │ ⭐ Bajo la aurora boreal      │  │
│ │                                │  │
│ │ "En Tromsø, vimos las luces... │  │
│ │ Lloré de alegría..."           │  │
│ │                                │  │
│ │ 😲 Asombro  🙏 Gratitud  🦋 Transformación │
│ │                                │  │
│ │ ❤️ 347 likes                   │  │
│ └────────────────────────────────┘  │
│ ┌────────────────────────────────┐  │
│ │ 👤 Juan López                  │  │
│ │ ⭐ Conexión en Perú            │  │
│ │ ... [similar layout]           │  │
│ └────────────────────────────────┘  │
└─────────────────────────────────────┘
```

### Funcionalidades
- **Lectura**: Lee historias completas de otros viajeros
- **Emociones Etiquetadas**: Ve qué sintió cada viajero
- **Like**: Muestra apreciación (visualización)
- **Compartir Tu Historia**: Botón en cada card para agregar la tuya
- **Inspiración**: Descubre cómo otros fueron transformados

### Mock Data Incluido
```dart
TravelerStory(
  author: 'María García',
  title: 'Bajo la aurora boreal',
  story: 'En Tromsø, vimos las luces del norte...',
  emotionalHighlights: ['Asombro', 'Gratitud', 'Transformación'],
  likes: 347,
  rating: 5.0,
  createdAt: DateTime.now().subtract(Duration(days: 7)),
)
```

### Próxima Integración
```dart
// Cuando implementes backend:
Future<List<TravelerStory>> getStories() async {
  final response = await http.get(Uri.parse('$baseUrl/api/stories'));
  // Parsear y retornar lista
}
```

---

## 2. Travel Diary Screen (Diario de Viaje)

### Acceso
```dart
Navigator.of(context).pushNamed('/diary');
```

### Qué Muestra
Interfaz para capturar reflexiones emocionales durante viajes + historial.

### Interfaz
```
┌──────────────────────────────────────┐
│ Mi Diario de Viaje                   │
├──────────────────────────────────────┤
│                                      │
│ AGREGAR NUEVA ENTRADA                │
│ ┌──────────────────────────────────┐ │
│ │ 📍 Ubicación: Tromsø             │ │
│ │                                  │ │
│ │ Reflexión: [textarea]            │ │
│ │ "Hoy vi las auroras..."          │ │
│ │                                  │ │
│ │ Emociones (elige hasta 5):       │ │
│ │ [Alegría] [Asombro] [Gratitud]   │ │
│ │ [Transformación] [Paz Interior]  │ │
│ │                                  │ │
│ │ Profundidad de Reflexión:        │ │
│ │ ⭐⭐⭐⭐⭐ (5)                      │ │
│ │                                  │ │
│ │ [GUARDAR ENTRADA]                │ │
│ └──────────────────────────────────┘ │
│                                      │
│ ESTADÍSTICAS                         │
│ • 2 entradas registradas             │
│ • Profundidad promedio: 4.5⭐        │
│ • Emociones únicas: 6                │
│                                      │
│ HISTÓRICO                            │
│ ┌──────────────────────────────────┐ │
│ │ 🔴 Hoy - 14:32                   │ │
│ │ Ubicación: Tromsø                │ │
│ │ "Las auroras han sido..."        │ │
│ │ 😲 Asombro, 🙏 Gratitud         │ │
│ │ Profundidad: ⭐⭐⭐⭐⭐           │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ 🔴 Ayer - 10:15                  │ │
│ │ Ubicación: Airport Tromsø        │ │
│ │ "Nerviosa pero emocionada..."    │ │
│ │ 😨 Miedo, 🎉 Esperanza           │ │
│ │ Profundidad: ⭐⭐⭐               │ │
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

### Emociones Disponibles (10)
1. 😊 Alegría
2. 😲 Asombro
3. 🙏 Gratitud
4. 🦋 Transformación
5. 😨 Miedo
6. 🧘 Paz Interior
7. 💕 Conexión
8. 🍂 Nostalgia
9. 🌅 Esperanza
10. 💭 Reflexión

### Funcionalidades
- **Crear Entrada**: Registra ubicación, reflexión, emociones, profundidad
- **Ver Histórico**: Lista todas tus entradas con timeline
- **Estadísticas**: Ve métricas de tu progreso emocional
- **Filtrar por Emoción**: Próximo: ver tendencias
- **Exportar Diario**: Próximo: descargar como PDF

### Mock Data Incluido
```dart
DiaryEntry(
  id: 'diary_1',
  location: 'Tromsø, Noruega',
  content: 'Las auroras boreales fueron lo más hermoso que he visto...',
  emotions: ['Asombro', 'Gratitud', 'Transformación'],
  reflectionDepth: 5,
  createdAt: DateTime.now(),
)
```

### Próxima Integración
```dart
// Guardar en Firebase
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('diaryEntries')
  .add(diaryEntry.toJson());
```

---

## 3. Emotional Preferences Quiz Screen

### Acceso
```dart
Navigator.of(context).pushNamed('/quiz');
```

### Qué Muestra
Quiz interactivo de 8 preguntas para descubrir tu tipo de viajero.

### Interfaz - Durante Quiz
```
┌──────────────────────────────────────┐
│ 🎯 Descubre Tu Tipo de Viajero      │
├──────────────────────────────────────┤
│                                      │
│ Pregunta 3 de 8                      │
│ [████░░░░░░░░░░░░░░]                │
│                                      │
│ ¿Qué es lo más importante para ti   │
│ en un viaje?                         │
│                                      │
│ ○ Conocer gente local                │
│ ○ Descubrir cosas sobre mí           │
│ ○ Vivir experiencias extremas        │
│ ○ Conectar con la naturaleza         │
│ ○ Aprender cosas nuevas              │
│                                      │
│ ● ● ○ ○ ○ ○ ○ ○                   │
│ Anterior            Siguiente        │
│                                      │
└──────────────────────────────────────┘
```

### Las 8 Preguntas
```
1. ¿Qué buscas principalmente en un viaje?
2. ¿Qué tipo de experiencia te impacta más?
3. ¿Cómo sabes que tuviste un buen viaje?
4. ¿Qué emociones deseas experimentar?
5. ¿Cuál es tu mayor miedo en viajes?
6. En un grupo, ¿qué rol juegas?
7. Tu recuerdo ideal de un viaje es...
8. ¿Cómo prefieres aprender sobre nuevas culturas?
```

### Interfaz - Resultados
```
┌──────────────────────────────────────┐
│ Tu Tipo de Viajero                  │
├──────────────────────────────────────┤
│                                      │
│              🦋 TRANSFORMADO         │
│                                      │
│ Eres alguien que busca crecer        │
│ personalmente a través de tus viajes.│
│ Valoras la reflexión y el            │
│ descubrimiento interior.             │
│                                      │
│ RECOMENDACIONES PARA TI:             │
│ • Retiros de transformación personal │
│ • Meditación y mindfulness           │
│ • Voluntariado significativo         │
│ • Diarios de reflexión               │
│ • Encuentros con mentores            │
│                                      │
│ VIAJES PERFECTOS PARA TI:            │
│ [Bali - Retiro Yoga ⭐⭐⭐⭐⭐]      │
│ [Perú - Reflexión en Montaña ...]   │
│ [India - Meditación ...]             │
│                                      │
│ [SEGUIR DESCUBRIENDO]                │
│                                      │
└──────────────────────────────────────┘
```

### 5 Arquetipos Resultantes

#### 💕 Conector
- **Busca**: Conexiones humanas auténticas
- **Valora**: Relaciones y momentos compartidos
- **Recomendaciones**: Homestays, talleres locales, voluntariado
- **Color**: Rojo

#### 🦋 Transformado
- **Busca**: Crecimiento y autoconocimiento
- **Valora**: Reflexión e impacto personal
- **Recomendaciones**: Retiros, meditación, coaching
- **Color**: Morado (Deep Purple)

#### ⚡ Aventurero
- **Busca**: Adrenalina y nuevas emociones
- **Valora**: Desafíos y experiencias extremas
- **Recomendaciones**: Trekking, deportes, expediciones
- **Color**: Naranja

#### 🌅 Contemplativo
- **Busca**: Paz interior y conexión con naturaleza
- **Valora**: Solitud reflexiva y belleza
- **Recomendaciones**: Retiros espirituales, naturaleza, fotografía
- **Color**: Cian

#### 📚 Aprendiz
- **Busca**: Conocimiento y descubrimiento
- **Valora**: Educación y comprensión profunda
- **Recomendaciones**: Viajes académicos, museos, especializados
- **Color**: Verde

### Sistema de Scoring
```dart
// 5 categorías rastreadas:
conexion: 0-40 puntos
transformacion: 0-40 puntos
aventura: 0-40 puntos
reflexion: 0-40 puntos
aprendizaje: 0-40 puntos

// El más alto gana
if (conexion > max) -> CONECTOR
if (transformacion > max) -> TRANSFORMADO
// ... etc
```

### Próxima Integración
```dart
// Guardar resultado
await _storageService.saveQuizResult(
  userId: user.id,
  result: archetype, // 'CONECTOR', 'TRANSFORMADO', etc.
  scores: scores,
  timestamp: DateTime.now(),
);

// Usar para filtrar viajes
final recommendedTrips = trips
  .where((t) => t.recommendedFor.contains(archetype))
  .toList();
```

---

## 4. Experience Impact Dashboard Screen

### Acceso
```dart
Navigator.of(context).pushNamed('/impact-dashboard');
```

### Qué Muestra
Visualización comprehensiva de tu transformación personal acumulada.

### Interfaz
```
┌─────────────────────────────────────────┐
│ Mi Impacto de Viaje                     │
├─────────────────────────────────────────┤
│                                         │
│ Tu Transformación Personal              │
│ Visualiza cómo tus viajes te han        │
│ transformado...                         │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │      ÍNDICE DE TRANSFORMACIÓN       │ │
│ │                                     │ │
│ │            75%                      │ │
│ │            ⭕ (gauge)               │ │
│ │                                     │ │
│ │ Has alcanzado un nivel alto de      │ │
│ │ transformación en tus viajes        │ │
│ │ recientes                           │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ EMOCIONES EXPERIMENTADAS                │
│ 😲 Asombro (45%)  🙏 Gratitud (38%)    │
│ 💕 Conexión (52%) 🧘 Paz (41%)         │
│ 🌅 Esperanza (47%) 💭 Reflexión (56%)  │
│                                         │
│ APRENDIZAJES CLAVE                      │
│ ┌─────────────────────────────────────┐ │
│ │ ✓ Aceptación                        │ │
│ │ Aprendí a aceptar las cosas que...  │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ ♥ Compasión                         │ │
│ │ Desarrollé mayor empatía por...     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ PERSONAS QUE IMPACTASTE                 │
│ 8 Amigos nuevos  3 Mentores             │
│ 12 Historias compartidas                │
│                                         │
│ TU LÍNEA DE TRANSFORMACIÓN              │
│ 🔴 Tromsø, Noruega (5 días)            │
│    "Las auroras cambiaron tu           │
│     perspectiva sobre la vida"         │
│    85% Impacto                         │
│                                         │
│ 🔴 Toscana, Italia (7 días)            │
│    "Conexiones humanas y tradiciones"   │
│    72% Impacto                         │
│                                         │
│ PRÓXIMOS PASOS                          │
│ 🚀 Basado en tu transformación:         │
│ • Explorar voluntariado                 │
│ • Participar en retiros transformacionales │
│ • Conectar con otros viajeros           │
│                                         │
│ [COMPARTIR MI TRANSFORMACIÓN]           │
│                                         │
└─────────────────────────────────────────┘
```

### Componentes

#### 1. Índice de Transformación (Gauge)
- Visual circular del 0-100%
- Interpretación: "Nivel Alto", "Nivel Medio", etc.
- Basado en: promedio de todos los impactos

#### 2. Emociones Experimentadas
- 10 emociones posibles con percentiles
- Mapa de calor de estados emocionales
- Muestra las más experimentadas

#### 3. Aprendizajes Clave
- 4 aprendizajes ejemplares
- Cada uno con un ícono y descripción
- Asociados a viajes específicos

#### 4. Personas Impactadas
- Stats de conexiones hechas
- Red de relaciones ampliada
- Impacto social

#### 5. Línea de Tiempo
- Viajes pasados con marcadores
- Impacto individual por viaje
- Narrativa de transformación

#### 6. Recomendaciones
- 3 sugerencias personalizadas
- Basadas en patrón emocional
- Links a viajes similares

### Funcionalidades
- **Visualizar**: Ver transformación gráficamente
- **Entender**: Qué aprendiste y emocionaste
- **Compartir**: Exportar resultados
- **Reflexionar**: Revisar línea de tiempo
- **Planificar**: Próximos viajes recomendados

### Próxima Integración
```dart
// Calcular desde histórico de diarios + impactos
Future<ExperienceImpact> calculateImpact(String userId) async {
  final diaryEntries = await getUserDiaryEntries(userId);
  final trips = await getUserTrips(userId);
  
  // Análisis de emociones
  final emotionFrequency = calculateEmotionFrequency(diaryEntries);
  
  // Puntuación de impacto
  final impactScore = calculateImpactScore(
    reflectionDepth: diaryEntries.map((e) => e.reflectionDepth),
    emotionDiversity: emotionFrequency.length,
    connectionsMade: trips.length,
  );
  
  return ExperienceImpact(
    emotions: emotionFrequency.keys.toList(),
    impactScore: impactScore,
    // ...
  );
}
```

---

## 5. Home Screen Actualizada

### Acceso
Pantalla por defecto al abrir app (después de autenticación)

### Cambios Principales
1. **Hero Banner**: "✨ Viajes que Transforman" (énfasis emocional)
2. **CTA Quiz**: Prominente gradient box incentivando autodescubrimiento
3. **Arquetipos**: 5 cards deslizables mostrando tipos de viajeros
4. **Viajes Destacados**: Carousel existente (sin cambios)
5. **Historias**: Preview de 2 historias + link a /stories
6. **Mi Experiencia**: Quick access a /diary y /impact-dashboard

### Flujo Recomendado para Nuevo Usuario
```
1. Usuario ve HomeScreen
2. Lee "Viajes que Transforman"
3. Ve 5 arquetipos
4. Hace clic en "Empezar Quiz"
5. Completa quiz (8 preguntas)
6. Ve su arquetipo + viajes recomendados
7. Elige viaje
8. Durante viaje: Usa /diary para reflexionar
9. Post-viaje: Ve /impact-dashboard
10. Comparte historia en /stories
```

---

## Integración con Fase 1

Todas las nuevas pantallas **se añaden encima** de la funcionalidad existente:

```
┌─ BÚSQUEDA
├─ DETALLE DE VIAJE
├─ CARRITO
├─ RESERVAS
├─ PERFIL
└─ AUTENTICACIÓN (Login/Register)
     ▲
     │ TODO LO ANTERIOR FUNCIONA IGUAL
     │
     ▼
┌─ STORIES (NUEVO)
├─ DIARY (NUEVO)
├─ QUIZ (NUEVO)
├─ IMPACT DASHBOARD (NUEVO)
└─ HOME MEJORADA
```

---

## Testing Manual - Checklist

- [ ] Navegar a /stories desde home
- [ ] Revisar mock data de historias (3 stories)
- [ ] Navegar a /diary desde home
- [ ] Crear entrada de diario con todas emociones
- [ ] Ver estadísticas actualizadas
- [ ] Navegar a /quiz desde CTA en home
- [ ] Completar todas 8 preguntas
- [ ] Ver resultados personalizados para cada arquetipo
- [ ] Navegar a /impact-dashboard
- [ ] Verificar visualización de métricas
- [ ] Volver a home y verificar que todo carga

---

## Notas Técnicas

- Todas las pantallas usan **StatefulWidget** para manejo de estado
- Mock data se carga en `initState()`
- Navegación usa **Named Routes** (main.dart)
- Responsive design para diferentes tamaños de pantalla
- Colores coordinados con Material Design 3 (deepPurple primario)

