# 🐱 Configuración de RevenueCat para FeelTrip

Sigue estos pasos para obtener las credenciales necesarias para procesar pagos.

## 1. Crear Cuenta y Proyecto
1. Ve a [RevenueCat](https://www.revenuecat.com/) y regístrate (es gratis hasta cierto límite de ingresos).
2. Crea un nuevo proyecto llamado **"FeelTrip"**.

## 2. Configurar Apps

### Para Android (Play Store)
1. En el dashboard, ve a **Project Settings** > **Apps**.
2. Haz clic en **+ New** y selecciona **Play Store**.
3. Ingresa el **Google Play Package Name**.
   - Lo encuentras en `android/app/build.gradle` (o `build.gradle.kts`) bajo `applicationId`.
   - **Alternativa:** Abre `android/app/src/main/AndroidManifest.xml` y busca `package="com..."` al inicio.
   - **Tu ID actual es:** `com.example.feeltrip_app`

### Para iOS (App Store)
1. Haz clic en **+ New** y selecciona **App Store**.
2. Ingresa el **App Bundle ID**.
   - Lo encuentras en Xcode.
   - Ejemplo: `com.tuempresa.feeltrip`

## 3. Obtener API Keys Públicas
1. En la sección **Apps** de tu proyecto en RevenueCat, verás las tarjetas de tus apps.
2. Haz clic en **Public API Key** para copiarla.
   - **¡OJO!** No uses el "RevenueCat ID" (`appea6...`). Ese es interno.
   - Necesitas la **Public API Key** que empieza con `goog_`.
   - Android suele empezar con `goog_...`
   - iOS suele empezar con `appl_...`

## 4. Configurar en tu Proyecto Flutter
1. Abre (o crea) el archivo `.env` en la raíz de tu proyecto.
2. Agrega tus llaves:

```env
REVENUECAT_GOOGLE_KEY=goog_tu_clave_aqui
REVENUECAT_APPLE_KEY=appl_tu_clave_aqui
```