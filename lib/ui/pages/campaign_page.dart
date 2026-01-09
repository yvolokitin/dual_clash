import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/localization.dart';

class CampaignPage extends StatelessWidget {
  const CampaignPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isCompact = width < 520;
            final horizontalPadding = isCompact ? 16.0 : 28.0;
            final titleSize = isCompact ? 32.0 : 40.0;
            final subtitleSize = isCompact ? 14.0 : 16.0;
            final progressSize = isCompact ? 18.0 : 20.0;
            final mapHeight = isCompact ? 620.0 : 700.0;
            final maxContentWidth = math.min(width, 560.0);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'DUALCLASH',
                        style: TextStyle(
                          fontSize: subtitleSize,
                          letterSpacing: 2,
                          color: const Color(0xFF6A7AA8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.menuCampaign.toUpperCase(),
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.6,
                          color: const Color(0xFF355FA8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Progress: 6 / 30',
                        style: TextStyle(
                          fontSize: progressSize,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF394B76),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: mapHeight,
                        width: double.infinity,
                        child: _CampaignMap(
                          mapHeight: mapHeight,
                          isCompact: isCompact,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _PlayButton(
                        label: l10n.playLabel,
                        isCompact: isCompact,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Level 7',
                        style: TextStyle(
                          fontSize: isCompact ? 16.0 : 18.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4C5D84),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CampaignMap extends StatelessWidget {
  final double mapHeight;
  final bool isCompact;

  const _CampaignMap({required this.mapHeight, required this.isCompact});

  List<Offset> _buildPoints(double width, double height) {
    return [
      Offset(width * 0.28, height * 0.1),
      Offset(width * 0.72, height * 0.2),
      Offset(width * 0.36, height * 0.32),
      Offset(width * 0.26, height * 0.48),
      Offset(width * 0.4, height * 0.64),
      Offset(width * 0.68, height * 0.82),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final nodeSize = isCompact ? 72.0 : 86.0;
    final badgeSize = isCompact ? 30.0 : 34.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        final mapHeight = constraints.maxHeight;
        final points = _buildPoints(mapWidth, mapHeight);
        final cardWidth = math.min(mapWidth * 0.72, 260.0);
        final cardHeight = isCompact ? 180.0 : 200.0;
        final cardLeft = (mapWidth - cardWidth) / 2;
        final cardTop = points[3].dy - cardHeight * 0.15;
        final ribbonWidth = math.min(mapWidth * 0.5, 200.0);
        final ribbonLeft = (mapWidth - ribbonWidth) / 2 + mapWidth * 0.08;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(mapWidth, mapHeight),
              painter: _CampaignPathPainter(points: points),
            ),
            Positioned(
              left: points[0].dx - nodeSize / 2,
              top: points[0].dy - nodeSize / 2,
              child: _CampaignNode(
                level: 6,
                size: nodeSize,
                stars: 3,
                completed: true,
              ),
            ),
            Positioned(
              left: points[1].dx - nodeSize / 2,
              top: points[1].dy - nodeSize / 2,
              child: _CampaignNode(
                level: 5,
                size: nodeSize,
                current: true,
                badgeSize: badgeSize,
              ),
            ),
            Positioned(
              left: points[2].dx - nodeSize / 2,
              top: points[2].dy - nodeSize / 2,
              child: _CampaignNode(
                level: 4,
                size: nodeSize,
                locked: true,
              ),
            ),
            Positioned(
              left: points[3].dx - nodeSize / 2,
              top: points[3].dy - nodeSize / 2,
              child: _CampaignNode(
                level: 3,
                size: nodeSize,
              ),
            ),
            Positioned(
              left: points[4].dx - nodeSize / 2,
              top: points[4].dy - nodeSize / 2,
              child: _CampaignNode(
                level: 8,
                size: nodeSize,
                locked: true,
              ),
            ),
            Positioned(
              left: points[5].dx - nodeSize / 2,
              top: points[5].dy - nodeSize / 2,
              child: _CampaignNode(
                level: 9,
                size: nodeSize,
                locked: true,
              ),
            ),
            Positioned(
              left: ribbonLeft,
              top: points[2].dy + nodeSize * 0.4,
              width: ribbonWidth,
              child: _UpgradeRibbon(isCompact: isCompact),
            ),
            Positioned(
              left: cardLeft,
              top: cardTop,
              width: cardWidth,
              height: cardHeight,
              child: const _LevelDetailsCard(),
            ),
          ],
        );
      },
    );
  }
}

class _CampaignPathPainter extends CustomPainter {
  final List<Offset> points;

  const _CampaignPathPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = const Color(0xFFBFD4EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final next = points[i];
      final control = Offset((prev.dx + next.dx) / 2, (prev.dy + next.dy) / 2);
      path.quadraticBezierTo(control.dx, control.dy, next.dx, next.dy);
    }

    const dashLength = 14.0;
    const gapLength = 10.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLength, metric.length);
        final segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CampaignPathPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _CampaignNode extends StatelessWidget {
  final int level;
  final double size;
  final int stars;
  final bool locked;
  final bool completed;
  final bool current;
  final double? badgeSize;

  const _CampaignNode({
    required this.level,
    required this.size,
    this.stars = 0,
    this.locked = false,
    this.completed = false,
    this.current = false,
    this.badgeSize,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = locked ? const Color(0xFF9AA6C2) : const Color(0xFF54679A);
    final borderColor = locked ? const Color(0xFF7483A8) : const Color(0xFF3B4E7A);
    final badgeSizeResolved = badgeSize ?? size * 0.35;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  baseColor.withOpacity(0.95),
                  baseColor.withOpacity(0.8),
                ],
                radius: 0.9,
              ),
              border: Border.all(color: borderColor, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
          ),
          Text(
            '$level',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.42,
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          if (stars > 0)
            Positioned(
              bottom: size * 0.08,
              child: Row(
                children: List.generate(
                  stars,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Image.asset(
                      'assets/icons/star.png',
                      width: size * 0.2,
                      height: size * 0.2,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          if (locked)
            Positioned(
              bottom: -size * 0.15,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFCAD3E6),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_rounded, size: 18, color: Color(0xFF516184)),
              ),
            ),
          if (completed)
            Positioned(
              bottom: -size * 0.12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD166),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.star_rounded, size: 18, color: Colors.white),
              ),
            ),
          if (current)
            Positioned(
              right: -badgeSizeResolved * 0.2,
              bottom: badgeSizeResolved * 0.1,
              child: Container(
                width: badgeSizeResolved,
                height: badgeSizeResolved,
                decoration: BoxDecoration(
                  color: const Color(0xFF7ED957),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4B9F35), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UpgradeRibbon extends StatelessWidget {
  final bool isCompact;

  const _UpgradeRibbon({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 8 : 10,
        horizontal: isCompact ? 16 : 18,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC74F), Color(0xFFFF8A2B)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'AI UPGRADE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: isCompact ? 14 : 16,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _LevelDetailsCard extends StatelessWidget {
  const _LevelDetailsCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'LEVEL 7',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF3B4E7A),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              iconPath: 'assets/icons/box_green.png',
              label: 'AI: EASY',
            ),
            const Divider(height: 16, color: Color(0xFFE1E6F2)),
            _DetailRow(
              iconPath: 'assets/icons/bomb.png',
              label: 'Bombs: ON',
              highlight: 'ON',
            ),
            const Divider(height: 16, color: Color(0xFFE1E6F2)),
            _DetailRow(
              iconPath: 'assets/icons/game_board_7x7.png',
              label: '7x7',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String iconPath;
  final String label;
  final String? highlight;

  const _DetailRow({required this.iconPath, required this.label, this.highlight});

  @override
  Widget build(BuildContext context) {
    final baseStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Color(0xFF3B4E7A),
    );
    return Row(
      children: [
        Image.asset(iconPath, width: 28, height: 28, fit: BoxFit.contain),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: baseStyle,
              children: [
                if (highlight == null) TextSpan(text: label),
                if (highlight != null)
                  TextSpan(
                    text: label.replaceAll(highlight!, ''),
                    style: baseStyle,
                  ),
                if (highlight != null)
                  TextSpan(
                    text: highlight,
                    style: baseStyle.copyWith(color: const Color(0xFFFFB020)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isCompact;

  const _PlayButton({
    required this.label,
    required this.onPressed,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isCompact ? double.infinity : 260,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: isCompact ? 14 : 16),
          backgroundColor: const Color(0xFF2E7BD9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 6,
        ),
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: isCompact ? 18 : 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
