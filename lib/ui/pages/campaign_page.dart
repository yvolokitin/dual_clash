import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/localization.dart';
import '../../logic/game_controller.dart';
import '../../models/campaign_level.dart';
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
    _campaignController.loadProgress();
  }

  @override
  void dispose() {
    _campaignController.dispose();
    super.dispose();
  }

  void _showBuddhaCampaignInfo(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF3B2F77),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.buddhaCampaignTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.buddhaCampaignDescription,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandGold,
                            foregroundColor: const Color(0xFF2B221D),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          child: Text(l10n.commonClose),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: l10n.commonClose,
                ),
              ),
            ],
          ),
        );
      },
    );
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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: _BuddhaCampaignHeader(
                        title: l10n.buddhaCampaignTitle,
                        onTap: () => _showBuddhaCampaignInfo(context),
                        imageHeight: headerHeight * 0.55,
                      ),
                    ),
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

class _BuddhaCampaignHeader extends StatelessWidget {
  final String title;
  final double imageHeight;
  final VoidCallback onTap;

  const _BuddhaCampaignHeader({
    required this.title,
    required this.imageHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/buddha.png',
                height: imageHeight.clamp(40, 96),
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
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

  void _showPassedLevelMenu({
    required BuildContext context,
    required CampaignLevel level,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF3B2F77),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.white),
                  title: const Text(
                    'Details',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showLevelDetails(context, level);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events_outlined,
                      color: Colors.white),
                  title: const Text(
                    'Results',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showBestResult(context, level);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.play_arrow, color: Colors.white),
                  title: const Text(
                    'Play again',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    campaignController.launchLevel(
                      context: context,
                      gameController: gameController,
                      level: level,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLevelDetails(BuildContext context, CampaignLevel level) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3B2F77),
          title: Text(
            'Level ${level.index} details',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Board size', '${level.boardSize}x${level.boardSize}'),
              _detailRow('AI level', level.aiLevel.toString()),
              _detailRow(
                'Bombs',
                level.bombsEnabled ? 'Enabled' : 'Disabled',
              ),
              _detailRow(
                'Preset',
                level.fixedState == null ? 'No' : 'Yes',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _showBestResult(
    BuildContext context,
    CampaignLevel level,
  ) async {
    final result = await campaignController.bestResultForLevel(level.index);
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3B2F77),
          title: Text(
            'Level ${level.index} results',
            style: const TextStyle(color: Colors.white),
          ),
          content: result == null
              ? const Text(
                  'No results saved yet.',
                  style: TextStyle(color: Colors.white70),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow('Winner', result.winner),
                    _detailRow('Red total', result.redTotal.toString()),
                    _detailRow('Blue total', result.blueTotal.toString()),
                    _detailRow('Bonus red', result.bonusRed.toString()),
                    _detailRow('Bonus blue', result.bonusBlue.toString()),
                    _detailRow('Turns red', result.turnsRed.toString()),
                    _detailRow('Turns blue', result.turnsBlue.toString()),
                    _detailRow(
                      'Play time',
                      _formatPlayTime(result.playMs),
                    ),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatPlayTime(int ms) {
    final totalSeconds = (ms / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final totalLevels = campaignController.levels.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isMobilePlatform = defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS;
        final isCompactMobileLayout = isMobilePlatform && width < 700;
        final rowPattern = isCompactMobileLayout
            ? [4, 5, 5, 5, 5, 4, 1]
            : [4, 6, 8, 6, 4, 1];
        final rows = _buildRows(
          totalLevels: totalLevels,
          rowPattern: rowPattern,
        );
        final columnSpacing = isCompactMobileLayout ? 2.0 : 10.0;
        final deviceClass = _deviceClassForWidth(width);
        final minNodeSize = _nodeSizeForDeviceClass(deviceClass);
        final maxColumns = rows.map((row) => row.length).reduce(
              (value, element) => value > element ? value : element,
            );
        final availableWidth = width - columnSpacing * (maxColumns - 1);
        final minRowSpacing = isCompactMobileLayout ? 2.0 : 14.0;
        final maxRowSpacing = rows.length > 1
            ? (height - minNodeSize * rows.length) / (rows.length - 1)
            : minRowSpacing;
        final rowSpacing = maxRowSpacing < minRowSpacing
            ? (maxRowSpacing < 0 ? 0.0 : maxRowSpacing)
            : minRowSpacing;
        final availableHeight = height - rowSpacing * (rows.length - 1);
        final sizeByWidth = availableWidth / maxColumns;
        final sizeByHeight = availableHeight / rows.length;
        final maxNodeSize = sizeByWidth < sizeByHeight ? sizeByWidth : sizeByHeight;
        final nodeSize = maxNodeSize < minNodeSize ? minNodeSize : maxNodeSize;
        final adjustedNodeSize =
            isCompactMobileLayout ? nodeSize * 0.9 : nodeSize;

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
                      size: adjustedNodeSize,
                      status: campaignController
                          .statusForLevel(rows[rowIndex][i]),
                      isFinalLevel: rows[rowIndex][i] == totalLevels,
                      onTap: () {
                        final level = campaignController
                            .levelForIndex(rows[rowIndex][i]);
                        if (level == null) return;
                        if (campaignController.statusForLevel(level.index) ==
                            CampaignLevelStatus.passed) {
                          _showPassedLevelMenu(
                            context: context,
                            level: level,
                          );
                          return;
                        }
                        campaignController.launchLevel(
                          context: context,
                          gameController: gameController,
                          level: level,
                        );
                      },
                    ),
                    if (i < rows[rowIndex].length - 1)
                      SizedBox(width: columnSpacing),
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
