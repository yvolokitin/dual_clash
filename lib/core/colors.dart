import 'package:flutter/material.dart';

class AppColors {
  // Mutable background color so Settings can change it at runtime
  static Color bg = const Color(0xFF38518F); // FF3B7D23); // game page green background
  static const tile = Color(0xFFD9C7A6); // sand
  static const red = Color(0xFFD84A3A);
  static const blue = Color(0xFF1F73D1);
  static const neutral = Color(0xFF8E8E90);
  static const accentYellow = Color(0xFFFFD166);

  // Dark board cell background and border for EMPTY cells
  static const cellDark = Color(0xFF1C4011);
  static const cellDarkBorder = Color(0xFF121317);

  // Board gradient border colors (legacy, may be overridden in widgets)
  static const boardGradStart = Color(0xFF6E2FB8);
  static const boardGradEnd = Color(0xFF3A137A);

  // Highlights/Shadows for beveled tiles (generic, color-agnostic overlays)
  static const topHighlight = Color(0x33FFFFFF);
  static const midHighlight = Color(0x11FFFFFF);
  static const bottomInnerShadow = Color(0x22000000);

  // Settings dialog styling (approx Block Blast)
  static const dialogGradTop = Color(0xFF1F2333);
  static const dialogGradBottom = Color(0xFF151826);
  static const dialogOutline = Color(0x33FFFFFF);
  static const dialogShadow = Color(0xAA000000);
  static const dialogFieldBg = Color(0xFF2A2F45);
  static const dialogTitle = Colors.white;
  static const dialogSubtitle = Colors.white70;
  static const brandGold = Color(0xFFFFC34A);
}
