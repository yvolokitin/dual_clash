import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
    final String duelOutcomeLine = _duelOutcomeLine(winner);
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


          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bg, bg],
        ),
            color: AppColors.dialogShadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          )
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                            icon: const Icon(Icons.close,
                                color: Colors.white70),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double baseTileSize =
                          (constraints.maxWidth * 0.5)
                              .clamp(140.0, 220.0);
                      final double tileSize = isPhoneFullscreen
                          ? baseTileSize
                          : baseTileSize * 0.8;
                      return Column(
                        children: [
                          Center(
                            child: Container(
                              width: tileSize,
                              height: tileSize,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
    final bool isChallengeLoss = isChallengeMode &&
        winner != null &&
        winner != CellState.red;
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: hasWinner
                                      ? AppColors.brandGold
                                      : Colors.white24,
                                  width: 2,
                              padding: EdgeInsets.all(tileSize * 0.1),
                              child: Image.asset(
                                winnerAsset,
                                fit: BoxFit.contain,
                              ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              isChallengeMode
                                  ? outcomeLine
                                  : duelOutcomeLine,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                          ),
                          if (isChallengeMode) ...[
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.06),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(color: Colors.white24),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      icon: const Icon(Icons.grid_on),
                      label: const Text('Show final board'),
                ],
              ),
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
                                winner != null && winner != CellState.red
                                    ? 'You lost. All points burned.'
                                    : performanceRating,
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
                                isChallengeLoss
                        final double baseTileSize =
                            (constraints.maxWidth * 0.5)
                                .clamp(140.0, 220.0);
                        final double tileSize = isPhoneFullscreen
                            ? baseTileSize
                            : baseTileSize * 0.8;
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
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                duelOutcomeLine,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Action buttons based on result and AI level
                  _ResultsActions(controller: controller, winner: winner),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.06),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(color: Colors.white24),
                      ),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w800, letterSpacing: 0.2),
                    ),
                    icon: const Icon(Icons.grid_on),
                    label: const Text('Show final board'),
                  ),
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

  String _duelOutcomeLine(CellState? winner) {
    switch (winner) {
      case CellState.red:
        return 'Red player wins.';
      case CellState.blue:
        return 'Blue player wins.';
      case CellState.yellow:
        return 'Yellow player wins.';
      case CellState.green:
        return 'Green player wins.';
      case CellState.neutral:
      case CellState.empty:
      case null:
        return 'Match ended in a draw.';
    }
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


class _ResultsActions extends StatelessWidget {
  final GameController controller;
  final CellState? winner;
  const _ResultsActions({required this.controller, required this.winner});

  @override
  Widget build(BuildContext context) {
    final int ai = controller.aiLevel;
    const int minAiLevel = 1;
    const int maxAiLevel = 7;
    final bool canDecreaseAi = ai > minAiLevel;
    final bool canIncreaseAi = ai < maxAiLevel;

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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play again'),
          ),
        ],
      );
    }

              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              fontSize: 16,
            ),
      );
    }

              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
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
      if (canIncreaseAi) {
        challengeButtons.add(
          primaryButton(
            text: 'Continue to Next AI Level',
            icon: Icons.trending_up,
            onPressed: () async {
              Navigator.of(context).pop();
              final next = ai + 1;
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
      } else {
        challengeButtons.add(
          primaryButton(
            text: 'Play Again',
            icon: Icons.replay,
            onPressed: () {
              Navigator.of(context).pop();
              controller.newGame();
            },
          ),
        );
      }
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
      if (canDecreaseAi) {
        challengeButtons.add(
          secondaryButton(
            text: 'Play lower AI level',
            icon: Icons.trending_down,
            onPressed: () async {
              Navigator.of(context).pop();
              final lower = ai - 1;
              await controller.setAiLevel(lower);
              controller.newGame();
            },
          ),
        );
      }
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
