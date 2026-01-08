import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../logic/game_controller.dart';
import '../../models/cell_state.dart';
import '../../core/constants.dart';
import '../../core/colors.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  static const _hlColor = Color(0x66FFFFFF);
  static const _selIconColor = Colors.orangeAccent;
  final GameController controller;
  const BoardWidget({super.key, required this.controller});

  List<Color> _borderGradientColors() {
    // Use a darker-to-lighter green gradient around the current bg (#3B7D23)
    final base = AppColors.bg;
    final hsl = HSLColor.fromColor(base);

    final darker =
        hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();
    final lighter =
        hsl.withLightness((hsl.lightness + 0.22).clamp(0.0, 1.0)).toColor();
    return [darker, lighter];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fit the board to available space by using the smaller of width/height.
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final sizeWithoutPadding = math.min(availableWidth, availableHeight);
        const minSidePadding = 10.0;
        final sideMargin = (availableWidth - sizeWithoutPadding) / 2;
        final horizontalPadding = sideMargin < minSidePadding ? minSidePadding : 0.0;
        final paddedWidth =
            math.max(0.0, availableWidth - horizontalPadding * 2);
        final size = math.min(paddedWidth, availableHeight);
        // Report the pixel size to controller so other UI (score row) can match width
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.setBoardPixelSize(size);
        });

        const border = 3.0; // 3px gradient border line
        final innerSize =
            size; // outer container remains square; padding will shrink grid area visually

        final cellSize = innerSize / K.n;
        const cellSpacing = 2.0;
        final gridCellSize =
            (innerSize - cellSpacing * (K.n - 1)) / K.n;
        final showScorePopup = !controller.humanVsHuman &&
            controller.scorePopupPoints > 0 &&
            controller.scorePopupCell != null;
        final scorePopupCell = controller.scorePopupCell;
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _Quake(
              quaking: controller.isQuaking,
              durationMs: controller.quakeDurationMs,
              child: Container(
            width: innerSize,
            height: innerSize,
            padding: const EdgeInsets.all(border),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _borderGradientColors(),
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                // Subtle lift to make the board protrude above the background
                BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 24,
                    offset: Offset(0, 14)),
                BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 2)),
              ],
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              // Vignette: transparent center fading to a subtle dark edge for better visibility
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.90,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.25),
                ],
                stops: const [0.55, 1.0],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Solid backdrop to eliminate any tiny seams between cells
                      Container(color: const Color(0xFF171D3F)),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: K.n,
                          mainAxisSpacing: cellSpacing,
                          crossAxisSpacing: cellSpacing,
                        ),
                        itemCount: K.n * K.n,
                        itemBuilder: (context, index) {
                          final r = index ~/ K.n;
                          final c = index % K.n;
                          final st = controller.board[r][c];
                          final isGold = controller.gameOver &&
                              controller.goldCells.contains((r, c));

                          // For 9x9 board, cells should have slight rounding (2px).
                          final BorderRadius cellRadius =
                              BorderRadius.circular(2);

                          Widget cellStack = Stack(
                            fit: StackFit.expand,
                            children: [
                              CellWidget(
                                state: st,
                                borderRadius: cellRadius,
                                usePlayerTokens: controller.usePlayerTokens,
                                onTap: () {
                                  controller.onCellTap(r, c);
                                },
                                onLongPress: () {
                                  controller.deselectSelection();
                                },
                              ),
                              if (controller.blowPreview.contains((r, c)))
                                _AffectedHighlight(),
                              if (controller.selectedCell == (r, c) &&
                                  (st == CellState.red ||
                                      st == CellState.blue ||
                                      st == CellState.yellow ||
                                      st == CellState.green ||
                                      st == CellState.bomb ||
                                      st == CellState.neutral))
                                const _SelectedGoldBorder(),
                              if (controller.isBombDropTarget(r, c))
                                const _SelectedGoldBorder(),
                              if (controller.selectedCell == (r, c) &&
                                  (st == CellState.red ||
                                      st == CellState.blue ||
                                      st == CellState.yellow ||
                                      st == CellState.green))
                                const _SelectedBlowIcon(),
                              if (controller.isExploding &&
                                  controller.explodingCells.contains((r, c)))
                                const _ExplosionAnim(),
                              if (isGold) const _GoldPulseBorder(),
                            ],
                          );

                          final dropDist = controller.isFalling
                              ? (controller.fallingDistances[(r, c)] ?? 0)
                              : 0;
                          if (dropDist > 0) {
                            cellStack = _FallDown(
                              distanceCells: dropDist,
                              cellSize: cellSize,
                              durationMs: controller.fallDurationMs,
                              child: cellStack,
                            );
                          }

                          return DragTarget<bool>(
                            onWillAcceptWithDetails: (_) =>
                                controller.isBombDropTarget(r, c),
                            onAcceptWithDetails: (_) {
                              controller.handleBombDrop(r, c);
                            },
                            builder: (context, _, __) => AspectRatio(
                              aspectRatio: 1,
                              child: cellStack,
                            ),
                          );
                        },
                      ),
                      if (showScorePopup && scorePopupCell != null)
                        Positioned(
                          left: scorePopupCell.$2 *
                                  (gridCellSize + cellSpacing) +
                              gridCellSize / 2,
                          top: scorePopupCell.$1 *
                                  (gridCellSize + cellSpacing) +
                              gridCellSize / 2,
                          child: IgnorePointer(
                            child: _ScoreFlyUp(
                              id: controller.scorePopupId,
                              points: controller.scorePopupPoints,
                              rise: gridCellSize * 1.2,
                              fontSize: gridCellSize * 0.55,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Subtle top-edge highlight to make board appear slightly protruding
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x33FFFFFF),
                              Color(0x11000000),
                              Color(0x00000000)
                            ],
                            stops: [0.0, 0.06, 0.18],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.srcATop,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),

                // Bottom inner shadow for depth
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0x33000000), Color(0x00000000)],
                            stops: [0.0, 0.2],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.srcATop,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),

                // Winner running border animation overlay
                if (controller.showWinnerBorderAnim)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _WinnerBorderRun(
                        color: (() {
                          if (!controller.gameOver) return null;
                          if (controller.isMultiDuel) {
                            final winner = controller.duelWinner();
                            if (winner == null) return null;
                            switch (winner) {
                              case CellState.red:
                                return AppColors.red;
                              case CellState.blue:
                                return AppColors.blue;
                              case CellState.yellow:
                                return AppColors.yellow;
                              case CellState.green:
                                return AppColors.green;
                              case CellState.bomb:
                              case CellState.wall:
                              case CellState.neutral:
                              case CellState.empty:
                                return null;
                            }
                          }
                          final redTotal = controller.scoreRedTotal();
                          final blueTotal = controller.scoreBlueTotal();
                          if (redTotal == blueTotal) return null;
                          return redTotal > blueTotal
                              ? AppColors.red
                              : AppColors.blue;
                        })(),
                        durationMs: controller.winnerBorderAnimMs,
                      ),
                    ),
                  ),
              ],
            ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WinnerBorderRun extends StatefulWidget {
  final Color? color; // null -> no animation
  final int durationMs;
  const _WinnerBorderRun({required this.color, required this.durationMs});

  @override
  State<_WinnerBorderRun> createState() => _WinnerBorderRunState();
}

