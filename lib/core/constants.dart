import 'package:flutter/material.dart';

class K {
  static const int n = 9; // 9x9 grid
}

class AiBelt {
  // 1..7 mapping
  static const List<String> names = [
    'White', 'Orange', 'Red', 'Green', 'Blue', 'Brown', 'Black'
  ];

  static const List<int> colors = [
    0xFFFFFFFF, // White
    0xFFFFA500, // Orange
    0xFFFF3B30, // Red
    0xFF34C759, // Green
    0xFF0A84FF, // Blue
    0xFF8B4513, // Brown
    0xFF000000, // Black
  ];

  static String nameFor(int level) {
    final idx = (level.clamp(1, 7)) - 1;
    return names[idx];
  }

  static Color colorFor(int level) {
    final idx = (level.clamp(1, 7)) - 1;
    return Color(colors[idx]);
  }
}
