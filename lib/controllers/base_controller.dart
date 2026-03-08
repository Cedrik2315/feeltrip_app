import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:feeltrip_app/utils/error_handler.dart';

/// Un controlador base que maneja estados comunes como 'cargando' y 'error'.
/// Todos los demás controladores de la aplicación (ej: HomeController, StoryController)
/// deberían extender de esta clase para heredar esta funcionalidad.
abstract class BaseController extends GetxController {
  // Variable observable para el estado de carga. La UI reaccionará a sus cambios.
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Variable observable para mensajes de error.
  final _errorMessage = Rx<String?>(null);
  String? get errorMessage => _errorMessage.value;

  /// Establece el estado de carga.
  void setLoading(bool loading) {
    _isLoading.value = loading;
  }

  /// Establece un mensaje de error.
  void setError(String? message) {
    _errorMessage.value = message;
  }

  /// Ejecuta una operación asíncrona (como una llamada a API)
  /// manejando automáticamente los estados de carga y los errores.
  Future<void> runBusyFuture(Future<dynamic> busyFuture,
      {BuildContext? context}) async {
    setError(null);
    setLoading(true);
    try {
      await busyFuture;
    } catch (e, s) {
      // Usamos nuestro manejador de errores centralizado.
      // Verificamos si el contexto es válido antes de usarlo para evitar errores
      // si el widget fue desmontado durante la operación asíncrona.
      AppErrorHandler.handle(e,
          stackTrace: s,
          uiContext: (context?.mounted ?? false) ? context : null);
      setError(e.toString()); // Opcional: guardar el error en el controlador
    } finally {
      setLoading(false);
    }
  }
}
