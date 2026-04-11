## TODO: Integración AI con Sistema de Agencias

**Estado: En progreso**

### Pasos del Plan (pendientes ✅ completados):

1. ✅ **Actualizar AgencyService**: Agregar `getAgenciesByMood(String mood)`
2. ✅ **Actualizar OsintAiService**: 
   - Agregar `getRecommendedAgencies(String mood)`
   - Actualizar prompt AI con agencias recomendadas
3. ✅ **Integrar en UI**: Agregar tarjeta/botón 'Ver Perfil' en results_screen.dart
4. ✅ **Testear**: Run `flutter run`, complete emotional quiz, generate proposal - verify agency rec in card & prompt, navigation to agency profile works (mock data).
5. ⏳ **Validar**: dart analyze, flutter test
6. ⏳ **Firestore**: Asegurar datos de prueba en 'agencies' collection

**Dependencias**: AgencyService, TravelAgency model, app_router (/agency/:id), Firestore agencies con specialties/verified.
