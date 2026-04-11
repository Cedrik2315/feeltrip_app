# ⚡ QUICK START - Firebase Firestore en FeelTrip App

## 🎯 Objetivo
Pasar de mock data a **datos reales en Firestore** en 30 minutos.

## ✅ Lo que ya está listo (no hay que hacer)
- ✅ Backend Firestore implementado
- ✅ Servicios (StoryService, DiaryService)
- ✅ State management (ExperienceController)
- ✅ Modelos con serialización
- ✅ UI integrada
- ✅ Main.dart con Firebase init

**Te falta:** Configurar Firebase Console

---

## 🚀 PASO 1: Añadir flutter_dotenv (2 min)

```bash
cd c:\Users\monch\Documents\feeltrip_app
flutter pub add flutter_dotenv
flutter pub get
```

---

## 🔧 PASO 2: Crear Firebase Project (5 min)

1. Ve a https://console.firebase.google.com/
2. Click "Agregar proyecto"
3. Nombre: `feeltrip-app`
4. Click "Crear proyecto"
5. Espera a que se cree (2-3 min)

---

## 📦 PASO 3: Configurar Android (10 min)

### 3.1 Agregar app Android
1. En Firebase Console, click ⚙️ (settings)
2. Click "Agregar app"
3. Selecciona Android
4. Package name: `com.example.feeltrip_app`
   - Si no sabes, abre `android/app/build.gradle` y busca `applicationId`
5. Descarga `google-services.json`

### 3.2 Copiar archivo
```bash
# Copiar a:
android/app/google-services.json
```

---

## 🍎 PASO 4: Configurar iOS (10 min) - OPCIONAL por ahora

### 4.1 Agregar app iOS (opcional)
1. En Firebase Console, click "Agregar app"
2. Selecciona iOS
3. Bundle ID: `com.example.feeltripApp`
4. Descarga `GoogleService-Info.plist`

### 4.2 Copiar archivo (opcional)
```bash
# Copiar a:
ios/Runner/GoogleService-Info.plist
```

---

## 📝 PASO 5: Crear .env (2 min)

Crea archivo `.env` en la **raíz** del proyecto (junto a pubspec.yaml):

```env
# Firebase Configuration
FIREBASE_API_KEY=AIzaSy...
FIREBASE_AUTH_DOMAIN=feeltrip-app.firebaseapp.com
FIREBASE_PROJECT_ID=feeltrip-app
FIREBASE_STORAGE_BUCKET=feeltrip-app.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:android:abc123

# Emulator (keep false for now)
USE_EMULATOR=false
```

**¿De dónde sacar estos valores?**
- Ve a Firebase Console
- Project Settings (⚙️)
- Copia los valores de "SDK setup and configuration"

---

## 🔓 PASO 6: Reglas de Firestore (2 min)

1. En Firebase Console, ve a **Firestore Database**
2. Click en **Rules**
3. Reemplaza todo con:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

4. Click **Publicar**

⚠️ **NOTA:** Esto es INSEGURO. Cambiar después en producción.

---

## ▶️ PASO 7: Ejecutar (5 min)

```bash
cd c:\Users\monch\Documents\feeltrip_app

# Descargar dependencias
flutter pub get

# Ejecutar en debug
flutter run

# O en iOS:
# flutter run -d iPhone
```

---

## 🎮 PASO 8: Probar Funcionalidades (5 min)

### Historias
1. Ve a la pantalla "Historias"
2. Deberías ver historias cargadas desde Firestore
3. Click "❤️ Compartir Mi Historia"
4. Rellena el form y guarda
5. La historia aparece al instante ✨

### Diario
1. Ve a "Mi Diario Personal"
2. Click "+" para nueva entrada
3. Rellena: ubicación, pensamiento, emociones, profundidad
4. Click "Guardar"
5. Las stats se actualizan automáticamente ✨

### Real-time Sync
1. Abre la app en 2 dispositivos
2. Crea historia en dispositivo 1
3. En dispositivo 2, debería aparecer al instante
4. Like en dispositivo 2
5. El contador se actualiza en dispositivo 1 ✨

---

## ✅ VALIDACIÓN

Si todo funciona, deberías ver:
- [x] Historias cargadas desde Firestore
- [x] Poder crear nuevas historias
- [x] Contador de likes funcional
- [x] Crear entradas de diario
- [x] Stats automáticas (total, profundidad, emociones)
- [x] Datos sincronizados entre dispositivos

---

## 🐛 Si algo no funciona

### Error: "Firebase no está inicializado"
```
Solución:
1. Verifica que main() tiene:
   await Firebase.initializeApp();
   await FirebaseConfig.initialize();

2. flutter clean
3. flutter pub get
4. flutter run
```

### Error: "permission-denied" en Firestore
```
Solución:
1. Ve a Firebase Console
2. Firestore Database → Rules
3. Pega las reglas de PASO 6
4. Click Publicar
```

### Historias no cargan
```
Solución:
1. Verifica conexión a internet
2. Abre Firebase Console y revisa Firestore
3. Revisa Android Studio Logcat o Xcode console
4. Busca mensajes de error
```

### Datos no se sincronizan entre dispositivos
```
Solución:
1. Ambos dispositivos conectados a internet
2. Ambos usando misma red (o WiFi/datos)
3. Firestore rules están publicadas
4. Espera 2-3 segundos
```

---

## 📱 Testing en Emulador

### Android Emulator
```bash
# Abrir emulador Android
flutter emulators --launch Pixel_3_XL

# Luego:
flutter run
```

### iOS Simulator
```bash
# Abrir simulator
open -a Simulator

# Luego:
flutter run -d iPhone
```

---

## 📊 Ver datos en Firebase Console

1. Firebase Console → Firestore Database
2. Deberías ver colecciones:
   - `publicStories` (historias públicas)
   - `users` (con subcollecciones)

Ejemplo:
```
publicStories/
├── story_001
│   ├── author: "Usuario"
│   ├── title: "Mi Historia"
│   ├── likes: 5
│   └── createdAt: (timestamp)
```

---

## 🎓 Próximos pasos (después)

1. **Agregar autenticación real** (Firebase Auth)
2. **Fotos** (Firebase Storage)
3. **Reglas de seguridad** (production mode)
4. **Analytics** (Google Analytics)

---

## 📚 Documentación Completa

- `FIREBASE_SETUP.md` - Setup detallado
- `FIREBASE_ARCHITECTURE.md` - Arquitectura y diagramas
- `FIREBASE_INTEGRATION_STATUS.md` - Estado completo
- `EVOLUTION.md` - Antes vs después

---

## ⏱️ Resumen Tiempo

| Tarea | Tiempo |
|-------|--------|
| flutter pub add flutter_dotenv | 2 min |
| Crear Firebase project | 5 min |
| Configurar Android | 10 min |
| Crear .env | 2 min |
| Firestore rules | 2 min |
| flutter run | 5 min |
| Testing | 5 min |
| **TOTAL** | **31 minutos** ⏱️ |

---

## 🚀 ¡Listo!

Después de estos pasos, tendrás:
- ✅ Backend Firebase funcionando
- ✅ Datos sincronizados en tiempo real
- ✅ Histórico completo
- ✅ Stats automáticas
- ✅ App lista para usuarios

**Enjoy! 🎉**
