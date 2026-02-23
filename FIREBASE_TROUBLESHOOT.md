# 🔧 VERIFICAR FIREBASE - CHECKLIST

## ¿DÓNDE DEBES ESTAR?

### 1️⃣ Verifica que estés autenticado
```
En https://console.firebase.google.com/
Arriba a la derecha: ¿Ves tu cuenta de Google?
Si NO: Haz click → Sign In → Usa tu cuenta
```

### 2️⃣ Verifica que estés en el proyecto "feeltrip_app"
```
Arriba a la izquierda: ¿Dice "feeltrip_app"?
Si NO: Haz click → Selecciona "feeltrip_app" de la lista
Si no ves "feeltrip_app": Probablemente necesitas crear el proyecto primero
```

### 3️⃣ Verifica que estés en "Firestore Database"
```
Panel izquierdo:
  Build
    → Firestore Database  ← AQUÍ
    → Realtime Database
    → Authentication
    → etc
```

### 4️⃣ Verifica que veas la opción "+ Create Collection"
```
En la zona principal debería decir:
"Cloud Firestore" con un botón azul "+ Create Collection"

Si NO ves esto:
  → Haz click en "Firestore Database" del panel izquierdo
```

---

## SI AÚN NO VES "stories"

Probablemente no la creaste todavía. Vamos a crear la primera collection:

### CREAR COLLECTION "stories"

```
1. En Firestore Database
2. Haz click: + Create Collection
3. Collection ID: stories
4. Haz click: Next
5. Auto ID: (deja que Firebase genere)
6. Agrega los campos:

   id: "story_001"
   title: "Mi aventura en Patagonia"
   story: "Fue increíble..."
   author: "Juan Pérez"
   userId: "user123"
   rating: 4.8
   likes: 25

7. Haz click: Save
```

---

## AHORA SÍ DEBERÍAS VER

```
En Firestore Database:
  Collections
    ✅ stories (con 1 documento)
```

Cuando VEAS "stories" en la lista, avísame y creamos "agencies".

---

## ¿NO FUNCIONA AÚN?

Probablemente NO CREASTE el proyecto Firebase en Google Cloud.

### CREAR PROYECTO FIREBASE

```
1. Abre: https://console.firebase.google.com/
2. Click: + Add project
3. Name: feeltrip_app
4. Continúa con las opciones por defecto
5. Click: Create project (espera 1-2 min)
6. Cuando esté listo, entra al proyecto
7. Click: Firestore Database
8. Click: Create database
9. Ubicación: us-central1 (o la más cercana)
10. Modo: Production
11. Click: Enable
```

Entonces sí podrás crear collections.

---

## ✅ CHECKLIST ANTES DE CONTINUAR

- [ ] Estoy autenticado en Google (veo mi cuenta)
- [ ] Estoy en proyecto "feeltrip_app"
- [ ] Estoy en "Firestore Database"
- [ ] Veo botón "+ Create Collection"
- [ ] He creado collection "stories" con 1 documento
- [ ] Veo "stories" en la lista de Collections

Cuando TODO esté checkeado → Listo para crear "agencies"
