import 'package:flutter/material.dart';
import 'ui/pages/main_menu_page.dart';
import 'logic/game_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TwoTouchApp());
}

class TwoTouchApp extends StatefulWidget {
  const TwoTouchApp({super.key});

  @override
  State<TwoTouchApp> createState() => _TwoTouchAppState();
}

class _TwoTouchAppState extends State<TwoTouchApp> {
  late final GameController controller;

  @override
  void initState() {
    super.initState();
    controller = GameController();
    // Load persisted theme color and apply
    controller.loadSettingsAndApply();
  }

  TextTheme _boldAll(TextTheme t) {
    return t.copyWith(
      displayLarge: t.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      displayMedium: t.displayMedium?.copyWith(fontWeight: FontWeight.w700),
      displaySmall: t.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineLarge: t.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: t.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      bodyMedium: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      bodySmall: t.bodySmall?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      labelMedium: t.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      labelSmall: t.labelSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = ThemeData();
    return MaterialApp(
      title: 'Two Touch 9x9',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: _boldAll(base.textTheme.apply(fontFamily: 'Fredoka')),
        primaryTextTheme:
            _boldAll(base.primaryTextTheme.apply(fontFamily: 'Fredoka')),
      ),
      home: MainMenuPage(controller: controller),
    );
  }
}
