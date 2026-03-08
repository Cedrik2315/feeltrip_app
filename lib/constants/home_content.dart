import 'package:flutter/material.dart';

class HomeArchetypeItem {
  const HomeArchetypeItem({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });

  final String emoji;
  final String title;
  final String description;
  final Color color;
}

class HomeQuickAccessItem {
  const HomeQuickAccessItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String route;
}

const List<HomeArchetypeItem> homeArchetypes = [
  HomeArchetypeItem(
    emoji: '💕',
    title: 'Conector',
    description: 'Conexiones humanas\ny culturales',
    color: Colors.red,
  ),
  HomeArchetypeItem(
    emoji: '🦋',
    title: 'Transformado',
    description: 'Crecimiento personal\ny reflexión',
    color: Colors.deepPurple,
  ),
  HomeArchetypeItem(
    emoji: '⚡',
    title: 'Aventurero',
    description: 'Adrenalina y\nnuevas emociones',
    color: Colors.orange,
  ),
  HomeArchetypeItem(
    emoji: '🌄',
    title: 'Contemplativo',
    description: 'Paz interior y\nconexión con la naturaleza',
    color: Colors.cyan,
  ),
  HomeArchetypeItem(
    emoji: '📚',
    title: 'Aprendiz',
    description: 'Conocimiento y\ndescubrimiento',
    color: Colors.green,
  ),
];

const List<HomeQuickAccessItem> homeQuickAccessItems = [
  HomeQuickAccessItem(
    emoji: '📔',
    title: 'Mi diario',
    subtitle: 'Registra tus emociones',
    route: '/diary',
  ),
  HomeQuickAccessItem(
    emoji: '📊',
    title: 'Mi impacto',
    subtitle: 'Mide tu transformación',
    route: '/impact-dashboard',
  ),
  HomeQuickAccessItem(
    emoji: '🌐',
    title: 'Comunidad',
    subtitle: 'Historias de viajeros',
    route: '/stories',
  ),
];
