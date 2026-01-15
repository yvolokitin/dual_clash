import 'dart:ui' as ui;

import 'package:dual_clash/core/feature_flags.dart';
import 'package:dual_clash/core/localization.dart';
import 'package:dual_clash/core/navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dual_clash/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:window_manager/window_manager.dart' if (dart.library.html) 'package:dual_clash/core/noop_window_manager.dart';
import 'core/platforms.dart';

import 'core/constants.dart';
import 'logic/game_challenge_music_controller.dart';
import 'logic/game_controller.dart';
import 'logic/game_sfx_controller.dart';
import 'logic/main_menu_music_controller.dart';
import 'logic/transition_sfx_controller.dart';
import 'ui/pages/legal_pages.dart';
import 'ui/pages/main_menu_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isWindows) {
    await windowManager.ensureInitialized();

    const minSize = Size(900, 700); // <--- your minimum
    const initialSize = Size(1100, 800);

    WindowOptions windowOptions = const WindowOptions(
      size: initialSize,
      minimumSize: minSize,
      center: true,
      title: 'Dual Clash',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  _configureBoardSizeForDevice();

  // AdMob SDK init, Initialize AdMob only if supported (mobile)
  if (FF_ADS && isMobile) {
    await MobileAds.instance.initialize();
  }

  runApp(const TwoTouchApp());
}

class TwoTouchApp extends StatefulWidget {
  const TwoTouchApp({super.key});

  @override
  State<TwoTouchApp> createState() => _TwoTouchAppState();
}

class _TwoTouchAppState extends State<TwoTouchApp>
    with WidgetsBindingObserver {
  late final GameController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = GameController();
    // Load persisted theme color and apply
    controller.loadSettingsAndApply();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resumeAudioForLifecycle();
      return;
    }
    _stopAudioForLifecycle();
  }

  Future<void> _stopAudioForLifecycle() async {
    await MainMenuMusicController.instance.stop();
    await GameChallengeMusicController.instance.stop();
    await TransitionSfxController.instance.stop();
    await GameSfxController.instance.stopAll();
  }

  Future<void> _resumeAudioForLifecycle() async {
    await MainMenuMusicController.instance.resume();
    await GameChallengeMusicController.instance.resume();
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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final localeCode = switch (controller.languageCode) {
          'de' => 'de',
          'fr' => 'fr',
          'pl' => 'pl',
          'ru' => 'ru',
          'es' => 'es',
          'nl' => 'nl',
          _ => 'en',
        };
        return MaterialApp(
          navigatorKey: appNavigatorKey,
          routes: {
            '/privacy': (context) => const PrivacyPolicyPage(),
            '/terms': (context) => const TermsOfUsePage(),
            '/support': (context) => const SupportPage(),
            '/app-store-privacy': (context) => const AppStorePrivacyPage(),
          },
          onGenerateTitle: (context) =>
              context.l10n.appTitle('${K.n}x${K.n}'),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ru'),
            Locale('es'),
            Locale('de'),
            Locale('fr'),
            Locale('nl'),
            Locale('pl'),
          ],
          navigatorObservers: [routeObserver],
          locale: Locale(localeCode),
          theme: base.copyWith(
            textTheme: _boldAll(base.textTheme.apply(fontFamily: 'Fredoka')),
            primaryTextTheme:
                _boldAll(base.primaryTextTheme.apply(fontFamily: 'Fredoka')),
          ),
          home: MainMenuPage(controller: controller),
        );
      },
    );
  }
}

void _configureBoardSizeForDevice() {
  const double tabletBreakpoint = 600.0;
  final bool isMobilePlatform = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  final views = WidgetsBinding.instance.platformDispatcher.views;
  final ui.FlutterView? view = views.isNotEmpty ? views.first : null;
  final double shortestSide = view == null
      ? 0
      : (view.physicalSize / view.devicePixelRatio).shortestSide;
  final bool isPhone = isMobilePlatform && shortestSide < tabletBreakpoint;
  K.n = isPhone ? 7 : 9;
}
