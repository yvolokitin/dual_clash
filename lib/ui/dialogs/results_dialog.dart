import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/models/cell_state.dart';
import 'package:dual_clash/ui/widgets/animated_total_counter.dart';

/// Results dialog extracted from GamePage so it can be reused and maintained independently.
Future<void> showAnimatedResultsDialog(
    {required BuildContext context, required GameController controller}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Results',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic);
      return Stack(
        children: [
          // Soft blur backdrop
          Positioned.fill(
            child: AnimatedBuilder(
              animation: anim,
              builder: (context, _) => BackdropFilter(
                filter: ui.ImageFilter.blur(
                    sigmaX: 6 * anim.value, sigmaY: 6 * anim.value),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                child: _ResultsCard(controller: controller),
              ),
            ),
          ),
        ],
      );
    },
  );
}

String _formatDuration(int ms) {
  if (ms <= 0) return '0s';
  int seconds = (ms / 1000).floor();
  int hours = seconds ~/ 3600;
  seconds %= 3600;
  int minutes = seconds ~/ 60;
  seconds %= 60;
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  if (minutes > 0) {
    return '${minutes}m ${seconds}s';
  }
  return '${seconds}s';
}

class _ResultsCard extends StatelessWidget {
  final GameController controller;
  const _ResultsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bg;
    final redBase = controller.scoreRedBase();
    final blueBase = controller.scoreBlueBase();
    final redTotal = controller.scoreRedTotal();
    final blueTotal = controller.scoreBlueTotal();
    final winner = redTotal == blueTotal
        ? null
        : (redTotal > blueTotal ? CellState.red : CellState.blue);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bg, bg]),
          boxShadow: const [
            BoxShadow(
                color: AppColors.dialogShadow,
                blurRadius: 24,
                offset: Offset(0, 12))
          ],
          border: Border.all(color: AppColors.dialogOutline, width: 1),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      if (winner == CellState.red)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.asset('assets/icons/winner-removebg.png',
                              width: 36, height: 36),
                        )
                      else if (winner == CellState.blue)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.asset('assets/icons/looser-removebg.png',
                              width: 36, height: 36),
                        ),
                      Text(
                        winner == null
                            ? 'Draw'
                            : (winner == CellState.red
                                ? 'Player Wins!'
                                : 'AI Wins!'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24)),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 20,
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _scoreRow(
                      label: 'Player',
                      color: AppColors.red,
                      base: redBase,
                      bonus: controller.bonusRed,
                      total: redTotal,
                      highlight: winner == CellState.red),
                  const SizedBox(height: 8),
                  _scoreRow(
                      label: 'AI',
                      color: AppColors.blue,
                      base: blueBase,
                      bonus: controller.bonusBlue,
                      total: blueTotal,
                      highlight: winner == CellState.blue),

                  const SizedBox(height: 12),
                  // Points and time on the same row if fit; otherwise wrap
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        AnimatedTotalCounter(value: controller.totalUserScore),
                        _timeChip(
                            label: 'Time played',
                            value: _formatDuration(controller.lastGamePlayMs)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Turns row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statChip(
                          icon: Icons.rotate_left,
                          label: 'Player turns',
                          value: controller.turnsRed.toString()),
                      _statChip(
                          icon: Icons.rotate_right,
                          label: 'AI turns',
                          value: controller.turnsBlue.toString()),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // Total user points summary per game outcome
                  _TotalsSummary(controller: controller, winner: winner),

                  const SizedBox(height: 12),
                  // Action buttons based on result and AI level
                  _ResultsActions(controller: controller, winner: winner),
                  const SizedBox(height: 16),
                  // Mini board preview
                  _MiniBoardPreview(controller: controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreRow(
      {required String label,
      required Color color,
      required int base,
      required int bonus,
      required int total,
      required bool highlight}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: highlight ? AppColors.brandGold : Colors.white24,
            width: highlight ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: highlight ? AppColors.brandGold : Colors.white,
                  fontWeight: FontWeight.w800)),
          const Spacer(),
          // Show only the number of boxes (base) without calculations
          Text('$base',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _statChip(
      {required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _timeChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/duration-removebg.png',
              width: 18, height: 18),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _TotalsSummary extends StatelessWidget {
  final GameController controller;
  final CellState? winner;
  const _TotalsSummary({required this.controller, required this.winner});

  @override
  Widget build(BuildContext context) {
    final total = controller.totalUserScore;
    final before = controller.lastTotalBeforeAward;
    final awarded = controller.lastGamePointsAwarded;
    final won = winner == CellState.red;

    Widget line1 = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Your total points',
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
        AnimatedTotalCounter(value: total),
      ],
    );

    Widget line2;
    if (won) {
      final newTotal = before + awarded;
      line2 = Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Won award', style: TextStyle(color: Colors.white54)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: Colors.lightGreenAccent, size: 18),
                const SizedBox(width: 6),
                Text('+${awarded}',
                    style: const TextStyle(
                        color: Colors.lightGreenAccent,
                        fontWeight: FontWeight.w900)),
                const SizedBox(width: 10),
                const Text('= ', style: TextStyle(color: Colors.white54)),
                AnimatedTotalCounter(value: newTotal),
              ],
            ),
          ],
        ),
      );
    } else {
      line2 = const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line1,
          line2,
        ],
      ),
    );
  }
}

