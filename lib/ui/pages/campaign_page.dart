import 'package:flutter/material.dart';

import '../../core/colors.dart';

class CampaignPage extends StatelessWidget {
  const CampaignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B3B8F),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final headerHeight = height * 0.2;
            final nodeSize = width < 420 ? 54.0 : 64.0;
            final horizontalPadding = width < 420 ? 20.0 : 32.0;
            return Column(
              children: [
                SizedBox(
                  height: headerHeight,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: _DualClashLogo(),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 12,
                    ),
                    child: _CampaignRouteList(nodeSize: nodeSize),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DualClashLogo extends StatelessWidget {
  const _DualClashLogo();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxHeight * 0.9;
        final tileSize = size / 2;
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  width: tileSize,
                  height: tileSize,
                  child: Image.asset('assets/icons/player_red.png', fit: BoxFit.contain),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  width: tileSize,
                  height: tileSize,
                  child: Image.asset('assets/icons/player_grey.png', fit: BoxFit.contain),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  width: tileSize,
                  height: tileSize,
                  child: Image.asset('assets/icons/player_red.png', fit: BoxFit.contain),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  width: tileSize,
                  height: tileSize,
                  child: Image.asset('assets/icons/player_blue.png', fit: BoxFit.contain),
                ),
                Center(
                  child: Image.asset(
                    'assets/icons/dual_clash-words-removebg.png',
                    fit: BoxFit.contain,
                    width: size,
                    height: size,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CampaignRouteList extends StatelessWidget {
  final double nodeSize;

  const _CampaignRouteList({required this.nodeSize});

  CampaignLevelStatus _statusForLevel(int level) {
    if (level <= 6) return CampaignLevelStatus.passed;
    if (level == 7) return CampaignLevelStatus.failed;
    return CampaignLevelStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    final levels = List<int>.generate(30, (index) => index + 1);
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _RoutePathPainter(),
          ),
        ),
        Column(
          children: levels.map((level) {
            final isLeft = level.isOdd;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment:
                    isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  _CampaignNode(
                    level: level,
                    size: nodeSize,
                    status: _statusForLevel(level),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

enum CampaignLevelStatus { passed, available, failed }

class _CampaignNode extends StatelessWidget {
  final int level;
  final double size;
  final CampaignLevelStatus status;

  const _CampaignNode({
    required this.level,
    required this.size,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    switch (status) {
      case CampaignLevelStatus.passed:
        backgroundColor = AppColors.green;
        borderColor = const Color(0xFF1F7C32);
        break;
      case CampaignLevelStatus.failed:
        backgroundColor = AppColors.red;
        borderColor = const Color(0xFFA02A1E);
        break;
      case CampaignLevelStatus.available:
        backgroundColor = AppColors.brandGold;
        borderColor = const Color(0xFFD89A20);
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$level',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutePathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const dashLength = 12.0;
    const gapLength = 10.0;
    final centerX = size.width / 2;
    final path = Path()
      ..moveTo(centerX, 0)
      ..lineTo(centerX, size.height);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashLength;
        final segment = metric.extractPath(distance, end.clamp(0, metric.length));
        canvas.drawPath(segment, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
