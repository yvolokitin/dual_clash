import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart' show RenderBox;
import '../../logic/game_controller.dart';
import '../../core/colors.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'menu_page.dart' show showLoadGameDialog; // reuse existing dialog
import 'game_page.dart';
import 'duel_page.dart';
import 'multi_human_page.dart';

class MainMenuPage extends StatefulWidget {
  final GameController controller;
  const MainMenuPage({super.key, required this.controller});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final GlobalKey _duelTileKey = GlobalKey();
  final GlobalKey _gameTileKey = GlobalKey();
  final GlobalKey _loadTileKey = GlobalKey();
  final GlobalKey _profileTileKey = GlobalKey();
  Animation<double>? _bgAnim;
  bool _showContent = true; // hidden until startup animation completes
  static const Color _violet = Color(0xFF8A2BE2);
  static const Color _menuGreen = Color(0xFF22B14C);

  @override
  void initState() {
    super.initState();
    // If animation already played this session, show content immediately
    _showContent = _StartupHeroLogo.hasPlayed;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final size = MediaQuery.of(context).size;
    final double topHeroHeight = size.height * 0.35; // 35% of top page for the image
    final Color bgColor = _bgAnim != null
        ? ColorTween(begin: _violet, end: _menuGreen).evaluate(_bgAnim!)!
        : (_showContent ? _menuGreen : _violet);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top app bar row (back and title)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: _showContent
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                  child: _StartupHeroLogo(
                                      onAttachAnimation: (anim) {
                                        // Bind background tween to the startup animation
                                        setState(() {
                                          _bgAnim = anim;
                                        });
                                        anim.addListener(() {
                                          if (mounted) setState(() {});
                                        });
                                      },
                                      onCompleted: () {
                                        if (mounted) setState(() => _showContent = true);
                                      },
                                    ),
                ),
              ),
            ),

            // Total points + time as one chip card (unified icon/text sizes)
