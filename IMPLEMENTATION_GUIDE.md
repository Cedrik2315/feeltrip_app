# 📖 Guía de Implementación - Nuevas Características FeelTrip

## 🎯 Objetivo

Esta guía te ayuda a integrar y activar las 3 nuevas características:
1. ✅ Comentarios con reacciones
2. ✅ Compartir en redes sociales
3. ✅ Perfiles de agencias

---

## ✅ FASE 1: VERIFICACIÓN DE INSTALACIÓN

### Paso 1.1: Verificar dependencias
```bash
flutter pub get
```

**Esperado:** Se instalan `share_plus: ^7.2.0` y `url_launcher: ^6.2.0`

### Paso 1.2: Verificar compilación
```bash
flutter doctor
flutter clean
flutter pub get
flutter build apk --debug
```

**Esperado:** APK compilado sin errores

---

## 🔐 FASE 2: CONFIGURAR FIRESTORE

### Paso 2.1: Actualizar Firestore Security Rules

1. Abre [Firebase Console](https://console.firebase.google.com/)
2. Ve a: **Firestore Database** → **Rules**
3. Reemplaza con el contenido de `firestore-rules.txt`
4. Publica las reglas

**Reglas claves:**
- ✅ Todos pueden leer historias y agencias
- ✅ Solo autenticados pueden comentar
- ✅ Solo el dueño puede eliminar su comentario
- ✅ Los comentarios se guardan en: `stories/{storyId}/comments/{commentId}`

### Paso 2.2: Crear colecciones de prueba en Firestore

**Colección: `stories`**
```json
{
  "id": "story_001",
  "title": "Mi aventura en Patagonia",
  "story": "Fue increíble...",
  "author": "Juan Perez",
  "userId": "user123",
  "rating": 4.5,
  "likes": 10,
  "emotionalHighlights": ["aventura", "naturaleza"],
  "createdAt": Timestamp.now()
}
```

**Colección: `agencies`**
```json
{
  "id": "agency_001",
  "name": "FeelTrip Tours",
  "description": "Agencia de viajes vivenciales...",
  "logo": "https://...",
  "city": "Buenos Aires",
  "country": "Argentina",
  "latitude": -34.603,
  "longitude": -58.381,
  "specialties": ["adventure", "cultural"],
  "rating": 4.8,
  "reviewCount": 25,
  "followers": 150,
  "verified": true,
  "phoneNumber": "+54 11 1234 5678",
  "email": "info@feeltrip.com",
  "website": "www.feeltrip.com",
  "createdAt": Timestamp.now()
}
```

---

## 🎮 FASE 3: USAR LAS CARACTERÍSTICAS

### 3.1: Agregar Comentarios en una Pantalla

```dart
import 'package:feeltrip_app/screens/comments_screen.dart';

// En tu botón o elemento interactivo:
ElevatedButton(
  onPressed: () {
    ref.read(routerProvider).push('/comments/$storyId');
  },
  child: Text('Ver Comentarios'),
)
```

### 3.2: Usar el Servicio de Comentarios Directamente

```dart
import 'package:feeltrip_app/services/comment_service.dart';

final commentService = CommentService();

// Agregar comentario
await commentService.addComment(
  storyId: 'story_001',
  userId: 'user123',
  userName: 'Juan Perez',
  userAvatar: 'https://...',
  content: '¡Qué hermoso lugar!',
);

// Obtener comentarios en tiempo real
commentService.getComments('story_001').listen((comments) {
  print('Comentarios cargados: ${comments.length}');
});
```

### 3.3: Compartir Historias

```dart
import 'package:feeltrip_app/services/sharing_service.dart';

// Compartir genéricamente (múltiples apps)
final deepLink = SharingService.generateStoryDeepLink('story_001');
await SharingService.shareGeneral(
  title: 'Mi aventura en Patagonia',
  description: 'Fue increíble, deberías verlo...',
  deepLink: deepLink,
);

// O compartir a WhatsApp específicamente
await SharingService.shareToWhatsApp(
  storyTitle: 'Mi aventura',
  storyDescription: 'Descripción...',
  deepLink: deepLink,
);
```

### 3.4: Ver Perfil de Agencia

```dart
// Usando GoRouter (configurado en routerProvider)

// Navegar al perfil
ref.read(routerProvider).push('/agency/agency_001');
```

### 3.5: Usar el Servicio de Agencias

```dart
import 'package:feeltrip_app/services/agency_service.dart';

final agencyService = AgencyService();

// Obtener agencia específica
final agency = await agencyService.getAgencyById('agency_001');
print('Agencia: ${agency?.name}');

// Obtener todas las agencias ordenadas por rating
agencyService.getAllAgencies().listen((agencies) {
  print('Total de agencias: ${agencies.length}');
});

// Buscar por ciudad
agencyService.getAgenciesByCity('Buenos Aires').listen((agencies) {
  print('Agencias en CABA: ${agencies.length}');
});

// Buscar por especialidad
agencyService.getAgenciesBySpecialty('adventure').listen((agencies) {
  print('Agencias de aventura: ${agencies.length}');
});

// Seguir agencia
await agencyService.followAgency('agency_001');

// Actualizar rating
await agencyService.updateAgencyRating(
  agencyId: 'agency_001',
  newRating: 5.0,
);
```

---

## 🧪 FASE 4: TESTING LOCAL

### Test 4.1: Comentarios

```dart
// En un test o en main.dart para debugging:
Future<void> testComments() async {
  final service = CommentService();
  
  // Crear comentario
  await service.addComment(
    storyId: 'test_story',
    userId: 'test_user',
    userName: 'Test User',
    userAvatar: 'https://via.placeholder.com/50',
    content: 'Este es un comentario de prueba',
  );
  
  // Verificar que se cargó
  service.getComments('test_story').listen((comments) {
    assert(comments.isNotEmpty);
    print('✅ Comentario creado exitosamente');
  });
}
```

### Test 4.2: Compartir

```dart
// En un botón para testing:
ElevatedButton(
  onPressed: () async {
    final deepLink = SharingService.generateStoryDeepLink('test_001');
    print('Deep Link generado: $deepLink');
    
    await SharingService.shareGeneral(
      title: 'Test Story',
      description: 'This is a test',
      deepLink: deepLink,
    );
  },
  child: Text('Test Share'),
)
```

### Test 4.3: Agencias

```dart
Future<void> testAgencies() async {
  final service = AgencyService();
  
  // Crear agencia de prueba
  final agency = TravelAgency(
    id: 'test_agency',
    name: 'Test Agency',
    description: 'Test Description',
    logo: 'https://via.placeholder.com/100',
    phoneNumber: '+54 11 1234 5678',
    email: 'test@test.com',
    website: 'test.com',
    address: '123 Main St',
    city: 'Buenos Aires',
    country: 'Argentina',
    latitude: -34.603,
    longitude: -58.381,
    specialties: ['adventure'],
    createdAt: DateTime.now(),
  );
  
  await service.createAgency(agency);
  print('✅ Agencia creada exitosamente');
  
  // Obtener agencia
  final retrieved = await service.getAgencyById('test_agency');
  assert(retrieved != null);
  print('✅ Agencia obtenida: ${retrieved!.name}');
}
```

---

## 🎬 FASE 5: INTEGRACIÓN EN LA APP

### 5.1: Agregar a StroriesScreen (YA HECHO)

Los siguientes cambios ya fueron realizados:

```dart
// 1. Imports agregados:
import 'package:feeltrip_app/screens/comments_screen.dart';
import 'package:feeltrip_app/services/sharing_service.dart';

// 2. Botones en _buildStoryCard() actualizados:
IconButton(
  icon: Icon(Icons.comment, size: 20),
  onPressed: () {
    Get.to(() => CommentsScreen(storyId: story.id));
  },
),

IconButton(
  icon: Icon(Icons.share, size: 20),
  onPressed: () {
    _shareStory(story);
  },
),

// 3. Método _shareStory() agregado:
void _shareStory(TravelerStory story) {
  final deepLink = SharingService.generateStoryDeepLink(story.id);
  SharingService.shareGeneral(
    title: story.title,
    description: story.story,
    deepLink: deepLink,
  );
}
```

### 5.2: Crear Screen para Listar Agencias (OPCIONAL - para la siguiente fase)

```dart
import 'package:feeltrip_app/screens/agency_profile_screen.dart';
import 'package:feeltrip_app/services/agency_service.dart';

class AgenciesListScreen extends StatelessWidget {
  final agencyService = AgencyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agencias')),
      body: StreamBuilder<List<TravelAgency>>(
        stream: agencyService.getAllAgencies(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
          final agencies = snapshot.data!;
          return ListView.builder(
            itemCount: agencies.length,
            itemBuilder: (context, index) {
              final agency = agencies[index];
              return ListTile(
                title: Text(agency.name),
                subtitle: Text(agency.city),
                onTap: () {
                  Get.to(() => AgencyProfileScreen(agencyId: agency.id));
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## 📱 FASE 6: EJECUTAR EN EMULADOR

### Paso 6.1: Conectar emulador
```bash
flutter devices
# Verificar que el emulador aparece en la lista
```

### Paso 6.2: Ejecutar app
```bash
flutter run
```

### Paso 6.3: Testear flujos

1. **Comentarios:**
   - Navega a una historia
   - Haz click en el botón comentarios
   - Agrega un comentario
   - Verifica que aparezca en tiempo real

2. **Compartir:**
   - Haz click en botón compartir
   - Selecciona WhatsApp o cualquier app
   - Verifica que incluya el deep link

3. **Agencias:**
   - Navega manualmente a `AgencyProfileScreen(agencyId: 'test_agency')`
   - Verifica que carga datos correctamente
   - Haz click en botones de contacto

---

## 🐛 TROUBLESHOOTING

### Error: "Collection not found"
**Causa:** La colección no existe en Firestore
**Solución:** 
1. Abre Firebase Console
2. Crea la colección manualmente
3. Agrega al menos un documento

### Error: "Permission denied"
**Causa:** Las Firestore Security Rules son muy restrictivas
**Solución:**
1. Verifica que actualizaste las rules en `firestore-rules.txt`
2. Asegúrate de publicar los cambios en Firebase Console
3. Espera 1-2 minutos para que se propaguen

### Error: "url_launcher not available"
**Causa:** Plugin no instalado para la plataforma
**Solución:**
```bash
flutter pub get
flutter clean
flutter pub get
flutter run
```

### Los comentarios no aparecen en tiempo real
**Causa:** El StreamBuilder no está actualizado
**Solución:**
1. Verifica que usas `StreamBuilder`
2. Asegúrate de que el `storyId` es correcto
3. Revisa la consola de Firebase para ver si hay errores

---

## ✨ BUENAS PRÁCTICAS

1. **Siempre verifica autenticación:**
   ```dart
   if (FirebaseAuth.instance.currentUser == null) {
     // Mostrar dialog de login
     return;
   }
   ```

2. **Maneja errores:**
   ```dart
   try {
     await commentService.addComment(...);
   } catch (e) {
     print('Error: $e');
     // Mostrar snackbar al usuario
   }
   ```

3. **Usa Stream builders para datos en tiempo real:**
   ```dart
   StreamBuilder<List<Comment>>(
     stream: commentService.getComments(storyId),
     builder: (context, snapshot) {
       // Renderizar UI
     },
   )
   ```

4. **Optimiza queries:**
   - Ordena por fecha descendente para lo más reciente
   - Usa límites para paginar
   - Índices en Firestore para queries complejas

---

## 🚀 Próximos Pasos

1. ✅ Compilar y testear en emulador
2. ⏳ Crear datos de prueba en Firestore
3. ⏳ Testear compartir en redes sociales reales
4. ⏳ Implementar Notificaciones (Firebase Cloud Messaging)
5. ⏳ Agregar Watermarked Images
6. ⏳ Agency Matching Algorithm

---

## 📞 Referencias Rápidas

- **CommentService:** `lib/services/comment_service.dart`
- **CommentsScreen:** `lib/screens/comments_screen.dart`
- **SharingService:** `lib/services/sharing_service.dart`
- **AgencyService:** `lib/services/agency_service.dart`
- **AgencyProfileScreen:** `lib/screens/agency_profile_screen.dart`
- **Models:** `lib/models/comment_model.dart`, `lib/models/agency_model.dart`

**Documentación oficial:**
- [Flutter Share Plus](https://pub.dev/packages/share_plus)
- [URL Launcher](https://pub.dev/packages/url_launcher)
- [Firestore Flutter](https://firebase.flutter.dev/docs/firestore/overview)

---

**Última actualización:** 2024
**Status:** ✅ LISTO PARA USAR
