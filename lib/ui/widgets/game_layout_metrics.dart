import 'dart:io';

import 'package:dual_clash/core/constants.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Layout values derived from the board size and platform characteristics.
///
/// Centralizing these calculations keeps the UI consistent across game modes
/// and avoids accidental drift from the board sizing logic.
class GameLayoutMetrics {
  final bool isMobile;
  final double boardCellSize;
  final double scoreItemSize;
  final double scoreTopPadding;
  final double menuIconSize;
  final double pointsItemSize;
  final TextStyle scoreTextStyle;
  final TextStyle pointsTextStyle;
  final double? boardWidth;

  const GameLayoutMetrics({
    required this.isMobile,
    required this.boardCellSize,
    required this.scoreItemSize,
    required this.scoreTopPadding,
    required this.menuIconSize,
    required this.pointsItemSize,
    required this.scoreTextStyle,
    required this.pointsTextStyle,
    required this.boardWidth,
  });

  factory GameLayoutMetrics.from(
      BuildContext context, GameController controller) {
    final bool isMobile =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    final bool isTallMobile =
        isMobile && MediaQuery.of(context).size.height > 1200;

    // Match score row icon sizes relative to exact board cell size.
    // Keep the border and grid spacing in sync with BoardWidget.
    const double boardBorderPx = 3.0;
    const double gridSpacingPx = 2.0;
    final bool hasBoardSize = controller.boardPixelSize > 0;
    final double innerBoardSide =
        hasBoardSize ? controller.boardPixelSize - 2 * boardBorderPx : 0;
    final double boardCellSize = hasBoardSize
        ? (innerBoardSide - gridSpacingPx * (K.n - 1)) / K.n
        : 22.0;
    final double scoreItemSize = boardCellSize * 0.595;
    final double scoreFontScale = isTallMobile ? 0.9 : 1.0;
    final double scoreTopPadding = isTallMobile ? 20.0 : 0.0;

    final scoreTextStyle = TextStyle(
      fontSize: scoreItemSize * scoreFontScale,
      height: 1.0,
      fontWeight: FontWeight.w800,
      color: const Color(0xFFE5AD3A),
    );

    final double menuIconSize =
        isMobile ? boardCellSize * 1.2 : boardCellSize;
    final double pointsItemSize =
        isMobile ? scoreItemSize * 1.2 : scoreItemSize;

    final TextStyle pointsTextStyle = isMobile
        ? scoreTextStyle.copyWith(
            fontSize: scoreTextStyle.fontSize! * 1.2,
            fontWeight: FontWeight.w900,
          )
        : scoreTextStyle;

    return GameLayoutMetrics(
      isMobile: isMobile,
      boardCellSize: boardCellSize,
      scoreItemSize: scoreItemSize,
      scoreTopPadding: scoreTopPadding,
      menuIconSize: menuIconSize,
      pointsItemSize: pointsItemSize,
      scoreTextStyle: scoreTextStyle,
      pointsTextStyle: pointsTextStyle,
      boardWidth: hasBoardSize ? controller.boardPixelSize : null,
    );
  }
}
