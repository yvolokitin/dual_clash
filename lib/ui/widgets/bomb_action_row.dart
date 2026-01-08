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
    final enabled = controller.canPlaceBomb;
    final armed = controller.canActivateAnyBomb;
    final active = controller.bombMode;
    final accent = armed ? const Color(0xFFFFC34A) : Colors.white70;
    final hint = controller.bombActionHint;
    final canDrag = controller.canPlaceBomb;
    final isSelected = enabled && (active || controller.bombDragActive);
    final borderColor = isSelected ? const Color(0xFFFFC34A) : Colors.transparent;
    final isCooldown = controller.isBombCooldownVisual;
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
              isCooldown: isCooldown,
              canDrag: canDrag,
              onPressed: () {
                if (!enabled) return;
                controller.toggleBombMode();
              },
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
  final bool isCooldown;
  final bool canDrag;
  final VoidCallback? onPressed;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnd;

  const _BombDraggable({
    required this.enabled,
    required this.armed,
    required this.active,
    required this.accent,
    required this.isCooldown,
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
      isCooldown: isCooldown,
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
          isCooldown: isCooldown,
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
  final bool isCooldown;
  final VoidCallback? onPressed;

  const _BombButton({
    required this.enabled,
    required this.armed,
    required this.active,
    required this.accent,
    required this.isCooldown,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const baseColor = Colors.transparent;
    const borderColor = Colors.transparent;
    const iconSize = 40.0;
    final icon = Image.asset(
      'assets/icons/bomb.png',
      width: iconSize,
      height: iconSize,
      fit: BoxFit.contain,
    );
    final iconWidget = isCooldown
        ? ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            child: Opacity(opacity: 0.65, child: icon),
          )
        : icon;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 0,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: 'Bomb',
        iconSize: iconSize,
        icon: iconWidget,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(4),
        ),
      ),
    );
  }
}
