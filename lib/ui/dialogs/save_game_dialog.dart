import 'dart:ui' as ui;

import 'package:dual_clash/core/localization.dart';
import 'package:dual_clash/ui/widgets/save_game_card.dart';
import 'package:flutter/material.dart';
import 'package:dual_clash/core/platforms.dart';

/// Shows the animated Save Game dialog with soft blur, fade and scale
/// transitions, wrapping the universal SaveGameCard.
Future<void> showAnimatedSaveGameDialog({
  required BuildContext context,
  required String initialName,
  required ValueChanged<String> onSave,
  required String title,
  required String nameLabel,
  required String nameHint,
  required String saveButtonLabel,
  required String cancelButtonLabel,
}) {
  bool closing = false;
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.saveGameBarrierLabel,
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      void handleSave(String name) async {
        if (closing) return;
        closing = true;
        await Future<void>.sync(() => onSave(name));
        if (Navigator.of(ctx, rootNavigator: true).canPop()) {
          Navigator.of(ctx, rootNavigator: true).pop();
        }
      }

      return Stack(
        children: [
          // Soft blur backdrop
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
                child: SaveGameCard(
                  title: title,
                  initialName: initialName,
                  onSave: handleSave,
                  nameLabel: nameLabel,
                  nameHint: nameHint,
                  saveButtonLabel: saveButtonLabel,
                  cancelButtonLabel: cancelButtonLabel,
                  infoNote: isWeb ? context.l10n.webSaveGameNote : null,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