/*
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: _showContent
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Builder(
                            builder: (context) {
                              const Color darkBlue = Color(0xFF001F5B);
                              String _formatDuration(int ms) {
                                if (ms <= 0) return '0s';
                                int seconds = (ms / 1000).floor();
                                final hours = seconds ~/ 3600;
                                seconds %= 3600;
                                final minutes = seconds ~/ 60;
                                seconds %= 60;
                                if (hours > 0) return '${hours}h ${minutes}m';
                                if (minutes > 0) return '${minutes}m ${seconds}s';
                                return '${seconds}s';
                              }

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 4)),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                              'assets/icons/points-removebg.png',
                                              width: 24,
                                              height: 24),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${controller.totalUserScore}',
                                            style: const TextStyle(
                                                color: darkBlue,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: Colors.black12,
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Image.asset(
                                              'assets/icons/duration-removebg.png',
                                              width: 24,
                                              height: 24),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatDuration(controller.totalPlayTimeMs),
                                            style: const TextStyle(
                                                color: darkBlue,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
*/
            const SizedBox(height: 16),

            // Centered menu items
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                child: _showContent
                    ? Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: GridView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 1.1,
                              ),
                              children: [
                                _MenuTile(
                                  key: _gameTileKey,
                                  imagePath: 'assets/icons/menu_pvai.png',
                                  label: 'Game challange',
                                  color: AppColors.red,
                                  onTap: () {
                                    controller.humanVsHuman = false;
                                    controller.newGame();
                                    _pushWithSlide(
                                      context,
                                      GamePage(controller: controller),
                                      const Offset(-1.0, 0.0), // from left → right
                                    );
                                  },
                                ),
                                _MenuTile(
                                  key: _duelTileKey,
                                  imagePath: 'assets/icons/menu_121.png',
                                  label: 'Duel mode',
                                  color: AppColors.blue,
                                  onTap: () {
                                    _openDuelFlyout(context, controller);
                                  },
                                ),
                                _MenuTile(
                                  key: _loadTileKey,
                                  imagePath: 'assets/icons/menu_load.png',
                                  label: 'Load game',
                                  color: Colors.orange,
                                  onTap: () async {
                                    // Press effect comes from InkWell; keep dialog for loading
                                    final ok = await showLoadGameDialog(
                                        context: context, controller: controller);
                                    if (ok == true && context.mounted) {
                                      Navigator.of(context).pop('loaded');
                                    }
                                  },
                                ),
                                _MenuTile(
                                  key: _profileTileKey,
                                  imagePath: 'assets/icons/menu_profile.png',
                                  label: 'Profile',
                                  color: Color(0xFFC0C0C0),
                                  onTap: () {
                                    // Open profile with a top → down slide
                                    _pushWithSlide(
                                      context,
                                      _buildProfileFullScreen(controller),
                                      const Offset(0.0, -1.0),
                                    );
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
      ),
    );
  }

  Future<void> _openDuelFlyout(BuildContext context, GameController controller) async {
    // Measure the Duel tile and target tiles global rects
    Rect rect = Rect.zero;
    Rect gameRect = Rect.zero;
    Rect loadRect = Rect.zero;
    Rect profileRect = Rect.zero;
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
      final ctxLoad = _loadTileKey.currentContext;
      if (ctxLoad != null) {
        final box = ctxLoad.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final topLeft = box.localToGlobal(Offset.zero);
          loadRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, box.size.width, box.size.height);
        }
      }
      final ctxProfile = _profileTileKey.currentContext;
      if (ctxProfile != null) {
        final box = ctxProfile.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final topLeft = box.localToGlobal(Offset.zero);
          profileRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, box.size.width, box.size.height);
        }
      }
    } catch (_) {}

    // Fallback: if we couldn't measure required rects, show the old top overlay
    if (rect == Rect.zero || gameRect == Rect.zero || loadRect == Rect.zero || profileRect == Rect.zero) {
      await _openDuelModesOverlay(context, controller);
      return;
    }

    // Capture for builder
    final Rect duelRect = rect;
    final Rect targetGameRect = gameRect;
    final Rect targetLoadRect = loadRect;
    final Rect targetProfileRect = profileRect;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Modes',
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
            final r2 = _lerpRect(from, targetLoadRect, curved.value);
            final r3 = _lerpRect(from, targetProfileRect, curved.value);
            return Stack(
              children: [
                // Tapping anywhere dismisses
                Positioned.fill(
                  child: GestureDetector(onTap: () => Navigator.of(ctx).pop()),
                ),

                // Duel (active) → lands over Game challenge
                Positioned(
                  left: r1.left,
                  top: r1.top,
                  width: r1.width,
                  height: r1.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: _buildFlyoutTile(
                        imagePath: 'assets/icons/menu_121.png',
                        label: 'Duel mode',
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
                        width: r1.width,
                        height: r1.height,
                      ),
                    ),
                  ),
                ),

                // Triple (disabled) → lands over Load game
                Positioned(
                  left: r2.left,
                  top: r2.top,
                  width: r2.width,
                  height: r2.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: _buildFlyoutTile(
                        imagePath: 'assets/icons/menu_424.png',
                        label: 'Triple Threat',
                        disabled: true,
                        width: r2.width,
                        height: r2.height,
                      ),
                    ),
                  ),
                ),

                // Quad (disabled) → lands over Profile
                Positioned(
                  left: r3.left,
                  top: r3.top,
                  width: r3.width,
                  height: r3.height,
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                      child: _buildFlyoutTile(
                        imagePath: 'assets/icons/menu_424.png',
                        label: 'Quad Clash',
                        disabled: true,
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

  Future<void> _openDuelModesOverlay(BuildContext context, GameController controller) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Modes',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, a2, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return Center(
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Material(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFlyoutTile(
                            imagePath: 'assets/icons/menu_121.png',
                            label: 'Duel mode',
                            disabled: false,
                            width: 190,
                            height: 170,
                            color: AppColors.blue,
                            onTap: () {
                              Navigator.of(ctx).pop();
                              _pushWithSlide(
                                context,
                                DuelPage(controller: controller),
                                const Offset(1.0, 0.0),
                              );
                            },
                          ),
                          const SizedBox(width: 14),
                          _buildFlyoutTile(
                            imagePath: 'assets/icons/menu_424.png',
                            label: 'Triple Threat',
                            disabled: true,
                            width: 190,
                            height: 170,
                          ),
                          const SizedBox(width: 14),
                          _buildFlyoutTile(
                            imagePath: 'assets/icons/menu_424.png',
                            label: 'Quad Clash',
                            disabled: true,
                            width: 190,
                            height: 170,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlyoutTile({
    required String imagePath,
    required String label,
    required bool disabled,
    required double width,
    required double height,
    Color? color,
    VoidCallback? onTap,
  }) {
    final outerRadius = BorderRadius.circular(16);
    final innerRadius = BorderRadius.circular(13);

    Color _darken(Color c, [double amount = 0.18]) {
      final hsl = HSLColor.fromColor(c);
      final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
      return hsl.withLightness(lightness).toColor();
    }

    Color _lighten(Color c, [double amount = 0.18]) {
      final hsl = HSLColor.fromColor(c);
      final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
      return hsl.withLightness(lightness).toColor();
    }

    final Color activeBase = color ?? AppColors.blue;
    final Color base = disabled ? Colors.grey.shade600 : activeBase;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _darken(base),
        _lighten(base),
      ],
    );

    Widget image = Image.asset(imagePath, fit: BoxFit.contain);
    if (disabled) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: Opacity(opacity: 0.65, child: image),
      );
    }

    final labelStyle = TextStyle(
      color: disabled ? Colors.white70 : Colors.white,
      fontWeight: FontWeight.w800,
      fontSize: 16,
    );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: outerRadius,
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: outerRadius,
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                color: base.withOpacity(disabled ? 0.85 : 0.9),
                borderRadius: innerRadius,
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(child: image),
                  ),
                  const SizedBox(height: 6),
                  Text(label, style: labelStyle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _pushWithSlide(BuildContext context, Widget page, Offset beginOffset) {
    Navigator.of(context).push(
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

  Widget _buildProfileFullScreen(GameController controller) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ProfileDialog(controller: controller),
        ),
      ),
    );
  }
}

