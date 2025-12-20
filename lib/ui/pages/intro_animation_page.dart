import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../logic/game_controller.dart';
import 'game_page.dart';
import 'main_menu_page.dart';

class IntroAnimationPage extends StatefulWidget {
  final GameController controller;
  const IntroAnimationPage({super.key, required this.controller});

  @override
  State<IntroAnimationPage> createState() => _IntroAnimationPageState();
}

class _IntroAnimationPageState extends State<IntroAnimationPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          buildMainMenuRoute(
            builder: (_) => MainMenuPage(
              controller: widget.controller,
              onAction: _handleMainMenuAction,
            ),
          ),
        );
      }
    });
  }

  void _handleMainMenuAction(String action) {
    if (!mounted) return;
    if (action == 'challenge') {
      widget.controller.newGame();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => GamePage(controller: widget.controller)),
      );
    } else if (action == 'loaded') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => GamePage(controller: widget.controller)),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _waveOffset(Offset begin, Offset end, double t, double amplitude) {
    final base = Offset(
      ui.lerpDouble(begin.dx, end.dx, t) ?? end.dx,
      ui.lerpDouble(begin.dy, end.dy, t) ?? end.dy,
    );
    final direction = end - begin;
    final normal = Offset(-direction.dy, direction.dx);
    final length = normal.distance;
    if (length == 0) return base;
    final wave = math.sin(t * math.pi * 1.3) * (1 - t) * amplitude;
    final unitNormal = Offset(normal.dx / length, normal.dy / length);
    return base + unitNormal * wave;
  }

  Widget _buildAnimatedBox({
    required Animation<double> animation,
    required Offset begin,
    required Offset end,
    required double amplitude,
    required double size,
    required String asset,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final pos = _waveOffset(begin, end, t, amplitude);
        final opacity = math.min(1.0, t * 1.4);
        final scale = ui.lerpDouble(0.8, 1.0, Curves.easeOutBack.transform(t)) ??
            1.0;
        return Positioned(
          left: pos.dx,
          top: pos.dy,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: SizedBox(
                width: size,
                height: size,
                child: Image.asset(asset),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C3A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final boxSize = math.min(size.width, size.height) * 0.22;
          final spacing = boxSize * 0.12;
          final finalWidth = boxSize * 2 + spacing;
          final startX = size.width / 2 - finalWidth / 2;
          final topY = size.height / 2 - boxSize - spacing / 2;
          final bottomY = topY + boxSize + spacing;

          final targets = <Offset>[
            Offset(startX, topY),
            Offset(startX + boxSize + spacing, topY),
            Offset(startX, bottomY),
            Offset(startX + boxSize + spacing, bottomY),
          ];

          final animations = <Animation<double>>[
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
            ),
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.05, 0.78, curve: Curves.easeOutCubic),
            ),
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.12, 0.82, curve: Curves.easeOutCubic),
            ),
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.18, 0.86, curve: Curves.easeOutCubic),
            ),
          ];

          final begins = <Offset>[
            Offset(-boxSize * 1.2, topY - boxSize * 0.6),
            Offset(size.width + boxSize * 0.6, topY - boxSize * 0.3),
            Offset(size.width + boxSize * 0.8, bottomY + boxSize * 0.5),
            Offset(-boxSize * 1.1, bottomY + boxSize * 0.7),
          ];

          final amplitudes = <double>[
            boxSize * 0.55,
            boxSize * 0.45,
            boxSize * 0.6,
            boxSize * 0.5,
          ];

          final wordFade = CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
          );

          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0C1C3A),
                        const Color(0xFF14335E),
                        const Color(0xFF0C1C3A),
                      ],
                    ),
                  ),
                ),
              ),
              _buildAnimatedBox(
                animation: animations[0],
                begin: begins[0],
                end: targets[0],
                amplitude: amplitudes[0],
                size: boxSize,
                asset: 'assets/icons/box_red-removebg.png',
              ),
              _buildAnimatedBox(
                animation: animations[1],
                begin: begins[1],
                end: targets[1],
                amplitude: amplitudes[1],
                size: boxSize,
                asset: 'assets/icons/box_grey-removebg.png',
              ),
              _buildAnimatedBox(
                animation: animations[2],
                begin: begins[2],
                end: targets[2],
                amplitude: amplitudes[2],
                size: boxSize,
                asset: 'assets/icons/box_red-removebg.png',
              ),
              _buildAnimatedBox(
                animation: animations[3],
                begin: begins[3],
                end: targets[3],
                amplitude: amplitudes[3],
                size: boxSize,
                asset: 'assets/icons/box_blue-removebg.png',
              ),
              Positioned(
                left: size.width / 2 - finalWidth / 2,
                right: size.width / 2 - finalWidth / 2,
                top: topY - boxSize * 0.9,
                child: FadeTransition(
                  opacity: wordFade,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.2),
                      end: Offset.zero,
                    ).animate(wordFade),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/dual_clash-words-removebg.png',
                        height: boxSize * 0.8,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
