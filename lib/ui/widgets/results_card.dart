import 'package:flutter/material.dart';
import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/models/cell_state.dart';
import 'package:dual_clash/ui/widgets/animated_total_counter.dart';
import 'package:dual_clash/logic/rules_engine.dart';

// Independent ResultsCard widget extracted to be reusable across the app.
class ResultsCard extends StatelessWidget {
  final GameController controller;
  const ResultsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isCompact = size.width < 550;
    final bg = AppColors.bg;
    final redBase = controller.scoreRedBase();
    final blueBase = controller.scoreBlueBase();
    final neutrals = RulesEngine.countOf(controller.board, CellState.neutral);
    final redTotal = controller.scoreRedTotal();
    final blueTotal = controller.scoreBlueTotal();
    final bool isDuel = controller.humanVsHuman;
    final bool isChallengeMode = !isDuel;
    CellState? winner;
    if (controller.isMultiDuel) {
      winner = controller.duelWinner();
    } else if (isChallengeMode) {
      final int maxScore = [
        redTotal,
        blueTotal,
        neutrals,
      ].reduce((a, b) => a > b ? a : b);
      final int topCount = [
        redTotal,
        blueTotal,
        neutrals,
      ].where((score) => score == maxScore).length;
      if (topCount == 1) {
        if (maxScore == redTotal) {
          winner = CellState.red;
        } else if (maxScore == blueTotal) {
          winner = CellState.blue;
        } else {
          winner = CellState.neutral;
        }
      } else {
        winner = null;
      }
    } else {
      winner = redTotal == blueTotal
          ? null
          : (redTotal > blueTotal ? CellState.red : CellState.blue);
    }

    final bool hasWinner = winner != null;
    final bool showYellow = isDuel && controller.isMultiDuel;
    final bool showGreen =
        isDuel && controller.isMultiDuel && controller.duelPlayerCount >= 4;

    final tiles = [
      _ResultTileData(
        asset: 'assets/icons/box_red.png',
        count: redBase,
        state: CellState.red,
      ),
      _ResultTileData(
        asset: 'assets/icons/box_blue.png',
        count: blueBase,
        state: CellState.blue,
      ),
      if (showYellow)
        _ResultTileData(
          asset: 'assets/icons/box_yellow.png',
          count: controller.scoreYellowBase(),
          state: CellState.yellow,
        ),
      if (showGreen)
        _ResultTileData(
          asset: 'assets/icons/box_green.png',
          count: controller.scoreGreenBase(),
          state: CellState.green,
        ),
      _ResultTileData(
        asset: 'assets/icons/box_grey.png',
        count: neutrals,
        state: CellState.neutral,
      ),
    ];

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: isCompact ? 0 : 24, vertical: isCompact ? 0 : 24),
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
            maxWidth: isCompact ? size.width : 520,
            maxHeight: isCompact ? size.height : size.height * 0.9,
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
                      const Text(
                        'Results',
                        style: TextStyle(
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

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final int columns = width >= 420 ? 3 : 2;
                      final double spacing = 10;
                      final double ratio = width >= 420 ? 1.1 : 1.0;
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: ratio,
                        children: tiles
                            .map((tile) => _scoreTile(
                                  data: tile,
                                  isWinner: tile.state != null &&
                                      tile.state == winner,
                                  isDisabled: hasWinner &&
                                      (tile.state == null ||
                                          tile.state != winner),
                                ))
                            .toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  // Points and time on the same row if fit; otherwise they will wrap to 2 rows automatically
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        // AnimatedTotalCounter(value: controller.totalUserScore),
                        _timeChip(
                            label: 'Time played',
                            value: _formatDuration(controller.lastGamePlayMs)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Turns row beneath
                  if (isDuel && controller.isMultiDuel)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _statChip(
                            icon: Icons.rotate_left,
                            label: 'Red turns',
                            value: controller.turnsRed.toString()),
                        _statChip(
                            icon: Icons.rotate_left,
                            label: 'Blue turns',
                            value: controller.turnsBlue.toString()),
                        _statChip(
                            icon: Icons.rotate_left,
                            label: 'Yellow turns',
                            value: controller.turnsYellow.toString()),
                        if (controller.duelPlayerCount >= 4)
                          _statChip(
                              icon: Icons.rotate_left,
                              label: 'Green turns',
                              value: controller.turnsGreen.toString()),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statChip(
                            icon: Icons.rotate_left,
                            label: isDuel ? 'Red turns' : 'Player turns',
                            value: controller.turnsRed.toString()),
                        _statChip(
                            icon: Icons.rotate_right,
                            label: isDuel ? 'Blue turns' : 'AI turns',
                            value: controller.turnsBlue.toString()),
                      ],
                    ),

                  if (!isDuel) ...[
                    const SizedBox(height: 12),
                    // Total user points summary per game outcome
                    _TotalsSummary(controller: controller, winner: winner),
                  ],

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

  Widget _scoreTile(
      {required _ResultTileData data,
      required bool isWinner,
      required bool isDisabled}) {
    final Color borderColor = isWinner
        ? AppColors.brandGold
        : (isDisabled ? Colors.white12 : Colors.white24);
    final Color countTextColor =
        isDisabled ? Colors.white54 : Colors.white;
    final Color countBorderColor =
        isWinner ? AppColors.brandGold : Colors.white24;
    final double circleSize = 44;
    final double overlap = circleSize / 2;

    final ColorFilter? filter = isDisabled
        ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: isDisabled
            ? AppColors.neutral.withOpacity(0.35)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isWinner ? 2 : 1),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: overlap),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ColorFiltered(
                  colorFilter: filter ??
                      const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      ),
                  child: Opacity(
                    opacity: isDisabled ? 0.5 : 1,
                    child: Image.asset(
                      data.asset,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: circleSize,
              height: circleSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(isDisabled ? 0.08 : 0.14),
                border: Border.all(color: countBorderColor, width: 1),
              ),
              child: Text(
                '${data.count}',
                style: TextStyle(
                    color: countTextColor, fontWeight: FontWeight.w900),
              ),
            ),
          ),
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

