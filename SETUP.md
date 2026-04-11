# 📋 GUÍA DE CONFIGURACIÓN - FeelTrip App

## 🚀 Inicio Rápido

### Requisitos Previos
```
- Flutter 2.12+
- Dart 2.17+
- Android SDK (para desarrollo Android)
- Xcode (para desarrollo iOS)
- VS Code o Android Studio
```

### Instalación Inicial

1. **Clona el repositorio**
```bash
git clone https://github.com/tu-usuario/feeltrip_app.git
cd feeltrip_app
```

2. **Limpia proyectos anteriores**
```bash
flutter clean
```

3. **Obtén todas las dependencias**
```bash
flutter pub get
```

4. **Ejecuta la aplicación**
```bash
flutter run
```

## 🔧 Configuración del Proyecto

### Estructura de Directorios

```
feeltrip_app/
├── android/              # Configuración Android
├── ios/                  # Configuración iOS
├── lib/
│   ├── main.dart         # Punto de entrada
│   ├── models/           # Modelos de datos
│   ├── screens/          # Pantallas de UI
│   └── services/         # Servicios (API, Storage)
├── test/                 # Pruebas unitarias
├── pubspec.yaml          # Dependencias
└── README.md             # Documentación
```

### Agregar Dependencias

Si necesitas agregar una nueva dependencia:

```bash
flutter pub add nombre_paquete
```

### Generar APK/Bundle

**APK Debug:**
```bash
flutter build apk --debug
```

**APK Release:**
```bash
flutter build apk --release
```

**App Bundle (Play Store):**
```bash
flutter build appbundle
```

**IPA (App Store):**
```bash
flutter build ios --release
```

## 🌐 Configuración de API

### Base URL de Producción
Editar en `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://api.feeltrip.com/api';
```

### Variables de Entorno
Crear archivo `.env`:

```env
API_URL=https://api.feeltrip.com/api
API_KEY=tu_api_key_aqui
STRIPE_KEY=tu_stripe_key
```

## 🔐 Seguridad

### Firebase Setup (Opcional)
1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Crea un nuevo proyecto
3. Descarga `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)
4. Colócalos en sus respectivas carpetas

### Configuración de Autenticación
Editar en `lib/services/api_service.dart`:

```dart
Future<bool> login(String email, String password) async {
  // Implementar lógica de login
}
```

## 🎨 Personalización

### Cambiar Tema Principal
En `lib/main.dart`, modifica:

```dart
primaryColor: Colors.deepPurple,  // Cambiar color
```

### Cambiar Nombre de Aplicación

**Android:**
- Editar `android/app/src/main/AndroidManifest.xml`
- Cambiar `android:label="feeltrip"`

**iOS:**
- Editar `ios/Runner/Info.plist`
- Cambiar `<string>feeltrip</string>`

### Cambiar Icono de App

**Android:**
- Reemplazar `android/app/src/main/res/mipmap-*/ic_launcher.png`

**iOS:**
- Reemplazar iconos en `ios/Runner/Assets.xcassets`

## 📱 Desarrollo por Plataforma

### Android

Requisitos:
- Android SDK 21+ (API Level)
- Emulador o dispositivo físico

Comandos útiles:
```bash
# Listar dispositivos
flutter devices

# Ejecutar en dispositivo específico
flutter run -d device_id

# Instalar en dispositivo
adb install build/app/outputs/apk/release/app-release.apk
```

### iOS

Requisitos:
- macOS 10.15+
- Xcode 12.0+
- CocoaPods

Comandos:
```bash
# Ver dispositivos iOS
xcrun simctl list

# Ejecutar en iOS
flutter run -d iPhone
```

## 🧪 Testing

### Ejecutar Pruebas Unitarias
```bash
flutter test
```

### Ejecutar Pruebas de Integración
```bash
flutter drive --target=test_driver/app.dart
```

## 📊 Monitoreo y Debugging

### DevTools
```bash
flutter pub global activate devtools
devtools
```

### Hot Reload
```bash
# Durante ejecución
r          # Hot reload
R          # Hot restart
q          # Quit
```

### Logs
```bash
flutter logs
```

### Performance
```bash
flutter run --profile
```

## 🐛 Solución de Problemas

### Error: "Flutter SDK not found"
```bash
export PATH="$PATH:/ruta/a/flutter/bin"
```

### Error: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Error: "CocoaPods dependency error" (iOS)
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### Ports Already in Use
```bash
# Cambiar puerto
flutter run --device-vmservice-port=50300
```

## 📚 Recursos Útiles

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design](https://material.io/design)
- [GetX Package](https://pub.dev/packages/get)

## ✅ Checklist Pre-Publicación

- [ ] Todos los tests pasan
- [ ] No hay errores en la consola
- [ ] Iconos de app configurados
- [ ] Nombre de app actualizado
- [ ] API endpoints de producción configurados
- [ ] Versión actualizada en pubspec.yaml
- [ ] Certificados/keys de seguridad configurados
- [ ] Privacy policy implementada
- [ ] Terms of service implementados
- [ ] Screenshots para stores preparados

## 📞 Soporte

Para más ayuda:
1. Revisa la [documentación oficial](https://flutter.dev)
2. Busca en [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
3. Abre un issue en el repositorio

---

**Versión**: 1.0.0 | **Última actualización**: Enero 2026
