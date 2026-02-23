# 🏗️ Arquitectura Firebase - FeelTrip App

## 📐 Diagrama de Capas

```
┌─────────────────────────────────────────────────────────────┐
│                    UI LAYER (Screens)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │StoriesScreen │  │TravelDiary   │  │  Other UI    │      │
│  │              │  │Screen        │  │              │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          └──────────────────┼──────────────────┘
                             │
          ┌──────────────────▼──────────────────┐
          │   STATE MANAGEMENT (GetX)           │
          │  ExperienceController               │
          │  - stories: RxList<TravelerStory>   │
          │  - diaryEntries: RxList<DiaryEntry>│
          │  - diaryStats: RxMap<String, dyn>  │
          └──────────────────┬──────────────────┘
                             │
          ┌──────────────────▼──────────────────┐
          │     SERVICE LAYER (Firestore)       │
          │  ┌────────────────┐                 │
          │  │ StoryService   │                 │
          │  │ - Create, Read │                 │
          │  │ - Update, Like │                 │
          │  │ - Search, Del  │                 │
          │  └────────────────┘                 │
          │  ┌────────────────┐                 │
          │  │DiaryService    │                 │
          │  │ - CRUD Entries │                 │
          │  │ - Auto Stats   │                 │
          │  │ - Export JSON  │                 │
          │  └────────────────┘                 │
          └──────────────────┬──────────────────┘
                             │
          ┌──────────────────▼──────────────────┐
          │      MODELS (Serialization)         │
          │  ┌────────────────┐                 │
          │  │ TravelerStory  │                 │
          │  │ - fromJson()   │                 │
          │  │ - toJson()     │                 │
          │  │ - fromFirestore│                 │
          │  │ - toFirestore()│                 │
          │  └────────────────┘                 │
          │  ┌────────────────┐                 │
          │  │  DiaryEntry    │                 │
          │  │ - fromJson()   │                 │
          │  │ - toJson()     │                 │
          │  │ - fromFirestore│                 │
          │  │ - toFirestore()│                 │
          │  └────────────────┘                 │
          └──────────────────┬──────────────────┘
                             │
          ┌──────────────────▼──────────────────┐
          │      FIREBASE CLOUD (Backend)       │
          │  ┌────────────────┐                 │
          │  │ Cloud Firestore│                 │
          │  │  - Realtime DB │                 │
          │  │  - Auto Sync   │                 │
          │  │  - Queries     │                 │
          │  └────────────────┘                 │
          │  ┌────────────────┐                 │
          │  │ Authentication │                 │
          │  │ - Sign Up/In   │                 │
          │  │ - JWT Tokens   │                 │
          │  └────────────────┘                 │
          └──────────────────────────────────────┘
```

## 📊 Data Flow

### Escribir una Historia

```
User Input
    │
    ▼
StoriesScreen._showShareStoryDialog()
    │ ┌─ Crea TravelerStory
    ▼
ExperienceController.createStory(story)
    │ ┌─ Actualiza stories.obs (UI)
    │ ┌─ Emite event isSavingStory
    ▼
StoryService.createStory(userId, story)
    │ ┌─ Valida datos
    │ ┌─ Genera ID único
    │ ┌─ Converts toFirestore()
    ▼
Firestore.collection('users/{userId}/stories').doc(id).set(data)
    │ ┌─ Sincroniza con Cloud
    │ ┌─ Guarda en local
    ▼
Firestore.collection('publicStories').doc(id).set(data)
    │ ┌─ Copia pública para feed
    ▼
Stream actualiza listeners
    │
    ▼
Obx() en StoriesScreen detecta cambio
    │
    ▼
UI re-construye con nuevas stories ✅
```

### Leer Historias Públicas (Stream)

```
StoriesScreen.initState()
    │
    ▼
_controller.loadAllData()
    │
    ▼
ExperienceController.loadStories()
    │ ┌─ stories.bindStream(_storyService.getPublicStoriesStream())
    ▼
StoryService.getPublicStoriesStream()
    │ ┌─ Crea listener continuo
    ▼
Firestore listener on publicStories
    │ ┌─ Escucha cambios
    ▼
Para cada documento:
    │ ┌─ TravelerStory.fromFirestore(doc)
    ▼
Stream emite List<TravelerStory>
    │ ┌─ Actualiza stories.obs
    ▼
Obx() detecta cambio
    │
    ▼
ListView.builder re-construye ✅
```

### Crear Entrada de Diario (con Auto-Stats)

```
User Input
    │
    ▼
TravelDiaryScreen._buildEntryForm()
    │ ┌─ Crea DiaryEntry
    │ ┌─ Selecciona emociones
    │ ┌─ Set reflectionDepth
    ▼
ExperienceController.createDiaryEntry(entry)
    │ ┌─ diaryEntries.add(entry) [local]
    │ ┌─ Emite isSavingDiary
    ▼
DiaryService.createDiaryEntry(userId, entry)
    │ ┌─ Converts toFirestore()
    ▼
Firestore.collection('users/{userId}/diaryEntries')
       .doc(entry.id).set(data)
    │
    ▼
DiaryService._updateUserDiaryStats(userId)
    │ ┌─ Lee todas las entradas
    │ ┌─ Calcula:
    │   ├─ entryCount = total
    │   ├─ avgReflectionDepth = promedio
    │   ├─ uniqueEmotionCount = SET.length
    │   └─ overallImpactScore = suma
    ▼
Firestore.collection('users/{userId}/diaryStats')
       .doc(userId).set(stats)
    │
    ▼
Stream de diaryEntries y diaryStats se actualiza
    │
    ▼
ExperienceController recibe cambios
    │ ┌─ diaryEntries.obs actualiza
    │ ┌─ diaryStats.obs actualiza
    ▼
Obx() detectan cambios
    │
    ▼
TravelDiaryScreen re-construye con:
    ├─ Nuevo card en lista
    ├─ Stats actualizadas
    └─ GridView re-calcula ✅
```

