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
                        children: const [
                          _SectionTitle('Goal'),
                          _BodyText(
                              'Fill the 9×9 board by taking turns. You are Red, the AI is Blue. Grey tiles are neutral.'),
                          SizedBox(height: 12),
                          _SectionTitle('Turns & Actions'),
                          _BodyText(
                              'Tap an empty cell to place your color. After your move, the AI takes its turn. The starting player can be changed in Settings.'),
                          _BodyText(
                              'Tap one of your own pieces to preview a “blow.” Tap the same piece again to detonate it. The detonated cell and any orthogonal non-empty neighbors are removed.'),
                          _BodyText(
                              'Tap a Grey (neutral) tile to preview all Grey tiles. Tap again to drop all Grey tiles off the board at once.'),
                          SizedBox(height: 12),
                          _SectionTitle('Placement Effects'),
                          _BodyText(
                              'When you place a piece, any orthogonal opponent neighbor becomes Grey. Any orthogonal Grey neighbor becomes your color.'),
                          SizedBox(height: 12),
                          _SectionTitle('Scoring (Final Totals)'),
                          _BodyText(
                              'Base Score: number of tiles of your color when the game ends.'),
                          _BodyText(
                              'Bonus: +50 for every full row or full column filled with one color (counted separately for each color).'),
                          _BodyText('Total Score: Base Score + Bonus.'),
                          SizedBox(height: 12),
                          _SectionTitle('Scoring (In-Game Points for Red)'),
                          _BodyText(
                              '+1 per placement, +2 extra if placed in a corner, +2 for each Blue turned Grey, +3 for each Grey turned Red.'),
                          _BodyText(
                              'Blowing up pieces and Grey drops give 0 points. Full Red rows/columns add +50 each at game end.'),
                          _BodyText(
                              'Your trophy total is awarded after the game ends: win = full Red game points, draw = half, loss = 0.'),
                          SizedBox(height: 12),
                          _SectionTitle('Winning'),
                          _BodyText(
                              'When the board is full, the game ends. The highest Total Score wins. Grey counts too—if Grey has the biggest total, you lose even if Blue is lower. Draws are possible.'),
                          SizedBox(height: 12),
                          _SectionTitle('Duel Mode vs Game Challenge'),
                          _BodyText(
                              'Game Challenge is you vs the AI (Red vs Blue) with points, bonuses, and trophies.'),
                          _BodyText(
                              'Duel Mode is local multiplayer: 2–4 human players take turns (Red/Blue/Yellow/Green). There is no AI, trophies, or bonus points; the winner is the player with the most tiles on the board when it fills.'),
                          SizedBox(height: 12),
                          _SectionTitle('AI Level'),
                          _BodyText(
                              'Choose the AI difficulty in Settings (1–7). Higher levels think further ahead but take longer.'),
                          SizedBox(height: 12),
                          _SectionTitle('History & Profile'),
                          _BodyText(
                              'Finished games are saved in History with all details.'),
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
