import 'package:flutter/material.dart';

class ImpactData {

  const ImpactData({
    required this.label,
    required this.emoji,
    required this.percentage,
    this.color = Colors.deepPurple,
  });
  final String label;
  final String emoji;
  final int percentage;
  final Color color;
}