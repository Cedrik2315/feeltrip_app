import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'achievement_dialog.dart';

class AchievementGrid extends StatelessWidget {
  final bool isUserPremium;

  // Lista de logros disponibles - IDs deben coincidir con AchievementService
  final List<Map<String, dynamic>> allBadges = [
    // --- LOGROS PREMIUM (RELIQUIAS) ---
    {
      'id': 'mecenas_global',
      'name': 'Mecenas Global',
      'icon': Icons.workspace_premium,
      'desc': 'Realizar la primera suscripción.',
      'isPremium': true,
    },
    {
      'id': 'ciudadano_mundo',
      'name': 'Ciudadano del Mundo',
      'icon': Icons.public,
      'desc': 'Usar el traductor en 5 países distintos.',
      'isPremium': true,
    },
    {
      'id': 'leyenda_viviente',
      'name': 'Leyenda Viviente',
      'icon': Icons.fort,
      'desc': 'Completar 50 rutas o viajes.',
      'isPremium': true,
    },
    // --- LOGROS ESTÁNDAR (EXPLORADOR) ---
    {
      'id': 'primer_paso',
      'name': 'Primer Paso',
      'icon': Icons.explore,
      'desc': 'Iniciaste tu primer viaje.',
      'isPremium': false,
    },
    {
      'id': 'cazador_luces',
      'name': 'Cazador de Luces',
      'icon': Icons.camera_alt,
      'desc': 'Guardaste una memoria visual.',
      'isPremium': false,
    },
    {
      'id': 'alquimista_emocional',
      'name': 'Alquimista',
      'icon': Icons.auto_awesome,
      'desc': '3 emociones en una semana.',
      'isPremium': false,
    },
    {
      'id': 'viajero_frecuente',
      'name': 'Viajero Frecuente',
      'icon': Icons.auto_graph,
      'desc': '5 rutas completadas.',
      'isPremium': false,
    },
  ];

  AchievementGrid({super.key, required this.isUserPremium});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      return _buildLockedGrid();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .snapshots(),
      builder: (context, snapshot) {
        // Creamos un set con los IDs de los logros ya desbloqueados
        final unlockedIds = snapshot.hasData
            ? snapshot.data!.docs.map((doc) => doc.id).toSet()
            : <String>{};

        return _buildGrid(unlockedIds);
      },
    );
  }

  Widget _buildLockedGrid() {
    return _buildGrid(<String>{});
  }

  Widget _buildGrid(Set<String> unlockedIds) {
    final premiumBadges =
        allBadges.where((b) => b['isPremium'] == true).toList();
    final standardBadges =
        allBadges.where((b) => b['isPremium'] != true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- SECCIÓN PREMIUM ---
        const Text(
          "Reliquias de Leyenda",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: premiumBadges.length,
            itemBuilder: (context, index) {
              final badge = premiumBadges[index];
              final isUnlocked = unlockedIds.contains(badge['id']);
              return Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: _buildPremiumBadge(context, badge, isUnlocked),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // --- SECCIÓN ESTÁNDAR ---
        const Text(
          "Logros de Explorador",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildStandardGrid(standardBadges, unlockedIds),
      ],
    );
  }

  Widget _buildPremiumBadge(
      BuildContext context, Map<String, dynamic> badge, bool isUnlocked) {
    // Si el usuario NO es premium, mostramos candado y bloqueamos interacción
    final showContent = isUserPremium;
    final icon = showContent ? badge['icon'] as IconData : Icons.lock_outline;
    final color = isUnlocked ? Colors.amber[800] : Colors.grey[400];

    return GestureDetector(
      onTap: (isUnlocked && showContent)
          ? () => _showBadgeDialog(context, badge)
          : null,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Fondo de resplandor para logros premium (solo si es usuario premium)
              if (showContent)
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              // El icono del logro
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked ? Colors.amber[50] : Colors.grey[200],
                  border: Border.all(
                    color: isUnlocked ? Colors.amber : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              badge['name'] as String,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.black87 : Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardGrid(
      List<Map<String, dynamic>> badges, Set<String> unlockedIds) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final isUnlocked = unlockedIds.contains(badge['id']);

        return GestureDetector(
          onTap: isUnlocked ? () => _showBadgeDialog(context, badge) : null,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked ? Colors.deepPurple[100] : Colors.grey[200],
                  border: Border.all(
                    color: isUnlocked ? Colors.deepPurple : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  badge['icon'] as IconData,
                  size: 30,
                  color: isUnlocked ? Colors.deepPurple : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge['name'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                  color: isUnlocked ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBadgeDialog(BuildContext context, Map<String, dynamic> badge) {
    HapticFeedback.vibrate();
    showDialog(
      context: context,
      builder: (_) => AchievementDialog(
        title: badge['name'] as String,
        icon: badge['icon'] as IconData,
      ),
    );
  }
}
