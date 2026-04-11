import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/models/travel_agency_model.dart';

class AgencyService {
  final _firestore = FirebaseFirestore.instance;

  /// Obtiene el flujo de agencias registradas en tiempo real.
  Stream<List<Map<String, dynamic>>> getAgenciesStream() {
    return _firestore.collection('agencies').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  /// Obtiene los leads (prospectos) para una agencia específica.
  Stream<List<Map<String, dynamic>>> getLeadsStream(String agencyId) {
    return _firestore.collection('agency_leads')
        .where('agencyId', isEqualTo: agencyId)
        .orderBy('createdAt', descending: true)
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  /// Registra un nuevo lead (interés de un usuario en una agencia).
  /// Base fundamental para el Panel de Agencias de la Fase 3.
  Future<void> submitLead({
    required String userId,
    required String agencyId,
    required String message,
    String? tripId,
  }) async {
    try {
      // Creamos un lead transaccional que la agencia verá en su panel
      await _firestore.collection('agency_leads').add({
        'userId': userId,
        'agencyId': agencyId,
        'tripId': tripId,
        'message': message,
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });
      AppLogger.i('AgencyService: Lead enviado con éxito a la agencia $agencyId');
    } catch (e) {
      AppLogger.e('AgencyService: Error al enviar lead: $e');
      rethrow;
    }
  }

  /// Obtiene una agencia por su ID.
  Future<TravelAgency?> getAgencyById(String agencyId) async {
    try {
      final doc = await _firestore.collection('agencies').doc(agencyId).get();
      if (doc.exists && doc.data() != null) {
        return TravelAgency.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.e('AgencyService: Error al obtener agencia $agencyId: $e');
      return null;
    }
  }

  /// Seguir a una agencia.
  Future<void> followAgency(String agencyId) async {
    try {
      // Placeholder para implementar la lógica de seguimiento en Firebase
      AppLogger.i('AgencyService: Solicitud para seguir a la agencia $agencyId');
    } catch (e) {
      AppLogger.e('AgencyService: Error al seguir agencia: $e');
    }
  }
}
