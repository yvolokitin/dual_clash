import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/localization.dart';
import '../../logic/game_controller.dart';
import '../controllers/campaign_controller.dart';

class CampaignPage extends StatefulWidget {
  final GameController controller;
  const CampaignPage({super.key, required this.controller});

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  late final CampaignController _campaignController;

  @override
  void initState() {
    super.initState();
    _campaignController = CampaignController();
  }

  @override
  void dispose() {
    _campaignController.dispose();
    super.dispose();
  }

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
                    child: AnimatedBuilder(
                      animation: _campaignController,
                      builder: (context, _) {
                        return _CampaignRouteGrid(
                          campaignController: _campaignController,
                          gameController: widget.controller,
                        );
                      },
                    ),
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
  final CampaignController campaignController;
  final GameController gameController;

  const _CampaignRouteGrid({
    required this.campaignController,
    required this.gameController,
  });

  @override
  Widget build(BuildContext context) {
    final totalLevels = campaignController.levels.length;
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
                      status: campaignController
                          .statusForLevel(rows[rowIndex][i]),
                      isFinalLevel: rows[rowIndex][i] == totalLevels,
                      onTap: () {
                        final level = campaignController
                            .levelForIndex(rows[rowIndex][i]);
                        if (level == null) return;
                        campaignController.launchLevel(
                          context: context,
                          gameController: gameController,
                          level: level,
                        );
                      },
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

class _CampaignNode extends StatelessWidget {
  final int level;
  final double size;
  final CampaignLevelStatus status;
  final bool isFinalLevel;
  final VoidCallback? onTap;

  const _CampaignNode({
    required this.level,
    required this.size,
    required this.status,
    required this.isFinalLevel,
    this.onTap,
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
      case CampaignLevelStatus.locked:
        backgroundColor = const Color(0xFF7A7A7A);
        borderColor = const Color(0xFF5B5B5B);
        break;
    }

    final isLocked = status == CampaignLevelStatus.locked;
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Opacity(
        opacity: isLocked ? 0.55 : 1,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isFinalLevel ? Colors.white : borderColor,
              width: isFinalLevel ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
              if (isFinalLevel)
                const BoxShadow(
                  color: Colors.white70,
                  blurRadius: 14,
                  offset: Offset(0, 0),
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
        ),
      ),
    );
  }
}
