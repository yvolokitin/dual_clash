import 'dart:math' as math;

import 'package:flutter/material.dart';

class MenuTile extends StatefulWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool showLabel;
  final bool transparentBackground;
  final bool spinOnTap;
  final VoidCallback? onSpinStart;
  const MenuTile({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onTap,
    required this.color,
    this.showLabel = true,
    this.transparentBackground = false,
    this.spinOnTap = false,
    this.onSpinStart,
  });

  @override
  State<MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<MenuTile> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _spinController;
  late final Animation<double> _spinAnimation;

  Color _darken(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color _lighten(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static const _pressDuration = Duration(milliseconds: 120);
  static const _hoverDuration = Duration(milliseconds: 220);
  static const _spinDuration = Duration(milliseconds: 520);

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: _spinDuration);
    _spinAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.spinOnTap) {
      if (_spinController.isAnimating) return;
      widget.onSpinStart?.call();
      await _spinController.forward(from: 0);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final outerRadius = BorderRadius.circular(16);
    final innerRadius = BorderRadius.circular(13);
    final Color base = widget.color.withOpacity(1.0);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _darken(base),
        _lighten(base),
      ],
    );
    final bool transparentBackground = widget.transparentBackground;

    // Entire tile scales a bit on press to mimic a button press
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: _pressDuration,
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          onHover: (h) => setState(() => _hovered = h),
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: outerRadius,
          child: Container(
            decoration: BoxDecoration(
              gradient: transparentBackground ? null : gradient,
              borderRadius: outerRadius,
              boxShadow: transparentBackground
                  ? null
                  : const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            padding: transparentBackground
                ? EdgeInsets.zero
                : const EdgeInsets.all(3), // 3px gradient border
            child: Container(
              decoration: BoxDecoration(
                color: transparentBackground
                    ? Colors.transparent
                    : widget.color.withOpacity(0.9),
                borderRadius: innerRadius,
              ),
              padding: transparentBackground
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: ClipRect(
                        child: AnimatedBuilder(
                          animation: _spinAnimation,
                          builder: (context, child) {
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(_spinAnimation.value),
                              child: child,
                            );
                          },
                          child: AnimatedScale(
                            scale: _hovered ? 1.05 : 1.0,
                            duration: _hoverDuration,
                            curve: Curves.easeOutCubic,
                            child: AnimatedRotation(
                              turns: _hovered ? (5 / 360) : 0,
                              duration: _hoverDuration,
                              curve: Curves.easeOutCubic,
                              child: Image.asset(
                                widget.imagePath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.showLabel) ...[
                    const SizedBox(height: 6),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
