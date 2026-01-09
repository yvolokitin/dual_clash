import 'package:dual_clash/core/constants.dart';
import 'package:dual_clash/core/localization.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:flutter/material.dart';

/// Displays the current AI difficulty belt directly below the board.
class GamePageAiLevelRow extends StatelessWidget {
  final GameController controller;
  final double boardCellSize;
  final double? boardWidth;
  final TextStyle labelStyle;
  final bool isMobile;

  const GamePageAiLevelRow({
    super.key,
    required this.controller,
    required this.boardCellSize,
    required this.boardWidth,
    required this.labelStyle,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = labelStyle.copyWith(fontWeight: FontWeight.w700);
    final l10n = context.l10n;
    final bool isTablet =
        isMobile && MediaQuery.of(context).size.shortestSide >= 600;
    final double labelFontSize =
        boardCellSize * 0.288 * (isTablet ? 0.85 : 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: isMobile ? 20 : 14),
        SizedBox(
          height: boardCellSize * 0.36,
          child: Center(
            child: SizedBox(
              width: boardWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.currentAiLevelLabel,
                    style: baseStyle.copyWith(
                      fontSize: labelFontSize,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: boardCellSize * 0.1),
                  Image.asset(
                    AiBelt.assetFor(controller.aiLevel),
                    height: boardCellSize * 0.36,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: boardCellSize * 0.1),
                  Text(
                    l10n.aiLevelDisplay(
                      aiBeltName(l10n, controller.aiLevel),
                      controller.aiLevel,
                    ),
                    style: baseStyle.copyWith(
                      fontSize: labelFontSize,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
