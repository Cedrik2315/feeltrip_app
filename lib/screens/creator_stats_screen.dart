import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/story_service.dart';
import '../services/comment_service.dart';

class CreatorStatsScreen extends StatefulWidget {
  const CreatorStatsScreen({super.key});

  @override
  State<CreatorStatsScreen> createState() => _CreatorStatsScreenState();
}

class _CreatorStatsScreenState extends State<CreatorStatsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? currentUid;
  int totalStories = 0;
  int totalLikes = 0;
  int totalComments = 0;
  List<FlSpot> monthlyData = [];

  @override
  void initState() {
    super.initState();
    currentUid = AuthService.currentUser?.uid;
    _loadStats();
    _generateMockMonthlyData();
  }

  Future<void> _loadStats() async {
    if (currentUid == null) return;

    try {
      // Total stories
      final storySnap = await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('stories')
          .get();
      totalStories = storySnap.docs.length;

      // Total likes (sum likes from stories)
      int likesSum = 0;
      for (var doc in storySnap.docs) {
        likesSum += (doc.data()['likes'] as num?)?.toInt() ?? 0;
      }
      totalLikes = likesSum;

      // Total comments
      final commentSnap = await _firestore
          .collection('stories')
          .where('userId', isEqualTo: currentUid)
          .get();
      int commentsSum = 0;
      for (var doc in commentSnap.docs) {
        final commentsRef =
            _firestore.collection('stories').doc(doc.id).collection('comments');
        final commentsSnap = await commentsRef.get();
        commentsSum += commentsSnap.docs.length;
      }
      totalComments = commentsSum;

      setState(() {});
    } catch (e) {
      // log eliminado: Error loading stats: $e
    }
  }

  void _generateMockMonthlyData() {
    final now = DateTime.now();
    monthlyData = [];
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthlyData.add(
          FlSpot(i.toDouble(), (20 + (i * 3)).toDouble())); // Mock activity
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas Creador'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen General',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _statCard('📖 Historias', totalStories.toString())),
                Expanded(child: _statCard('❤️ Likes', totalLikes.toString())),
                Expanded(
                    child:
                        _statCard('💬 Comentarios', totalComments.toString())),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Actividad Mensual',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyData,
                      isCurved: true,
                      color: Colors.deepPurple,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.deepPurple.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Datos generados con datos simulados. En producción, consulta Firestore por mes.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            if (currentUid == null)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.account_circle,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Inicia sesión para ver tus estadísticas'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