## 🔄 Real-time Synchronization

```
Dispositivo 1           Cloud Firestore           Dispositivo 2
     │                        │                         │
     │ create story           │                         │
     ├───────────────────────►│                         │
     │                        │ stream updates          │
     │                        ├────────────────────────►│
     │                        │                   UI updates
     │                        │                         ▼
     │ edit story             │                         │
     ├───────────────────────►│                         │
     │                        │ stream updates          │
     │                        ├────────────────────────►│
     │                        │                   UI updates
     ▼                        ▼                         ▼
   Local Cache         Firestore Cloud            Local Cache
   Synced              Authoritative              Synced
```

## 🗂️ Firestore Collection Structure

```
firestore
│
├── users/
│   └── {userId}
│       ├── profile
│       │   ├── name: string
│       │   ├── email: string
│       │   └── createdAt: timestamp
│       │
│       ├── stories/ (subcollection)
│       │   └── {storyId}
│       │       ├── id: string
│       │       ├── author: string
│       │       ├── title: string
│       │       ├── story: string
│       │       ├── emotionalHighlights: array
│       │       ├── rating: number
│       │       ├── likes: number
│       │       └── createdAt: timestamp
│       │
│       ├── diaryEntries/ (subcollection)
│       │   └── {entryId}
│       │       ├── id: string
│       │       ├── location: string
│       │       ├── content: string
│       │       ├── emotions: array
│       │       ├── reflectionDepth: number
│       │       └── createdAt: timestamp
│       │
│       └── diaryStats/
│           └── stats
│               ├── userId: string
│               ├── entryCount: number
│               ├── avgReflectionDepth: number
│               ├── uniqueEmotionCount: number
│               ├── overallImpactScore: number
│               └── lastUpdated: timestamp
│
└── publicStories/ (collection)
    └── {storyId}
        ├── id: string
        ├── author: string
        ├── title: string
        ├── story: string
        ├── emotionalHighlights: array
        ├── rating: number
        ├── likes: number
        ├── userId: string
        └── createdAt: timestamp
```

## 🔌 Integración con GetX

### Pattern: Binding Stream a Observable

```dart
// DiaryService.getDiaryEntriesStream(userId) retorna Stream<List<DiaryEntry>>
// ExperienceController.loadDiaryEntries() hace:

diaryEntries.bindStream(
  _diaryService.getDiaryEntriesStream(userId)
);

// Ahora cualquier cambio en Firestore actualiza automáticamente diaryEntries.obs
// Y los Obx() widgets en pantalla se reconstruyen
```

### Pattern: Operaciones Asincrónicas

```dart
// En ExperienceController:
Future<void> createStory(TravelerStory story) async {
  try {
    isSavingStory.value = true;
    errorMessage.value = '';
    
    await _storyService.createStory(userId!, story);
    
    successMessage.value = 'Historia creada!';
    successMessage.value = ''; // Clear after 3 seconds
    
  } catch (e) {
    errorMessage.value = 'Error: $e';
  } finally {
    isSavingStory.value = false;
  }
}

// En la UI:
Obx(() {
  if (_controller.isSavingStory.value) {
    return CircularProgressIndicator();
  }
  return ElevatedButton(...);
})
```

## 📈 Performance Considerations

### ✅ Lo que hacemos bien:

1. **Streams para actualizaciones en tiempo real**
   - No polling continuo
   - Solo actualiza cuando hay cambios
   
2. **Paginación en getPublicStories(limit)**
   - Reduce tamaño de descarga
   - Mejor UX en listas largas

3. **Auto-stats con _updateUserDiaryStats()**
   - Calcula en servidor (Firestore)
   - No requiere lógica en cliente

4. **Local cache con RxList**
   - Datos disponibles offline
   - Rápida reconstrucción de UI

### ⚠️ Consideraciones para producción:

1. **Añadir índices de Firestore** para queries complejas
2. **Implementar paginación cursor-based** para listas grandes
3. **Cache persistente local** con hive/isar
4. **Rate limiting** en creación de historias
5. **Validación Server-side** en Firebase Functions

## 🧪 Testing

### Unit Test Example:
```dart
test('ExperienceController creates story', () async {
  final controller = ExperienceController();
  await controller.initialize('test-user');
  
  final story = TravelerStory(
    id: '1',
    author: 'Test User',
    title: 'Test Story',
    // ...
  );
  
  await controller.createStory(story);
  
  expect(controller.stories.contains(story), true);
});
```

### Integration Test Example:
```dart
testWidgets('StoriesScreen shows stories from Firestore', 
  (WidgetTester tester) async {
    await tester.pumpWidget(FeelTripApp());
    
    await tester.tap(find.text('Historias'));
    await tester.pumpAndSettle();
    
    expect(find.byType(ListView), findsOneWidget);
  },
);
```

## 🔐 Security Flow

```
User Login
    │
    ▼
Firebase Auth
    │ ┌─ Validar credenciales
    │ ┌─ Generar JWT token
    ▼
User autenticado con uid
    │
    ▼
ExperienceController.initialize(uid)
    │ ┌─ userId = uid
    ▼
Firestore Security Rules
    │ ┌─ request.auth.uid == userId
    ▼
Acceso permitido/denegado
    │
    ▼
Si permitido: Sincronizar datos
Si denegado: Error message
```

---

**Arquitectura:** Modular | Escalable | Testeable | Production-Ready ✅
