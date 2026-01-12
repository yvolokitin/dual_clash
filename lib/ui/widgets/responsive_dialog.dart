import 'dart:math' as math;

import 'package:flutter/material.dart';

const double _defaultDialogWidth = 560;

/// Clamp text scale to a sensible range for layout math.
double dialogTextScale(BuildContext context) {
  final textScale = MediaQuery.textScaleFactorOf(context);
  return textScale.clamp(1.0, 1.3);
}

EdgeInsets scaleInsets(EdgeInsets base, double scale) {
  return EdgeInsets.fromLTRB(
    base.left * scale,
    base.top * scale,
    base.right * scale,
    base.bottom * scale,
  );
}

Future<T?> showResponsiveDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String? barrierLabel,
  Color? barrierColor,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor,
    builder: (dialogContext) {
      return ResponsiveDialog(child: builder(dialogContext));
    },
  );
}

Future<T?> showResponsiveBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor ?? Colors.transparent,
    builder: (sheetContext) {
      final size = MediaQuery.of(sheetContext).size;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: size.height * 0.9),
          child: SingleChildScrollView(
            child: builder(sheetContext),
          ),
        ),
      );
    },
  );
}

class ResponsiveDialog extends StatelessWidget {
  final Widget child;
  final EdgeInsets insetPadding;
  final BorderRadius borderRadius;
  final bool fullscreen;
  final double maxWidth;
  final double maxWidthFactor;
  final double maxHeightFactor;
  final bool useSafeArea;
  final bool scrollable;
  final bool forceHeight;

  const ResponsiveDialog({
    super.key,
    required this.child,
    this.insetPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.fullscreen = false,
    this.maxWidth = _defaultDialogWidth,
    this.maxWidthFactor = 0.8,
    this.maxHeightFactor = 0.8,
    this.useSafeArea = false,
    this.scrollable = false,
    this.forceHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthLimit = size.width * maxWidthFactor;
    final computedMaxWidth = fullscreen
        ? size.width
        : math.min(maxWidth, widthLimit.isFinite ? widthLimit : maxWidth);
    final computedMaxHeight =
        fullscreen ? size.height : size.height * maxHeightFactor;
    return Dialog(
      insetPadding: insetPadding,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: computedMaxWidth,
          maxHeight: computedMaxHeight,
          minWidth: fullscreen ? size.width : 0,
          minHeight: fullscreen ? size.height : 0,
        ),
        child: SafeArea(
          top: fullscreen || useSafeArea,
          bottom: fullscreen || useSafeArea,
          child: LayoutBuilder(
            builder: (context, constraints) {
              Widget content = child;
              if (scrollable) {
                content = SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: child,
                  ),
                );
              }
              if (forceHeight) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: content,
                );
              }
              return content;
            },
          ),
        ),
      ),
    );
  }
}
