{ pkgs, ... }: {
  # Canal de software a utilizar
  channel = "stable-23.11"; 

  # Paquetes que se instalarán en el entorno
  packages = [
    pkgs.flutter
    pkgs.dart
    pkgs.jdk17 # Necesario para el build de Android
  ];

  # Configuración específica de variables de entorno
  env = {
    # Aquí podrías poner tu API Key de Gemini si la usas como variable de entorno
    # GEMINI_API_KEY = "tu_llave_aqui"; 
  };

  idx = {
    # Extensiones de VS Code que se instalarán automáticamente
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
      "google.gemini-code-assist" # La IA nativa de Antigravity
    ];

    # Configuración de los previsualizadores (Previews)
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flutter" "run" "--machine" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "$PORT"];
          manager = "flutter";
        };
        android = {
          command = ["flutter" "run" "--machine" "-d" "android" "-d" "emulator-5554"];
          manager = "flutter";
        };
      };
    };
  }
}