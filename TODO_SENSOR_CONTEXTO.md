# TODO: Sensor de Contexto - Progreso

## Plan Aprobado - Pasos:

### 1. [✓] Leer/Editar lib/models/vision_models.dart (agregar Position? location a VisionResult)
### 2. [✓] Editar lib/services/location_service.dart (manejo 'Permiso denegado')
### 3. [✓] Editar lib/core/di/providers.dart (crear locationProvider reactivo)
### 4. [✓] Editar lib/services/vision_service.dart (analyzeImage con Position?)
### 5. [✓] Editar lib/services/osint_ai_service.dart (prompt con location)
### 6. [✓] Editar lib/screens/smart_camera_screen.dart (capture + location + SnackBar)
### 7. [ ] Test: flutter run → SmartCameraScreen → verificar logs/SnackBar/propuesta

**Notas:** Mantener coherencia Riverpod/Logger. Usar LocationAccuracy.high ya OK.

Actualizar ✓ al completar cada paso.

