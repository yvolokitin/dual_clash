import 'package:flutter/material.dart';

/// Centralized text styles used across UI widgets to avoid tight coupling
/// between pages and small reusable components.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle chip = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
}