class _WinnerBorderRunState extends State<_WinnerBorderRun>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.durationMs));
    // Use a constant speed; if the overlay is visible for full duration, one lap feels natural
    _t = CurvedAnimation(parent: _ac, curve: Curves.linear);
    _ac.repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.color == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        return CustomPaint(
          painter:
              _BorderRunnerPainter(progress: _t.value, color: widget.color!),
        );
      },
    );
  }
}

class _BorderRunnerPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  _BorderRunnerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r =
        RRect.fromRectAndRadius(rect.deflate(3), const Radius.circular(10));

    // Base faint border
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = color.withOpacity(0.35);
    final path = Path()..addRRect(r);
    canvas.drawPath(path, base);

    // Moving highlight segment
    final pm = path.computeMetrics().first;
    final length = pm.length;
    final segLen = length * 0.22; // ~22% of perimeter
    double start = (length * progress) % length;
    double end = start + segLen;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5
      ..color = color;

    if (end <= length) {
      final seg = pm.extractPath(start, end);
      canvas.drawPath(seg, paint);
    } else {
      final seg1 = pm.extractPath(start, length);
      final seg2 = pm.extractPath(0, end - length);
      canvas.drawPath(seg1, paint);
      canvas.drawPath(seg2, paint);
    }

    // Glow
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..color = color.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    if (end <= length) {
      final seg = pm.extractPath(start, end);
      canvas.drawPath(seg, glow);
    } else {
      final seg1 = pm.extractPath(start, length);
      final seg2 = pm.extractPath(0, end - length);
      canvas.drawPath(seg1, glow);
      canvas.drawPath(seg2, glow);
    }
  }

  @override
  bool shouldRepaint(covariant _BorderRunnerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _SelectedGoldBorder extends StatelessWidget {
  const _SelectedGoldBorder();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.brandGold, width: 2),
        ),
      ),
    );
  }
}

