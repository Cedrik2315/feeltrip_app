class RateLimiter {
  final Map<String, List<DateTime>> _requestHistory = {};
  
  /// Límite de peticiones permitidas
  final int maxRequests;
  /// Ventana de tiempo en segundos
  final int windowSeconds;

  RateLimiter({this.maxRequests = 5, this.windowSeconds = 60});

  /// Verifica si el usuario (identificado por [key]) puede realizar una petición.
  /// Retorna true si está permitido, false si debe ser limitado.
  bool canRequest(String key) {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(seconds: windowSeconds));

    if (!_requestHistory.containsKey(key)) {
      _requestHistory[key] = [now];
      return true;
    }

    // Limpiar historial antiguo fuera de la ventana
    _requestHistory[key] = _requestHistory[key]!
        .where((timestamp) => timestamp.isAfter(windowStart))
        .toList();

    if (_requestHistory[key]!.length < maxRequests) {
      _requestHistory[key]!.add(now);
      return true;
    }

    return false;
  }

  /// Retorna el tiempo restante en segundos hasta que el usuario pueda volver a pedir.
  int secondsToWait(String key) {
    if (!_requestHistory.containsKey(key) || _requestHistory[key]!.isEmpty) return 0;
    
    final oldestInWindow = _requestHistory[key]!.first;
    final canRequestAt = oldestInWindow.add(Duration(seconds: windowSeconds));
    final diff = canRequestAt.difference(DateTime.now()).inSeconds;
    
    return diff > 0 ? diff : 0;
  }
}
