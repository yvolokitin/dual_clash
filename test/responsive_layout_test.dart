import 'package:dual_clash/l10n/app_localizations.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/ui/dialogs/main_menu_dialog.dart';
import 'package:dual_clash/ui/pages/game_page.dart';
import 'package:dual_clash/ui/pages/help_page.dart';
import 'package:dual_clash/ui/pages/history_page.dart';
import 'package:dual_clash/ui/pages/profile_page.dart';
import 'package:dual_clash/ui/pages/settings_page.dart';
import 'package:dual_clash/ui/pages/statistics_page.dart';
import 'package:dual_clash/ui/widgets/results_card.dart';
import 'package:dual_clash/ui/widgets/save_game_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'has_premium': true});
  });

  Future<void> pumpResponsiveWidget(
    WidgetTester tester, {
    required Widget child,
    required Size size,
    required double textScale,
  }) async {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(size: size, textScaleFactor: textScale),
          child: child,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('key dialogs and pages fit on small screens with text scaling',
      (tester) async {
    final controller = GameController();
    final widgets = <Widget Function()>[
      () => GamePage(controller: controller),
      () => MainMenuDialog(controller: controller),
      () => SettingsDialog(controller: controller),
      () => HelpDialog(controller: controller),
      () => HistoryDialog(controller: controller),
      () => StatisticsDialog(controller: controller),
      () => ProfileDialog(controller: controller),
      () => SaveGameCard(
            title: 'Save Game',
            initialName: 'Sample Save',
            onSave: (_) {},
            nameLabel: 'Name',
            nameHint: 'Enter name',
            saveButtonLabel: 'Save',
            cancelButtonLabel: 'Cancel',
          ),
      () => ResultsCard(controller: controller),
    ];

    const sizes = [Size(375, 667), Size(390, 844)];
    const textScales = [1.0, 1.3];

    for (final size in sizes) {
      for (final textScale in textScales) {
        for (final widgetBuilder in widgets) {
          await pumpResponsiveWidget(
            tester,
            child: widgetBuilder(),
            size: size,
            textScale: textScale,
          );
          expect(tester.takeException(), isNull);
        }
      }
    }

    await tester.binding.setSurfaceSize(null);
  });
}
