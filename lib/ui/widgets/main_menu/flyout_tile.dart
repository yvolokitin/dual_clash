import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/colors.dart';

class FlyoutTile extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool disabled;
  final double width;
  final double height;
  final Color? color;
  final VoidCallback? onTap;
  const FlyoutTile({
    super.key,
    required this.imagePath,
    required this.label,
    required this.disabled,
    required this.width,
    required this.height,
    this.color,
    this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final bool isCompactIos =
        defaultTargetPlatform == TargetPlatform.iOS && MediaQuery.sizeOf(context).width < 800;
    final outerRadius = BorderRadius.circular(16);
    final innerRadius = BorderRadius.circular(13);

    final Color activeBase = color ?? AppColors.blue;
    final Color base = disabled ? Colors.grey.shade600 : activeBase;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _darken(base),
        _lighten(base),
      ],
    );

    Widget image = Image.asset(imagePath, fit: BoxFit.contain);
    if (disabled) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: Opacity(opacity: 0.65, child: image),
      );
    }

    final double labelFontSize = isCompactIos ? 16 * 0.85 : 16;
    final double labelSpacing = isCompactIos ? 4 : 6;
    final int imageFlex = isCompactIos ? 6 : 1;
    final int labelFlex = isCompactIos ? 1 : 0;
    final labelStyle = TextStyle(
      color: disabled ? Colors.white70 : Colors.white,
      fontWeight: FontWeight.w800,
      fontSize: labelFontSize,
    );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: outerRadius,
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: outerRadius,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                color: base.withOpacity(disabled ? 0.85 : 0.9),
                borderRadius: innerRadius,
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: imageFlex,
                    child: Center(child: image),
                  ),
                  if (labelFlex > 0)
                    Expanded(
                      flex: labelFlex,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: labelSpacing),
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: labelStyle,
                          ),
                        ],
                      ),
                    )
                  else ...[
                    SizedBox(height: labelSpacing),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle,
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