class _ResultTileData {
  final String asset;
  final int count;
  final CellState? state;

  const _ResultTileData(
      {required this.asset, required this.count, required this.state});
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
            const Text('This game earned',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w700)),
            Text('+$awarded = $before → $newTotal',
                style: const TextStyle(
                    color: Colors.lightGreenAccent,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      );
    } else if (winner == null) {
      if (awarded > 0) {
        final newTotal = before + awarded;
        line2 = Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Draw game: half points awarded',
                  style: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.w700)),
              Text('+$awarded = $before → $newTotal',
                  style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.w900)),
            ],
          ),
        );
      } else {
        line2 = const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Draw game: your total remains the same.',
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w700)),
        );
      }
    } else {
      line2 = const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text('You lost: your total remained the same.',
            textAlign: TextAlign.right,
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
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
    final int ai = controller.aiLevel;
    final bool atMin = ai <= 1;
    final bool atMax = ai >= 7;

    // Helper builders copied from GamePage to preserve styles
    Widget goldButton(
        {required String text,
        required IconData icon,
        required VoidCallback onPressed}) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGold,
          foregroundColor: const Color(0xFF2B221D),
          shadowColor: Colors.black54,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
        ),
        icon: Icon(icon),
        label: Text(text),
      );
    }

    Widget outlineButton(
        {required String text,
        required IconData icon,
        required VoidCallback onPressed}) {
      return TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.08),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Colors.white24),
          ),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
        ),
        icon: Icon(icon, size: 20),
        label: Text(text),
      );
    }

    // Duel mode: single Play again button
    if (controller.humanVsHuman) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              controller.newGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandGold,
              foregroundColor: const Color(0xFF2B221D),
              shadowColor: Colors.black54,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play again'),
          ),
        ],
      );
    }

    List<Widget> buttons;

    if (atMin || atMax || winner == null) {
      // At bounds or draw: single Next Game
      buttons = [
        goldButton(
          text: 'Play next game',
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
        outlineButton(
          text: 'Continue play same level',
          icon: Icons.replay,
          onPressed: () {
            Navigator.of(context).pop();
            controller.newGame();
          },
        ),
        goldButton(
          text: 'Play next AI level',
          icon: Icons.trending_up,
          onPressed: () async {
            Navigator.of(context).pop();
            final next = (ai + 1).clamp(1, 7);
            await controller.setAiLevel(next);
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
      case CellState.yellow:
        fill = AppColors.yellow;
        break;
      case CellState.green:
        fill = AppColors.green;
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
