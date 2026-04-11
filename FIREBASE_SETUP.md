# Integración de Firebase Firestore - FeelTrip App

## 📋 Resumen de Cambios

La aplicación FeelTrip ahora está completamente integrada con Firebase Firestore para persistencia de datos en la nube. Esta guía te explica cómo completar la configuración.

## 🔧 Archivos Nuevos Creados

### 1. **lib/config/firebase_config.dart**
- Configuración centralizada de Firebase
- Definición de nombres de colecciones
- Inicialización de Firestore
- Definición de estructura de datos

### 2. **lib/config/firebase_options.dart**
- Configuración específica por plataforma
- Cargas credenciales de Firebase desde variables de entorno
- Soporte para emulador local

### 3. **lib/services/story_service.dart**
- Gestión completa de historias en Firestore
- Métodos: CRUD, búsqueda, likes, streams en tiempo real
- Integración con colecciones público/privado

### 4. **lib/services/diary_service.dart**
- Gestión de entradas de diario en Firestore
- Estadísticas automáticas (profundidad, emociones, impacto)
- Filtros avanzados, exportación JSON
- Streams para actualizaciones en tiempo real

### 5. **lib/controllers/experience_controller.dart**
- **Riverpod Notifier** para gestión de estado (`AsyncNotifier`).
- Integración de `StoryService` y `DiaryService` a través de `ref`.
- 25+ métodos públicos para mutar el estado.
- Manejo de estados asíncronos (loading, data, error) con `AsyncValue`.

## 📦 Dependencias

Ya están en `pubspec.yaml`:
```yaml
firebase_core: ^4.5.0
cloud_firestore: ^6.1.3
flutter_riverpod: ^3.1.0
riverpod_annotation: ^4.0.0
uuid: ^4.5.3
```

Aún **necesitas agregar**:
```yaml
flutter_dotenv: ^5.1.0
```

```bash
flutter pub add flutter_dotenv
```

## 🚀 Pasos de Configuración

### Paso 1: Crear Proyecto en Firebase Console
1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Crea un nuevo proyecto llamado `feeltrip-app`
3. Activa Firestore Database (en modo test por ahora)
4. Agrega tu app (iOS, Android, web)

### Paso 2: Descargar Configuración
1. **Para Android:**
   - Descarga `google-services.json`
   - Colócalo en `android/app/google-services.json`

2. **Para iOS:**
   - Descarga `GoogleService-Info.plist`
   - Colócalo en `ios/Runner/GoogleService-Info.plist`

### Paso 3: Crear Archivo .env
Crea `.env` en la raíz del proyecto:

```env
# Firebase Configuration
FIREBASE_API_KEY=tu_api_key_aqui
FIREBASE_AUTH_DOMAIN=feeltrip-app.firebaseapp.com
FIREBASE_PROJECT_ID=feeltrip-app
FIREBASE_STORAGE_BUCKET=feeltrip-app.appspot.com
FIREBASE_MESSAGING_SENDER_ID=tu_sender_id
FIREBASE_APP_ID=tu_app_id

# Emulator (development)
USE_EMULATOR=false
FIRESTORE_EMULATOR_HOST=localhost:8080
```

### Paso 4: Actualizar pubspec.yaml
```bash
flutter pub get
```

### Paso 5: Estructura de Firestore

La app crea automáticamente esta estructura:

```
firestore/
├── users/
│   └── {userId}/
│       ├── profile/ (usuario data)
│       ├── stories/ (subcollection)
│       │   └── {storyId}: TravelerStory
│       ├── diaryEntries/ (subcollection)
│       │   └── {entryId}: DiaryEntry
│       └── diaryStats/
│           └── {userId}: stats
├── publicStories/
│   └── {storyId}: TravelerStory (para feed público)
```

## 💻 Modificaciones en Código Existente

### main.dart
```dart
// Agregado:
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await Firebase.initializeApp();              // NEW
  await FirebaseConfig.initialize();           // NEW
  runApp(const FeelTripApp());
}
```

### stories_screen.dart
```dart
// Ahora usa ExperienceController:
late ExperienceController _controller;

@override
void initState() {
  super.initState();
  _controller = Get.isRegistered<ExperienceController>()
      ? Get.find<ExperienceController>()
      : Get.put(ExperienceController());
  
  if (_controller.stories.isEmpty) {
    _controller.loadAllData();
  }
}

// Usa Obx() para actualizaciones en tiempo real
Obx(() => ListView.builder(
  itemCount: _controller.stories.length,
  itemBuilder: (_, i) => _buildStoryCard(_controller.stories[i]),
))
```

