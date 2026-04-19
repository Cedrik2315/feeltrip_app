# Smoke Test - Dispositivos Físicos (iOS & Android)

Este documento describe el flujo de validación crítico end-to-end (Smoke Test) diseñado para ser ejecutado en hardware real, dado que involucra funciones nativas irremplazables (Módulo de Cámara y Antena GPS real) y pasarela de pagos.

## 📝 Precondiciones
- Tener un teléfono Android y un iPhone conectados mediante USB (o Wi-Fi debugging).
- Las claves de Producción de **RevenueCat** deben estar colocadas en el archivo `.env`.
- Si es iOS, estar validado con firma desde Xcode.

## 🧪 Fase 1: Instalación y Permisos de Hardware

1. **Arranque y Posicionamiento GPS**
   - [ ] Inicia la app por primera vez.
   - [ ] Navega al mapa o busca expediciones cercanas.
   - [ ] **Validación iOS**: ¿Aparece el Alert de Apple con el texto *"Usamos tu ubicación para mostrarte las experiencias..."*?
   - [ ] **Validación Android**: ¿Aparece el modal nativo de ubicación precisa?
   - [ ] Acepta el permiso. El mapa debe centrarse en tu latitud/longitud real.

2. **Inclusión Multimedia (Cámara)**
   - [ ] Accede a la opción para generar una crónica o sacar una foto (OCR/Diario).
   - [ ] **Validación iOS/Android**: ¿Aparece el Alert nativo pidiendo permisos de Cámara y Micrófono?
   - [ ] Deniega el permiso y comprueba que la app no crashea (debe mostrar feedback visual).
   - [ ] Otorga el permiso y toma una fotografía exitosamente con la cámara trasera.

## 🧪 Fase 2: Autenticación y Registro

1. **Registro Nuevo Usuario**
   - [ ] Realiza el flujo `Onboarding -> Registro`.
   - [ ] Ingresa un email de prueba y contraseña.
   - [ ] Comprueba que el pase se genera en la base de datos de Firebase Production.

## 🧪 Fase 3: Pasarela de Pago (Mercado Pago / RevenueCat)

1. **Reserva de Experiencia (Mercado Pago)**
   - [ ] Selecciona una Expedición y presiona "Reservar".
   - [ ] Completa el flujo hasta la pasarela de MP.
   - [ ] Usa una tarjeta de prueba de Mercado Pago (o rechaza el pago).
   - [ ] Valida que el `bookingStatus` pase a ser 'pending' o 'paid' según el escenario.

2. **Mejora Premium (RevenueCat)**
   - [ ] Navega a perfil y presiona "Mejorar a Premium".
   - [ ] Debes ver la pasarela nativa (App Store / Google Play). 
   - [ ] Efectúa la suscripción de sandbox (Sandbox Apple ID / Google Test Account).
   - [ ] Comprueba que tu cuenta se marca como VIP instantáneamente.

## 🧪 Fase 4: Crónica Vivencial con IA

1. **Generador de IA (Gemini)**
   - [ ] Abre tu Diario de Viaje o la herramienta de "Generador de Ruta".
   - [ ] Usa la foto que tomaste en el *Paso 1* o ingresa tu estado de ánimo.
   - [ ] Solicita la generación.
   - [ ] Verifica que Gemini retorne una respuesta estructurada o un reporte experiencial completo sin generar error de parseo (Timeout o Exception).

---

### 🚀 Instrucciones para Ejecutar en Tu Dispositivo
1. Conecta tu móvil por USB.
2. Ejecuta `flutter devices` en la terminal para obtener el ID de tu equipo.
3. Compila con todo su rendimiento instalando con: `flutter run --release -d <ID_DEL_DISPOSITIVO>`
