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

  CampaignLevelData _dataForLevel(int level) {
    if (level <= 6) {
      return CampaignLevelData(
        level: level,
        state: _isCheckpointLevel(level)
            ? CampaignTileState.checkpoint
            : CampaignTileState.completed,
      );
    }
    if (level == 7) {
      return const CampaignLevelData(
        level: 7,
        state: CampaignTileState.failed,
      );
    }
    if (level == 8) {
      return const CampaignLevelData(
        level: 8,
        state: CampaignTileState.current,
        isNewlyUnlocked: true,
      );
    }
    return CampaignLevelData(
      level: level,
      state: _isCheckpointLevel(level)
          ? CampaignTileState.checkpoint
          : CampaignTileState.locked,
    );
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
                      data: _dataForLevel(rows[rowIndex][i]),
                      size: nodeSize,
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

  bool _isCheckpointLevel(int level) {
    return level % 5 == 0 || level == 1;
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

enum CampaignTileState { locked, current, completed, failed, checkpoint }

class CampaignLevelData {
  final int level;
  final CampaignTileState state;
  final bool isNewlyUnlocked;

  const CampaignLevelData({
    required this.level,
    required this.state,
    this.isNewlyUnlocked = false,
  });
}

class _CampaignNode extends StatefulWidget {
  final CampaignLevelData data;
  final double size;
  final bool isFinalLevel;

  const _CampaignNode({
    required this.data,
    required this.size,
    required this.isFinalLevel,
  });

  @override
  State<_CampaignNode> createState() => _CampaignNodeState();
}

class _CampaignNodeState extends State<_CampaignNode>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _entryController;
  late final Animation<double> _entryAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    );
    _syncAnimationState();
  }

  @override
  void didUpdateWidget(covariant _CampaignNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.state != widget.data.state ||
        oldWidget.data.isNewlyUnlocked != widget.data.isNewlyUnlocked) {
      _syncAnimationState();
    }
  }

  void _syncAnimationState() {
    if (widget.data.state == CampaignTileState.current) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 0.0;
    }

    if (widget.data.isNewlyUnlocked) {
      _entryController.forward(from: 0.0);
    } else {
      _entryController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForState(widget.data.state);
    final iconData = _iconForState(widget.data.state);
    final isAnimated =
        widget.data.state == CampaignTileState.current || widget.data.isNewlyUnlocked;

    final content = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isFinalLevel ? Colors.white : colors.border,
                width: widget.isFinalLevel ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                if (widget.isFinalLevel)
                  const BoxShadow(
                    color: Colors.white70,
                    blurRadius: 14,
                    offset: Offset(0, 0),
                  ),
                if (widget.data.state == CampaignTileState.current)
                  const BoxShadow(
                    color: Color(0x662979FF),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                '${widget.data.level}',
                style: TextStyle(
                  color: colors.text,
                  fontSize: widget.size * 0.42,
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
            ),
          ),
          Positioned(
            right: widget.size * 0.08,
            top: widget.size * 0.08,
            child: Icon(
              iconData,
              size: widget.size * 0.22,
              color: colors.icon,
            ),
          ),
        ],
      ),
    );

    final tappableContent = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {},
        child: content,
      ),
    );

    if (!isAnimated) {
      return tappableContent;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _entryAnimation]),
      builder: (context, child) {
        final pulseScale = widget.data.state == CampaignTileState.current
            ? 1 + (_pulseAnimation.value * 0.04)
            : 1.0;
        final entryScale = widget.data.isNewlyUnlocked
            ? (0.85 + _entryAnimation.value * 0.15)
            : 1.0;
        return Transform.scale(
          scale: pulseScale * entryScale,
          child: child,
        );
      },
      child: tappableContent,
    );
  }
}

class _CampaignTileColors {
  final Color background;
  final Color border;
  final Color text;
  final Color icon;

  const _CampaignTileColors({
    required this.background,
    required this.border,
    required this.text,
    required this.icon,
  });
}

_CampaignTileColors _colorsForState(CampaignTileState state) {
  switch (state) {
    case CampaignTileState.locked:
      return const _CampaignTileColors(
        background: Color(0xFFB0B7C3),
        border: Color(0xFF8A92A1),
        text: Colors.white,
        icon: Colors.white,
      );
    case CampaignTileState.current:
      return const _CampaignTileColors(
        background: Color(0xFF2979FF),
        border: Color(0xFF1C5ED6),
        text: Colors.white,
        icon: Colors.white,
      );
    case CampaignTileState.completed:
      return const _CampaignTileColors(
        background: Color(0xFF4CAF50),
        border: Color(0xFF2E7D32),
        text: Colors.white,
        icon: Colors.white,
      );
    case CampaignTileState.failed:
      return const _CampaignTileColors(
        background: Color(0xFFFF7043),
        border: Color(0xFFE4572E),
        text: Colors.white,
        icon: Colors.white,
      );
    case CampaignTileState.checkpoint:
      return const _CampaignTileColors(
        background: Color(0xFFFFD54F),
        border: Color(0xFFD8B340),
        text: Color(0xFF4B3B1E),
        icon: Color(0xFF4B3B1E),
      );
  }
}

IconData _iconForState(CampaignTileState state) {
  switch (state) {
    case CampaignTileState.locked:
      return Icons.lock;
    case CampaignTileState.current:
      return Icons.play_arrow_rounded;
    case CampaignTileState.completed:
      return Icons.check_circle_rounded;
    case CampaignTileState.failed:
      return Icons.warning_amber_rounded;
    case CampaignTileState.checkpoint:
      return Icons.emoji_events_rounded;
  }
}
