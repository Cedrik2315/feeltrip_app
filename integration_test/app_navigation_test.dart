import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:feeltrip_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Navigation E2E Test', () {
    testWidgets('Verify guided user journey starting from WelcomeScreen', (tester) async {
      app.main();
      
      // 1. Esperamos a que el video de fondo finalice y aparezca la opacidad
      debugPrint('Aguardando finalización de video en WelcomeScreen...');
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // 2. Encontramos el botón de ingreso
      final btnIngresar = find.text('INGRESAR AL SISTEMA');
      expect(btnIngresar, findsOneWidget, reason: 'El botón de INGRESAR no apareció');

      // 3. Hacemos clic
      debugPrint('Clic en INGRESAR AL SISTEMA');
      await tester.tap(btnIngresar);
      await tester.pumpAndSettle();

      // 4. Verificamos que aterrizamos en HomeScreen
      debugPrint('Verificando HomeScreen...');
      expect(find.text('FeelTrip'), findsOneWidget, reason: 'App title FeelTrip not found en Home');
      expect(find.text('EXPEDICIONES RECIENTES'), findsOneWidget);

      // 5. Clic al engranaje de configuración
      final settingsIcon = find.byIcon(Icons.settings_outlined);
      expect(settingsIcon, findsOneWidget);
      debugPrint('Clic navegando a Settings...');
      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();

      debugPrint('Journey Completado con Éxito ✅');
    });
  });
}
