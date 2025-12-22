import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:dual_clash/ui/widgets/save_game_card.dart';

/// Shows the animated Save Game dialog with soft blur, fade and scale
/// transitions, wrapping the universal SaveGameCard.
Future<void> showAnimatedSaveGameDialog({
  required BuildContext context,
  required String initialName,
  required ValueChanged<String> onSave,
  String title = 'Save game',
  String nameLabel = 'Name for this save',
  String saveButtonLabel = 'Save',
  String cancelButtonLabel = 'Cancel',
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Save Game',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
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
                  onSave: onSave,
                  nameLabel: nameLabel,
                  saveButtonLabel: saveButtonLabel,
                  cancelButtonLabel: cancelButtonLabel,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
