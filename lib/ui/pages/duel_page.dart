import 'package:flutter/material.dart';
import 'dart:ui' as ui; // for potential future effects
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/core/constants.dart';
import 'package:dual_clash/models/cell_state.dart';
import 'package:dual_clash/logic/rules_engine.dart';
import 'package:dual_clash/ui/widgets/board_widget.dart';
import 'package:dual_clash/ui/dialogs/results_dialog.dart' as results;

class DuelPage extends StatefulWidget {
  final GameController controller;
  const DuelPage({super.key, required this.controller});

  @override
  State<DuelPage> createState() => _DuelPageState();
}

class _DuelPageState extends State<DuelPage> {
  @override
  void initState() {
    super.initState();
    // Enable human vs human and start a fresh game
    widget.controller.humanVsHuman = true;
    // Ensure AI doesn't schedule at start
    widget.controller.newGame();
  }

  @override
  void dispose() {
    // Restore default mode when leaving Duel page
    widget.controller.humanVsHuman = false;
    super.dispose();
  }

  void _maybeShowResultsDialog(BuildContext context) {
    final c = widget.controller;
    if (c.gameOver && !c.resultsShown) {
      c.resultsShown = true; // guard
      // Small delay so the user can see the border animation
      Future.delayed(Duration(milliseconds: c.winnerBorderAnimMs), () {
        if (!context.mounted) return;
        results.showAnimatedResultsDialog(context: context, controller: c);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final redBase = controller.scoreRedBase();
        final blueBase = controller.scoreBlueBase();
        final neutralsCount = RulesEngine.countOf(controller.board, CellState.neutral);

        // Match score row icon size to exact board cell image size, scaled same as GamePage
        const double _boardBorderPx = 3.0; // keep in sync with BoardWidget
        final double _gridSpacingPx = K.n == 9 ? 2.0 : 0.0; // keep in sync with BoardWidget
        final bool _hasBoardSize = controller.boardPixelSize > 0;
        final double _innerBoardSide =
            _hasBoardSize ? controller.boardPixelSize - 2 * _boardBorderPx : 0;
        final double scoreItemSize = (_hasBoardSize
                ? (_innerBoardSide - _gridSpacingPx * (K.n - 1)) / K.n
                : 22.0) *
            0.595; // keep consistent with GamePage

        // Score-row text style: same height as icon, bold, and gold color
        final textStyle = TextStyle(
          fontSize: scoreItemSize,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFE5AD3A),
        );

        _maybeShowResultsDialog(context);

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                // Score row (no game points, only back to main menu)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 14.0, left: 16.0, right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: controller.boardPixelSize > 0 ? controller.boardPixelSize : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: main menu button pops back directly
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Image.asset('assets/icons/main_menu.png',
                                    width: scoreItemSize, height: scoreItemSize),
                                tooltip: 'Main Menu',
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                          // Right side: counts only (number -> icon) for red, grey, blue
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$redBase', style: textStyle),
                              const SizedBox(width: 6),
                              Image.asset('assets/icons/player_red.png',
                                  width: scoreItemSize, height: scoreItemSize),
                              const SizedBox(width: 18),
                              Text('$neutralsCount', style: textStyle),
                              const SizedBox(width: 6),
                              Image.asset('assets/icons/player_grey.png',
                                  width: scoreItemSize, height: scoreItemSize),
                              const SizedBox(width: 18),
                              Text('$blueBase', style: textStyle),
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
                      ],
                    ),
                  ),
                ),
                // No simulate/statistics/undo row in duel mode
              ],
            ),
          ),
        );
      },
    );
  }
}
