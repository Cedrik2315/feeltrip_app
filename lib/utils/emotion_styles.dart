import 'package:flutter/material.dart';

class EmotionStyle {
  /// Returns a Color for the given emotion emoji
  static Color getColor(String emotion) {
    switch (emotion) {
      case '😀': // Happy/Joy
        return Colors.amber;
      case '😌': // Peaceful/Calm
        return Colors.lightBlue;
      case '😍': // Love
        return Colors.pink;
      case '😎': // Cool/Adventurous
        return Colors.orange;
      case '😭': // Sad
        return Colors.blueGrey;
      case '😡': // Angry
        return Colors.red;
      case '😐': // Neutral
        return Colors.grey;
      case '🥰': // Affectionate
        return Colors.deepPurple;
      default:
        return Colors.purple;
    }
  }

  /// Returns an IconData for the given emotion emoji
  static IconData getIcon(String emotion) {
    switch (emotion) {
      case '😀': // Happy/Joy
        return Icons.sentiment_very_satisfied;
      case '😌': // Peaceful/Calm
        return Icons.spa;
      case '😍': // Love
        return Icons.favorite;
      case '😎': // Cool/Adventurous
        return Icons.flash_on;
      case '😭': // Sad
        return Icons.sentiment_dissatisfied;
      case '😡': // Angry
        return Icons.whatshot;
      case '😐': // Neutral
        return Icons.sentiment_neutral;
      case '🥰': // Affectionate
        return Icons.favorite_border;
      default:
        return Icons.emoji_emotions;
    }
  }
}
