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
    final hint = controller.bombActionHint;
    final canDrag = controller.canPlaceBomb;
    final isSelected = active || controller.bombDragActive;
    final borderColor = isSelected ? const Color(0xFFFFC34A) : Colors.transparent;
    return SizedBox(
      width: boardWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: _BombDraggable(
              enabled: enabled,
              armed: armed,
              active: active,
              accent: accent,
              canDrag: canDrag,
              onPressed: enabled ? controller.toggleBombMode : null,
              onDragStarted: controller.startBombDrag,
              onDragEnd: controller.endBombDrag,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hint ?? 'Drag or tap the bomb to use it.',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

class _BombDraggable extends StatelessWidget {
  final bool enabled;
  final bool armed;
  final bool active;
  final Color accent;
  final bool canDrag;
  final VoidCallback? onPressed;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnd;

  const _BombDraggable({
    required this.enabled,
    required this.armed,
    required this.active,
    required this.accent,
    required this.canDrag,
    this.onPressed,
    required this.onDragStarted,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final button = _BombButton(
      enabled: enabled,
      armed: armed,
      active: active,
      accent: accent,
      onPressed: onPressed,
    );
    if (!canDrag) {
      return button;
    }
    return Draggable<bool>(
      data: true,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd(),
      onDraggableCanceled: (_, __) => onDragEnd(),
      feedback: Material(
        color: Colors.transparent,
        child: _BombButton(
          enabled: true,
          armed: armed,
          active: active,
          accent: accent,
          onPressed: null,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.6,
        child: button,
      ),
      child: button,
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
          color: enabled ? null : Colors.grey,
          colorBlendMode: BlendMode.srcIn,
        ),
        style: IconButton.styleFrom(
          backgroundColor: active ? accent.withOpacity(0.25) : Colors.transparent,
          padding: const EdgeInsets.all(10),
        ),
      ),
    );
  }
}
