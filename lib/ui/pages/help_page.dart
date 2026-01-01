import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../logic/game_controller.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';

class HelpDialog extends StatelessWidget {
  final GameController controller;
  const HelpDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobilePlatform = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final bool isTabletDevice = isTablet(context);
    final bool isPhoneFullscreen = isMobilePlatform && !isTabletDevice;
    final bg = AppColors.bg;
    final boardLabel = '${K.n}x${K.n}';
    return Dialog(
      insetPadding: isPhoneFullscreen
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: size.width * 0.1, vertical: size.height * 0.1),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isPhoneFullscreen ? 0 : 22)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isPhoneFullscreen ? 0 : 22),
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
            maxWidth: isPhoneFullscreen ? size.width : size.width * 0.8,
            maxHeight: isPhoneFullscreen ? size.height : size.height * 0.8,
            minWidth: isPhoneFullscreen ? size.width : 0,
            minHeight: isPhoneFullscreen ? size.height : 0,
          ),
          child: SafeArea(
            top: isPhoneFullscreen,
            bottom: isPhoneFullscreen,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      const Text('How to Play',
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
                            border: Border.all(color: Colors.white24)),
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
                          const _SectionTitle('Goal'),
                          _BodyText(
                              'Fill the $boardLabel board by taking turns with the AI. You are Red, the AI is Blue. The player with the higher TOTAL score wins.'),
                          const SizedBox(height: 12),
                          const _SectionTitle('Turns & Placement'),
                          const _BodyText(
                              'Tap any empty cell to place your color. After your move, the AI places blue. The starting player can be changed in Settings.'),
                          const SizedBox(height: 12),
                          const _SectionTitle('Scoring'),
                          const _BodyText(
                              'Base Score: number of cells of your color on the board when the game ends.'),
                          const _BodyText(
                              'Bonus: +50 points for every full row or full column filled with your color.'),
                          const _BodyText('Total Score: Base Score + Bonus.'),
                          const _BodyText(
                              'Earning Points During Play (Red): +1 for each placement, +2 extra if placed in a corner, +2 for each Blue turned Neutral, +3 for each Neutral turned Red, +50 for each new full Red row/column.'),
                          const _BodyText(
                              'Your cumulative trophy counter only increases. Points are added after each finished game based on your Red Total. Opponent actions never reduce your cumulative total.'),
                          const SizedBox(height: 12),
                          const _SectionTitle('Winning'),
                          const _BodyText(
                              'When the board has no empty cells, the game ends. The player with the higher Total Score wins. Draws are possible.'),
                          const SizedBox(height: 12),
                          const _SectionTitle('AI Level'),
                          const _BodyText(
                              'Choose the AI difficulty in Settings (1–7). Higher levels think further ahead but take longer.'),
                          const SizedBox(height: 12),
                          const _SectionTitle('History & Profile'),
                          const _BodyText(
                              'Your finished games are saved in History with all details.'),
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
                      child: const Text('Close'),
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
    barrierLabel: 'Help',
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
