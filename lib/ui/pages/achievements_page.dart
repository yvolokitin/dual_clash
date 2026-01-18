import 'dart:ui' as ui;

import 'package:dual_clash/core/localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../logic/game_controller.dart';

Widget _beltTile(String name, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color, width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                fontSize: 12)),
      ],
    ),
  );
}

Widget beltsGridWidget(Set<String> badges) {
  final l10n = appLocalizations();
  final achievedLevels = <int>[
    for (int lvl = 1; lvl <= 7; lvl++)
      if (badges.contains('Beat AI L$lvl')) lvl
  ];
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.dialogFieldBg.withOpacity(0.6),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white24, width: 1),
    ),
    child: achievedLevels.isEmpty
        ? Text(l10n?.noBeltsEarnedYetMessage ?? 'No belts earned yet.',
            style: const TextStyle(color: Colors.white54))
        : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final lvl in achievedLevels)
                _beltTile(
                    l10n == null ? AiBelt.nameFor(lvl) : aiBeltName(l10n, lvl),
                    AiBelt.colorFor(lvl)),
            ],
          ),
  );
}

class AchievementsDialog extends StatelessWidget {
  final GameController controller;
  const AchievementsDialog({super.key, required this.controller});

  Widget _achChip(String text, bool achieved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: achieved
            ? Colors.lightGreenAccent.withOpacity(0.18)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: achieved ? Colors.lightGreenAccent : Colors.white24,
            width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Icon(achieved ? Icons.check : Icons.radio_button_unchecked,
              color: achieved ? Colors.lightGreenAccent : Colors.white38,
              size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = context.l10n;
    final bool isMobilePlatform = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final bool isMobileFullscreen = isMobilePlatform;
    final bg = AppColors.bg;
    final EdgeInsets dialogInsetPadding = isMobileFullscreen
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(
            horizontal: size.width * 0.1, vertical: size.height * 0.1);
    final BorderRadius dialogRadius =
        BorderRadius.circular(isMobileFullscreen ? 0 : 22);
    final EdgeInsets contentPadding =
        const EdgeInsets.fromLTRB(18, 20, 18, 18);
    return Dialog(
      insetPadding: dialogInsetPadding,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: dialogRadius),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: dialogRadius,
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
            maxWidth: isMobileFullscreen ? size.width : size.width * 0.8,
            maxHeight: isMobileFullscreen ? size.height : size.height * 0.8,
            minWidth: isMobileFullscreen ? size.width : 0,
            minHeight: isMobileFullscreen ? size.height : 0,
          ),
          child: SafeArea(
            top: isMobileFullscreen,
            bottom: isMobileFullscreen,
            child: Padding(
              padding: contentPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Text(l10n.achievementsTitle,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dialogTitle,
                              letterSpacing: 0.2)),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1)),
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.beltsTitle,
                              style: const TextStyle(
                                  color: AppColors.dialogSubtitle,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2)),
                          const SizedBox(height: 8),
                          beltsGridWidget(controller.badges),
                          const SizedBox(height: 16),
                          Text(l10n.achievementsTitle,
                              style: const TextStyle(
                                  color: AppColors.dialogSubtitle,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _achChip(l10n.achievementFullRow,
                                  controller.achievedRedRow),
                              _achChip(
                                  l10n.achievementFullColumn,
                                  controller.achievedRedColumn),
                              _achChip(
                                  l10n.achievementDiagonal,
                                  controller.achievedRedDiagonal),
                              _achChip(l10n.achievement100GamePoints,
                                  controller.achievedGamePoints100),
                              _achChip(l10n.achievement1000GamePoints,
                                  controller.achievedGamePoints1000),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandGold,
                        foregroundColor: const Color(0xFF2B221D),
                        shadowColor: Colors.black54,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w800, letterSpacing: 0.2),
                      ),
                      child: Text(l10n.commonClose),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showAnimatedAchievementsDialog(
    {required BuildContext context, required GameController controller}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.achievementsTitle,
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic);
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
                child: AchievementsDialog(controller: controller),
              ),
            ),
          ),
        ],
      );
    },
  );
}
