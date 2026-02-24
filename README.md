# FeelTrip - Plataforma de Viajes Vivenciales

Una aplicación Flutter que transforma la manera en que viajamos, enfocándose en **experiencias transformadoras y vivenciales**. FeelTrip no es solo para reservar viajes, sino para capturar, compartir y revivir el impacto emocional de cada aventura.

La aplicación está construida sobre una arquitectura moderna con **Flutter y Firebase**, permitiendo sincronización de datos en tiempo real, persistencia en la nube y una base escalable para el futuro.

## 🌟 Características

### Core Vivencial (Fase 2)
- ✅ **Historias de Viajeros:** Inspírate con historias reales de transformación compartidas por la comunidad.
- ✅ **Diario Personal:** Registra tus reflexiones, emociones y la profundidad de tus experiencias en tiempo real.
- ✅ **Estadísticas de Impacto:** Observa cómo los viajes te transforman a través de métricas automáticas.
- ✅ **Quiz de Arquetipos:** Descubre tu perfil de viajero (Conector, Transformado, Aventurero, etc.) y recibe recomendaciones personalizadas.
- ✅ **Sincronización en la Nube:** Todos tus datos se guardan y sincronizan al instante entre dispositivos con Firebase Firestore.

### Características Adicionales
- ✅ Autenticación de usuarios (preparado para Firebase Auth).
- ✅ Exploración de viajes y búsqueda.
- ✅ Sistema de perfiles para agencias de viajes.
- ✅ Funcionalidad para compartir en redes sociales.
- ✅ Comentarios y reacciones en las historias.

## 🔧 Instalación y Setup

Para una guía rápida de 30 minutos y poner todo en marcha, consulta **[QUICK_START.md](./QUICK_START.md)**.

Para una guía de configuración detallada, incluyendo la creación del proyecto en Firebase, consulta **[FIREBASE_SETUP.md](./FIREBASE_SETUP.md)**.

### Requisitos Previos
- Flutter SDK (>=2.12.0)
- Una cuenta de Google para configurar Firebase.
- Android Studio / Xcode para emuladores.

## 📦 Dependencias Clave

- **`firebase_core`** & **`cloud_firestore`**: Para la integración con el backend de Firebase.
- **`get`**: Para la gestión de estado y navegación.
- **`flutter_dotenv`**: Para manejar variables de entorno y credenciales.
- **`uuid`**: Para la generación de IDs únicos.

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart                 # Entrada principal
├── models/                   # Modelos de datos
│   ├── user_model.dart
│   ├── trip_model.dart
│   ├── booking_model.dart
│   ├── review_model.dart
│   └── cart_item_model.dart
├── screens/                  # Pantallas de la app
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── trip_detail_screen.dart
│   ├── cart_screen.dart
│   ├── bookings_screen.dart
│   └── profile_screen.dart
├── services/                 # Servicios
│   ├── api_service.dart      # Integración con API
│   └── storage_service.dart  # Almacenamiento local
└── assets/                   # Recursos
    └── images/

```

## ️ Arquitectura
La aplicación sigue una arquitectura limpia y escalable:
- **UI (Screens)**: Widgets de Flutter que reaccionan a los cambios de estado.
- **State Management (Controllers)**: `ExperienceController` (GetX) maneja el estado de la UI y la lógica de presentación.
- **Business Logic (Services)**: `StoryService`, `DiaryService`, etc., encapsulan toda la comunicación con Firestore.
- **Data (Models)**: Clases Dart con métodos `toFirestore()` y `fromFirestore()` para serialización.
- **Backend**: Firebase Firestore como base de datos NoSQL en tiempo real.
Para más detalles, consulta **ARCHITECTURE.md** y **FIREBASE_ARCHITECTURE.md**.

## 🎨 Temas y Estilos

La aplicación utiliza:
- **Color secundario**: `Colors.purple`
- **Tipografía**: Fuentes del sistema (Roboto/San Francisco)

##  Seguridad

- **Aislamiento de Datos:** La estructura de Firestore aísla los datos privados de cada usuario.
- **Reglas de Seguridad:** El archivo `firestore-rules.txt` define reglas de acceso robustas para proteger los datos en el backend.
- **Autenticación:** Preparado para integración con Firebase Auth para una gestión de usuarios segura.

## 🚀 Características Futuras

El roadmap completo se encuentra en **ROADMAP.md**. Las próximas prioridades incluyen:
- [ ] **Notificaciones Push:** Con Firebase Cloud Messaging para alertar sobre comentarios y reacciones.
- [ ] **Autenticación Real:** Integración completa con Firebase Auth (Email, Google, etc.).
- [ ] **Almacenamiento de Imágenes:** Usar Firebase Storage para las fotos de las historias.
- [ ] **Dashboard de Analíticas:** Para los perfiles de agencias.
- [ ] **Monetización:** Integración de comisiones por reserva y tiers premium para agencias.

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo licencia MIT.

## 👨‍💼 Autor

**FeelTrip Development Team**

## 📞 Soporte

Para reportar bugs o sugerencias, por favor abre un issue en el repositorio.

---

**Última actualización**: Enero 2026
**Versión**: 1.0.0

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
