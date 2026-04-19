import 'package:google_generative_ai/google_generative_ai.dart';


void main() async {
  // Simulación directa para evitar dependencias de Flutter
  final apiKey = 'AIzaSyD_xpoj38mdaC3MlYjk50eezxR3jWl8L68'; // Usando la del .env
  
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );

  final commonContext = '''
    Explorador: Cedrik
    Expedición: #001 a Parque Nacional La Campana, Valparaíso.
    Datos: Llegada 17:30, 22°C. Lirico.
    Detalle sensorial: "El olor a tierra mojada tras la llovizna y el crujir de las hojas secas."
    Telemetría: 8.5 km, 450 m desnivel.
  ''';

  Future<void> test(String archetype) async {
    final prompt = '''
    Actúa como un cronista de viajes literario y mentor existencialista de FeelTrip.
    Tu estilo narrativo DEBE adaptarse al arquetipo del explorador: $archetype.
    
    INSTRUCCIONES DE ESTILO POR ARQUETIPO:
    - Aventurero: Usa verbos de acción, lenguaje visceral, enfoque en el desafío y la superación física.
    - Contemplativo: Usa lenguaje poético, metáforas sobre la luz y el silencio, enfoque en la belleza y la paz.
    - Conector: Enfócate en los encuentros, la calidez humana, la pertenencia y las historias compartidas.
    - Aprendiz: Usa un tono curioso, datos culturales sutiles y reflexiones sobre el saber del lugar.
    - Transformado: Enfócate en el cambio interno, el simbolismo de la mariposa y el dejar atrás la vieja versión.

    Redacta una crónica de transformación personal para el explorador Cedrik 
    sobre su expedición #001 a Parque Nacional La Campana.
    
    DATOS DE LA EXPEDICIÓN:
    $commonContext

    ESTRUCTURA DE LA RESPUESTA:
    1. El primer renglón DEBE ser un título evocador y místico.
    2. El resto debe ser un relato profundo en primera persona.
    3. Divide el texto en 3 o 4 párrafos claros.
    4. No uses formato Markdown, solo texto plano en español.
    ''';

    final response = await model.generateContent([Content.text(prompt)]);
    print('\n[RESULTADO PARA $archetype]:');
    print(response.text);
    print('-' * 20);
  }

  print('Lanzando prueba de crónicas...');
  await test('Aventurero');
  await test('Contemplativo');
}
