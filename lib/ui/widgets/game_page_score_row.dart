import 'package:dual_clash/core/localization.dart';
import 'package:dual_clash/ui/widgets/hover_scale_box.dart';
import 'package:flutter/material.dart';

/// Scoreboard row above the game board, shared between mobile/desktop layouts.
class GamePageScoreRow extends StatelessWidget {
  final bool isMobile;
  final double? boardWidth;
  final double scoreTopPadding;
  final double menuIconSize;
  final double scoreItemSize;
  final double pointsItemSize;
  final double boardCellSize;
  final TextStyle scoreTextStyle;
  final TextStyle pointsTextStyle;
  final int redBase;
  final int neutralCount;
  final int blueBase;
  final int redGamePoints;
  final bool showLeaderShadow;
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenStatistics;
  final VoidCallback onOpenAiSelector;

  const GamePageScoreRow({
    super.key,
    required this.isMobile,
    required this.boardWidth,
    required this.scoreTopPadding,
    required this.menuIconSize,
    required this.scoreItemSize,
    required this.pointsItemSize,
    required this.boardCellSize,
    required this.scoreTextStyle,
    required this.pointsTextStyle,
    required this.redBase,
    required this.neutralCount,
    required this.blueBase,
    required this.redGamePoints,
    required this.showLeaderShadow,
    required this.onOpenMenu,
    required this.onOpenStatistics,
    required this.onOpenAiSelector,
  });

  Widget _playerIcon({
    required String asset,
    required double size,
    required bool isLeader,
  }) {
    if (!isLeader) {
      return Image.asset(asset, width: size, height: size);
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD166).withOpacity(0.9),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Image.asset(asset, width: size, height: size),
    );
  }

  double _crownHeight(double size) => size * 0.4;

  Widget _playerIconWithCrown({
    required String asset,
    required double size,
    required bool isLeader,
  }) {
    final double crownHeight = _crownHeight(size);
    final double crownGap = 4;
    return SizedBox(
      width: size,
      height: size + crownHeight + crownGap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isLeader ? 1 : 0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: isLeader ? 1 : 0.9,
                child: SizedBox(
                  width: size,
                  height: crownHeight,
                  child: Image.asset(
                    'assets/icons/crown.png',
                    width: size,
                    height: crownHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: _playerIcon(asset: asset, size: size, isLeader: isLeader),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int maxScore = [redBase, neutralCount, blueBase].reduce(
      (value, element) => value > element ? value : element,
    );
    final bool highlightRed = showLeaderShadow &&
        redBase == maxScore &&
        redBase > neutralCount &&
        redBase > blueBase;
    final bool highlightNeutral = showLeaderShadow &&
        neutralCount == maxScore &&
        neutralCount > redBase &&
        neutralCount > blueBase;
    final bool highlightBlue = showLeaderShadow &&
        blueBase == maxScore &&
        blueBase > redBase &&
        blueBase > neutralCount;
    final double playerIconSize =
        isMobile ? boardCellSize * 0.8 : scoreItemSize;
    final double playerIconStackSize =
        playerIconSize + _crownHeight(playerIconSize) + 4;
    Widget scoreCount(String value) {
      return SizedBox(
        height: playerIconStackSize,
        child: Center(child: Text(value, style: scoreTextStyle)),
      );
    }

    final Widget playerCountsRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        scoreCount('$redBase'),
        const SizedBox(width: 6),
        _playerIconWithCrown(
          asset: 'assets/icons/player_red.png',
          size: playerIconSize,
          isLeader: highlightRed,
        ),
        const SizedBox(width: 18),
        scoreCount('$neutralCount'),
        const SizedBox(width: 6),
        _playerIconWithCrown(
          asset: 'assets/icons/player_grey.png',
          size: playerIconSize,
          isLeader: highlightNeutral,
        ),
        const SizedBox(width: 18),
        scoreCount('$blueBase'),
        const SizedBox(width: 6),
        HoverScaleBox(
          size: playerIconStackSize,
          onTap: onOpenAiSelector,
          child: _playerIconWithCrown(
            asset: 'assets/icons/player_blue.png',
            size: playerIconSize,
            isLeader: highlightBlue,
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 4.0 + scoreTopPadding,
        bottom: 14.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Center(
        child: SizedBox(
          width: boardWidth,
          child: isMobile
              ? Column(
                  key: const Key('score-row-mobile'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints.tightFor(
                            width: menuIconSize,
                            height: menuIconSize,
                          ),
                          icon: Image.asset(
                            'assets/icons/menu_pvai.png',
                            width: menuIconSize,
                            height: menuIconSize,
                          ),
                          tooltip: context.l10n.mainMenuTooltip,
                          onPressed: onOpenMenu,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: onOpenStatistics,
                              behavior: HitTestBehavior.opaque,
                              child: Image.asset(
                                'assets/icons/points-removebg.png',
                                width: pointsItemSize,
                                height: pointsItemSize,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: onOpenStatistics,
                              behavior: HitTestBehavior.opaque,
                              child: Text(
                                '$redGamePoints',
                                style: pointsTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Center(child: playerCountsRow),
                  ],
                )
              : Row(
                  key: const Key('score-row-desktop'),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints.tightFor(
                            width: menuIconSize,
                            height: menuIconSize,
                          ),
                          icon: Image.asset(
                            'assets/icons/menu_pvai.png',
                            width: menuIconSize,
                            height: menuIconSize,
                          ),
                          tooltip: context.l10n.mainMenuTooltip,
                          onPressed: onOpenMenu,
                        ),
                        const SizedBox(width: 8),
                        Image.asset('assets/icons/points-removebg.png',
                            width: scoreItemSize, height: scoreItemSize),
                        const SizedBox(width: 6),
                        Text('$redGamePoints', style: scoreTextStyle),
                      ],
                    ),
                    playerCountsRow,
                  ],
                ),
        ),
      ),
    );
  }
}
