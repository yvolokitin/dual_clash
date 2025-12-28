import 'dart:convert';
import 'dart:typed_data';

import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/ui/pages/main_menu_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAssetBundle extends CachingAssetBundle {
  static final Uint8List _imageBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=',
  );

  @override
  Future<ByteData> load(String key) async {
    return ByteData.view(_imageBytes.buffer);
  }
}

void main() {
  testWidgets('main menu shows tiles after startup animation', (WidgetTester tester) async {
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: MaterialApp(
          home: MainMenuPage(controller: GameController()),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 5));

    expect(find.text('Game challange'), findsOneWidget);
    expect(find.text('Duel mode'), findsOneWidget);
    expect(find.text('Load game'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('duel tile opens flyout modes', (WidgetTester tester) async {
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: MaterialApp(
          home: MainMenuPage(controller: GameController()),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 5));

    await tester.tap(find.text('Duel mode'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Triple Threat'), findsOneWidget);
    expect(find.text('Quad Clash'), findsOneWidget);
  });
}
