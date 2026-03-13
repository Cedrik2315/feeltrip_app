# 🧪 TESTING MANUAL - Paso a Paso

## ⏱️ Tiempo Total: 20 minutos

---

## PASO 1: Crear Datos de Prueba en Firestore (5 min)

### Opción A: Desde Firebase Console (Recomendado)

1. Abre: https://console.firebase.google.com/
2. Selecciona proyecto: **feeltrip_app**
3. Ve a: **Firestore Database**
4. Crea **Collection: `stories`**

Agrega estos documentos:

```json
// Documento 1
{
  "id": "story_001",
  "title": "Mi aventura en Patagonia",
  "story": "Fue increíble caminar entre los glaciares. La naturaleza es majestuosa.",
  "author": "Juan Pérez",
  "userId": "user123",
  "rating": 4.8,
  "likes": 25,
  "emotionalHighlights": ["aventura", "naturaleza"],
  "createdAt": Timestamp.now()
}

// Documento 2
{
  "id": "story_002",
  "title": "Yoga en Bali",
  "story": "Una experiencia transformadora. El atardecer sobre el océano.",
  "author": "Maria García",
  "userId": "user456",
  "rating": 4.9,
  "likes": 42,
  "emotionalHighlights": ["tranquilidad", "transformación"],
  "createdAt": Timestamp.now()
}
```

5. Crea **Collection: `agencies`**

Agrega estos documentos:

```json
// Documento 1
{
  "id": "agency_001",
  "name": "FeelTrip Adventures",
  "description": "Especialistas en experiencias de aventura auténtica",
  "logo": "https://via.placeholder.com/200",
  "city": "Buenos Aires",
  "country": "Argentina",
  "latitude": -34.603,
  "longitude": -58.381,
  "specialties": ["adventure", "cultural"],
  "rating": 4.8,
  "reviewCount": 45,
  "followers": 250,
  "verified": true,
  "phoneNumber": "+54 11 1234 5678",
  "email": "info@feeltrip.com",
  "website": "www.feeltrip.com",
  "socialMedia": ["instagram.com/feeltrip"],
  "createdAt": Timestamp.now()
}

// Documento 2
{
  "id": "agency_002",
  "name": "Serenity Retreat",
  "description": "Retiros de bienestar y transformación",
  "logo": "https://via.placeholder.com/200",
  "city": "Bali",
  "country": "Indonesia",
  "latitude": -8.6705,
  "longitude": 115.2126,
  "specialties": ["relaxation", "spiritual"],
  "rating": 4.9,
  "reviewCount": 68,
  "followers": 380,
  "verified": true,
  "phoneNumber": "+62 361 1234 567",
  "email": "serenity@bali.com",
  "website": "www.serenity.com",
  "socialMedia": ["instagram.com/serenity"],
  "createdAt": Timestamp.now()
}
```

---

## PASO 2: Configurar Firestore Security Rules (5 min)

