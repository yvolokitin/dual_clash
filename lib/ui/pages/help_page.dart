import 'dart:ui' as ui;

import 'package:dual_clash/core/localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dual_clash/ui/widgets/dialog_header.dart';
import 'package:dual_clash/ui/widgets/responsive_dialog.dart';
import '../../logic/game_controller.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';

class HelpDialog extends StatelessWidget {
  final GameController controller;
  const HelpDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = context.l10n;
    final scale = dialogTextScale(context);
    final bool isMobilePlatform = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final bool isMobileFullscreen = isMobilePlatform;
    final bg = AppColors.bg;
    final boardLabel = '${K.n}x${K.n}';
    return ResponsiveDialog(
      insetPadding: isMobileFullscreen
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: size.width * 0.1, vertical: size.height * 0.1),
      borderRadius: BorderRadius.circular(isMobileFullscreen ? 0 : 22),
      fullscreen: isMobileFullscreen,
      forceHeight: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobileFullscreen ? 0 : 22),
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
        child: Padding(
          padding: scaleInsets(const EdgeInsets.all(18), scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DialogHeader(
                title: l10n.helpTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
                onClose: () => Navigator.of(context).pop(),
              ),
              SizedBox(height: 12 * scale),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(l10n.helpGoalTitle),
                      _BodyText(l10n.helpGoalBody(boardLabel)),
                      SizedBox(height: 12 * scale),
                      _SectionTitle(l10n.helpTurnsTitle),
                      _BodyText(l10n.helpTurnsBody),
                      SizedBox(height: 12 * scale),
                      _SectionTitle(l10n.helpScoringTitle),
                      _BodyText(l10n.helpScoringBase),
                      _BodyText(l10n.helpScoringBonus),
                      _BodyText(l10n.helpScoringTotal),
                      _BodyText(l10n.helpScoringEarning),
                      _BodyText(l10n.helpScoringCumulative),
                      SizedBox(height: 12 * scale),
                      _SectionTitle(l10n.helpWinningTitle),
                      _BodyText(l10n.helpWinningBody),
                      SizedBox(height: 12 * scale),
                      _SectionTitle(l10n.helpAiLevelTitle),
                      _BodyText(l10n.helpAiLevelBody),
                      SizedBox(height: 12 * scale),
                      _SectionTitle(l10n.helpHistoryProfileTitle),
                      _BodyText(l10n.helpHistoryProfileBody),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12 * scale),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGold,
                    foregroundColor: const Color(0xFF2B221D),
                    shadowColor: Colors.black54,
                    elevation: 4,
                    padding: EdgeInsets.symmetric(
                        horizontal: 20 * scale, vertical: 12 * scale),
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
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.dialogTitle,
            fontSize: 16,
            fontWeight: FontWeight.w800));
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70,
              height: 1.35,
              fontWeight: FontWeight.w600)),
    );
  }
}

Future<void> showAnimatedHelpDialog(
    {required BuildContext context, required GameController controller}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.helpTitle,
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
                child: HelpDialog(controller: controller),
              ),
            ),
          ),
        ],
      );
    },
  );
}
