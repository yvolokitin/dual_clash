import 'dart:math' as math;

import 'package:flutter/material.dart';

class WavesPainter extends CustomPainter {
  final Animation<double>? animation;
  final Color baseColor;
  WavesPainter({required this.animation, required this.baseColor}) : super(repaint: animation);

  Color _lighten(Color c, [double amount = 0.10]) {
    final hsl = HSLColor.fromColor(c);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // The Scaffold already paints the base background color. We only add wave layers.
    final t = (animation?.value ?? 0.0) * 2 * math.pi; // 0..2π loop over duration

    // Wave layer painter helper: fills downward to bottom edge
    Path makeWaveBottom({
      required double baseY,
      required double amplitude,
      required double wavelength,
      required double speed,
      required double phase,
    }) {
      final path = Path();
      final double width = size.width;
      final double height = size.height;
      final double dxStep = math.max(2.5, width / 120); // adaptive step for smoothness/perf
      double x = 0;
      double y =
          baseY + math.sin((x / wavelength) * 2 * math.pi + t * speed + phase) * amplitude;
      path.moveTo(0, y);
      for (x = dxStep; x <= width; x += dxStep) {
        y =
            baseY + math.sin((x / wavelength) * 2 * math.pi + t * speed + phase) * amplitude;
        path.lineTo(x, y);
      }
      // Close the shape to bottom so it can be filled
      path.lineTo(width, height);
      path.lineTo(0, height);
      path.close();
      return path;
    }

    // Wave layer painter helper: fills upward to top edge
    Path makeWaveTop({
      required double baseY,
      required double amplitude,
      required double wavelength,
      required double speed,
      required double phase,
    }) {
      final path = Path();
      final double width = size.width;
      final double dxStep = math.max(2.5, width / 120);
      double x = 0;
      double y =
          baseY + math.sin((x / wavelength) * 2 * math.pi + t * speed + phase) * amplitude;
      path.moveTo(0, y);
      for (x = dxStep; x <= width; x += dxStep) {
        y =
            baseY + math.sin((x / wavelength) * 2 * math.pi + t * speed + phase) * amplitude;
        path.lineTo(x, y);
      }
      // Close the shape to top so it can be filled
      path.lineTo(width, 0);
      path.lineTo(0, 0);
      path.close();
      return path;
    }

    // Colors for layers (same palette, semi-transparent)
    final farColor = _lighten(baseColor, 0.06).withOpacity(0.18);
    final midColor = _lighten(baseColor, 0.12).withOpacity(0.22);
    final nearColor = _lighten(baseColor, 0.18).withOpacity(0.26);

    final height = size.height;
    final width = size.width;

    // Bottom baselines positioned near the bottom
    final yFar = height * 0.80;
    final yMid = height * 0.86;
    final yNear = height * 0.90;

    // Top baselines positioned near the top
    final yTopNear = height * 0.10;
    final yTopMid = height * 0.14;
    final yTopFar = height * 0.20;

    // Bottom waves (moving left → right)
    final farPath = makeWaveBottom(
      baseY: yFar,
      amplitude: math.max(8.0, height * 0.010),
      wavelength: math.max(180.0, width * 0.90),
      speed: 0.6,
      phase: 0.0,
    );
    final midPath = makeWaveBottom(
      baseY: yMid,
      amplitude: math.max(12.0, height * 0.016),
      wavelength: math.max(160.0, width * 0.75),
      speed: 0.9,
      phase: math.pi / 3,
    );
    final nearPath = makeWaveBottom(
      baseY: yNear,
      amplitude: math.max(18.0, height * 0.022),
      wavelength: math.max(140.0, width * 0.60),
      speed: 1.2,
      phase: math.pi * 2 / 3,
    );

    // Top waves (moving right → left for mirrored motion)
    final topFarPath = makeWaveTop(
      baseY: yTopFar,
      amplitude: math.max(8.0, height * 0.010),
      wavelength: math.max(180.0, width * 0.90),
      speed: -0.6,
      phase: 0.0,
    );
    final topMidPath = makeWaveTop(
      baseY: yTopMid,
      amplitude: math.max(12.0, height * 0.016),
      wavelength: math.max(160.0, width * 0.75),
      speed: -0.9,
      phase: math.pi / 3,
    );
    final topNearPath = makeWaveTop(
      baseY: yTopNear,
      amplitude: math.max(18.0, height * 0.022),
      wavelength: math.max(140.0, width * 0.60),
      speed: -1.2,
      phase: math.pi * 2 / 3,
    );

    final paintFar = Paint()
      ..color = farColor
      ..style = PaintingStyle.fill;
    final paintMid = Paint()
      ..color = midColor
      ..style = PaintingStyle.fill;
    final paintNear = Paint()
      ..color = nearColor
      ..style = PaintingStyle.fill;

    // Draw bottom waves from farthest to nearest
    canvas.drawPath(farPath, paintFar);
    canvas.drawPath(midPath, paintMid);
    canvas.drawPath(nearPath, paintNear);

    // Draw top waves from farthest to nearest
    canvas.drawPath(topFarPath, paintFar);
    canvas.drawPath(topMidPath, paintMid);
    canvas.drawPath(topNearPath, paintNear);

    // Subtle shimmering crest highlight on the nearest bottom wave
    final crestPaint = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final double dxStep2 = math.max(2.5, width / 120);

    // Bottom crest
    final crestBottom = Path();
    double x2 = 0;
    double y2 = yNear +
        math.sin(
                (x2 / math.max(140.0, width * 0.60)) * 2 * math.pi + t * 1.2 +
                    math.pi * 2 / 3) *
            math.max(18.0, height * 0.022);
    crestBottom.moveTo(0, y2);
    for (x2 = dxStep2; x2 <= width; x2 += dxStep2) {
      y2 = yNear +
          math.sin(
                  (x2 / math.max(140.0, width * 0.60)) * 2 * math.pi + t * 1.2 +
                      math.pi * 2 / 3) *
              math.max(18.0, height * 0.022);
      crestBottom.lineTo(x2, y2);
    }
    canvas.drawPath(crestBottom, crestPaint);

    // Top crest
    final crestTop = Path();
    double xt = 0;
    double yt = yTopNear +
        math.sin(
                (xt / math.max(140.0, width * 0.60)) * 2 * math.pi + t * -1.2 +
                    math.pi * 2 / 3) *
            math.max(18.0, height * 0.022);
    crestTop.moveTo(0, yt);
    for (xt = dxStep2; xt <= width; xt += dxStep2) {
      yt = yTopNear +
          math.sin(
                  (xt / math.max(140.0, width * 0.60)) * 2 * math.pi + t * -1.2 +
                      math.pi * 2 / 3) *
              math.max(18.0, height * 0.022);
      crestTop.lineTo(xt, yt);
    }
    canvas.drawPath(crestTop, crestPaint);
  }

  @override
  bool shouldRepaint(covariant WavesPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor || oldDelegate.animation != animation;
  }
}
