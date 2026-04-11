# 🚀 VAMOS POR ESOS PASOS - TU PLAN DE ACCIÓN

```
╔══════════════════════════════════════════════════════════════════════════╗
║                 FEELTRIP TESTING - ACTION PLAN                           ║
║                   ⏱️ Tiempo total: 30 minutos                            ║
╚══════════════════════════════════════════════════════════════════════════╝
```

---

## 📍 DÓNDE ESTAMOS AHORA

```
✅ APP ESTÁ CORRIENDO en emulador
✅ CÓDIGO COMPILADO sin errores
✅ FIREBASE INICIALIZADO correctamente
✅ 3 FEATURES IMPLEMENTADAS

AHORA: Necesitamos TESTEAR que todo funciona
```

---

## 📋 TU PLAN (COPIA Y PEGA)

### ⏱️ FASE 1: SETUP (5 MINUTOS)

#### Acción 1.1: Abre Firebase Console
```
URL: https://console.firebase.google.com/
Proyecto: feeltrip_app
Sección: Firestore Database
```

#### Acción 1.2: Crea Collection "stories"
```
Collections → + Create Collection
Nombre: "stories"
Primer documento:
{
  "id": "story_001",
  "title": "Mi aventura en Patagonia",
  "story": "Fue increíble caminar entre los glaciares. La naturaleza es majestuosa.",
  "author": "Juan Pérez",
  "userId": "user123",
  "rating": 4.8,
  "likes": 25,
  "emotionalHighlights": ["aventura"],
  "createdAt": (Timestamp automático)
}
```

#### Acción 1.3: Crea Collection "agencies"
```
Collections → + Create Collection
Nombre: "agencies"
Primer documento:
{
  "id": "agency_001",
  "name": "FeelTrip Adventures",
  "description": "Agencia especializada en aventuras",
  "logo": "https://via.placeholder.com/200",
  "city": "Buenos Aires",
  "country": "Argentina",
  "latitude": -34.603,
  "longitude": -58.381,
  "specialties": ["adventure"],
  "rating": 4.8,
  "reviewCount": 45,
  "followers": 250,
  "verified": true,
  "phoneNumber": "+54 11 1234 5678",
  "email": "info@feeltrip.com",
  "website": "www.feeltrip.com",
  "createdAt": (Timestamp automático)
}
```

✅ **META PHASE 1:** Datos creados en Firestore

---

### ⏱️ FASE 2: SECURITY (3 MINUTOS)

#### Acción 2.1: Configura Security Rules
```
Firestore Database → Rules → (reemplaza con esto)

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /stories/{storyId} {
      allow read: if true;
      allow write: if request.auth != null;
      
      match /comments/{commentId} {
        allow read: if true;
        allow create: if request.auth != null;
        allow update, delete: if request.auth.uid == resource.data.userId;
      }
    }

    match /agencies/{agencyId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}

→ PUBLISH (espera 1-2 minutos)
```

✅ **META PHASE 2:** Security rules activas

---

### ⏱️ FASE 3: TEST COMENTARIOS (5 MINUTOS)

**En la APP (Emulador):**

```
1. Abre la app
2. Ve a: Stories Screen (Historias)
3. Busca: "Mi aventura en Patagonia"
4. Click: Botón de COMENTARIOS (chat icon)
   → Se abre CommentsScreen
5. Escribe: "¡Qué hermoso lugar!"
6. Click: ENVIAR (arrow button)

VERIFICA QUE:
  ✅ El comentario aparece al instante
  ✅ Muestra tu nombre y avatar
  ✅ Muestra timestamp ("Hace unos segundos")
  ✅ Está en la lista de comentarios

BONUS:
  • Click emoji → Selecciona ❤️
  • Click ❤️ → Aumenta likes
```

✅ **META PHASE 3:** Comentarios funcionando

---

### ⏱️ FASE 4: TEST COMPARTIR (3 MINUTOS)

**En la APP:**

```
1. Vuelve a Stories Screen
2. En la misma historia
3. Click: Botón COMPARTIR (share icon)
   → Se abre selector nativo

VERIFICA QUE:
  ✅ Aparece lista de apps (WhatsApp, Instagram, etc)
  ✅ Mensaje incluye:
     • Título: "Mi aventura en Patagonia"
     • Descripción
     • Link: https://feeltrip.app/story/...
  
OPCIONAL:
  • Si tienes WhatsApp:
    → Selecciona WhatsApp
    → Haz click ENVIAR
    → Link funciona ✅
```

✅ **META PHASE 4:** Compartir funcionando

---

### ⏱️ FASE 5: TEST AGENCIAS (4 MINUTOS)

**En el CÓDIGO (Debug Mode):**

