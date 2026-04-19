/// Entidad de dominio para los códigos de invitación de FeelTrip.
/// Representa un documento de la colección `inviteCodes/{code}` en Firestore.
class InviteCode {
  const InviteCode({
    required this.code,
    required this.ownerId,
    this.usedBy,
    this.usedAt,
    required this.isActive,
  });

  /// El código en sí (ej: "FELT-X7K2"). También es el ID del documento.
  final String code;

  /// UID del usuario propietario del código.
  final String ownerId;

  /// UID del usuario que usó el código (null si aún no fue usado).
  final String? usedBy;

  /// Fecha en que fue usado (null si aún no fue usado).
  final DateTime? usedAt;

  /// false cuando ya fue consumido.
  final bool isActive;

  /// Construye desde el mapa de Firestore.
  factory InviteCode.fromFirestore(String code, Map<String, dynamic> data) {
    return InviteCode(
      code: code,
      ownerId: data['ownerId'] as String? ?? '',
      usedBy: data['usedBy'] as String?,
      usedAt: (data['usedAt'] as dynamic)?.toDate() as DateTime?,
      isActive: (data['isActive'] as bool?) ?? false,
    );
  }

  /// Convierte a mapa para escritura en Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'usedBy': usedBy,
      'usedAt': usedAt,
      'isActive': isActive,
    };
  }
}
