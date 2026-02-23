# FeelTrip - Aplicación de Agencia de Viajes

Una aplicación Flutter completa para una agencia de viajes que ofrece una experiencia de usuario moderna e intuitiva para reservar y explorar viajes alrededor del mundo.

## 🌟 Características

### Autenticación
- ✅ Pantalla de Onboarding
- ✅ Registro de nuevos usuarios
- ✅ Inicio de sesión seguro
- ✅ Gestión de sesión local

### Exploración de Viajes
- ✅ Pantalla de inicio con viajes destacados
- ✅ Búsqueda avanzada por destino, categoría y dificultad
- ✅ Filtrado de viajes por precio
- ✅ Detalles completos de cada viaje con galerías de imágenes

### Reservas y Carrito
- ✅ Agregar viajes al carrito
- ✅ Gestionar cantidad de viajeros
- ✅ Carrito de compras persistente
- ✅ Proceso de pago simulado
- ✅ Sistema de impuestos

### Historial de Reservas
- ✅ Ver todas las reservas del usuario
- ✅ Estado de las reservas
- ✅ Cancelación de viajes
- ✅ Detalles y recibos

### Perfil de Usuario
- ✅ Editar información personal
- ✅ Cambiar contraseña
- ✅ Preferencias de notificaciones
- ✅ Cambio de idioma y tema
- ✅ Cierre de sesión

### Experiencia de Usuario
- ✅ Interfaz moderna y responsiva
- ✅ Tema coherente con paleta de colores púrpura
- ✅ Navegación intuitiva con barra inferior
- ✅ Animaciones suaves
- ✅ Cargas asincrónicas
- ✅ Manejo de errores

## 📱 Pantallas

1. **Onboarding** - Introducción a la aplicación
2. **Login** - Inicio de sesión
3. **Register** - Registro de nuevos usuarios
4. **Home** - Página principal con viajes destacados
5. **Search** - Búsqueda y filtrado de viajes
6. **Trip Details** - Detalles completos de un viaje
7. **Cart** - Carrito de compras
8. **Bookings** - Mis reservas
9. **Profile** - Perfil del usuario

## 🔧 Instalación

### Requisitos
- Flutter SDK (>=2.12.0)
- Dart SDK
- Android Studio o Xcode para emuladores
- Un editor de código (VS Code o Android Studio)

### Pasos

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/feeltrip_app.git
cd feeltrip_app
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar la aplicación**
```bash
flutter run
```

## 📦 Dependencias

- **get**: Gestión de estado y navegación
- **http**: Llamadas a API REST
- **shared_preferences**: Almacenamiento local
- **carousel_slider**: Carruseles de imágenes
- **smooth_page_indicator**: Indicadores de página
- **flutter_rating_bar**: Barras de calificación
- **image_picker**: Selección de imágenes
- **intl**: Internacionalización
- **uuid**: Generación de IDs únicos
- **cached_network_image**: Caché de imágenes

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

## 🌐 API Endpoints

La aplicación está configurada para conectarse a `https://api.feeltrip.com/api` con los siguientes endpoints:

### Viajes
- `GET /trips` - Obtener todos los viajes
- `GET /trips/{id}` - Obtener detalles de un viaje
- `GET /trips/{id}/reviews` - Obtener reseñas de un viaje

### Reservas
- `POST /bookings` - Crear una reserva
- `GET /users/{userId}/bookings` - Obtener mis reservas
- `POST /bookings/{id}/cancel` - Cancelar una reserva

### Favoritos
- `POST /users/{userId}/favorites/{tripId}` - Agregar/quitar favorito
- `GET /users/{userId}/favorites` - Obtener favoritos

### Reseñas
- `POST /trips/{tripId}/reviews` - Agregar reseña

### Pagos
- `POST /payments` - Procesar pago

## 🎨 Temas y Estilos

La aplicación utiliza:
- **Color primario**: `Colors.deepPurple` (#673AB7)
- **Color secundario**: `Colors.purple`
- **Tipografía**: Fuentes del sistema
- **Espaciado**: Consistente con Material Design 3

## 💾 Almacenamiento Local

Usando `SharedPreferences`:
- Token de autenticación
- Datos del usuario
- Carrito de compras
- Preferencias (tema, idioma)

## 🔐 Seguridad

- Tokens almacenados localmente
- Validación de formularios
- Manejo seguro de contraseñas
- HTTPS para comunicación con API

## 📝 Notas de Implementación

### Datos Simulados
Actualmente la aplicación utiliza datos simulados para demostración. Para conectarla a una API real:

1. Actualiza `ApiService` con tu URL de API
2. Implementa autenticación real con tokens JWT
3. Conecta Firebase o tu servicio de autenticación

### Personalización

Para personalizar la aplicación:
- Cambiar colores: Actualizar `Colors.deepPurple` en `main.dart`
- Agregar más categorías: Modificar arrays en `search_screen.dart`
- Añadir métodos de pago: Extender `processPayment()` en `api_service.dart`

## 🚀 Características Futuras

- [ ] Integración real con API backend
- [ ] Autenticación con Firebase
- [ ] Pagos con Stripe
- [ ] Chat con agentes de viajes
- [ ] Seguimiento de viajes en tiempo real
- [ ] Integración con mapas
- [ ] Sistema de reseñas completo
- [ ] Notificaciones push
- [ ] Descubrimiento de experiencias locales
- [ ] Idiomas múltiples

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