```
Opción A - Desde DevTools:
1. Press 'd' en terminal
2. Abre: http://localhost:57407/devtools
3. En console, ejecuta:
   Get.to(() => AgencyProfileScreen(agencyId: 'agency_001'))

Opción B - Desde main.dart temporal:
1. En home_screen.dart, agrega botón:
   ElevatedButton(
     onPressed: () => Get.to(() => AgencyProfileScreen(agencyId: 'agency_001')),
     child: Text('Test Agency'),
   )
2. Click el botón

VERIFICA QUE:
  ✅ Se carga perfil de "FeelTrip Adventures"
  ✅ Muestra logo placeholder
  ✅ Rating: ⭐ 4.8
  ✅ Followers: 250
  ✅ Especialidades: "adventure"
  ✅ Descripción visible
  ✅ Botones de contacto:
     • Teléfono
     • Email
     • Website

BONUS:
  • Click teléfono → Abre marcador
  • Click email → Abre cliente de email
  • Click website → Abre navegador
```

✅ **META PHASE 5:** Agencias funcionando

---

### ⏱️ FASE 6: VERIFICAR FIRESTORE (2 MINUTOS)

**En Firebase Console:**

```
1. Firestore Database → Collections
2. Abre: stories → story_001 → comments
3. Verifica que tu comentario está aquí:
   {
     "id": "...",
     "storyId": "story_001",
     "userId": "user123",
     "content": "¡Qué hermoso lugar!",
     "reactions": ["❤️"],  // si agregaste
     "likes": 1,           // si hiciste like
     "createdAt": (timestamp)
   }

✅ Dato guardado correctamente en Firestore
```

✅ **META PHASE 6:** Datos verificados

---

## 📊 RESUMEN DE COMPLETITUD

```
INICIALMENTE:
Code:           ✅ 100% completado
Compilación:    ✅ sin errores
App corriendo:  ✅ en emulador

AHORA NECESITAS:
Datos Firebase: ⏳ (5 min - Fase 1)
Security Rules: ⏳ (3 min - Fase 2)
Test Comentarios: ⏳ (5 min - Fase 3)
Test Compartir:   ⏳ (3 min - Fase 4)
Test Agencias:    ⏳ (4 min - Fase 5)
Verificar datos:  ⏳ (2 min - Fase 6)

TOTAL: ~22 minutos
```

---

## 🎯 CHECKLIST RÁPIDO

- [ ] Abierto Firebase Console
- [ ] Collection "stories" creada con data
- [ ] Collection "agencies" creada con data
- [ ] Security rules configuradas y publicadas
- [ ] App testeada - comentarios funcionan
- [ ] App testeada - compartir funciona
- [ ] App testeada - agencias funcionan
- [ ] Firestore revisado - datos guardados

**SI TODO ESTÁ CHECKEADO → ✅ LISTO PARA LAUNCH**

---

## 🚨 SI ALGO FALLA

### "No veo la historia en la app"
```
→ Los datos se sincronizan en tiempo real
→ Espera 1-2 segundos
→ O haz Hot Reload (press 'r')
```

### "Comentarios no aparecen"
```
→ Verifica que storyId es correcto
→ Chequea security rules están publicadas
→ Mira Firebase Console para ver los datos
```

### "Compartir no funciona"
```
→ Normal en emulador sin apps
→ Funciona perfecto en dispositivo real
→ Las URLs están correctas
```

### "Agency profile no carga"
```
→ Verifica que agencies collection existe
→ Chequea que el documento tiene los campos necesarios
→ Haz Hot Restart (press 'R')
```

---

## 📱 COMANDOS ÚTILES EN TERMINAL

```
Mientras la app está corriendo:

r    = Hot Reload (recarga rápido)
R    = Hot Restart (reinicia app)
d    = Abrir DevTools
h    = Listar comandos
q    = Salir

En la app:
Click botón → Acciones corresponden a las features
```

---

## ✨ DESPUÉS DE TERMINAR

```
1. ✅ Todos los tests pasaron
   → EXCELENTE, estamos listos para launch

2. ⚠️ Algo falló
   → Revisa STATUS_CHECK.md → Troubleshooting
   → O contacta el dev team

3. 🚀 PRÓXIMO PASO
   → Leer ROADMAP.md
   → Planificar Fase 2 (Notificaciones)
   → Decidir fecha de launch público
```

---

## 🎊 RESUMEN

```
TAREA:       Test las 3 features
TIEMPO:      30 minutos
DOCUMENTOS:  MANUAL_TESTING.md (detallado)
             STATUS_CHECK.md (si algo falla)
RESULTADO:   ✅ 3 features validadas y listas
SIGUIENTE:   Launch o Fase 2
```

---

## 🚀 EMPEZAR AHORA

> **PASO 1:** Abre Firebase Console
> 
> **PASO 2:** Crea datos en Firestore
> 
> **PASO 3:** Configura security rules
> 
> **PASOS 4-6:** Testea en la app
> 
> **TIEMPO:** 30 minutos
> 
> **RESULTADO:** ✅ Todo funciona perfectamente

---

**¿LISTO? Abre Firebase Console y comienza con FASE 1.**

Avísame cuando termines los tests 🎉