class _MenuTile extends StatefulWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _MenuTile({Key? key, required this.imagePath, required this.label, required this.onTap, required this.color}) : super(key: key);

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> {
  bool _hovered = false;
  bool _pressed = false;

  Color _darken(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color _lighten(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static const _pressDuration = Duration(milliseconds: 120);
  static const _hoverDuration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final outerRadius = BorderRadius.circular(16);
    final innerRadius = BorderRadius.circular(13);
    final Color base = widget.color.withOpacity(1.0);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _darken(base),
        _lighten(base),
      ],
    );

    // Entire tile scales a bit on press to mimic a button press
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: _pressDuration,
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (h) => setState(() => _hovered = h),
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: outerRadius,
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: outerRadius,
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.all(3), // 3px gradient border
            child: Container(
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.9),
                borderRadius: innerRadius,
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: ClipRect(
                        child: AnimatedScale(
                          scale: _hovered ? 1.05 : 1.0,
                          duration: _hoverDuration,
                          curve: Curves.easeOutCubic,
                          child: AnimatedRotation(
                            turns: _hovered ? (5 / 360) : 0,
                            duration: _hoverDuration,
                            curve: Curves.easeOutCubic,
                            child: Image.asset(
                              widget.imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlyoutTile extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool disabled;
  final double width;
  final double height;
  final Color? color;
  final VoidCallback? onTap;
  const _FlyoutTile({
    required this.imagePath,
    required this.label,
    required this.disabled,
    required this.width,
    required this.height,
    this.color,
    this.onTap,
  });

  Color _darken(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color _lighten(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final outerRadius = BorderRadius.circular(16);
    final innerRadius = BorderRadius.circular(13);

    final Color activeBase = color ?? AppColors.blue;
    final Color base = disabled ? Colors.grey.shade600 : activeBase;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _darken(base),
        _lighten(base),
      ],
    );

    Widget image = Image.asset(imagePath, fit: BoxFit.contain);
    if (disabled) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: Opacity(opacity: 0.65, child: image),
      );
    }

    final labelStyle = TextStyle(
      color: disabled ? Colors.white70 : Colors.white,
      fontWeight: FontWeight.w800,
      fontSize: 16,
    );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: outerRadius,
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: outerRadius,
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                color: base.withOpacity(disabled ? 0.85 : 0.9),
                borderRadius: innerRadius,
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(child: image),
                  ),
                  const SizedBox(height: 6),
                  Text(label, style: labelStyle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuActionTile extends StatelessWidget {
  final Color color;
  final String iconPath;
  final String label;
  final VoidCallback onTap;
  const _MenuActionTile(
      {required this.color,
      required this.iconPath,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final outerRadius = BorderRadius.circular(10);
    final innerRadius = BorderRadius.circular(7);

    Color darken(Color c, [double amount = 0.18]) {
      final hsl = HSLColor.fromColor(c);
      final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
      return hsl.withLightness(lightness).toColor();
    }

    Color lighten(Color c, [double amount = 0.18]) {
      final hsl = HSLColor.fromColor(c);
      final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
      return hsl.withLightness(lightness).toColor();
    }

    final Color base = color.withOpacity(1.0);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        darken(base),
        lighten(base),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: outerRadius,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: outerRadius,
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
          padding: const EdgeInsets.all(3), // 3px gradient border
          child: Container(
            padding: const EdgeInsets.fromLTRB(
                20, 12, 16, 12), // 20px left margin, ~15% reduced height
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              borderRadius: innerRadius, // less rounded
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Image.asset(iconPath, fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileFullScreen extends StatelessWidget {
  final GameController controller;
  const _ProfileFullScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ProfileDialog(controller: controller),
        ),
      ),
    );
  }
}

class _StartupHeroLogo extends StatefulWidget {
  const _StartupHeroLogo({this.onAttachAnimation, this.onCompleted});

  final ValueChanged<Animation<double>>? onAttachAnimation;
  final VoidCallback? onCompleted;

  static bool get hasPlayed => _StartupHeroLogoState._playedOnce;

  @override
  State<_StartupHeroLogo> createState() => _StartupHeroLogoState();
}

class _StartupHeroLogoState extends State<_StartupHeroLogo>
    with SingleTickerProviderStateMixin {
  static bool _playedOnce = false; // session-scoped within app process
  AnimationController? _ctrl;
  Animation<double>? _t;
  bool _showStaticLogo = false; // show static composed grid on subsequent entries only
  static List<String>? _sessionImages; // cache 4 random player images for the session

  List<String> _candidatePlayers() => const [
        'assets/icons/player_blue.png',
        'assets/icons/player_brown.png',
        'assets/icons/player_green.png',
        'assets/icons/player_grey.png',
        'assets/icons/player_orange.png',
        'assets/icons/player_red.png',
        'assets/icons/player_violet.png',
        'assets/icons/player_yellow.png',
      ];

  void _initSessionImagesIfNeeded() {
    if (_sessionImages == null) {
      final all = List<String>.from(_candidatePlayers());
      all.shuffle();
      _sessionImages = all.take(4).toList(growable: false);
    }
  }

  @override
  void initState() {
    super.initState();
    _initSessionImagesIfNeeded();
    if (!_playedOnce) {
      _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
      _t = CurvedAnimation(parent: _ctrl!, curve: Curves.easeInOutCubic);
      // Expose the animation to parent so it can drive background color
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.onAttachAnimation != null && _t != null) {
          widget.onAttachAnimation!.call(_t!);
        }
      });
      _ctrl!.forward();
      _ctrl!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _playedOnce = true; // future builds in new routes show the static logo
          // Notify parent that animation is done so the rest of UI can appear
          widget.onCompleted?.call();
          // Keep showing the final animation frame in this first session view
          if (mounted) setState(() {});
        }
      });
    } else {
      _showStaticLogo = true;
      // If skipping animation, notify parent immediately so page content shows
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCompleted?.call();
      });
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If already played earlier in session and this is not the first instance, show the composed 2x2 grid using cached images
    if (_playedOnce && _showStaticLogo) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final targetSize = math.min(w, h) * 0.7;
          final tileSize = targetSize / 2;
          final centerX = w / 2;
          final centerY = h / 2;
          final finalPos = <Offset>[
            Offset(centerX - tileSize, centerY - tileSize),
            Offset(centerX, centerY - tileSize),
            Offset(centerX - tileSize, centerY),
            Offset(centerX, centerY),
          ];

          final images = _sessionImages!;
          List<Widget> tiles = [];
          for (int i = 0; i < 4; i++) {
            tiles.add(Positioned(
              left: finalPos[i].dx,
              top: finalPos[i].dy,
              width: tileSize,
              height: tileSize,
              child: Image.asset(images[i], fit: BoxFit.contain),
            ));
          }
          // Words overlay fully visible
          tiles.add(Positioned(
            left: centerX - targetSize / 2,
            top: centerY - targetSize / 2,
            width: targetSize,
            height: targetSize,
            child: IgnorePointer(
              child: Center(
                child: Image.asset('assets/icons/dual_clash-words-removebg.png', fit: BoxFit.contain),
              ),
            ),
          ));

          return SizedBox(width: w, height: h, child: Stack(children: tiles));
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        // Target merge area size ~ 70% of available height, keep square-ish
        final targetSize = math.min(w, h) * 0.7;
        final tileSize = targetSize / 2;
        final centerX = w / 2;
        final centerY = h / 2;
        // Final positions for 2x2 layout: (top: red-grey), (bottom: red-blue)
        final finalPos = <Offset>[
          // top-left: red
          Offset(centerX - tileSize, centerY - tileSize),
          // top-right: grey
          Offset(centerX, centerY - tileSize),
          // bottom-left: red
          Offset(centerX - tileSize, centerY),
          // bottom-right: blue
          Offset(centerX, centerY),
        ];

        // Start positions per spec
        // - Top-left red: from left to right along top row Y
        // - Top-right grey: from right to left along top row Y
        // - Bottom-left red: from bottom up at its final X
        // - Bottom-right blue: from bottom up at its final X
        final startPos = <Offset>[
          Offset(-targetSize, centerY - tileSize), // left outside, top row
          Offset(w + targetSize, centerY - tileSize), // right outside, top row
          Offset(centerX - tileSize, h + targetSize), // below screen
          Offset(centerX, h + targetSize), // below screen
        ];

        // Helper: compute a half-donut arc using a quadratic Bezier with oriented control
        Offset pathLerp(Offset a, Offset b, double t, int index) {
          final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
          late Offset control;
          if (index == 0) {
            // top-left from left → arc downward
            control = mid.translate(w * 0.10, h * 0.18);
          } else if (index == 1) {
            // top-right from right → arc downward
            control = mid.translate(-w * 0.10, h * 0.18);
          } else if (index == 2) {
            // bottom-left from bottom → arc upward
            control = mid.translate(-w * 0.08, -h * 0.20);
          } else {
            // bottom-right from bottom → arc upward
            control = mid.translate(w * 0.08, -h * 0.20);
          }
          final oneMinusT = 1 - t;
          final bez = Offset(
            oneMinusT * oneMinusT * a.dx + 2 * oneMinusT * t * control.dx + t * t * b.dx,
            oneMinusT * oneMinusT * a.dy + 2 * oneMinusT * t * control.dy + t * t * b.dy,
          );
          // Subtle wavy perturbation along the path
          final waveMag = 6.0;
          final wave = math.sin(t * math.pi * 2) * waveMag; // 2 cycles
          final dir = (b - a);
          final len = math.max(1.0, dir.distance);
          // Perpendicular normal
          final nx = -dir.dy / len;
          final ny = dir.dx / len;
          return bez.translate(wave * nx, wave * ny);
        }

        // Phase timings within 4s: fly-in (0-72%), settle (72-84%), shake (84-92%), words fade (88-100%)
        final flyEnd = 0.72;
        final settleEnd = 0.84;
        final shakeEnd = 0.92;
        final wordsStart = 0.88;

        return AnimatedBuilder(
          animation: _t!,
          builder: (context, child) {
            final t = (_t!.value).clamp(0.0, 1.0);
            final flyT = (t / flyEnd).clamp(0.0, 1.0);
            final settleT = t <= flyEnd
                ? 0.0
                : ((t - flyEnd) / (settleEnd - flyEnd)).clamp(0.0, 1.0);
            final wordsT = t <= wordsStart
                ? 0.0
                : ((t - wordsStart) / (1 - wordsStart)).clamp(0.0, 1.0);

            List<Widget> tiles = [];
            final images = _sessionImages!;

            for (int i = 0; i < 4; i++) {
              final pFly = pathLerp(startPos[i], finalPos[i], Curves.easeInOut.transform(flyT), i);
              final pSettle = Offset.lerp(pFly, finalPos[i], Curves.easeOut.transform(settleT))!;

              // Shake effect after merge
              Offset shakeOffset = Offset.zero;
              if (t >= settleEnd && t < shakeEnd) {
                final sp = ((t - settleEnd) / (shakeEnd - settleEnd)).clamp(0.0, 1.0);
                final amp = (1.0 - sp) * (tileSize * 0.07); // decaying amplitude (~7% of tile)
                final phase = i * math.pi / 3;
                final dx = amp * math.sin(sp * 10 * math.pi + phase);
                final dy = amp * 0.6 * math.cos(sp * 10 * math.pi + phase);
                shakeOffset = Offset(dx, dy);
              }

              Offset pos;
              if (t < flyEnd) {
                pos = pFly;
              } else if (t < settleEnd) {
                pos = pSettle;
              } else if (t < shakeEnd) {
                pos = finalPos[i] + shakeOffset;
              } else {
                pos = finalPos[i];
              }

              // slight scale-in during fly
              final scale = t < flyEnd ? (0.6 + 0.4 * flyT) : 1.0;
              final opacity = (t < 0.05 && i > 1) ? (t / 0.05) : 1.0; // early fade-in

              tiles.add(Positioned(
                left: pos.dx,
                top: pos.dy,
                width: tileSize,
                height: tileSize,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.center,
                    child: Image.asset(images[i], fit: BoxFit.contain),
                  ),
                ),
              ));
            }

            // Words overlay fades in at the end
            tiles.add(Positioned(
              left: centerX - targetSize / 2,
              top: centerY - targetSize / 2,
              width: targetSize,
              height: targetSize,
              child: IgnorePointer(
                child: Opacity(
                  opacity: Curves.easeIn.transform(wordsT),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/dual_clash-words-removebg.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ));

            return SizedBox(
              width: w,
              height: h,
              child: Stack(children: tiles),
            );
          },
        );
      },
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
