import 'dart:ui' as ui;

import 'package:dual_clash/core/localization.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/ui/widgets/results_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Results dialog extracted from GamePage so it can be reused and maintained independently.
Future<void> showAnimatedResultsDialog({
  required BuildContext context,
  required GameController controller,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.resultsTitle,
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic);
      final bool isMobilePlatform = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS);
      final bool isMobileFullscreen = isMobilePlatform;
      final Alignment dialogAlignment =
          isMobileFullscreen ? Alignment.topCenter : Alignment.center;
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
          Align(
            alignment: dialogAlignment,
            child: FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                child: ResultsCard(controller: controller),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Show the results dialog once when the game ends.
void maybeShowResultsDialog({
  required BuildContext context,
  required GameController controller,
}) {
  if (controller.gameOver && !controller.resultsShown) {
    controller.resultsShown = true;
    Future.delayed(Duration(milliseconds: controller.winnerBorderAnimMs), () {
      if (!context.mounted) return;
      showAnimatedResultsDialog(context: context, controller: controller);
    });
  }
}
