import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/ui/pages/game_page.dart';
import 'package:dual_clash/ui/widgets/game_layout_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('desktop score row keeps single-row layout', (tester) async {
    SharedPreferences.setMockInitialValues({'has_premium': true});
    final controller = GameController();
    controller.redGamePoints = 42;

    await tester.pumpWidget(
      MaterialApp(
        home: GamePage(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('score-row-desktop')), findsOneWidget);
    expect(find.byKey(const Key('score-row-mobile')), findsNothing);
    expect(find.byTooltip('Main Menu'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('support links show when premium is disabled on desktop',
      (tester) async {
    SharedPreferences.setMockInitialValues({'has_premium': false});
    final controller = GameController();

    await tester.pumpWidget(
      MaterialApp(
        home: GamePage(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Support the dev'), findsOneWidget);
    expect(find.text('Patreon'), findsOneWidget);
    expect(find.text('Boosty'), findsOneWidget);
    expect(find.text('Ko-fi'), findsOneWidget);
  });

  testWidgets('layout metrics reuse board sizing rules', (tester) async {
    final controller = GameController()..boardPixelSize = 900;
    late GameLayoutMetrics metrics;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            metrics = GameLayoutMetrics.from(context, controller);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(metrics.boardCellSize, closeTo(97.555, 0.01));
    expect(metrics.scoreItemSize,
        closeTo(metrics.boardCellSize * 0.595, 0.01));
  });
}
