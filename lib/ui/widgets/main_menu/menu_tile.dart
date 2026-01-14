import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MenuTile extends StatefulWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool showLabel;
  final bool transparentBackground;
  const MenuTile({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onTap,
    required this.color,
    this.showLabel = true,
    this.transparentBackground = false,
  });

  @override
  State<MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<MenuTile> {
  bool _hovered = false;
  bool _pressed = false;

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

  @override
  Widget build(BuildContext context) {
    final bool isCompactIos =
        defaultTargetPlatform == TargetPlatform.iOS && MediaQuery.sizeOf(context).width < 800;
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
    final double imageScale = isCompactIos ? 1.0 : (_hovered ? 1.05 : 1.0);
    final double imageTurns = isCompactIos ? 0.0 : (_hovered ? (5 / 360) : 0);
    final double labelFontSize = isCompactIos ? 16 * 0.85 : 16;
    final double labelSpacing = isCompactIos ? 4 : 6;
    final int imageFlex = isCompactIos ? 6 : 1;
    final int labelFlex = isCompactIos ? 1 : 0;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: _pressDuration,
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
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
                    flex: imageFlex,
                    child: Center(
                      child: ClipRect(
                        child: AnimatedScale(
                          scale: imageScale,
                          duration: _hoverDuration,
                          curve: Curves.easeOutCubic,
                          child: AnimatedRotation(
                            turns: imageTurns,
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
                  if (widget.showLabel)
                    labelFlex > 0
                        ? Expanded(
                            flex: labelFlex,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: labelSpacing),
                                Text(
                                  widget.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: labelFontSize,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              SizedBox(height: labelSpacing),
                              Text(
                                widget.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: labelFontSize,
                                ),
                              ),
                            ],
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