class _AffectedHighlight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0x22FFFFFF),
          borderRadius: BorderRadius.all(Radius.circular(6)),
          boxShadow: [
            BoxShadow(color: Color(0x55FFFFFF), blurRadius: 6, spreadRadius: 1),
          ],
        ),
      ),
    );
  }
}

class _SelectedBlowIcon extends StatelessWidget {
  const _SelectedBlowIcon();
  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Center(
        child: Icon(
          Icons.whatshot,
          color: Colors.orangeAccent,
          size: 28,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 6),
            Shadow(color: Colors.orange, blurRadius: 4),
          ],
        ),
      ),
    );
  }
}

class _ExplosionAnim extends StatefulWidget {
  const _ExplosionAnim();
  @override
  State<_ExplosionAnim> createState() => _ExplosionAnimState();
}

class _ExplosionAnimState extends State<_ExplosionAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _t;
  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420))
      ..forward();
    _t = CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final t = _t.value;
        // Layers: bright flash, fiery core, expanding shockwave ring
        final flashOpacity =
            t < 0.35 ? (1.0 - (t / 0.35)) : 0.0; // quick white flash
        final coreOpacity = 1.0 - t;
        final coreScale = 0.5 + 0.9 * t; // expand core
        final ringScale = 0.6 + 1.2 * t; // shockwave scale
        final ringOpacity = (1.0 - t).clamp(0.0, 0.9);
        final ringWidth = 2.0 + 6.0 * t;

        return IgnorePointer(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // White flash
              Opacity(
                opacity: flashOpacity,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white, Colors.transparent],
                      stops: [0.0, 1.0],
                    ),
                  ),
                ),
              ),

              // Fiery core
              Opacity(
                opacity: coreOpacity,
                child: Transform.scale(
                  scale: coreScale,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFFFFF176), // soft yellow
                          Color(0xFFFFA726), // orange
                          Color(0xFFE53935), // red
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.35, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Shockwave ring
              Opacity(
                opacity: ringOpacity,
                child: Transform.scale(
                  scale: ringScale,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            Colors.amberAccent.withOpacity(0.9 * ringOpacity),
                        width: ringWidth,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.orange.withOpacity(0.5 * ringOpacity),
                            blurRadius: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreFlyUp extends StatefulWidget {
  final int id;
  final int points;
  final double rise;
  final double fontSize;
  const _ScoreFlyUp(
      {required this.id,
      required this.points,
      required this.rise,
      required this.fontSize});

  @override
  State<_ScoreFlyUp> createState() => _ScoreFlyUpState();
}

class _ScoreFlyUpState extends State<_ScoreFlyUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2700))
      ..forward();
    _t = CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(covariant _ScoreFlyUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _ac.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final t = _t.value;
        final opacity = (1.0 - t).clamp(0.0, 1.0);
        final dy = -widget.rise * t;
        final scale = 0.9 + 0.2 * t;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Transform.scale(
              scale: scale,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Text(
                  '+${widget.points}',
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandGold,
                    shadows: const [
                      Shadow(
                          color: Colors.black54,
                          blurRadius: 6,
                          offset: Offset(0, 2)),
                      Shadow(
                          color: Colors.black87,
                          blurRadius: 12,
                          offset: Offset(0, 4)),
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
}

class _FallDown extends StatelessWidget {
  final int distanceCells;
  final double cellSize;
  final int durationMs;
  final Widget child;
  const _FallDown(
      {required this.distanceCells,
      required this.cellSize,
      required this.child,
      required this.durationMs});

  @override
  Widget build(BuildContext context) {
    // Translate downward by distanceCells * cellSize over time and fade out
    final dy = distanceCells * cellSize;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: dy),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        final t = (val / (dy == 0 ? 1 : dy)).clamp(0.0, 1.0);
        final opacity = 1.0 - t; // fade out while falling
        return Opacity(
          opacity: opacity,
          child: Transform.translate(offset: Offset(0, val), child: child),
        );
      },
      child: child,
    );
  }
}

class _GoldPulseBorder extends StatefulWidget {
  const _GoldPulseBorder();
  @override
  State<_GoldPulseBorder> createState() => _GoldPulseBorderState();
}

class _GoldPulseBorderState extends State<_GoldPulseBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _t = CurvedAnimation(parent: _ac, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final glow = 4 + 6 * _t.value;
        final opacity = 0.6 + 0.4 * (1 - (_t.value - 0.5).abs() * 2);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: AppColors.brandGold.withOpacity(opacity), width: 3),
            boxShadow: [
              BoxShadow(
                  color: AppColors.brandGold.withOpacity(0.5 * opacity),
                  blurRadius: glow,
                  spreadRadius: 0),
            ],
          ),
        );
      },
    );
  }
}

