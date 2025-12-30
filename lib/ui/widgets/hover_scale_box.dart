import 'package:flutter/material.dart';

/// Scales its child slightly on hover without changing layout constraints.
///
/// The widget keeps a fixed square footprint via [size], which prevents
/// surrounding widgets from reflowing when the hover animation is active.
class HoverScaleBox extends StatefulWidget {
  final double size;
  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;
  final Duration duration;

  const HoverScaleBox({
    super.key,
    required this.size,
    required this.child,
    this.onTap,
    this.hoverScale = 1.06,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<HoverScaleBox> createState() => _HoverScaleBoxState();
}

class _HoverScaleBoxState extends State<HoverScaleBox> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scaled = AnimatedScale(
      scale: _hovered ? widget.hoverScale : 1.0,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: widget.child,
    );

    final fixedBox = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Center(child: scaled),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ClipRect(child: fixedBox),
      ),
    );
  }
}