1. En Firebase Console → **Firestore Database** → **Rules**
2. Reemplaza el contenido con esto:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // --- 1. FUNCIONES DE AYUDA (COMBINADAS) ---
    function isAuthenticated() {
      return request.auth != null;
    }
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    function isResourceOwner() {
      return isAuthenticated() && resource.data.userId == request.auth.uid;
    }
    function isAssigningSelf() {
      return isAuthenticated() && request.resource.data.userId == request.auth.uid;
    }

    // --- 2. VALIDACIONES DE DATOS ---
    function isValidString(text, min, max) {
      return text is string && text.size() >= min && text.size() <= max;
    }
    function isValidRating(rating) {
      return (rating is number || rating is int) && rating >= 0 && rating <= 5;
    }

    // --- 3. LÓGICA DE INTERACCIÓN ---
    function onlyStoryLikeMutation() {
      return request.resource.data.diff(resource.data).changedKeys().hasOnly(['likes']) &&
        request.resource.data.userId == resource.data.userId;
    }
    function onlyCommentReactionMutation() {
      return request.resource.data.diff(resource.data).changedKeys().hasOnly(['likes', 'reactions']) &&
        request.resource.data.userId == resource.data.userId;
    }

    // --- REGLAS DE COLECCIONES ---

    // 1. USUARIOS (Perfil, Diario, Carrito)
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      match /diaryEntries/{entryId} { allow read, write: if isOwner(userId); }
      match /cartItems/{itemId} { allow read, write: if isOwner(userId); }
      match /private/{docId} { allow read, write: if isOwner(userId); }
    }

    // 2. HISTORIAS (Stories)
    match /stories/{storyId} {
      allow read: if true;
      allow create: if isAssigningSelf()
                    && isValidString(request.resource.data.title, 3, 100)
                    && isValidString(request.resource.data.story, 10, 5000)
                    && isValidRating(request.resource.data.rating);
      allow update: if (isResourceOwner()
                        && isValidString(request.resource.data.title, 3, 100)
                        && isValidString(request.resource.data.story, 10, 5000))
                    || (isAuthenticated() && onlyStoryLikeMutation());
      allow delete: if isResourceOwner();

      // 2.1 Comentarios
      match /comments/{commentId} {
        allow read: if true;
        allow create: if isAssigningSelf() && isValidString(request.resource.data.content, 1, 1000);
        allow update: if isResourceOwner() || (isAuthenticated() && onlyCommentReactionMutation());
        allow delete: if isResourceOwner();
      }
    }

    // 3. AGENCIAS Y EXPERIENCIAS (Lectura pública, escritura protegida)
    match /agencies/{agencyId} { allow read: if true; allow write: if false; }
    match /experiences/{experienceId} { allow read: if true; allow write: if false; }

    // Bloquear todo lo demás
    match /{document=**} { allow read, write: if false; }
  }
}
```

Estas reglas **fusionadas** ahora validan:
- Que el título de la historia tenga entre 3 y 100 caracteres.
- Que la historia tenga entre 10 y 5000 caracteres.
- Que los comentarios no excedan los 1000 caracteres.
- Que el usuario solo pueda editar/borrar sus propios datos.
- Que el diario sea accesible **solo** por su dueño (ruta `/users/{userId}/diaryEntries`).
- Que el **carrito de compras** sea privado para cada usuario.
- Que **otros usuarios** puedan dar "like" a historias y reaccionar a comentarios sin poder editar el resto del contenido.

3. Haz click: **PUBLISH**
4. Espera 1-2 minutos para que se propaguen los cambios

---

## PASO 3: Testear Comentarios (5 min)

### En la App (Emulador)

1. **Abre la app en el emulador** (ya está running)
2. **Navega a: Historias/Stories Screen**
3. **Busca la historia: "Mi aventura en Patagonia"**
4. **Haz click en el botón COMENTARIOS** (ícono de chat/comentario)
5. Se abre **CommentsScreen**
6. **En el input de comentarios, escribe:** `"¡Qué hermoso lugar!"`
7. **Haz click en ENVIAR** (botón de flecha azul)

### ✅ Verifica que:
- [ ] El comentario aparece al instante
- [ ] Muestra tu avatar (placeholder)
- [ ] Muestra timestamp: "Hace unos segundos"
- [ ] Se ve en la lista de comentarios
- [ ] Puede ver comentarios en tiempo real

### 🎁 Bonus Tests:

**Test reacciones:**
1. En el comentario, haz click en el ícono de emoji
2. Se abre un modal con 6 opciones: ❤️ 😂 😍 🔥 👍 😢
3. Haz click en una
4. ✅ Se agrega al comentario

**Test likes:**
1. Haz click en el ícono de ❤️ en el comentario
2. ✅ El número de likes aumenta

---

## PASO 4: Testear Compartir (3 min)

### En la App

1. **Vuelve a Stories Screen**
2. **En la misma historia, haz click en botón COMPARTIR** (ícono de flecha/share)
3. Se abre el selector nativo de apps

### ✅ Verifica que:
- [ ] Aparece lista de apps disponibles
- [ ] Opciones incluyen: WhatsApp, Instagram, Facebook, Email, Más
- [ ] El mensaje incluye:
  - Título de la historia
  - Descripción
  - Link: `https://feeltrip.app/story/story_001`

### 🎁 Bonus - Compartir a WhatsApp:
1. Si tienes WhatsApp en emulador o móvil:
   - Selecciona WhatsApp
   - Pre-filled message aparece
   - Haz click ENVIAR

