import 'dart:ui' as ui;

import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/core/constants.dart';
import 'package:dual_clash/core/localization.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:flutter/material.dart';

/// Shows a dialog that lets the player choose the AI difficulty belt.
Future<void> showAiDifficultyDialog({
  required BuildContext context,
  required GameController controller,
}) async {
  int tempLevel = controller.aiLevel;
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.aiDifficultyTitle,
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
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                      constraints: const BoxConstraints(
                          maxWidth: 560, maxHeight: 520),
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
                                    Text(context.l10n.aiDifficultyTitle,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800)),
                                    const Spacer(),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.white24)),
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
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    for (int lvl = 1; lvl <= 7; lvl++)
                                      Tooltip(
                                        message: _aiLevelShortTip(lvl),
                                        child: _aiLevelChoiceTile(
                                          level: lvl,
                                          selected: tempLevel == lvl,
                                          onTap: () => setState(() {
                                            tempLevel = lvl;
                                          }),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _aiLevelShortTip(tempLevel),
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.2),
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
                                        child: Text(context.l10n.commonCancel),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await controller.setAiLevel(tempLevel);
                                          if (context.mounted) {
                                            Navigator.of(ctx).pop();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.brandGold,
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
                                        child: Text(context.l10n.commonConfirm),
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

Widget _aiLevelChoiceTile({
  required int level,
  required bool selected,
  required VoidCallback onTap,
}) {
  final l10n = appLocalizations();
  final String label = l10n == null
      ? AiBelt.nameFor(level)
      : aiBeltName(l10n, level);
  final String asset = AiBelt.assetFor(level);
  final Color border = selected ? AppColors.brandGold : Colors.white12;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 84,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.dialogFieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  height: 54,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.35),
                    ],
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _aiLevelShortTip(int lvl) {
  final l10n = appLocalizations();
  if (l10n == null) {
    return _aiLevelShortTipFallback(lvl);
  }
  switch (lvl) {
    case 1:
      return l10n.aiDifficultyTipBeginner;
    case 2:
      return l10n.aiDifficultyTipEasy;
    case 3:
      return l10n.aiDifficultyTipNormal;
    case 4:
      return l10n.aiDifficultyTipChallenging;
    case 5:
      return l10n.aiDifficultyTipHard;
    case 6:
      return l10n.aiDifficultyTipExpert;
    case 7:
      return l10n.aiDifficultyTipMaster;
    default:
      return l10n.aiDifficultyTipSelect;
  }
}

String _aiLevelShortTipFallback(int lvl) {
  switch (lvl) {
    case 1:
      return 'White — Beginner: makes random moves.';
    case 2:
      return 'Yellow — Easy: prefers immediate gains.';
    case 3:
      return 'Orange — Normal: greedy with basic positioning.';
    case 4:
      return 'Green — Challenging: shallow search with some foresight.';
    case 5:
      return 'Blue — Hard: deeper search with pruning.';
    case 6:
      return 'Brown — Expert: advanced pruning and caching.';
    case 7:
      return 'Black — Master: strongest and most calculating.';
    default:
      return 'Select a belt level.';
  }
}