class _Quake extends StatefulWidget {
  final bool quaking;
  final int durationMs;
  final Widget child;
  const _Quake(
      {required this.quaking, required this.durationMs, required this.child});

  @override
  State<_Quake> createState() => _QuakeState();
}

class _QuakeState extends State<_Quake> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _t;
  bool _wasQuaking = false;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.durationMs));
    _t = CurvedAnimation(parent: _ac, curve: Curves.linear);
    if (widget.quaking) {
      _ac.forward(from: 0);
      _wasQuaking = true;
    }
  }

  @override
  void didUpdateWidget(covariant _Quake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quaking && !_wasQuaking) {
      _ac.duration = Duration(milliseconds: widget.durationMs);
      _ac.forward(from: 0);
      _wasQuaking = true;
    } else if (!widget.quaking && _wasQuaking) {
      _wasQuaking = false;
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.quaking) return widget.child;
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final t = _t.value;
        // Decaying multi-frequency shake
        final decay = (1.0 - t);
        final amp = 6.0 * decay; // max ~6px shake, reduces to 0
        final dx = amp * math.sin(2 * math.pi * (10 * t)) +
            (amp * 0.5) * math.sin(2 * math.pi * (17 * t + 0.3));
        final dy = (amp * 0.8) * math.sin(2 * math.pi * (13 * t + 0.1)) +
            (amp * 0.3) * math.sin(2 * math.pi * (19 * t + 0.6));
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
      child: widget.child,
    );
  }
}
