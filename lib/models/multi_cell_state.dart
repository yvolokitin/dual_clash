import 'package:flutter/material.dart';

/// Separate cell state for multi-human modes to avoid impacting existing 2-player logic.
enum MultiCellState { empty, red, blue, yellow, green, neutral }

extension MultiCellStateX on MultiCellState {
  bool get isEmpty => this == MultiCellState.empty;
  bool get isNeutral => this == MultiCellState.neutral;
  bool get isPlayer => this == MultiCellState.red || this == MultiCellState.blue || this == MultiCellState.yellow || this == MultiCellState.green;
}

class MultiColors {
  static const Color red = Color(0xFFD84A3A);
  static const Color blue = Color(0xFF1F73D1);
  static const Color yellow = Color(0xFFFFD166);
  static const Color green = Color(0xFF35A853);
  static const Color neutral = Color(0xFF8E8E90);
}
