import 'package:flutter/material.dart';

class DialogCloseButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;

  const DialogCloseButton({
    super.key,
    required this.onPressed,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: size * 0.55,
        icon: const Icon(Icons.close, color: Colors.white70),
        onPressed: onPressed,
      ),
    );
  }
}

class DialogHeader extends StatelessWidget {
  final String title;
  final TextStyle? style;
  final VoidCallback onClose;

  const DialogHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 36),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            softWrap: true,
            style: style,
          ),
        ),
        DialogCloseButton(onPressed: onClose),
      ],
    );
  }
}
