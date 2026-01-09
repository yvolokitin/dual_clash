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
    if (level <= 6) return CampaignLevelStatus.passed;
    if (level == 7) return CampaignLevelStatus.failed;
    return CampaignLevelStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    const totalLevels = 30;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const rowPattern = [2, 3, 4, 3, 2];
        final rows = _buildRows(
          totalLevels: totalLevels,
          rowPattern: rowPattern,
          blockCount: 2,
        );
        const rowSpacing = 14.0;
        const columnSpacing = 10.0;
        final deviceClass = _deviceClassForWidth(width);
        final nodeSize = _nodeSizeForDeviceClass(deviceClass);
        const blockGap = 28.0;

        return SingleChildScrollView(
          child: Column(
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
                      ),
                      if (i < rows[rowIndex].length - 1)
                        const SizedBox(width: columnSpacing),
                    ],
                  ],
                ),
                if (rowIndex < rows.length - 1) ...[
                  if ((rowIndex + 1) % rowPattern.length == 0)
                    const SizedBox(height: blockGap),
                  const SizedBox(height: rowSpacing),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  List<List<int>> _buildRows({
    required int totalLevels,
    required List<int> rowPattern,
    required int blockCount,
  }) {
    final rows = <List<int>>[];
    var currentLevel = 1;

    for (var blockIndex = 0; blockIndex < blockCount; blockIndex++) {
      for (final rowSize in rowPattern) {
        if (currentLevel > totalLevels) {
          break;
        }
        final remainingInBlock = totalLevels - currentLevel + 1;
        final count = remainingInBlock < rowSize ? remainingInBlock : rowSize;
        rows.add(
          List.generate(count, (index) => currentLevel + index),
        );
        currentLevel += count;
      }
    }

    final remaining = totalLevels - currentLevel + 1;
    if (remaining > 0) {
      rows.add(
        List.generate(remaining, (index) => currentLevel + index),
      );
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
