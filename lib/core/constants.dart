import 'package:flutter/material.dart';

class K {
  static int n = 9; // 9x9 grid (runtime override for phone sizing)
}

class AiBelt {
  // 1..7 mapping
  // 1 - White, 2 - Yellow, 3 - Orange, 4 - Green, 5 - Blue, 6 - Brown, 7 - Black
  static const List<String> names = [
    'White',
    'Yellow',
    'Orange',
    'Green',
    'Blue',
    'Brown',
    'Black'
  ];

  static const List<int> colors = [
    0xFFFFFFFF, // White
    0xFFFFD60A, // Yellow
    0xFFFFA500, // Orange
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

  static String assetFor(int level) {
    final name = nameFor(level).toLowerCase();
    return 'assets/icons/belt_${name}.png';
  }
}

bool isTablet(BuildContext context) {
  final data = MediaQuery.of(context);
  return data.size.shortestSide >= 600;
}