class _ResultsActions extends StatelessWidget {
  final GameController controller;
  final CellState? winner;
  const _ResultsActions({required this.controller, required this.winner});

  @override
  Widget build(BuildContext context) {
    final ai = controller.aiLevel;

    Widget outlineButton(
            {required String text,
            required IconData icon,
            required VoidCallback onPressed}) =>
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(text),
        );

    Widget goldButton(
            {required String text,
            required IconData icon,
            required VoidCallback onPressed}) =>
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(text),
        );

    List<Widget> buttons;
    if (winner == null) {
      // Draw
      buttons = [
        outlineButton(
          text: 'Play again',
          icon: Icons.replay,
          onPressed: () {
            Navigator.of(context).pop();
            controller.newGame();
          },
        ),
        goldButton(
          text: 'Continue play same level',
          icon: Icons.play_arrow,
          onPressed: () {
            Navigator.of(context).pop();
            controller.newGame();
          },
        ),
      ];
    } else if (winner == CellState.red) {
      // User won
      buttons = [
        goldButton(
          text: 'Play higher AI level',
          icon: Icons.trending_up,
          onPressed: () async {
            Navigator.of(context).pop();
            final higher = (ai + 1).clamp(1, 7);
            await controller.setAiLevel(higher);
            controller.newGame();
          },
        ),
        outlineButton(
          text: 'Continue play same level',
          icon: Icons.replay,
          onPressed: () {
            Navigator.of(context).pop();
            controller.newGame();
          },
        ),
      ];
    } else {
      // User lost
      buttons = [
        goldButton(
          text: 'Play lower AI level',
          icon: Icons.trending_down,
          onPressed: () async {
            Navigator.of(context).pop();
            final lower = (ai - 1).clamp(1, 7);
            await controller.setAiLevel(lower);
            controller.newGame();
          },
        ),
        outlineButton(
          text: 'Continue play same level',
          icon: Icons.replay,
          onPressed: () {
            Navigator.of(context).pop();
            controller.newGame();
          },
        ),
      ];
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          buttons[i],
        ]
      ],
    );
  }
}

class _MiniBoardPreview extends StatelessWidget {
  final GameController controller;
  const _MiniBoardPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final b = controller.board;
    final n = b.length;
    if (n == 0) return const SizedBox.shrink();
    // Fixed small squares; overall about 3-4x smaller than main board
    const double cell = 14.0;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Final board',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int r = 0; r < n; r++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int c = 0; c < n; c++) _miniCell(b[r][c], cell),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniCell(CellState s, double cell) {
    Color fill;
    switch (s) {
      case CellState.red:
        fill = AppColors.red;
        break;
      case CellState.blue:
        fill = AppColors.blue;
        break;
      case CellState.neutral:
        fill = Colors.grey;
        break;
      case CellState.empty:
      default:
        fill = Colors.transparent;
    }
    return Container(
      width: cell,
      height: cell,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: fill.withOpacity(s == CellState.empty ? 0.0 : 0.9),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.white12, width: 1),
      ),
    );
  }
}
