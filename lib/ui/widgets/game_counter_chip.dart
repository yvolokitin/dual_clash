import 'package:flutter/material.dart';
import 'package:dual_clash/ui/styles/text_styles.dart';

/// Displays the current accumulated game points as a small pill chip.
/// Extracted from GamePage to make it reusable across pages.
class GameCounterChip extends StatelessWidget {
  final int points;
  final Color? borderColor;
  final double? borderWidth;
  final double? itemSize;
  const GameCounterChip(
      {super.key, required this.points, this.borderColor, this.borderWidth, this.itemSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
            color: borderColor ?? Colors.white24, width: borderWidth ?? 1),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/points-removebg.png',
              width: itemSize ?? 22, height: itemSize ?? 22),
          const SizedBox(width: 6),
          Text(
            '$points',
            style: AppTextStyles.chip.copyWith(
              color: const Color(0xFFE5AD3A),
              fontSize: itemSize ?? 22,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
