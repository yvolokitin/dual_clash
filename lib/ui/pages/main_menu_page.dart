import 'dart:math' as math;

import 'package:dual_clash/core/localization.dart';
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
import 'profile_page.dart';
import 'settings_page.dart';
import 'game_page.dart';
import 'duel_page.dart';

class MainMenuPage extends StatefulWidget {
  final GameController controller;
  const MainMenuPage({super.key, required this.controller});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> with SingleTickerProviderStateMixin {
  final GlobalKey _duelTileKey = GlobalKey();
  final GlobalKey _gameTileKey = GlobalKey();
  final GlobalKey _campaignTileKey = GlobalKey();
  final GlobalKey _playerHubTileKey = GlobalKey();
  Animation<double>? _bgAnim;
  VoidCallback? _bgAnimListener;
  bool _showContent = true; // hidden until startup animation completes
  bool _menuActionInProgress = false;
  static const Color _violet = Color(0xFF8A2BE2);
  static const Color _menuGreen = Color(0xFF22B14C);
  static const Color _playerHubColor = Color(0xFF7C3AED);

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

  Future<void> _handleLoadGame(BuildContext context, GameController controller) async {
    final ok = await showLoadGameDialog(
      context: context,
      controller: controller,
    );
    if (ok == true && context.mounted) {
      await _pushWithSlide(
        context,
        GamePage(controller: controller),
        const Offset(-1.0, 0.0),
      );
    }
  }

  void _openLoadGameAfterClose(BuildContext context, GameController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        _handleLoadGame(context, controller);
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
  }

  @override
  void dispose() {
    if (_bgAnim != null && _bgAnimListener != null) {
      _bgAnim!.removeListener(_bgAnimListener!);
    }
    _stopWaves();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final size = MediaQuery.of(context).size;
    final compactLabels = _isCompactWidth(context);
    final l10n = context.l10n;
    final double topHeroHeight = size.height * 0.35; // 35% of top page for the image
    final Color bgColor = _bgAnim != null
        ? ColorTween(begin: _violet, end: _menuGreen).evaluate(_bgAnim!)!
        : (_showContent ? _menuGreen : _violet);

    final height = MediaQuery.of(context).size.height;
    final bool isTallMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android) &&
        height > 1200;
    final double menuGridMaxWidth = isTallMobile ? 420 * 1.15 : 420;

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
                    painter: WavesPainter(animation: _wavesCtrl, baseColor: _menuGreen),
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
                        onCompleted: () {
                          if (mounted) {
                            setState(() {
                              _showContent = true;
                            });
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
                                      imagePath: 'assets/icons/menu_pvai.png',
                                      label: compactLabels
                                          ? l10n.menuGameShort
                                          : l10n.menuGameChallenge,
                                      color: AppColors.red,
                                      onTap: () {
                                        _runMenuAction(() async {
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
                                      imagePath: 'assets/icons/menu_121.png',
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
                                      imagePath: 'assets/icons/menu_camp.png',
                                      label: compactLabels
                                          ? l10n.menuCampaignShort
                                          : l10n.menuCampaign,
                                      color: Colors.orange,
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
                                      imagePath: 'assets/icons/menu_settings.png',
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
                        imagePath: 'assets/icons/menu_323.png',
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
                        imagePath: 'assets/icons/menu_121.png',
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
                        imagePath: 'assets/icons/menu_424.png',
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
                        imagePath: 'assets/icons/menu_222.png',
                        label: l10n.menuAlliance2v2,
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
            final r1 = _lerpRect(hubRect, targetGameRect, curved.value);
            final r2 = _lerpRect(hubRect, targetDuelRect, curved.value);
            final r3 = _lerpRect(hubRect, targetLoadRect, curved.value);
            final r4 = _lerpRect(hubRect, hubRect, curved.value);
            final minLeft = math.min(math.min(r1.left, r2.left), math.min(r3.left, r4.left));
            final maxRight = math.max(math.max(r1.right, r2.right), math.max(r3.right, r4.right));
            final minTop = math.min(math.min(r1.top, r2.top), math.min(r3.top, r4.top));
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
                        imagePath: 'assets/icons/menu_profile.png',
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
                        imagePath: 'assets/icons/menu_options.png',
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
                        width: r2.width,
                        height: r2.height,
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
                        imagePath: 'assets/icons/menu_load.png',
                        label: compactLabels
                            ? l10n.menuLoadShort
                            : l10n.menuLoadGame,
                        disabled: false,
                        color: Colors.orange,
                        onTap: () {
                          _dismissPlayerHub(context);
                          _openLoadGameAfterClose(context, controller);
                        },
                        width: r4.width,
                        height: r4.height,
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
                        imagePath: 'assets/icons/menu_history.png',
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
                        width: r3.width,
                        height: r3.height,
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
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              FlyoutTile(
                                imagePath: 'assets/icons/menu_profile.png',
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
                              FlyoutTile(
                                imagePath: 'assets/icons/menu_options.png',
                                label: l10n.languageTitle,
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
                              FlyoutTile(
                                imagePath: 'assets/icons/menu_history.png',
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
                              FlyoutTile(
                                imagePath: 'assets/icons/menu_load.png',
                                label: l10n.menuLoadGame,
                                disabled: false,
                                width: tileWidth,
                                height: tileHeight,
                                color: Colors.orange,
                                onTap: () {
                                  _dismissPlayerHub(context);
                                  _openLoadGameAfterClose(context, controller);
                                },
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
                                    imagePath: 'assets/icons/menu_323.png',
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
                                    imagePath: 'assets/icons/menu_121.png',
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
                                    imagePath: 'assets/icons/menu_424.png',
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
                                    imagePath: 'assets/icons/menu_222.png',
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
