# ⚙️ GUÍA DE SETUP - Notificaciones Push (FCM)

## 🎯 Objetivo
Configurar Firebase Cloud Messaging (FCM) en tu proyecto de Flutter para recibir notificaciones push en Android e iOS.

## ✅ Requisitos Previos
- Tu proyecto ya debe estar configurado en Firebase.
- Debes tener la Firebase CLI instalada (`npm install -g firebase-tools`).

---

## 📦 PASO 1: Agregar Dependencia (1 min)

1.  Abre tu terminal en la raíz del proyecto `feeltrip_app`.
2.  Ejecuta el siguiente comando:
    ```bash
    flutter pub add firebase_messaging
    ```

---

## 🤖 PASO 2: Configuración para Android (5 min)

1.  **Asegúrate de tener `google-services.json`**:
    El archivo `android/app/google-services.json` debe estar presente y actualizado desde tu Firebase Console.

2.  **Modifica `android/app/build.gradle`**:
    Asegúrate de que la `minSdkVersion` sea al menos 21.
    ```groovy
    android {
        defaultConfig {
            // ...
            minSdkVersion 21 // Requerido por firebase_messaging
            // ...
        }
    }
    ```

3.  **Modifica `android/app/src/main/AndroidManifest.xml`**:
    Dentro de la etiqueta `<application>`, agrega la siguiente meta-data para el canal de notificación por defecto.

    ```xml
    <application ...>
        <activity ...>
            <!-- ... -->
        </activity>

        <!-- Agrega esto -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
        
    </application>
    ```
    Esto asegura que las notificaciones se muestren correctamente en Android 8.0+.

---

## 🍎 PASO 3: Configuración para iOS (10 min)

1.  **Habilita Push Notifications en Xcode**:
    - Abre tu proyecto de iOS en Xcode: `open ios/Runner.xcworkspace`.
    - Selecciona `Runner` en el navegador de proyectos.
    - Ve a la pestaña `Signing & Capabilities`.
    - Haz clic en `+ Capability`.
    - Busca y agrega `Push Notifications`.
    - Busca y agrega `Background Modes`.
    - Dentro de `Background Modes`, marca la casilla `Remote notifications`.

2.  **Configura APNs en Firebase Console**:
    - Ve a tu Firebase Console → Project Settings (⚙️) → Cloud Messaging.
    - En la sección "Apple app configuration", sube tu **APNs Authentication Key**.
    - Si no tienes una, sigue la guía oficial de Firebase para generar una. Necesitarás una cuenta de Apple Developer.
    - Ingresa tu **Team ID** (lo encuentras en tu cuenta de Apple Developer).

3.  **Importante**: Las notificaciones push **no funcionan en el simulador de iOS**. Debes usar un dispositivo físico para probarlas.

---

## ☁️ PASO 4: Desplegar la Cloud Function (5 min)

La nueva Cloud Function `sendCommentNotification` debe ser desplegada para que el backend pueda enviar las notificaciones.

1.  Abre una terminal en la carpeta `functions` de tu proyecto.
2.  Asegúrate de que `firebase-admin` y `firebase-functions` estén en `package.json`.
3.  Copia el código de la función en `functions/src/index.ts`.
4.  Despliega la función:
    ```bash
    firebase deploy --only functions:sendCommentNotification
    ```

---

## ✅ ¡LISTO!

Ahora tu aplicación está configurada para recibir notificaciones push. Sigue las guías de testing para validar la implementación.