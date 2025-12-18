import 'package:flutter/material.dart';
import 'package:two_touch_game_flutter/models/cell_state.dart';
import 'package:two_touch_game_flutter/ui/styles/text_styles.dart';

/// A small pill that shows the last move's point delta and who caused it.
/// Positive (green) for Player (red), negative (red) for AI (blue).
class LivePointsChip extends StatelessWidget {
  final int points;
  final CellState? by; // null means neutral/no change
  const LivePointsChip({super.key, required this.points, required this.by});

  @override
  Widget build(BuildContext context) {
    final bool isRed = by == CellState.red;
    final bool isBlue = by == CellState.blue;
    final Color bg = Colors.white.withOpacity(0.08);
    final Color border = Colors.white24;
    Color textColor;
    String sign;
    if (!isRed && !isBlue) {
      textColor = Colors.white70;
      sign = '';
    } else if (points >= 0) {
      textColor = isRed ? Colors.lightGreenAccent : Colors.white70;
      sign = points > 0 ? '+' : '';
    } else {
      textColor = isBlue ? Colors.redAccent : Colors.white70;
      sign = '';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, anim) {
          final slide = Tween<Offset>(
            begin: Offset(0, points > 0 ? 0.3 : (points < 0 ? -0.3 : 0.0)),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: Text(
          by == null ? '0' : '$sign$points',
          key: ValueKey('${by?.index ?? -1}:$points'),
          style: AppTextStyles.chip.copyWith(color: textColor),
        ),
      ),
    );
  }
}
