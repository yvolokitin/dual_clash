import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/core/constants.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/models/cell_state.dart';
import 'package:dual_clash/models/game_result.dart';
import 'package:dual_clash/logic/rules_engine.dart';

// Independent ResultsCard widget extracted to be reusable across the app.
class ResultsCard extends StatelessWidget {
  final GameController controller;
  const ResultsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobilePlatform = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final bool isTabletDevice = isTablet(context);
    final bool isPhoneFullscreen = isMobilePlatform && !isTabletDevice;
    final EdgeInsets contentPadding =
        EdgeInsets.fromLTRB(16, isPhoneFullscreen ? 20 : 16, 16, 16);
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

    final BorderRadius dialogRadius =
        BorderRadius.circular(isPhoneFullscreen ? 0 : 22);
    final int playerScore = redTotal;
    final int opponentScore = [blueTotal, neutrals].reduce(math.max);
    final List<GameResult> history = controller.history;
    final bool lastMatchesCurrent = history.isNotEmpty &&
        history.last.redTotal == redTotal &&
        history.last.blueTotal == blueTotal &&
        history.last.playMs == controller.lastGamePlayMs;
    final List<GameResult> previousResults =
        lastMatchesCurrent && history.length > 1
            ? history.sublist(0, history.length - 1)
            : history;
    final int previousBestScore = previousResults.isEmpty
        ? 0
        : previousResults.map((r) => r.redTotal).reduce(math.max);
    final int bestScore = math.max(playerScore, previousBestScore);
    final bool isNewBest = playerScore >= bestScore;
    final String bestScoreLine = isNewBest
        ? 'New Best Score'
        : '${bestScore - playerScore} points below your best score';
    final String performanceRating =
        _performanceRating(playerScore, opponentScore, isNewBest);
    final String outcomeLine = _challengeOutcomeLine(winner);
    final String winnerAsset = _winnerAsset(winner);
    final content = Container(
      decoration: BoxDecoration(
        borderRadius: dialogRadius,
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
          maxWidth: isPhoneFullscreen ? size.width : size.width * 0.8,
          maxHeight: isPhoneFullscreen ? size.height : size.height * 0.8,
          minWidth: isPhoneFullscreen ? size.width : 0,
          minHeight: isPhoneFullscreen ? size.height : 0,
        ),
        child: SafeArea(
          top: isPhoneFullscreen,
          bottom: isPhoneFullscreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: contentPadding,
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
                      if (!isMobilePlatform)
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
                            icon:
                                const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isChallengeMode) ...[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double tileSize = (constraints.maxWidth * 0.5)
                            .clamp(140.0, 220.0);
                        return Column(
                          children: [
                            Center(
                              child: Container(
                                width: tileSize,
                                height: tileSize,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: hasWinner
                                        ? AppColors.brandGold
                                        : Colors.white24,
                                    width: 2,
                                  ),
                                ),
                                padding: EdgeInsets.all(tileSize * 0.1),
                                child: Image.asset(
                                  winnerAsset,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                outcomeLine,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                performanceRating,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.brandGold,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                bestScoreLine,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ] else ...[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final int tileCount = tiles.length;
                        int columns;
                        if (tileCount == 3) {
                          columns = 3;
                        } else if (tileCount == 4) {
                          columns = 3;
                        } else if (tileCount == 5) {
                          columns = 3;
                        } else {
                          columns = width >= 420 ? 3 : 2;
                        }
                        final double spacing = 10;
                        final double ratio = width >= 420 ? 1.1 : 1.0;
                        final bool compactRow = tileCount == 3 && width < 550;
                        final double baseScale = compactRow ? 0.7 : 0.8;
                        final double scale =
                            isPhoneFullscreen ? baseScale : baseScale * 0.8;
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
                              .map((tile) => Transform.scale(
                                    scale: scale,
                                    child: tile,
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
                              value:
                                  _formatDuration(controller.lastGamePlayMs)),
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

    final EdgeInsets dialogInsetPadding = isPhoneFullscreen
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(
            horizontal: size.width * 0.1, vertical: size.height * 0.1);
    return Dialog(
      insetPadding: dialogInsetPadding,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: dialogRadius),
      child: isPhoneFullscreen
          ? SizedBox(
              width: size.width,
              height: size.height,
              child: content,
            )
          : content,
    );
  }

  Widget _scoreTile(
      {required _ResultTileData data,
      required bool isWinner,
      required bool isDisabled}) {
    final Color borderColor =
        isWinner ? AppColors.brandGold : Colors.transparent;
    final Color countTextColor =
        isWinner ? Colors.white : (isDisabled ? Colors.white54 : Colors.white);
    final Color countBorderColor =
        isWinner ? AppColors.brandGold : Colors.white24;
    final Color countFillColor = isWinner
        ? AppColors.brandGold
        : Colors.white.withOpacity(isDisabled ? 0.08 : 0.14);
    const double circleSize = 44 * 1.2;
    const double countFontSize = 14 * 1.2;
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
                color: countFillColor,
                border: Border.all(color: countBorderColor, width: 1),
              ),
              child: Text(
                '${data.count}',
                style: TextStyle(
                    color: countTextColor,
                    fontWeight: FontWeight.w900,
                    fontSize: countFontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _challengeOutcomeLine(CellState? winner) {
    switch (winner) {
      case CellState.red:
        return 'Red player territory controlled.';
      case CellState.blue:
        return 'Blue player territory controlled.';
      case CellState.neutral:
        return 'Neutral territory prevailed.';
      case CellState.yellow:
        return 'Yellow player territory controlled.';
      case CellState.green:
        return 'Green player territory controlled.';
      case CellState.empty:
      case null:
        return 'Balanced territory control.';
    }
  }

  String _performanceRating(
      int playerScore, int opponentScore, bool isNewBest) {
    final int diff = playerScore - opponentScore;
    if (isNewBest || diff >= 6) {
      return 'Brilliant Endgame';
    }
    if (diff >= 3) {
      return 'Great Control';
    }
    if (diff >= 1) {
      return 'Risky, but Effective';
    }
    return 'Solid Strategy';
  }

  String _winnerAsset(CellState? winner) {
    switch (winner) {
      case CellState.red:
        return 'assets/icons/box_red.png';
      case CellState.blue:
        return 'assets/icons/box_blue.png';
      case CellState.yellow:
        return 'assets/icons/box_yellow.png';
      case CellState.green:
        return 'assets/icons/box_green.png';
      case CellState.neutral:
      case CellState.empty:
      case null:
        return 'assets/icons/box_grey.png';
    }
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

class _ResultsActions extends StatelessWidget {
  final GameController controller;
  final CellState? winner;
  const _ResultsActions({required this.controller, required this.winner});

  @override
  Widget build(BuildContext context) {
    final int ai = controller.aiLevel;

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

    if (winner == null) {
      // Draw: single Next Game
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

    final bool isChallengeMode = !controller.humanVsHuman;
    if (!isChallengeMode) {
      return Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < buttons.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              buttons[i],
            ]
          ],
        ),
      );
    }

    Widget primaryButton(
        {required String text,
        required IconData icon,
        required VoidCallback onPressed}) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandGold,
            foregroundColor: const Color(0xFF2B221D),
            shadowColor: Colors.black54,
            elevation: 6,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            textStyle: const TextStyle(
                fontWeight: FontWeight.w900, letterSpacing: 0.4, fontSize: 16),
          ),
          icon: Icon(icon, size: 22),
          label: Text(text),
        ),
      );
    }

    Widget secondaryButton(
        {required String text,
        required IconData icon,
        required VoidCallback onPressed}) {
      return SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.08),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Colors.white24),
            ),
            textStyle: const TextStyle(
                fontWeight: FontWeight.w800, letterSpacing: 0.2),
          ),
          icon: Icon(icon, size: 20),
          label: Text(text),
        ),
      );
    }

    final List<Widget> challengeButtons = [];
    if (winner == CellState.red) {
      challengeButtons.add(
        primaryButton(
          text: 'Continue to Next AI Level',
          icon: Icons.trending_up,
          onPressed: () async {
            Navigator.of(context).pop();
            final next = (ai + 1).clamp(1, 7);
            await controller.setAiLevel(next);
            controller.newGame();
          },
        ),
      );
      challengeButtons.add(
        secondaryButton(
          text: 'Play Again',
          icon: Icons.replay,
          onPressed: () {
            Navigator.of(context).pop();
            controller.newGame();
          },
        ),
      );
    } else if (winner == null) {
      challengeButtons.add(
        primaryButton(
          text: 'Play Again',
          icon: Icons.play_arrow,
          onPressed: () {
            Navigator.of(context).pop();
            controller.newGame();
          },
        ),
      );
    } else {
      challengeButtons.add(
        primaryButton(
          text: 'Play Again',
          icon: Icons.play_arrow,
          onPressed: () {
            Navigator.of(context).pop();
            controller.newGame();
          },
        ),
      );
      challengeButtons.add(
        secondaryButton(
          text: 'Play lower AI level',
          icon: Icons.trending_down,
          onPressed: () async {
            Navigator.of(context).pop();
            final lower = (ai - 1).clamp(1, 7);
            await controller.setAiLevel(lower);
            controller.newGame();
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < challengeButtons.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          challengeButtons[i],
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
