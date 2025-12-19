import 'package:flutter/material.dart';

/// Animated numeric counter that highlights increases/decreases with color and motion.
/// Now uses an odometer-like rolling digit animation on changes.
class AnimatedTotalCounter extends StatefulWidget {
  final int value;
  const AnimatedTotalCounter({super.key, required this.value});

  @override
  State<AnimatedTotalCounter> createState() => _AnimatedTotalCounterState();
}

class _AnimatedTotalCounterState extends State<AnimatedTotalCounter> {
  late int _oldValue;
  int get _delta => widget.value - _oldValue;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedTotalCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        _oldValue = oldWidget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final increased = _delta > 0;
    final decreased = _delta < 0;
    final color = increased
        ? Colors.lightGreenAccent
        : decreased
            ? Colors.redAccent
            : Colors.white;
    final offsetY = increased ? -0.2 : (decreased ? 0.2 : 0.0);

    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.value),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        final scale = 1.0 + (increased || decreased ? 0.12 * (1 - (t)) : 0.0);
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: 0.8 + 0.2 * t,
            child: FractionalTranslation(
              translation: Offset(0, offsetY * (1 - t)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icons/points-removebg.png',
                      width: 22, height: 22),
                  const SizedBox(width: 6),
                  _RollingNumber(
                    value: widget.value,
                    previousValue: _oldValue,
                    textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: 0.5),
                    directionUp: increased,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A compact per-digit rolling number (odometer style) that animates the change
/// between previousValue and value. Handles different number of digits and signs.
class _RollingNumber extends StatelessWidget {
  final int value;
  final int previousValue;
  final TextStyle textStyle;
  final bool directionUp; // true when increasing => digits roll up

  const _RollingNumber({
    required this.value,
    required this.previousValue,
    required this.textStyle,
    required this.directionUp,
  });

  @override
  Widget build(BuildContext context) {
    final String newStr = value.abs().toString();
    final String oldStr = previousValue.abs().toString();

    // Right-align digits; pad with spaces to the same length for stable layout
    final int maxLen =
        newStr.length > oldStr.length ? newStr.length : oldStr.length;

    String padLeft(String s) => s.padLeft(maxLen, ' ');
    final String newPadded = padLeft(newStr);
    final String oldPadded = padLeft(oldStr);

    final bool showMinus =
        value < 0; // totals likely non-negative, but keep generic

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showMinus) Text('-', style: textStyle),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < maxLen; i++)
                _RollingDigit(
                  newChar: newPadded[i],
                  oldChar: oldPadded[i],
                  textStyle: textStyle,
                  rollUp: directionUp,
                  // unique key per position and target char
                  key: ValueKey('d$i:${newPadded[i]}'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RollingDigit extends StatelessWidget {
  final String newChar; // '0'..'9' or space
  final String oldChar; // previous char
  final TextStyle textStyle;
  final bool rollUp; // true => new digit slides up from below

  const _RollingDigit({
    super.key,
    required this.newChar,
    required this.oldChar,
    required this.textStyle,
    required this.rollUp,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSpace = newChar == ' ';
    // Fixed width box for each digit using TextPainter to estimate width via zero width space trick is overkill.
    // Use a SizedBox based on a single '8' character metrics via DefaultTextStyle.
    final TextStyle style = textStyle;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) {
        final begin = Offset(0, rollUp ? 0.7 : -0.7);
        final tween = Tween<Offset>(begin: begin, end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return ClipRect(
          child: SlideTransition(position: anim.drive(tween), child: child),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: isSpace
          ? SizedBox(
              key: const ValueKey('space'),
              width: _digitWidth(style),
              child: Text(' ', style: style),
            )
          : SizedBox(
              key: ValueKey('char:$newChar'),
              width: _digitWidth(style),
              child: Text(newChar, style: style),
            ),
    );
  }

  double _digitWidth(TextStyle style) {
    // A simple heuristic: measure width of '8' using TextPainter once per build.
    final TextPainter painter = TextPainter(
      text: TextSpan(text: '8', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.size.width;
  }
}