---

## PASO 5: Testear Agencias (4 min)

### En el código (Debug Mode)

La agencia no aparece en el nav normal, así que lo haremos programáticamente:

1. En **cualquier pantalla**, abre la **consola de debug** (DevTools)
2. Ejecuta este código Dart:

```dart
// En la consola o mediante hot reload:
import 'package:feeltrip_app/screens/agency_profile_screen.dart';
import 'package:get/get.dart';

// Navega al perfil de agencia
Get.to(() => AgencyProfileScreen(agencyId: 'agency_001'));
```

### O más simple - Desde main.dart:

1. Modifica el home screen temporalmente para agregar un botón de test
2. Haz click en él

```dart
// En home_screen.dart, agrega un botón de test:
ElevatedButton(
  onPressed: () {
    Get.to(() => AgencyProfileScreen(agencyId: 'agency_001'));
  },
  child: Text('Test Agency Profile'),
)
```

### ✅ Verifica en AgencyProfileScreen:
- [ ] Se carga la información de la agencia
- [ ] Muestra logo de FeelTrip Adventures
- [ ] Muestra rating: ⭐ 4.8
- [ ] Muestra followers: 250
- [ ] Muestra descripción
- [ ] Muestra especialidades: adventure, cultural (como chips)
- [ ] Botones de contacto:
  - [ ] Teléfono: +54 11 1234 5678
  - [ ] Email: info@feeltrip.com
  - [ ] Web: www.feeltrip.com
- [ ] Botón SEGUIR funciona
- [ ] Botón COMPARTIR abre selector

### 🎁 Bonus - Probar botones de contacto:
1. Haz click en botón TELÉFONO
   - ✅ Debería abrir marcador (si hay app)
2. Haz click en botón EMAIL
   - ✅ Debería abrir cliente de email
3. Haz click en botón WEB
   - ✅ Debería abrir navegador con la URL

---

## PASO 6: Verificar en Firestore (2 min)

1. Ve a Firebase Console → Firestore
2. Abre collection: **stories**
3. Abre documento: **story_001**
4. Abre subcollection: **comments**

### ✅ Verifica que:
- [ ] El comentario que escribiste está allí
- [ ] Tiene campos:
  - id
  - storyId
  - userId
  - userName
  - content: "¡Qué hermoso lugar!"
  - reactions: Array (si agregaste)
  - likes: número
  - createdAt: timestamp

---

## 📊 Resumen de Tests

| Feature | Test | ✅/❌ | Notas |
|---------|------|-------|-------|
| Comentarios | Escribir comentario | | |
| Comentarios | Ver en tiempo real | | |
| Comentarios | Agregar reacción | | |
| Comentarios | Like comentario | | |
| Compartir | Abrir selector | | |
| Compartir | Incluye deep link | | |
| Agencias | Cargar perfil | | |
| Agencias | Mostrar datos | | |
| Agencias | Botones contacto | | |
| Firestore | Datos guardados | | |

---

## 🎯 Próximos Pasos después del Testing

1. ✅ Tests completados
2. → Leer documentación (QUICK_REFERENCE.md)
3. → Revisar código en detalle
4. → Planificar Fase 2 (Notificaciones)
5. → Decidir fecha de launch

---

## ❌ Si algo falla...

### Error: "Collection not found"
**Solución:** Asegúrate de crear la collection en Firebase Console

### Error: "Permission denied"
**Solución:** Verifica que las Firestore rules están publicadas

### Error: "Comments Screen crashes"
**Solución:** Verifica que tienes datos en stories collection

### Error: "Compartir no funciona"
**Solución:** Normal en emulador sin apps. Funciona en dispositivo real

### Error: "Agency perfil no carga"
**Solución:** Verifica que agencies collection existe con datos

---

## ✨ Comandos útiles

**Recargar la app en caliente:**
```
r
```

**Reinicar la app completamente:**
```
R
```

**Abrir DevTools:**
```
d
```

**Listar comandos disponibles:**
```
h
```

**Salir:**
```
q
```

---

**¡Éxito en los tests! 🚀**

Después de completarlos, avísame los resultados y continuamos con los siguientes pasos.
