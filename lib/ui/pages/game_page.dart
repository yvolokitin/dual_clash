import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../logic/game_controller.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';

import '../../models/cell_state.dart';
import 'package:dual_clash/logic/rules_engine.dart';
import 'package:dual_clash/ui/dialogs/main_menu_dialog.dart' as mmd;
import 'package:dual_clash/ui/widgets/board_widget.dart';
import 'statistics_page.dart';
import 'package:dual_clash/ui/widgets/animated_total_counter.dart';
import 'package:dual_clash/ui/widgets/live_points_chip.dart';
import 'package:dual_clash/ui/widgets/results_card.dart';

class GamePage extends StatelessWidget {
  final GameController controller;
  const GamePage({super.key, required this.controller});

  bool _isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  void _maybeShowResultsDialog(BuildContext context) {
    if (controller.gameOver && !controller.resultsShown) {
      controller.resultsShown = true; // guard
      // Wait so player can see the winner border animation
      Future.delayed(Duration(milliseconds: controller.winnerBorderAnimMs), () {
        if (!context.mounted) return;
        showAnimatedResultsDialog(context: context, controller: controller);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final redBase = controller.scoreRedBase();
        final blueBase = controller.scoreBlueBase();
        final neutralsCount = RulesEngine.countOf(controller.board, CellState.neutral);
        final redTotal = controller.scoreRedTotal();
        final blueTotal = controller.scoreBlueTotal();
        final isWide = _isWide(context);
        final winner = controller.gameOver
            ? (redTotal == blueTotal
                ? null
                : (redTotal > blueTotal ? CellState.red : CellState.blue))
            : null;
        final bool finishedAndClosed =
            controller.gameOver && controller.resultsShown;

        // Match score row icon size to exact board cell image size
        const double _boardBorderPx = 3.0; // keep in sync with BoardWidget
        final double _gridSpacingPx = K.n == 9 ? 2.0 : 0.0; // keep in sync with BoardWidget
        final bool _hasBoardSize = controller.boardPixelSize > 0;
        final double _innerBoardSide =
            _hasBoardSize ? controller.boardPixelSize - 2 * _boardBorderPx : 0;
        final double scoreItemSize = (_hasBoardSize
            ? (_innerBoardSide - _gridSpacingPx * (K.n - 1)) / K.n
            : 22.0) * 0.595; // additional 15% smaller than previous (now ~59.5% of cell size)

        // Score-row text style: same height as icon, bold, and gold color
        final _chipTextStyle = TextStyle(
          fontSize: scoreItemSize,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFE5AD3A),
        );

        // Auto-show end results dialog once
        _maybeShowResultsDialog(context);

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [

                // Score row before the board — match board width (9 cells) and center the whole row
                Padding(
                  padding: const EdgeInsets.only(
                      top: 4.0, bottom: 14.0, left: 16.0, right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: controller.boardPixelSize > 0
                          ? controller.boardPixelSize
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: main_menu.png icon + game points chip
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Image.asset('assets/icons/main_menu.png',
                                    width: scoreItemSize, height: scoreItemSize),
                                tooltip: 'Main Menu',
                                onPressed: () async {
                                  await mmd.showAnimatedMainMenuDialog(
                                      context: context, controller: controller);
                                },
                              ),
                              const SizedBox(width: 8),
                              Image.asset('assets/icons/points-removebg.png',
                                  width: scoreItemSize, height: scoreItemSize),
                              const SizedBox(width: 6),
                              Text('${controller.redGamePoints}', style: _chipTextStyle),
                            ],
                          ),
                          // Right side: red, grey, blue counts
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$redBase', style: _chipTextStyle),
                              const SizedBox(width: 6),
                              Image.asset('assets/icons/player_red.png',
                                  width: scoreItemSize, height: scoreItemSize),
                              const SizedBox(width: 18),
                              Text('$neutralsCount', style: _chipTextStyle),
                              const SizedBox(width: 6),
                              Image.asset('assets/icons/player_grey.png',
                                  width: scoreItemSize, height: scoreItemSize),
                              const SizedBox(width: 18),
                              Text('$blueBase', style: _chipTextStyle),
                              const SizedBox(width: 6),
                              Image.asset('assets/icons/player_blue.png',
                                  width: scoreItemSize, height: scoreItemSize),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Board centered
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        BoardWidget(controller: controller),
                        if (controller.isAiThinking || controller.isSimulating)
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 8),
                                const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)),
                                const SizedBox(height: 10),
                                Text(
                                  controller.isSimulating
                                      ? 'Simulating game...'
                                      : 'AI is thinking...',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Bottom actions under the board: Simulate and Undo
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Simulate button
                      IconButton(
                        icon: Image.asset('assets/icons/simulate-removebg.png',
                            width: 42, height: 42),
                        tooltip: 'Simulate game',
                        onPressed:
                            (controller.isSimulating || controller.isAiThinking)
                                ? null
                                : () async {
                                    await controller.simulateGame();
                                  },
                      ),
                      const SizedBox(width: 16),
                      // Statistics button
                      IconButton(
                        icon: Image.asset(
                            'assets/icons/statistics-removebg.png',
                            width: 42,
                            height: 42),
                        tooltip: 'Statistics',
                        onPressed: () async {
                          await showAnimatedStatisticsDialog(
                              context: context, controller: controller);
                        },
                      ),
                      const SizedBox(width: 16),
                      // Undo button (hidden when game finished and results closed)
                      if (!finishedAndClosed)
                        IconButton(
                          icon: Image.asset('assets/icons/undo-removebg.png',
                              width: 42, height: 42),
                          tooltip: 'Undo to previous user turn',
                          onPressed: controller.canUndo
                              ? () {
                                  controller.undoToPreviousUserTurn();
                                }
                              : null,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmRestart(BuildContext context) async {
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Restart',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic);
        final bg = AppColors.bg;
        return Stack(
          children: [
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 6),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                builder: (context, sigma, _) {
                  return BackdropFilter(
                    filter: ui.ImageFilter.blur(
                        sigmaX: sigma * anim.value, sigmaY: sigma * anim.value),
                    child: const SizedBox.shrink(),
                  );
                },
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                  child: Dialog(
                    insetPadding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [bg, bg],
                        ),
                        boxShadow: const [
                          BoxShadow(
                              color: AppColors.dialogShadow,
                              blurRadius: 24,
                              offset: Offset(0, 12)),
                        ],
                        border: Border.all(
                            color: AppColors.dialogOutline, width: 1),
                      ),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: 520, maxHeight: 520),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Spacer(),
                                  const Text(
                                    'Restart game?',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.dialogTitle,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white24, width: 1),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      icon: const Icon(Icons.close,
                                          color: Colors.white70),
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Are you sure you want to restart the game? All score points will be lost.',
                                style: TextStyle(
                                    color: AppColors.dialogSubtitle,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Colors.white.withOpacity(0.08),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          side: const BorderSide(
                                              color: Colors.white24)),
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2),
                                    ),
                                    child: const Text('No'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brandGold,
                                      foregroundColor: const Color(0xFF2B221D),
                                      shadowColor: Colors.black54,
                                      elevation: 4,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2),
                                    ),
                                    child: const Text('Restart'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      controller.newGame();
    }
  }

  Widget _playerCard(
      {required int points,
      required String label,
      required Color color,
      required bool isTurn,
      required bool? highlight}) {
    // Double-line border when it's this player's turn; otherwise subtle border.
    final innerCard = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isTurn ? AppColors.brandGold : Colors.white24,
            width: isTurn ? 2 : 1),
        boxShadow: isTurn
            ? const [
                BoxShadow(
                    color: Color(0x66FFC34A), blurRadius: 12, spreadRadius: 1)
              ]
            : const [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$points',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(width: 8),
          Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 8),
          Text(
            label, // Removed the word 'TURN'; turn is indicated by double border.
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isTurn ? AppColors.brandGold : Colors.white,
            ),
          ),
        ],
      ),
    );

    if (!isTurn) return innerCard;

    // Wrap with an outer gold border to create a double-line effect when it's the player's turn.
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brandGold, width: 2),
      ),
      child: innerCard,
    );
  }

  // Special blue AI player card: order AI(label) - blue box - number, tappable to change AI level
  Widget _aiPlayerCard(
      {required BuildContext context,
      required int points,
      required String beltLabel,
      required bool isTurn,
      required bool? highlight}) {
    final inner = InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openAiDifficultySelector(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isTurn ? AppColors.brandGold : Colors.white24,
              width: isTurn ? 2 : 1),
          boxShadow: isTurn
              ? const [
                  BoxShadow(
                      color: Color(0x66FFC34A), blurRadius: 12, spreadRadius: 1)
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              beltLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isTurn ? AppColors.brandGold : Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 8),
            Text('$points',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ),
    );

    if (!isTurn) return inner;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brandGold, width: 2),
      ),
      child: inner,
    );
  }

  Future<void> _openAiDifficultySelector(BuildContext context) async {
    int tempLevel = controller.aiLevel;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AI difficulty',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, a2, child) {
        final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic);
        final bg = AppColors.bg;
        return Stack(
          children: [
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
                  scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                  child: Dialog(
                    insetPadding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22)),
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
                        border: Border.all(
                            color: AppColors.dialogOutline, width: 1),
                      ),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: 560, maxHeight: 520),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: StatefulBuilder(
                            builder: (ctx2, setState) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Spacer(),
                                      const Text('AI difficulty',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800)),
                                      const Spacer(),
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.08),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white24)),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 20,
                                          icon: const Icon(Icons.close,
                                              color: Colors.white70),
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (int lvl = 1; lvl <= 7; lvl++)
                                        _aiLevelChoiceTile(
                                          selected: tempLevel == lvl,
                                          label: AiBelt.nameFor(lvl),
                                          dot: AiBelt.colorFor(lvl),
                                          onTap: () => setState(() {
                                            tempLevel = lvl;
                                          }),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                Colors.white.withOpacity(0.08),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                side: const BorderSide(
                                                    color: Colors.white24)),
                                            textStyle: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.2),
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await controller
                                                .setAiLevel(tempLevel);
                                            if (context.mounted)
                                              Navigator.of(ctx).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.brandGold,
                                            foregroundColor:
                                                const Color(0xFF2B221D),
                                            shadowColor: Colors.black54,
                                            elevation: 4,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            textStyle: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.2),
                                          ),
                                          child: const Text('Confirm'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _aiLevelChoiceTile(
      {required bool selected,
      required String label,
      required Color dot,
      required VoidCallback onTap}) {
    final bg =
        selected ? Colors.white.withOpacity(0.12) : AppColors.dialogFieldBg;
    final border = selected ? AppColors.brandGold : Colors.white12;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: dot, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Results dialog
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
                child: ResultsCard(controller: controller),
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
      line2 = const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text('Draw game: your total remains the same.',
            textAlign: TextAlign.right,
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
      );
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

    // Helper builders
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
            const Text('Final board view',
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

// Curtains reveal animation over the game board after loading a saved game
Future<void> _showCurtainsRevealOverGame(BuildContext context) async {
  const duration = Duration(milliseconds: 650);
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Curtains',
    barrierColor: Colors.transparent,
    transitionDuration: duration,
    pageBuilder: (ctx, a1, a2) {
      Future.delayed(duration, () {
        if (Navigator.of(ctx).canPop()) {
          Navigator.of(ctx).pop();
        }
      });
      return const SizedBox.shrink();
    },
    transitionBuilder: (ctx, anim, secondary, child) {
      final curved =
          CurvedAnimation(parent: anim, curve: Curves.easeInOutCubic);
      final size = MediaQuery.of(ctx).size;
      final halfW = size.width / 2;
      return Stack(
        children: [
          // Left curtain
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: Transform.translate(
                    offset: Offset(-halfW * curved.value, 0),
                    child: Container(color: Colors.black87),
                  ),
                ),
                Expanded(
                  child: Transform.translate(
                    offset: Offset(halfW * curved.value, 0),
                    child: Container(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