### travel_diary_screen.dart
```dart
// Ahora usa ExperienceController:
late ExperienceController _controller;

// El form guarda en Firestore:
final entry = DiaryEntry(...);
_controller.createDiaryEntry(entry);

// Las estadísticas se actualizan automáticamente:
Obx(() => _buildStatCard(
  'Total',
  '${_controller.diaryEntries.length}',
  Icons.note,
))
```

## 📊 Modelos Actualizados

### lib/models/experience_model.dart
Todos los modelos tienen:
- `fromJson()` - para serialización JSON
- `toJson()` - para serialización JSON
- `fromFirestore()` - para deserializar de Firestore (NEW)
- `toFirestore()` - para serializar a Firestore (NEW)

```dart
factory ExperienceImpact.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return ExperienceImpact(
    // ...
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

Map<String, dynamic> toFirestore() {
  return {
    // ...
    'createdAt': createdAt, // Firestore maneja el tipo automáticamente
  };
}
```

## 🔐 Reglas de Seguridad Firestore

Para desarrollo (test mode):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Cualquiera puede leer y escribir
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

Para producción (después):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Solo usuarios autenticados pueden acceder sus propios datos
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    // Las historias públicas son legibles por todos
    match /publicStories/{document=**} {
      allow read: if true;
      allow create: if request.auth.uid != null;
    }
  }
}
```

## 🧪 Pruebas Locales con Emulador

### Instalar emulador:
```bash
firebase init emulators
firebase emulators:start
```

### En .env:
```env
USE_EMULATOR=true
FIRESTORE_EMULATOR_HOST=localhost:8080
```

## 📱 Métodos Principales del Controller

```dart
// Inicialización
await controller.initialize(userId);

// Historias
await controller.createStory(story);
await controller.likeStory(storyId);
await controller.unlikeStory(storyId);
await controller.deleteStory(storyId);
await controller.searchStoriesByEmotion(emotion);

// Diario
await controller.createDiaryEntry(entry);
await controller.updateDiaryEntry(entry);
await controller.deleteDiaryEntry(entryId);
await controller.filterByEmotion(emotion);
await controller.filterByDateRange(start, end);

// Estadísticas
Map<String, dynamic> stats = controller.diaryStats.value;
int total = controller.getTotalEntries();
double avgDepth = controller.getAverageDepth();
Set<String> emotions = controller.getUniqueEmotions();
```

## 🐛 Troubleshooting

### Error: "FirebaseException: [cloud_firestore/permission-denied]"
→ Revisa las reglas de seguridad en Firebase Console

### Error: "Firebase no está inicializado"
→ Asegúrate de llamar a `Firebase.initializeApp()` antes de usar Firestore

### Error: "Unable to get documents from Firestore"
→ Verifica que tienes conexión a internet y que el proyecto de Firebase está activo

### Los datos no se sincronizan
→ Usa `Obx()` para observar los cambios en tiempo real

## 🔗 Estructura de Datos Completa

### TravelerStory
```dart
{
  'id': String,
  'author': String,
  'title': String,
  'story': String,
  'emotionalHighlights': List<String>,
  'rating': double,
  'likes': int,
  'createdAt': Timestamp,
}
```

### DiaryEntry
```dart
{
  'id': String,
  'location': String,
  'content': String,
  'emotions': List<String>,
  'reflectionDepth': int,
  'createdAt': Timestamp,
}
```

### DiaryStats
```dart
{
  'userId': String,
  'entryCount': int,
  'avgReflectionDepth': double,
  'uniqueEmotionCount': int,
  'overallImpactScore': int,
  'lastUpdated': Timestamp,
}
```

## ✅ Validación de Setup

```bash
# Verificar que todo compila
flutter pub get
flutter analyze

# Correr tests
flutter test

# Ejecutar en modo debug
flutter run
```

## 📚 Documentación Adicional

- [Firebase Flutter Docs](https://firebase.flutter.dev/)
- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore)
- [GetX Documentation](https://github.com/jonataslaw/getx)

---

**Estado actual:** ✅ Backend completamente implementado | ⏳ Necesitas configurar Firebase Console

**Próximos pasos:**
1. Crear proyecto en Firebase Console
2. Descargar archivos de configuración
3. Crear archivo .env
4. Correr la app: `flutter run`
