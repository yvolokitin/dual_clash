// A minimal no-op stub for window_manager on web.
// Provides the subset of API used in main.dart so the web build compiles.
import 'package:flutter/material.dart';

class WindowOptions {
  final Size? size;
  final Size? minimumSize;
  final bool? center;
  final String? title;
  const WindowOptions({this.size, this.minimumSize, this.center, this.title});
}

class _WindowManagerNoop {
  Future<void> ensureInitialized() async {}
  Future<void> waitUntilReadyToShow(WindowOptions options, Future<void> Function() callback) async {
    await callback();
  }
  Future<void> show() async {}
  Future<void> focus() async {}
}

final _WindowManagerNoop windowManager = _WindowManagerNoop();
