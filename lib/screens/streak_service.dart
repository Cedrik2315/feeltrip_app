import 'package:cloud_firestore/cloud_firestore.dart';

class StreakService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> actualizarRacha(String userId) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();

    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Medianoche de hoy

    DateTime? lastCheckInDate;

    if (data.containsKey('lastCheckIn') && data['lastCheckIn'] != null) {
      final timestamp = data['lastCheckIn'] as Timestamp;
      final date = timestamp.toDate();
      lastCheckInDate = DateTime(date.year, date.month, date.day);
    }

    if (lastCheckInDate == null) {
      // Primera vez
      await userRef.update({
        'currentStreak': 1,
        'lastCheckIn': FieldValue.serverTimestamp(),
      });
    } else {
      final difference = today.difference(lastCheckInDate).inDays;

      if (difference == 0) {
        // Ya hizo check-in hoy, no hacemos nada
        return;
      } else if (difference == 1) {
        // Día consecutivo: ¡Aumenta la racha!
        await userRef.update({
          'currentStreak': FieldValue.increment(1),
          'lastCheckIn': FieldValue.serverTimestamp(),
          'totalXP': FieldValue.increment(150), // Bono por mantener racha
        });
      } else {
        // Se rompió la racha (difference > 1)
        await userRef.update({
          'currentStreak': 1,
          'lastCheckIn': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
