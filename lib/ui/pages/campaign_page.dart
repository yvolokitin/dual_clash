import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/localization.dart';

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
            final horizontalPadding = width < 420 ? 20.0 : 32.0;
            final l10n = context.l10n;
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 12,
                    ),
                    child: const _CampaignRouteGrid(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandGold,
                        foregroundColor: const Color(0xFF2B221D),
                        shadowColor: Colors.black54,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      child: Text(l10n.commonClose),
                    ),
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

class _CampaignRouteGrid extends StatelessWidget {
  const _CampaignRouteGrid();

  CampaignLevelStatus _statusForLevel(int level) {
    if (level <= 6) return CampaignLevelStatus.completed;
    if (level == 7) return CampaignLevelStatus.failed;
    if (level == 8) return CampaignLevelStatus.current;
    return CampaignLevelStatus.locked;
  }

  @override
  Widget build(BuildContext context) {
    const totalLevels = 29;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        const rowPattern = [4, 6, 8, 6, 4, 1];
        final rows = _buildRows(
          totalLevels: totalLevels,
          rowPattern: rowPattern,
        );
        const columnSpacing = 10.0;
        final deviceClass = _deviceClassForWidth(width);
        final minNodeSize = _nodeSizeForDeviceClass(deviceClass);
        final maxColumns = rows.map((row) => row.length).reduce(
              (value, element) => value > element ? value : element,
            );
        final availableWidth = width - columnSpacing * (maxColumns - 1);
        final maxRowSpacing = rows.length > 1
            ? (height - minNodeSize * rows.length) / (rows.length - 1)
            : 14.0;
        final rowSpacing = maxRowSpacing < 14.0
            ? (maxRowSpacing < 0 ? 0.0 : maxRowSpacing)
            : 14.0;
        final availableHeight = height - rowSpacing * (rows.length - 1);
        final sizeByWidth = availableWidth / maxColumns;
        final sizeByHeight = availableHeight / rows.length;
        final maxNodeSize = sizeByWidth < sizeByHeight ? sizeByWidth : sizeByHeight;
        final nodeSize = maxNodeSize < minNodeSize ? minNodeSize : maxNodeSize;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < rows[rowIndex].length; i++) ...[
                    _CampaignNode(
                      level: rows[rowIndex][i],
                      size: nodeSize,
                      status: _statusForLevel(rows[rowIndex][i]),
                      isFinalLevel: rows[rowIndex][i] == totalLevels,
                    ),
                    if (i < rows[rowIndex].length - 1)
                      const SizedBox(width: columnSpacing),
                  ],
                ],
              ),
              if (rowIndex < rows.length - 1)
                SizedBox(height: rowSpacing),
            ],
          ],
        );
      },
    );
  }

  List<List<int>> _buildRows({
    required int totalLevels,
    required List<int> rowPattern,
  }) {
    final rows = <List<int>>[];
    var currentLevel = 1;

    for (final rowSize in rowPattern) {
      if (currentLevel > totalLevels) {
        break;
      }
      final remaining = totalLevels - currentLevel + 1;
      final count = remaining < rowSize ? remaining : rowSize;
      rows.add(
        List.generate(count, (index) => currentLevel + index),
      );
      currentLevel += count;
    }

    return rows;
  }

  _DeviceClass _deviceClassForWidth(double width) {
    if (width >= 1024) {
      return _DeviceClass.desktop;
    }
    if (width >= 600) {
      return _DeviceClass.tablet;
    }
    return _DeviceClass.mobile;
  }

  double _nodeSizeForDeviceClass(_DeviceClass deviceClass) {
    switch (deviceClass) {
      case _DeviceClass.desktop:
        return 72;
      case _DeviceClass.tablet:
        return 64;
      case _DeviceClass.mobile:
        return 56;
    }
  }
}

enum _DeviceClass { mobile, tablet, desktop }

enum CampaignLevelStatus { locked, current, completed, failed }

class _CampaignNode extends StatefulWidget {
  final int level;
  final double size;
  final CampaignLevelStatus status;
  final bool isFinalLevel;

  const _CampaignNode({
    required this.level,
    required this.size,
    required this.status,
    required this.isFinalLevel,
  });

  @override
  State<_CampaignNode> createState() => _CampaignNodeState();
}

class _CampaignNodeState extends State<_CampaignNode>
    with SingleTickerProviderStateMixin {
  static const String _tileAsset = 'assets/icons/level.png';

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  bool get _isCurrent => widget.status == CampaignLevelStatus.current;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    if (_isCurrent) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _CampaignNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isCurrent && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!_isCurrent && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final borderRadius = BorderRadius.circular(size * 0.18);
    final tileTint = _tileTintForStatus(widget.status);
    final borderColor = widget.isFinalLevel ? const Color(0xFFFFD54F) : _borderForStatus(widget.status);
    final borderWidth = widget.isFinalLevel ? 3.0 : 2.0;
    final icon = _overlayIcon(widget.status, size * 0.28);

    Widget tile = SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(tileTint, BlendMode.modulate),
              child: Image.asset(
                _tileAsset,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              '${widget.level}',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.42,
                fontWeight: FontWeight.w900,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          if (icon != null)
            Positioned(
              top: size * 0.06,
              right: size * 0.06,
              child: icon,
            ),
        ],
      ),
    );

    if (_isCurrent) {
      tile = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: tile,
      );
    }

    return tile;
  }

  Color _tileTintForStatus(CampaignLevelStatus status) {
    switch (status) {
      case CampaignLevelStatus.locked:
        return const Color(0xFFB0B7C3);
      case CampaignLevelStatus.current:
        return const Color(0xFF2979FF);
      case CampaignLevelStatus.completed:
        return const Color(0xFF4CAF50);
      case CampaignLevelStatus.failed:
        return const Color(0xFFFF7043);
    }
  }

  Color _borderForStatus(CampaignLevelStatus status) {
    switch (status) {
      case CampaignLevelStatus.locked:
        return const Color(0xFF8E95A3);
      case CampaignLevelStatus.current:
        return const Color(0xFF1C5EDB);
      case CampaignLevelStatus.completed:
        return const Color(0xFF2E7D32);
      case CampaignLevelStatus.failed:
        return const Color(0xFFEF5A33);
    }
  }

  Widget? _overlayIcon(CampaignLevelStatus status, double size) {
    switch (status) {
      case CampaignLevelStatus.locked:
        return Icon(Icons.lock, color: Colors.white, size: size);
      case CampaignLevelStatus.current:
        return Icon(Icons.play_arrow_rounded, color: Colors.white, size: size);
      case CampaignLevelStatus.completed:
        return Icon(Icons.check_circle, color: Colors.white, size: size);
      case CampaignLevelStatus.failed:
        return Icon(Icons.warning_amber_rounded, color: Colors.white, size: size);
    }
  }
}
