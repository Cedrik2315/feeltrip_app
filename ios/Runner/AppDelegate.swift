import Flutter
import UIKit
import GoogleMaps // FIX: Importar GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // FIX: Proveer la API Key de Google Maps para iOS
    GMSServices.provideAPIKey("TU_API_KEY_DE_GOOGLE_MAPS_AQUÍ")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
