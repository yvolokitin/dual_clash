import 'dart:math' as math;

import 'package:dual_clash/core/localization.dart';
import 'package:dual_clash/core/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart' show RenderBox;
import 'package:flutter_svg/flutter_svg.dart';
import '../../logic/game_controller.dart';
import '../../core/colors.dart';
import '../widgets/main_menu/flyout_tile.dart';
import '../widgets/main_menu/menu_tile.dart';
import '../widgets/main_menu/startup_hero_logo.dart';
import '../widgets/main_menu/waves_painter.dart';
import 'campaign_page.dart';
import 'history_page.dart';
import 'menu_page.dart' show showLoadGameDialog; // reuse existing dialog
import 'achievements_page.dart';
import 'language_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'game_page.dart';
import 'duel_page.dart';
import 'package:dual_clash/logic/app_audio.dart';
import 'package:dual_clash/logic/audio_intent_resolver.dart' show RouteContext, NavigationPhase;
import 'package:dual_clash/logic/audio_coordinator.dart' show SfxType;

class MainMenuPage extends StatefulWidget {
  final GameController controller;
  const MainMenuPage({super.key, required this.controller});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage>
    with SingleTickerProviderStateMixin, RouteAware {
  final GlobalKey _duelTileKey = GlobalKey();
  final GlobalKey _gameTileKey = GlobalKey();
  final GlobalKey _campaignTileKey = GlobalKey();
  final GlobalKey _playerHubTileKey = GlobalKey();
  static bool _hasLoggedScreenSize = false;
  Animation<double>? _bgAnim;
  VoidCallback? _bgAnimListener;
  Animation<double>? _interactionAnim;
  VoidCallback? _interactionAnimListener;
  bool _showContent = true; // hidden until startup animation completes
  bool _menuActionInProgress = false;
  late final VoidCallback _musicSettingsListener;
  late bool _lastMusicEnabled;
  bool _routeSubscribed = false;
  static const Color _violet = Color(0xFF8A2BE2);
  static const Color _menuGreen = Color(0xFF22B14C);
  static const Color _playerHubColor = Colors.orange;

  bool _isCompactWidth(BuildContext context) => MediaQuery.of(context).size.width < 430;

  bool _isDesktopWidth(BuildContext context) => MediaQuery.of(context).size.width >= 900;

  void _dismissDialog(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  void _dismissPlayerHub(BuildContext context) {
    _dismissDialog(context);
  }

  // Waves background animation
  AnimationController? _wavesCtrl;
  bool _wavesActive = false;

  void _startWavesIfNeeded() {
    if (_wavesActive) return;
    _wavesCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..addListener(() {
        if (mounted) setState(() {});
      })
      ..repeat();
    _wavesActive = true;
  }

  void _stopWaves() {
    _wavesCtrl?.dispose();
    _wavesCtrl = null;
    _wavesActive = false;
  }

  Future<void> _runMenuAction(Future<void> Function() action) async {
    if (_menuActionInProgress) return;
    _menuActionInProgress = true;
    try {
      await action();
    } finally {
      if (mounted) {
        _menuActionInProgress = false;
      }
    }
  }

  Future<void> _handleLoadGame(GameController controller) async {
    final menuContext = context;
    final ok = await showLoadGameDialog(
      context: menuContext,
      controller: controller,
    );
    if (ok == true && mounted) {
      final Widget page = controller.humanVsHuman
          ? DuelPage(
              controller: controller,
              playerCount: controller.duelPlayerCount,
            )
          : GamePage(controller: controller);
      await _pushWithSlide(
        menuContext,
        page,
        const Offset(-1.0, 0.0),
      );
    }
  }

  void _openLoadGameAfterClose(GameController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleLoadGame(controller);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // If animation already played this session, show content immediately
    _showContent = StartupHeroLogo.hasPlayed;
    if (_showContent) {
      // Ensure waves start if launch animation was already played earlier in the session
      WidgetsBinding.instance.addPostFrameCallback((_) => _startWavesIfNeeded());
    }
    // Wire menu readiness to global audio coordinator
    AppAudio.coordinator?.onMenuReadyChanged(_showContent);
    _lastMusicEnabled = widget.controller.musicEnabled;
    _musicSettingsListener = () {
      if (_lastMusicEnabled != widget.controller.musicEnabled) {
        _lastMusicEnabled = widget.controller.musicEnabled;
        AppAudio.coordinator?.onMusicEnabledChanged(_lastMusicEnabled);
      }
    };
    widget.controller.addListener(_musicSettingsListener);
    if (!_hasLoggedScreenSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final double width = MediaQuery.sizeOf(context).width;
        final double height = MediaQuery.sizeOf(context).height;
        debugPrint('Device screen size: ${width}x${height}');
        _hasLoggedScreenSize = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeSubscribed) {
      return;
    }
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      routeObserver.subscribe(this, route);
      _routeSubscribed = true;
      if (route.isCurrent) {
        AppAudio.coordinator?.onRouteContextChanged(RouteContext.menu);
        AppAudio.coordinator?.onNavigationPhaseChanged(NavigationPhase.idle);
      }
    }
  }

  @override
  void didPush() {
    AppAudio.coordinator?.onRouteContextChanged(RouteContext.menu);
    AppAudio.coordinator?.onNavigationPhaseChanged(NavigationPhase.idle);
  }

  @override
  void didPopNext() {
    AppAudio.coordinator?.onRouteContextChanged(RouteContext.menu);
    AppAudio.coordinator?.onNavigationPhaseChanged(NavigationPhase.idle);
  }

  @override
  void didPushNext() {
    AppAudio.coordinator?.onNavigationPhaseChanged(NavigationPhase.transitioning);
  }

  @override
  void dispose() {
    if (_bgAnim != null && _bgAnimListener != null) {
      _bgAnim!.removeListener(_bgAnimListener!);
    }
    if (_interactionAnim != null && _interactionAnimListener != null) {
      _interactionAnim!.removeListener(_interactionAnimListener!);
    }
    _stopWaves();
    widget.controller.removeListener(_musicSettingsListener);
    if (_routeSubscribed) {
      routeObserver.unsubscribe(this);
    }
    // Reset global audio context because menu is being hidden/disposed
    AppAudio.coordinator?.onMenuReadyChanged(false);
    AppAudio.coordinator?.onNavigationPhaseChanged(NavigationPhase.transitioning);
    AppAudio.coordinator?.onRouteContextChanged(RouteContext.other);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final size = MediaQuery.of(context).size;
    final compactLabels = _isCompactWidth(context);
    final l10n = context.l10n;
    final double topHeroHeight = size.height * 0.35; // 35% of top page for the image
    // Background color logic:
    // - During interaction scatter, go from green -> violet using interactionAnim (eased)
    // - During intro/replay fly-in, go from violet -> green using bgAnim (existing)
    // - Otherwise: green when content shown, violet before first intro completes
    Color bgColor;
    if (_interactionAnim != null && (_interactionAnim!.value > 0.0)) {
      final double t = Curves.easeInOut.transform(_interactionAnim!.value.clamp(0.0, 1.0));
      bgColor = Color.lerp(_menuGreen, _violet, t)!;
    } else if (_bgAnim != null) {
      bgColor = ColorTween(begin: _violet, end: _menuGreen).evaluate(_bgAnim!)!;
    } else {
      bgColor = _showContent ? _menuGreen : _violet;
    }

    final height = MediaQuery.of(context).size.height;
    final bool isTallMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android) &&
        height > 1200;
    final double menuGridMaxWidth = isTallMobile ? 420 * 1.15 : 420;
    final String menuPvAiAsset = kIsWeb
        ? 'assets/icons/menu/menu_pvai.png'
        : 'assets/icons/menu/menu_pvai.gif';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _showContent ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  child: CustomPaint(
                    painter: WavesPainter(animation: _wavesCtrl, baseColor: bgColor),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top app bar row (back and title)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: _showContent
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: const [
                              Spacer(),
                              SizedBox.shrink(),
                              Spacer(),
                              SizedBox(width: 48),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // 25% top hero image
                SizedBox(
                  height: topHeroHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(
                      child: StartupHeroLogo(
                        onAttachAnimation: _attachBackgroundAnimation,
                        onAttachInteraction: _attachInteractionAnimation, 
                        onCompleted: () {
                          if (mounted) {
                            setState(() {
                              _showContent = true;
                            });
                            AppAudio.coordinator?.onMenuReadyChanged(true);
                            _startWavesIfNeeded();
                          }
                        },
                      ),
                    ),
                  ),
                ),

                // Centered menu items
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: _showContent
                        ? Center(
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: menuGridMaxWidth),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20.0),
                                child: GridView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 1.1,
                                  ),
                                  children: [
                                    MenuTile(
                                      key: _gameTileKey,
                                      imagePath: menuPvAiAsset,
                                      label: compactLabels
                                          ? l10n.menuGameShort
                                          : l10n.menuGameChallenge,
                                      color: AppColors.red,
                                      spinOnTap: true,
                                      onSpinStart: () {
                                        AppAudio.coordinator?.playSfx(SfxType.transition);
                                      },
                                      onTap: () {
                                        _runMenuAction(() async {
                                          AppAudio.coordinator?.onNavigationPhaseChanged(NavigationPhase.transitioning);
                                          controller.humanVsHuman = false;
                                          controller.newGame();
                                          await _pushWithSlide(
                                            context,
                                            GamePage(controller: controller),
                                            const Offset(-1.0, 0.0),
                                          );
                                        });
                                      },
                                    ),
                                    MenuTile(
                                      key: _duelTileKey,
                                      imagePath: 'assets/icons/menu/menu_121.webp',
                                      label: compactLabels
                                          ? l10n.menuDuelShort
                                          : l10n.menuDuelMode,
                                      color: AppColors.blue,
                                      onTap: () {
                                        _runMenuAction(() async {
                                          await _openDuelFlyout(context, controller);
                                        });
                                      },
                                    ),
                                    MenuTile(
                                      key: _campaignTileKey,
                                      imagePath: 'assets/icons/menu/menu_camp.webp',
                                      label: compactLabels
                                          ? l10n.menuCampaignShort
                                          : l10n.menuCampaign,
                                      color: _violet,
                                      onTap: () async {
                                        await _runMenuAction(() async {
                                          await _pushWithDrop(
                                            context,
                                            CampaignPage(controller: controller),
                                          );
                                        });
                                      },
                                    ),
                                    MenuTile(
                                      key: _playerHubTileKey,
                                      imagePath: 'assets/icons/menu/menu_settings.webp',
                                      label: compactLabels
                                          ? l10n.menuHubShort
                                          : l10n.menuPlayerHub,
                                      color: _playerHubColor,
                                      onTap: () {
                                        _runMenuAction(() async {
                                          await _openPlayerHubFlyout(
                                            context,
                                            controller,
                                          );
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                if (kIsWeb)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _LegalLink(
                            label: 'Privacy Policy',
                            onTap: () => Navigator.of(context).pushNamed('/privacy'),
                          ),
                          _LegalLink(
                            label: 'Terms of Use',
                            onTap: () => Navigator.of(context).pushNamed('/terms'),
                          ),
                          _LegalLink(
                            label: 'Support',
                            onTap: () => Navigator.of(context).pushNamed('/support'),
                          ),
                          _LegalLink(
                            label: 'App Store Privacy',
                            onTap: () =>
                                Navigator.of(context).pushNamed('/app-store-privacy'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDuelFlyout(BuildContext context, GameController controller) async {
    final compactLabels = _isCompactWidth(context);
    final l10n = context.l10n;
    // Measure the Duel tile and target tiles global rects
    Rect rect = Rect.zero;
    Rect gameRect = Rect.zero;
    Rect loadRect = Rect.zero;
    Rect playerHubRect = Rect.zero;
    try {
      final ctxDuel = _duelTileKey.currentContext;
      if (ctxDuel != null) {
        final box = ctxDuel.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final topLeft = box.localToGlobal(Offset.zero);
          rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, box.size.width, box.size.height);
        }
      }
      final ctxGame = _gameTileKey.currentContext;
      if (ctxGame != null) {
        final box = ctxGame.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final topLeft = box.localToGlobal(Offset.zero);
          gameRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, box.size.width, box.size.height);
        }
      }
      final ctxLoad = _campaignTileKey.currentContext;
      if (ctxLoad != null) {
        final box = ctxLoad.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final topLeft = box.localToGlobal(Offset.zero);
          loadRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, box.size.width, box.size.height);
        }
      }
      final ctxPlayerHub = _playerHubTileKey.currentContext;
      if (ctxPlayerHub != null) {
        final box = ctxPlayerHub.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final topLeft = box.localToGlobal(Offset.zero);
          playerHubRect =
              Rect.fromLTWH(topLeft.dx, topLeft.dy, box.size.width, box.size.height);
        }
      }
    } catch (_) {}

    // Fallback: if we couldn't measure required rects, show the old top overlay
    if (rect == Rect.zero ||
        gameRect == Rect.zero ||
        loadRect == Rect.zero ||
        playerHubRect == Rect.zero) {
      await _openDuelModesOverlay(context, controller);
      return;
    }

    // Capture for builder
    final Rect duelRect = rect;
    final Rect targetGameRect = gameRect;
    final Rect targetDuelRect = duelRect;
    final Rect targetLoadRect = loadRect;
    final Rect targetPlayerHubRect = playerHubRect;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.modesBarrierLabel,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, a2, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final Rect from = duelRect;
        Rect _lerpRect(Rect a, Rect b, double t) {
          final l = a.left + (b.left - a.left) * t;
          final tY = a.top + (b.top - a.top) * t;
          final w = a.width + (b.width - a.width) * t;
          final h = a.height + (b.height - a.height) * t;
          return Rect.fromLTWH(l, tY, w, h);
        }

        return AnimatedBuilder(
          animation: curved,
          builder: (context, _) {
            final r1 = _lerpRect(from, targetGameRect, curved.value);
            final r2 = _lerpRect(from, targetDuelRect, curved.value);
            final r3 = _lerpRect(from, targetLoadRect, curved.value);
            final r4 = _lerpRect(from, targetPlayerHubRect, curved.value);
            final minLeft = math.min(
              math.min(r1.left, r2.left),
              math.min(r3.left, r4.left),
            );
            final maxRight = math.max(
              math.max(r1.right, r2.right),
              math.max(r3.right, r4.right),
            );
            final minTop = math.min(math.min(r1.top, r2.top), math.min(r3.top, r4.top));
            final cancelSize = r2.width * 0.25;
            final cancelSpacing = _isDesktopWidth(context) ? 30.0 : 40.0;
            final cancelLeft = (minLeft + maxRight) / 2 - cancelSize / 2;
            final cancelTop = math.max(0.0, minTop - cancelSpacing - cancelSize);
            final showCancel = curved.value >= 0.98;
            return Stack(
              children: [
                // Tapping anywhere dismisses
                Positioned.fill(
                  child: GestureDetector(onTap: () => _dismissPlayerHub(context)),
                ),
                if (showCancel)
                  Positioned(
                    left: cancelLeft,
                    top: cancelTop,
                    width: cancelSize,
                    height: cancelSize,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _dismissPlayerHub(context),
                          child: SvgPicture.asset(
                            'assets/icons/close.svg',
                            width: cancelSize,
                            height: cancelSize,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Triple Threat → lands over Game challenge
                Positioned(
                  left: r1.left,
                  top: r1.top,
                  width: r1.width,
                  height: r1.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: FlyoutTile(
                        imagePath: 'assets/icons/menu/menu_323.webp',
                        label: compactLabels
                            ? l10n.menuTripleShort
                            : l10n.menuTripleThreat,
                        disabled: false,
                        color: AppColors.red,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _pushWithSlide(
                            context,
                            DuelPage(controller: controller, playerCount: 3),
                            const Offset(1.0, 0.0),
                          );
                        },
                        width: r1.width,
                        height: r1.height,
                      ),
                    ),
                  ),
                ),

                // Duel Mode → lands over Duel tile
                Positioned(
                  left: r2.left,
                  top: r2.top,
                  width: r2.width,
                  height: r2.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: FlyoutTile(
                        imagePath: 'assets/icons/menu/menu_121.webp',
                        label: compactLabels
                            ? l10n.menuDuelShort
                            : l10n.menuDuelMode,
                        disabled: false,
                        color: AppColors.blue,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _pushWithSlide(
                            context,
                            DuelPage(controller: controller),
                            const Offset(1.0, 0.0),
                          );
                        },
                        width: r2.width,
                        height: r2.height,
                      ),
                    ),
                  ),
                ),

                // Quad Clash → lands over Campaign
                Positioned(
                  left: r3.left,
                  top: r3.top,
                  width: r3.width,
                  height: r3.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: FlyoutTile(
                        imagePath: 'assets/icons/menu/menu_424.webp',
                        label: compactLabels
                            ? l10n.menuQuadShort
                            : l10n.menuQuadClash,
                        disabled: false,
                        color: AppColors.green,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _pushWithSlide(
                            context,
                            DuelPage(controller: controller, playerCount: 4),
                            const Offset(1.0, 0.0),
                          );
                        },
                        width: r3.width,
                        height: r3.height,
                      ),
                    ),
                  ),
                ),

                // Alliance 2vs2 → lands over Player Hub
                Positioned(
                  left: r4.left,
                  top: r4.top,
                  width: r4.width,
                  height: r4.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: FlyoutTile(
                        imagePath: 'assets/icons/menu/menu_222.png',
                        label: compactLabels
                            ? l10n.menuAlliance2v2Short
                            : l10n.menuAlliance2v2,
                        disabled: true,
                        color: Colors.grey,
                        width: r4.width,
                        height: r4.height,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openPlayerHubFlyout(BuildContext context, GameController controller) async {
    final compactLabels = _isCompactWidth(context);
    final l10n = context.l10n;
    Rect rect = Rect.zero;
    Rect gameRect = Rect.zero;
    Rect duelRect = Rect.zero;
    Rect loadRect = Rect.zero;
    try {
      final ctxHub = _playerHubTileKey.currentContext;
      if (ctxHub != null) {
        final box = ctxHub.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final topLeft = box.localToGlobal(Offset.zero);
          rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, box.size.width, box.size.height);
        }
      }
      final ctxGame = _gameTileKey.currentContext;
      if (ctxGame != null) {
        final box = ctxGame.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final topLeft = box.localToGlobal(Offset.zero);
          gameRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, box.size.width, box.size.height);
        }
      }
      final ctxDuel = _duelTileKey.currentContext;
      if (ctxDuel != null) {
        final box = ctxDuel.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final topLeft = box.localToGlobal(Offset.zero);
          duelRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, box.size.width, box.size.height);
        }
      }
      final ctxLoad = _campaignTileKey.currentContext;
      if (ctxLoad != null) {
        final box = ctxLoad.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final topLeft = box.localToGlobal(Offset.zero);
          loadRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, box.size.width, box.size.height);
        }
      }
    } catch (_) {}

    if (rect == Rect.zero ||
        gameRect == Rect.zero ||
        duelRect == Rect.zero ||
        loadRect == Rect.zero) {
      await _openPlayerHubOverlay(context, controller);
      return;
    }

    final Rect hubRect = rect;
    final Rect targetGameRect = gameRect;
    final Rect targetDuelRect = duelRect;
    final Rect targetLoadRect = loadRect;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.playerHubBarrierLabel,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, a2, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        Rect _lerpRect(Rect a, Rect b, double t) {
          final l = a.left + (b.left - a.left) * t;
          final tY = a.top + (b.top - a.top) * t;
          final w = a.width + (b.width - a.width) * t;
          final h = a.height + (b.height - a.height) * t;
          return Rect.fromLTWH(l, tY, w, h);
        }

        return AnimatedBuilder(
          animation: curved,
          builder: (context, _) {
            const spacing = 14.0;
            final tileWidth = targetGameRect.width;
            final tileHeight = targetGameRect.height;
            final Rect row2Left = Rect.fromLTWH(
              targetGameRect.left,
              targetGameRect.top,
              tileWidth,
              tileHeight,
            );
            final Rect row2Right = Rect.fromLTWH(
              targetDuelRect.left,
              targetDuelRect.top,
              tileWidth,
              tileHeight,
            );
            final Rect row3Left = Rect.fromLTWH(
              targetLoadRect.left,
              targetLoadRect.top,
              tileWidth,
              tileHeight,
            );
            final Rect row3Right = Rect.fromLTWH(
              hubRect.left,
              hubRect.top,
              tileWidth,
              tileHeight,
            );
            final Rect row1Left = Rect.fromLTWH(
              row2Left.left,
              row2Left.top - tileHeight - spacing,
              tileWidth,
              tileHeight,
            );
            final Rect row1Right = Rect.fromLTWH(
              row2Right.left,
              row2Right.top - tileHeight - spacing,
              tileWidth,
              tileHeight,
            );
            final r1 = _lerpRect(hubRect, row1Left, curved.value);
            final r2 = _lerpRect(hubRect, row1Right, curved.value);
            final r3 = _lerpRect(hubRect, row2Left, curved.value);
            final r4 = _lerpRect(hubRect, row2Right, curved.value);
            final r5 = _lerpRect(hubRect, row3Left, curved.value);
            final r6 = _lerpRect(hubRect, row3Right, curved.value);
            final minLeft = math.min(
                math.min(math.min(r1.left, r2.left), math.min(r3.left, r4.left)),
                math.min(r5.left, r6.left));
            final maxRight = math.max(
                math.max(math.max(r1.right, r2.right), math.max(r3.right, r4.right)),
                math.max(r5.right, r6.right));
            final minTop = math.min(
                math.min(math.min(r1.top, r2.top), math.min(r3.top, r4.top)),
                math.min(r5.top, r6.top));
            final cancelSize = r1.width * 0.25;
            final cancelSpacing = _isDesktopWidth(context) ? 30.0 : 40.0;
            final cancelLeft = (minLeft + maxRight) / 2 - cancelSize / 2;
            final cancelTop = math.max(0.0, minTop - cancelSpacing - cancelSize);
            final showCancel = curved.value >= 0.98;
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(onTap: () => _dismissPlayerHub(context)),
                ),
                if (showCancel)
                  Positioned(
                    left: cancelLeft,
                    top: cancelTop,
                    width: cancelSize,
                    height: cancelSize,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _dismissPlayerHub(context),
                          child: SvgPicture.asset(
                            'assets/icons/close.svg',
                            width: cancelSize,
                            height: cancelSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: r1.left,
                  top: r1.top,
                  width: r1.width,
                  height: r1.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: FlyoutTile(
                        imagePath: 'assets/icons/menu/menu_profile.png',
                        label: l10n.profileTitle,
                        disabled: false,
                        color: AppColors.red,
                        onTap: () {
                          _dismissPlayerHub(context);
                          showAnimatedProfileDialog(
                            context: context,
                            controller: controller,
                          );
                        },
                        width: r1.width,
                        height: r1.height,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: r2.left,
                  top: r2.top,
                  width: r2.width,
                  height: r2.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: FlyoutTile(
                        imagePath: 'assets/icons/star.png',
                        label: l10n.achievementsTitle,
                        disabled: false,
                        color: AppColors.brandGold,
                        onTap: () {
                          _dismissPlayerHub(context);
                          showAnimatedAchievementsDialog(
                            context: context,
                            controller: controller,
                          );
                        },
                        width: r2.width,
                        height: r2.height,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: r3.left,
                  top: r3.top,
                  width: r3.width,
                  height: r3.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: FlyoutTile(
                        imagePath: 'assets/icons/menu/menu_options.png',
                        label: l10n.settingsTitle,
                        disabled: false,
                        color: _violet,
                        onTap: () {
                          _dismissPlayerHub(context);
                          showAnimatedSettingsDialog(
                            context: context,
                            controller: controller,
                          );
                        },
                        width: r3.width,
                        height: r3.height,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: r4.left,
                  top: r4.top,
                  width: r4.width,
                  height: r4.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: FlyoutTile(
                        imagePath: 'assets/icons/menu/menu_language.png',
                        label: l10n.languageTitle,
                        disabled: false,
                        color: AppColors.neutral,
                        onTap: () {
                          _dismissPlayerHub(context);
                          showAnimatedLanguageDialog(
                            context: context,
                            controller: controller,
                          );
                        },
                        width: r4.width,
                        height: r4.height,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: r5.left,
                  top: r5.top,
                  width: r5.width,
                  height: r5.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: FlyoutTile(
                        imagePath: 'assets/icons/menu/menu_history.png',
                        label: l10n.historyTitle,
                        disabled: false,
                        color: AppColors.blue,
                        onTap: () {
                          _dismissPlayerHub(context);
                          showAnimatedHistoryDialog(
                            context: context,
                            controller: controller,
                          );
                        },
                        width: r5.width,
                        height: r5.height,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: r6.left,
                  top: r6.top,
                  width: r6.width,
                  height: r6.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: FlyoutTile(
                        imagePath: 'assets/icons/menu/menu_load.png',
                        label: compactLabels
                            ? l10n.menuLoadShort
                            : l10n.menuLoadGame,
                        disabled: false,
                        color: Colors.orange,
                        onTap: () {
                          _dismissPlayerHub(context);
                          _openLoadGameAfterClose(controller);
                        },
                        width: r6.width,
                        height: r6.height,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: FadeTransition(
                    opacity: curved,
                    child: Text(
                      l10n.playerHubCloseTip,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openPlayerHubOverlay(BuildContext context, GameController controller) async {
    final l10n = context.l10n;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.playerHubBarrierLabel,
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, a2, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        const tileWidth = 190.0;
        const tileHeight = 170.0;
        final cancelSize = tileWidth * 0.25;
        final cancelSpacing = _isDesktopWidth(context) ? 30.0 : 40.0;
        final showCancel = curved.value >= 0.98;
        return Center(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: showCancel,
                        maintainAnimation: true,
                        maintainSize: true,
                        maintainState: true,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => _dismissPlayerHub(context),
                              child: SvgPicture.asset(
                                'assets/icons/close.svg',
                                width: cancelSize,
                                height: cancelSize,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: cancelSpacing),
                      FadeTransition(
                        opacity: curved,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FlyoutTile(
                                    imagePath:
                                        'assets/icons/menu/menu_profile.png',
                                    label: l10n.profileTitle,
                                    disabled: false,
                                    width: tileWidth,
                                    height: tileHeight,
                                    color: AppColors.red,
                                    onTap: () {
                                      _dismissPlayerHub(context);
                                      showAnimatedProfileDialog(
                                        context: context,
                                        controller: controller,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 14),
                                  FlyoutTile(
                                    imagePath: 'assets/icons/star.png',
                                    label: l10n.achievementsTitle,
                                    disabled: false,
                                    width: tileWidth,
                                    height: tileHeight,
                                    color: AppColors.brandGold,
                                    onTap: () {
                                      _dismissPlayerHub(context);
                                      showAnimatedAchievementsDialog(
                                        context: context,
                                        controller: controller,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FlyoutTile(
                                    imagePath:
                                        'assets/icons/menu/menu_options.png',
                                    label: l10n.settingsTitle,
                                    disabled: false,
                                    width: tileWidth,
                                    height: tileHeight,
                                    color: _violet,
                                    onTap: () {
                                      _dismissPlayerHub(context);
                                      showAnimatedSettingsDialog(
                                        context: context,
                                        controller: controller,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 14),
                                  FlyoutTile(
                                    imagePath:
                                        'assets/icons/menu/menu_language.png',
                                    label: l10n.languageTitle,
                                    disabled: false,
                                    width: tileWidth,
                                    height: tileHeight,
                                    color: AppColors.neutral,
                                    onTap: () {
                                      _dismissPlayerHub(context);
                                      showAnimatedLanguageDialog(
                                        context: context,
                                        controller: controller,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FlyoutTile(
                                    imagePath:
                                        'assets/icons/menu/menu_history.png',
                                    label: l10n.historyTitle,
                                    disabled: false,
                                    width: tileWidth,
                                    height: tileHeight,
                                    color: AppColors.blue,
                                    onTap: () {
                                      _dismissPlayerHub(context);
                                      showAnimatedHistoryDialog(
                                        context: context,
                                        controller: controller,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 14),
                                  FlyoutTile(
                                    imagePath:
                                        'assets/icons/menu/menu_load.png',
                                    label: l10n.menuLoadGame,
                                    disabled: false,
                                    width: tileWidth,
                                    height: tileHeight,
                                    color: Colors.orange,
                                    onTap: () {
                                      _dismissPlayerHub(context);
                                      _openLoadGameAfterClose(controller);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.playerHubCloseTip,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDuelModesOverlay(BuildContext context, GameController controller) async {
    final compactLabels = _isCompactWidth(context);
    final l10n = context.l10n;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.modesBarrierLabel,
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, a2, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        const tileWidth = 190.0;
        const tileHeight = 170.0;
        final cancelSize = tileWidth * 0.25;
        final cancelSpacing = _isDesktopWidth(context) ? 30.0 : 40.0;
        final showCancel = curved.value >= 0.98;
        return Center(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: showCancel,
                        maintainAnimation: true,
                        maintainSize: true,
                        maintainState: true,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => _dismissDialog(context),
                              child: SvgPicture.asset(
                                'assets/icons/close.svg',
                                width: cancelSize,
                                height: cancelSize,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: cancelSpacing),
                      FadeTransition(
                        opacity: curved,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FlyoutTile(
                                    imagePath: 'assets/icons/menu/menu_323.webp',
                                    label: compactLabels
                                        ? l10n.menuTripleShort
                                        : l10n.menuTripleThreat,
                                    disabled: false,
                                    width: tileWidth,
                                    height: tileHeight,
                                    color: AppColors.red,
                                    onTap: () {
                                      _dismissDialog(context);
                                      _pushWithSlide(
                                        context,
                                        DuelPage(
                                          controller: controller,
                                          playerCount: 3,
                                        ),
                                        const Offset(1.0, 0.0),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 14),
                                  FlyoutTile(
                                    imagePath: 'assets/icons/menu/menu_121.webp',
                                    label: compactLabels
                                        ? l10n.menuDuelShort
                                        : l10n.menuDuelMode,
                                    disabled: false,
                                    width: tileWidth,
                                    height: tileHeight,
                                    color: AppColors.blue,
                                    onTap: () {
                                      _dismissDialog(context);
                                      _pushWithSlide(
                                        context,
                                        DuelPage(controller: controller),
                                        const Offset(1.0, 0.0),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FlyoutTile(
                                    imagePath: 'assets/icons/menu/menu_424.webp',
                                    label: compactLabels
                                        ? l10n.menuQuadShort
                                        : l10n.menuQuadClash,
                                    disabled: false,
                                    width: tileWidth,
                                    height: tileHeight,
                                    color: AppColors.green,
                                    onTap: () {
                                      _dismissDialog(context);
                                      _pushWithSlide(
                                        context,
                                        DuelPage(
                                          controller: controller,
                                          playerCount: 4,
                                        ),
                                        const Offset(1.0, 0.0),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 14),
                                  FlyoutTile(
                                    imagePath: 'assets/icons/menu/menu_222.png',
                                    label: l10n.menuAlliance2v2,
                                    disabled: true,
                                    width: tileWidth,
                                    height: tileHeight,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _attachBackgroundAnimation(Animation<double> anim) {
    if (_bgAnim != null && _bgAnimListener != null) {
      _bgAnim!.removeListener(_bgAnimListener!);
    }
    _bgAnim = anim;
    _bgAnimListener = () {
      if (mounted) setState(() {});
    };
    _bgAnim!.addListener(_bgAnimListener!);
    setState(() {});
  }

  void _attachInteractionAnimation(Animation<double> anim) {
    if (_interactionAnim != null && _interactionAnimListener != null) {
      _interactionAnim!.removeListener(_interactionAnimListener!);
    }
    _interactionAnim = anim;
    _interactionAnimListener = () {
      if (mounted) setState(() {});
    };
    _interactionAnim!.addListener(_interactionAnimListener!);
    setState(() {});
  }

  Future<void> _pushWithSlide(
    BuildContext context,
    Widget page,
    Offset beginOffset,
  ) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(begin: beginOffset, end: Offset.zero)
                .animate(curved),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _pushWithDrop(
    BuildContext context,
    Widget page,
  ) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, -1.2),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white.withOpacity(0.9),
        textStyle: Theme.of(context).textTheme.bodySmall,
      ),
      child: Text(label),
    );
  }
}

Route<T> buildMainMenuRoute<T>({required WidgetBuilder builder}) {
  // Cover effect: slide in from left on push, slide out to left on pop
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic);
      final offsetTween =
          Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero);
      return SlideTransition(
          position: offsetTween.animate(curved), child: child);
    },
  );
}
