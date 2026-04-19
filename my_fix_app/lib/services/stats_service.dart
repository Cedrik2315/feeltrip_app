import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/logger/app_logger.dart';

final statsServiceProvider = Provider((ref) => StatsService());

/// Servicio para gestionar estadísticas de creadores utilizando agregaciones de Firestore.
/// Esta implementación es vital para la escalabilidad Post-PMF, evitando la lectura
/// de miles de documentos individuales.
class StatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene las estadísticas consolidadas de un creador (historias totales y likes).
  /// Utiliza [AggregateQuery] para realizar el cálculo en el servidor.
  Future<Map<String, dynamic>> getCreatorStats(String creatorId) async {
    try {
      final query = _firestore
          .collection('stories')
          .where('userId', isEqualTo: creatorId);

      // Realizamos múltiples agregaciones en una sola llamada al servidor
      final aggregateSnapshot = await query
          .aggregate(
            count(),
            sum('likes'),
          )
          .get();

      final stats = {
        'totalStories': aggregateSnapshot.count,
        'totalLikes': aggregateSnapshot.getSum('likes') ?? 0,
      };

      AppLogger.i(
          'StatsService: Agregación completada para $creatorId: $stats');
      return stats;
    } catch (e) {
      AppLogger.e('StatsService: Error en consulta de agregación: $e');
      return {'totalStories': 0, 'totalLikes': 0};
    }
  }

  /// Nota de Escalabilidad: Para contadores de alta frecuencia (como likes en tiempo real
  /// de una cuenta viral), se debe implementar un "Distributed Counter" (Sharding)
  /// para evitar el límite de 1 escritura por segundo por documento.
  Future<void> incrementSharedCounter(
    DocumentReference ref, {
    int numShards = 10,
  }) async {
    final shardId = Random().nextInt(numShards);
    final shardRef = ref.collection('shards').doc(shardId.toString());

    return shardRef.set(
      {'count': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }

  /// Suma los valores de todos los shards para obtener el total real.
  Future<int> getSharedCount(DocumentReference ref) async {
    final snapshot =
        await ref.collection('shards').aggregate(sum('count')).get();
    return (snapshot.getSum('count') ?? 0).toInt();
  }
}
