import 'package:flutter/material.dart';
import '../../logic/game_controller.dart';

class BombActionRow extends StatelessWidget {
  final GameController controller;
  final double? boardWidth;

  const BombActionRow({
    super.key,
    required this.controller,
    this.boardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = controller.bombActionEnabled;
    final armed = controller.canActivateAnyBomb;
    final active = controller.bombMode;
    final accent = armed ? const Color(0xFFFFC34A) : Colors.white70;
    return SizedBox(
      width: boardWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BombButton(
            enabled: enabled,
            armed: armed,
            active: active,
            accent: accent,
            onPressed: enabled ? controller.toggleBombMode : null,
          ),
        ],
      ),
    );
  }
}

class _BombButton extends StatelessWidget {
  final bool enabled;
  final bool armed;
  final bool active;
  final Color accent;
  final VoidCallback? onPressed;

  const _BombButton({
    required this.enabled,
    required this.armed,
    required this.active,
    required this.accent,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = enabled ? const Color(0xFF2A2F45) : const Color(0xFF1B1F2E);
    final borderColor = enabled ? accent : Colors.white24;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: armed ? 2 : 1,
        ),
        boxShadow: armed
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: 'Bomb',
        icon: Image.asset(
          'assets/icons/star.png',
          width: 22,
          height: 22,
          fit: BoxFit.contain,
          color: enabled ? null : Colors.black26,
          colorBlendMode: enabled ? BlendMode.srcIn : BlendMode.srcIn,
        ),
        style: IconButton.styleFrom(
          backgroundColor: active ? accent.withOpacity(0.25) : Colors.transparent,
          padding: const EdgeInsets.all(10),
        ),
      ),
    );
  }
}
