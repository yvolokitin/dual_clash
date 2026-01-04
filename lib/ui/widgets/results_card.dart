import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/core/constants.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/models/cell_state.dart';
import 'package:dual_clash/logic/rules_engine.dart';
import 'package:dual_clash/ui/widgets/main_menu/menu_tile.dart';

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
        const EdgeInsets.fromLTRB(16, 20, 16, 16);
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
                  if (isChallengeMode)
                    _ChallengeOutcomeSummary(
                      winner: winner,
                      redTotal: redTotal,
                      blueTotal: blueTotal,
                      bestScore: controller.bestChallengeScore,
                      isNewBest: controller.lastGameWasNewBest,
                      boardSize: controller.board.length,
                      isPhoneFullscreen: isPhoneFullscreen,
                    )
                  else ...[
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

class _ChallengeOutcomeSummary extends StatelessWidget {
  final CellState? winner;
  final int redTotal;
  final int blueTotal;
  final int bestScore;
  final bool isNewBest;
  final int boardSize;
  final bool isPhoneFullscreen;
  const _ChallengeOutcomeSummary({
    required this.winner,
    required this.redTotal,
    required this.blueTotal,
    required this.bestScore,
    required this.isNewBest,
    required this.boardSize,
    required this.isPhoneFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    final data = _challengeOutcomeData(winner);
    final int totalCells = boardSize * boardSize;
    final int margin = redTotal - blueTotal;
    final int clearWinMargin = (totalCells * 0.25).ceil();
    final int solidWinMargin = (totalCells * 0.12).ceil();
    final String rating = _performanceRating(
      margin: margin,
      isNewBest: isNewBest,
      clearWinMargin: clearWinMargin,
      solidWinMargin: solidWinMargin,
      aiWon: blueTotal > redTotal,
    );
    final int pointsBelowBest = (bestScore - redTotal).clamp(0, bestScore);
    final String bestLine = isNewBest
        ? 'New Best Score'
        : '$pointsBelowBest points below best score';

    return LayoutBuilder(
      builder: (context, constraints) {
        final double tileBaseSize =
            (constraints.maxWidth * 0.45).clamp(140, 200);
        final double tileSize =
            isPhoneFullscreen ? tileBaseSize : tileBaseSize * 0.75;
        return Column(
          children: [
            Center(
              child: Container(
                width: tileSize,
                height: tileSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: data.accentColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: data.accentColor.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    data.asset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              data.summary,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Score reached: $redTotal',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.w700,
                fontFamily: 'ArchivoBlack',
                fontSize: 22.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Text(
                bestLine,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isNewBest ? Colors.lightGreenAccent : Colors.white70,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              rating,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChallengeOutcomeData {
  final String asset;
  final String summary;
  final Color accentColor;

  const _ChallengeOutcomeData({
    required this.asset,
    required this.summary,
    required this.accentColor,
  });
}

_ChallengeOutcomeData _challengeOutcomeData(CellState? winner) {
  switch (winner) {
    case CellState.red:
      return const _ChallengeOutcomeData(
        asset: 'assets/icons/box_red.png',
        summary: 'Red player territory controlled.',
        accentColor: AppColors.red,
      );
    case CellState.blue:
      return const _ChallengeOutcomeData(
        asset: 'assets/icons/box_blue.png',
        summary: 'Blue player territory controlled.',
        accentColor: AppColors.blue,
      );
    case CellState.neutral:
      return const _ChallengeOutcomeData(
        asset: 'assets/icons/box_grey.png',
        summary: 'Neutral territory controlled.',
        accentColor: Colors.grey,
      );
    default:
      return const _ChallengeOutcomeData(
        asset: 'assets/icons/box_grey.png',
        summary: 'Territory balanced.',
        accentColor: Colors.white54,
      );
  }
}

String _performanceRating({
  required int margin,
  required bool isNewBest,
  required int clearWinMargin,
  required int solidWinMargin,
  required bool aiWon,
}) {
  if (aiWon) {
    return 'You lost. Strategy required.';
  }
  if (isNewBest || margin >= clearWinMargin) {
    return 'Brilliant Endgame';
  }
  if (margin >= solidWinMargin) {
    return 'Great Control';
  }
  if (margin > 0) {
    return 'Risky, but Effective';
  }
  return 'Solid Strategy';
}

class _ResultsActions extends StatelessWidget {
  final GameController controller;
  final CellState? winner;
  const _ResultsActions({required this.controller, required this.winner});

  @override
  Widget build(BuildContext context) {
    final int ai = controller.aiLevel;
    const String primaryTileAsset = 'assets/icons/play-removebg.png';
    const String secondaryTileAsset = 'assets/icons/restart-removebg.png';

    Widget menuActionTile({
      required String label,
      required String asset,
      required Color color,
      required VoidCallback onTap,
      bool labelBelow = false,
    }) {
      final tile = MenuTile(
        imagePath: asset,
        label: label,
        color: color,
        onTap: onTap,
        showLabel: !labelBelow,
      );
      if (!labelBelow) {
        return tile;
      }
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: tile),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    // Duel mode: single Play again button
    if (controller.humanVsHuman) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final double tileWidth =
              constraints.maxWidth < 240 ? constraints.maxWidth : 240;
          return Center(
            child: SizedBox(
              width: tileWidth,
              child: AspectRatio(
                aspectRatio: 1.1,
                child: menuActionTile(
                  label: 'Play again',
                  asset: secondaryTileAsset,
                  color: AppColors.blue,
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.newGame();
                  },
                ),
              ),
            ),
          );
        },
      );
    }

    List<Widget> buttons = [];
    final bool shouldReduceTiles = winner == CellState.red && ai < 7;

    if (winner == CellState.red && ai < 7) {
      buttons.add(
        menuActionTile(
          label: 'Play again',
          asset: secondaryTileAsset,
          color: AppColors.blue,
          labelBelow: true,
          onTap: () {
            Navigator.of(context).pop();
            controller.newGame();
          },
        ),
      );
      buttons.add(
        menuActionTile(
          label: 'Continue to Next AI Level',
          asset: primaryTileAsset,
          color: AppColors.red,
          labelBelow: true,
          onTap: () async {
            Navigator.of(context).pop();
            final next = (ai + 1).clamp(1, 7);
            await controller.setAiLevel(next);
            controller.newGame();
          },
        ),
      );
    } else {
      buttons.add(
        menuActionTile(
          label: 'Play again',
          asset: primaryTileAsset,
          color: AppColors.red,
          onTap: () {
            Navigator.of(context).pop();
            controller.newGame();
          },
        ),
      );
      if (winner != null && winner != CellState.red && ai > 1) {
        buttons.add(
          menuActionTile(
            label: 'Play Lower AI Level',
            asset: secondaryTileAsset,
            color: AppColors.blue,
            onTap: () async {
              Navigator.of(context).pop();
              final lower = (ai - 1).clamp(1, 7);
              await controller.setAiLevel(lower);
              controller.newGame();
            },
          ),
        );
      } else if (winner == CellState.red && ai >= 7) {
        buttons.add(
          menuActionTile(
            label: 'Replay Same Level',
            asset: secondaryTileAsset,
            color: AppColors.blue,
            onTap: () {
              Navigator.of(context).pop();
              controller.newGame();
            },
          ),
        );
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (buttons.length == 1) {
          final double tileWidth =
              constraints.maxWidth < 240 ? constraints.maxWidth : 240;
          return Center(
            child: SizedBox(
              width: tileWidth,
              child: AspectRatio(
                aspectRatio: 1.1,
                child: buttons.first,
              ),
            ),
          );
        }

        if (shouldReduceTiles && buttons.length == 2) {
          final double tileWidth = (constraints.maxWidth - 12) / 2;
          final double reducedTileWidth = tileWidth / 2;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: reducedTileWidth,
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: buttons.first,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: reducedTileWidth,
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: buttons.last,
                ),
              ),
            ],
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: buttons,
        );
      },
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
