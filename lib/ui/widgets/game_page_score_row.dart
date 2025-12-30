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
  final TextStyle scoreTextStyle;
  final TextStyle pointsTextStyle;
  final int redBase;
  final int neutralCount;
  final int blueBase;
  final int redGamePoints;
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
    required this.scoreTextStyle,
    required this.pointsTextStyle,
    required this.redBase,
    required this.neutralCount,
    required this.blueBase,
    required this.redGamePoints,
    required this.onOpenMenu,
    required this.onOpenStatistics,
    required this.onOpenAiSelector,
  });

  @override
  Widget build(BuildContext context) {
    final Widget playerCountsRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$redBase', style: scoreTextStyle),
        const SizedBox(width: 6),
        Image.asset('assets/icons/player_red.png',
            width: scoreItemSize, height: scoreItemSize),
        const SizedBox(width: 18),
        Text('$neutralCount', style: scoreTextStyle),
        const SizedBox(width: 6),
        Image.asset('assets/icons/player_grey.png',
            width: scoreItemSize, height: scoreItemSize),
        const SizedBox(width: 18),
        Text('$blueBase', style: scoreTextStyle),
        const SizedBox(width: 6),
        HoverScaleBox(
          size: scoreItemSize,
          onTap: onOpenAiSelector,
          child: Image.asset(
            'assets/icons/player_blue.png',
            width: scoreItemSize,
            height: scoreItemSize,
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
                          tooltip: 'Main Menu',
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
                    const SizedBox(height: 10),
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
                          tooltip: 'Main Menu',
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
