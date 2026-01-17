import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:dual_clash/logic/app_audio.dart';
import 'package:dual_clash/logic/audio_coordinator.dart' show SfxType;

class StartupHeroLogo extends StatefulWidget {
  const StartupHeroLogo({
    super.key,
    this.onAttachAnimation,
    this.onAttachInteraction,
    this.onCompleted,
    this.forceStatic = false,
  });

  final ValueChanged<Animation<double>>? onAttachAnimation;
  final ValueChanged<Animation<double>>? onAttachInteraction;
  final VoidCallback? onCompleted;
  final bool forceStatic;

  static bool get hasPlayed => _StartupHeroLogoState._playedOnce;

  @override
  State<StartupHeroLogo> createState() => _StartupHeroLogoState();
}

class _StartupHeroLogoState extends State<StartupHeroLogo>
    with TickerProviderStateMixin {
  static bool _playedOnce = false; // session-scoped within app process
  AnimationController? _ctrl;
  Animation<double>? _t;
  AnimationController? _interactionCtrl;
  bool _showStaticLogo = false; // show static composed grid on subsequent entries only
  static List<String>? _sessionImages; // cache 4 random player images for the session
  bool _isHovering = false;
  bool _isReplayingIntro = false; // guard to orchestrate click->scatter->fly-in cycle
  bool _allowOnCompleted = false; // only true for the very first intro to notify parent
  bool _introListenerAdded = false; // ensure we add intro status listener once per controller instance

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
    _interactionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Expose interaction animation to parent (for background color driving)
    if (widget.onAttachInteraction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onAttachInteraction!.call(_interactionCtrl!);
      });
    }
    // Rebuild on every tick to update scatter offsets and word fade
    _interactionCtrl!.addListener(() {
      if (mounted) setState(() {});
    });
    _interactionCtrl!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // After scatter completes, pick new images and replay the intro animation.
        _sessionImages = null;
        _initSessionImagesIfNeeded();
        _interactionCtrl!.reset();
        if (mounted) {
          // Switch to intro replay rendering branch
          _isReplayingIntro = true;
          _showStaticLogo = false;
          _startIntroReplay();
          setState(() {});
        }
      }
    });
    if (!widget.forceStatic && !_playedOnce) {
      _ensureIntroController();
      // Expose the animation to parent so it can drive background color
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.onAttachAnimation != null && _t != null) {
          widget.onAttachAnimation!.call(_t!);
        }
      });
      // First intro should notify parent upon completion
      _allowOnCompleted = true;
      // Play startup SFX in parallel with the intro animation (first run only)
      AppAudio.coordinator?.playSfx(SfxType.startup);
      _ctrl!.forward();
    } else {
      _showStaticLogo = true;
      // If skipping animation, notify parent immediately so page content shows
      if (!widget.forceStatic) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onCompleted?.call();
        });
      }
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    _interactionCtrl?.dispose();
    super.dispose();
  }

  void _ensureIntroController() {
    if (_ctrl != null && _t != null && _introListenerAdded) return;
    _ctrl ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _t = CurvedAnimation(parent: _ctrl!, curve: Curves.easeInOutCubic);
    if (!_introListenerAdded) {
      _ctrl!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_isReplayingIntro) {
            // End of replay: return to static grid state.
            _isReplayingIntro = false;
            _showStaticLogo = true;
            if (mounted) setState(() {});
            return;
          }
          // First-time completion
          _playedOnce = true;
          if (_allowOnCompleted) {
            widget.onCompleted?.call();
            _allowOnCompleted = false;
          }
          if (mounted) setState(() {});
        }
      });
      _introListenerAdded = true;
    }
  }

  void _startIntroReplay() {
    _ensureIntroController();
    // Attach intro animation to parent as well for background driving during replay
    if (widget.onAttachAnimation != null && _t != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onAttachAnimation!.call(_t!);
      });
    }
    // Do not notify parent on replay
    _isReplayingIntro = true;
    _ctrl!.stop();
    _ctrl!.reset();
    _ctrl!.forward();
  }

  void _triggerInteraction() {
    // Allow interaction when first intro has completed (final frame shown) OR static grid is shown,
    // and no animations are currently running (no scatter and no intro/replay).
    final bool introAnimating = _ctrl?.isAnimating == true || _isReplayingIntro;
    final bool introCompletedAtRest = _playedOnce && !introAnimating; // first intro ended and not replaying
    final bool canInteract = _interactionCtrl != null && !_interactionCtrl!.isAnimating && (introCompletedAtRest || _showStaticLogo);
    if (!canInteract) {
      return;
    }
    // Play the same startup SFX whenever the user triggers the logo interaction
    // Reuses existing audio pipeline (AudioCoordinator -> AndroidSfxPlayer)
    AppAudio.coordinator?.playSfx(SfxType.startup);
    _interactionCtrl!.forward(from: 0.0);
  }

  Offset _interactionOffset(int index, double tileSize, double width, double height) {
    if (_interactionCtrl == null) {
      return Offset.zero;
    }
    final t = _interactionCtrl!.value.clamp(0.0, 1.0);
    if (t <= 0) {
      return Offset.zero;
    }
    const shakePhase = 0.35;
    if (t < shakePhase) {
      final sp = (t / shakePhase).clamp(0.0, 1.0);
      final amp = (1.0 - sp) * (tileSize * 0.06);
      final phase = index * math.pi / 3;
      final dx = amp * math.sin(sp * 10 * math.pi + phase);
      final dy = amp * 0.6 * math.cos(sp * 10 * math.pi + phase);
      return Offset(dx, dy);
    }
    // After shake, tiles fly outward to screen edges in their quadrant.
    final outT = ((t - shakePhase) / (1 - shakePhase)).clamp(0.0, 1.0);
    final eased = Curves.easeIn.transform(outT);
    double sx, sy;
    switch (index) {
      case 0: // top-left
        sx = -1.0; sy = -1.0; break;
      case 1: // top-right
        sx = 1.0; sy = -1.0; break;
      case 2: // bottom-left
        sx = -1.0; sy = 1.0; break;
      default: // bottom-right
        sx = 1.0; sy = 1.0; break;
    }
    final maxDist = math.max(width, height) + tileSize;
    final dx = sx * maxDist * eased;
    final dy = sy * maxDist * eased;
    return Offset(dx, dy);
  }

  double _interactionLogoScale() {
    if (_interactionCtrl == null) {
      return 1.0;
    }
    final t = _interactionCtrl!.value.clamp(0.0, 1.0);
    if (t <= 0) {
      return 1.0;
    }
    final zoomT = Curves.easeOut.transform(math.min(t, 0.2) / 0.2);
    return 1.0 + 0.07 * zoomT;
  }

  Widget _buildInteractiveLogo({required Widget child}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: _triggerInteraction,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If already played earlier in session and this is not the first instance, show the composed 2x2 grid using cached images
    if ((widget.forceStatic) || (_playedOnce && _showStaticLogo)) {
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
            final offset = _interactionOffset(i, tileSize, w, h);
            tiles.add(Positioned(
              left: finalPos[i].dx + offset.dx,
              top: finalPos[i].dy + offset.dy,
              width: tileSize,
              height: tileSize,
              child: Image.asset(images[i], fit: BoxFit.contain),
            ));
          }
          // Words overlay fully visible
          final double interactionT = (_interactionCtrl?.value ?? 0.0).clamp(0.0, 1.0);
          final double wordsFadeOut = Curves.easeInOut.transform(interactionT);
          tiles.add(Positioned(
            left: centerX - targetSize / 2,
            top: centerY - targetSize / 2,
            width: targetSize,
            height: targetSize,
            child: Opacity(
              opacity: 1.0 - wordsFadeOut,
              child: _buildInteractiveLogo(
                child: Center(
                  child: Transform.scale(
                    scale: _interactionLogoScale(),
                    child: AnimatedScale(
                      scale: _isHovering ? 1.07 : 1.0,
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      child: Image.asset(
                        'assets/icons/dual_clash-words-removebg.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
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
              final pFly = pathLerp(
                startPos[i],
                finalPos[i],
                Curves.easeInOut.transform(flyT),
                i,
              );
              final pSettle =
                  Offset.lerp(pFly, finalPos[i], Curves.easeOut.transform(settleT))!;

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

              final interactionOffset = _interactionOffset(i, tileSize, w, h);
              pos += interactionOffset;

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
              child: Opacity(
                opacity: Curves.easeIn.transform(wordsT),
                child: _buildInteractiveLogo(
                  child: Center(
                    child: Transform.scale(
                      scale: _interactionLogoScale(),
                      child: AnimatedScale(
                        scale: _isHovering ? 1.07 : 1.0,
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        child: Image.asset(
                          'assets/icons/dual_clash-words-removebg.png',
                          fit: BoxFit.contain,
                        ),
                      ),
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
