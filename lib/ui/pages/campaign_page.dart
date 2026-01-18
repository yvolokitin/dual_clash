import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/colors.dart';
import '../../core/localization.dart';
import '../../logic/game_controller.dart';
import '../../models/campaign_level.dart';
import '../../models/campaign_level_details.dart';
import '../../models/campaign_metadata.dart';
import '../controllers/campaign_controller.dart';
import '../dialogs/campaign_intro_dialog.dart';

class CampaignPage extends StatefulWidget {
  final GameController controller;
  const CampaignPage({super.key, required this.controller});

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  static const String _kLastCampaignId = 'campaign_last_played';
  static const String _kIntroShownPrefix = 'campaign_intro_shown_';
  final Map<String, CampaignController> _campaignControllers =
      <String, CampaignController>{};
  final Set<String> _loadedProgress = <String>{};
  final Set<String> _introShown = <String>{};
  late final PageController _pageController;
  List<CampaignMetadata> _campaigns = const [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(viewportFraction: 1.0, initialPage: _currentIndex);
  }

  @override
  void dispose() {
    for (final controller in _campaignControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeCampaigns();
  }

  void _initializeCampaigns() {
    final l10n = context.l10n;
    final definitions = <CampaignMetadata>[
      CampaignMetadata(
        id: 'shiva',
        title: l10n.shivaCampaignTitle,
        description: l10n.shivaCampaignDescription,
        iconAsset: 'assets/icons/campaigns/shiva.png',
        isUnlocked: false,
        totalLevels: campaignLevels.length,
        levels: campaignLevels,
      ),
      CampaignMetadata(
        id: 'buddha',
        title: l10n.buddhaCampaignTitle,
        description: l10n.buddhaCampaignDescription,
        iconAsset: 'assets/icons/campaigns/buddha.webp',
        isUnlocked: true,
        totalLevels: campaignLevels.length,
        levels: campaignLevels,
      ),
      CampaignMetadata(
        id: 'ganesha',
        title: l10n.ganeshaCampaignTitle,
        description: l10n.ganeshaCampaignDescription,
        iconAsset: 'assets/icons/campaigns/ganesha.png',
        isUnlocked: false,
        totalLevels: campaignLevels.length,
        levels: campaignLevels,
      ),
    ];
    _campaigns = definitions;
    if (_campaigns.isNotEmpty && _currentIndex == 0) {
      final firstUnlockedIndex =
          _campaigns.indexWhere((campaign) => campaign.isUnlocked);
      if (firstUnlockedIndex != -1) {
        _currentIndex = firstUnlockedIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _pageController.jumpToPage(_currentIndex);
        });
      }
    }
    for (final campaign in _campaigns) {
      _campaignControllers.putIfAbsent(
        campaign.id,
        () => CampaignController(
          campaignId: campaign.id,
          isUnlocked: campaign.isUnlocked,
          totalLevels: campaign.totalLevels,
          levels: campaign.levels,
        ),
      );
      if (campaign.isUnlocked && !_loadedProgress.contains(campaign.id)) {
        _loadedProgress.add(campaign.id);
        _campaignControllers[campaign.id]!.loadProgress();
      }
    }
    // Show one-time intro for the initially selected campaign
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _campaigns.isEmpty) return;
      _maybeShowCampaignIntro(_campaigns[_currentIndex]);
    });
    _restoreLastCampaignIfNeeded();
  }

  Future<void> _restoreLastCampaignIfNeeded() async {
    if (_campaigns.isEmpty) return;
    final unlocked = _campaigns.where((campaign) => campaign.isUnlocked).toList();
    if (unlocked.length <= 1) return;
    final prefs = await SharedPreferences.getInstance();
    final lastCampaignId = prefs.getString(_kLastCampaignId);
    if (lastCampaignId == null) return;
    final index = _campaigns.indexWhere(
      (campaign) => campaign.id == lastCampaignId && campaign.isUnlocked,
    );
    if (index <= -1 || index == _currentIndex) return;
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
    // After restore, maybe show intro for this campaign
    _maybeShowCampaignIntro(_campaigns[_currentIndex]);
  }

  Future<void> _persistSelectedCampaign(CampaignMetadata campaign) async {
    final unlocked = _campaigns.where((entry) => entry.isUnlocked).toList();
    if (unlocked.length <= 1) return;
    if (!campaign.isUnlocked) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastCampaignId, campaign.id);
  }

  Future<void> _maybeShowCampaignIntro(CampaignMetadata campaign) async {
    if (!campaign.isUnlocked) return;
    if (_introShown.contains(campaign.id)) return;
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kIntroShownPrefix${campaign.id}';
    final wasShown = prefs.getBool(key) ?? false;
    if (wasShown) {
      _introShown.add(campaign.id);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showCampaignIntroDialog(context: context, campaignId: campaign.id);
      _introShown.add(campaign.id);
      await prefs.setBool(key, true);
    });
  }

  void _showCampaignInfo(BuildContext context, CampaignMetadata campaign) {
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
                        campaign.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        campaign.description,
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
            if (_campaigns.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                SizedBox(
                  height: headerHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _CampaignNavigationHeader(
                      campaign: _campaigns[_currentIndex],
                      totalCampaigns: _campaigns.length,
                      currentIndex: _currentIndex,
                      imageHeight: headerHeight * 0.55,
                      onTap: () =>
                          _showCampaignInfo(context, _campaigns[_currentIndex]),
                      onPrevious: _currentIndex > 0
                          ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              )
                          : null,
                      onNext: _currentIndex < _campaigns.length - 1
                          ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 12,
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        if (!mounted) return;
                        setState(() {
                          _currentIndex = index;
                        });
                        _persistSelectedCampaign(_campaigns[index]);
                        _maybeShowCampaignIntro(_campaigns[index]);
                      },
                      itemCount: _campaigns.length,
                      itemBuilder: (context, index) {
                        final campaign = _campaigns[index];
                        final controller = _campaignControllers[campaign.id]!;
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, _) {
                            final page = _pageController.hasClients
                                ? (_pageController.page ?? _currentIndex)
                                : _currentIndex.toDouble();
                            final distance = (page - index).abs();
                            final scale =
                                (1 - (distance * 0.15)).clamp(0.85, 1.0);
                            return Transform.scale(
                              scale: scale.toDouble(),
                              child: AnimatedBuilder(
                                animation: controller,
                                builder: (context, _) {
                                  return _CampaignRouteGrid(
                                    campaignController: controller,
                                    gameController: widget.controller,
                                    comingSoonLabel: l10n.campaignComingSoon,
                                  );
                                },
                              ),
                            );
                          },
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

class _CampaignNavigationHeader extends StatelessWidget {
  final CampaignMetadata campaign;
  final int currentIndex;
  final int totalCampaigns;
  final double imageHeight;
  final VoidCallback onTap;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _CampaignNavigationHeader({
    required this.campaign,
    required this.currentIndex,
    required this.totalCampaigns,
    required this.imageHeight,
    required this.onTap,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = imageHeight.clamp(40, 96).toDouble();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          disabledColor: Colors.white24,
          tooltip: currentIndex > 0 ? 'Previous campaign' : null,
        ),
        Flexible(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CampaignHeaderIcon(
                      iconAsset: campaign.iconAsset,
                      isLocked: !campaign.isUnlocked,
                      size: iconSize,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      campaign.title,
                      textAlign: TextAlign.center,
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
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right, color: Colors.white),
          disabledColor: Colors.white24,
          tooltip: currentIndex < totalCampaigns - 1 ? 'Next campaign' : null,
        ),
      ],
    );
  }
}

class _CampaignHeaderIcon extends StatelessWidget {
  final String iconAsset;
  final bool isLocked;
  final double size;

  const _CampaignHeaderIcon({
    required this.iconAsset,
    required this.isLocked,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      iconAsset,
      height: size,
      fit: BoxFit.contain,
    );
    if (!isLocked) return image;
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: Opacity(
        opacity: 0.65,
        child: image,
      ),
    );
  }
}

class _CampaignRouteGrid extends StatelessWidget {
  final CampaignController campaignController;
  final GameController gameController;
  final String comingSoonLabel;

  const _CampaignRouteGrid({
    required this.campaignController,
    required this.gameController,
    required this.comingSoonLabel,
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

  void _showLevelDetails(BuildContext context, CampaignLevel level, {CampaignLevelStatus? status}) {
    final levelDetails = campaignLevelDetailsFor(
      campaignId: campaignController.campaignId,
      levelIndex: level.index,
    );
    final iconSize = (MediaQuery.of(context).size.height * 0.2 * 0.55)
        .clamp(40, 96)
        .toDouble();
    // Compute who starts first for this level
    final l10n = context.l10n;
    String starting = gameController.startingPlayer.name;
    final fixed = level.fixedState;
    if (fixed != null) {
      final sp = fixed['startingPlayer'];
      if (sp is String && sp.isNotEmpty) {
        starting = sp;
      }
    }
    final startsLabel = starting.toLowerCase() == 'blue'
        ? l10n.startingPlayerAi
        : l10n.startingPlayerHuman;
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
                        'Level ${level.index}: ${levelDetails.title}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        levelDetails.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (campaignController.campaignId == 'buddha') ...[
                        Center(
                          child: Image.asset(
                            'assets/icons/campaigns/buddha.webp',
                            height: iconSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _detailRow(
                        'Starts',
                        startsLabel,
                      ),
                      _detailRow(
                        'Board size',
                        '${level.boardSize}x${level.boardSize}',
                      ),
                      _detailRow('AI level', level.aiLevel.toString()),
                      _detailRow(
                        'Bombs',
                        level.bombsEnabled ? 'Enabled' : 'Disabled',
                      ),
                      _detailRow(
                        'Preset',
                        level.fixedState == null ? 'No' : 'Yes',
                      ),
                      const SizedBox(height: 16),
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
                          child: const Text('Close'),
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
                  tooltip: 'Close',
                ),
              ),
            ],
          ),
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
    final result = await campaignController.latestResultForLevel(level.index);
    if (!context.mounted) return;
    final iconSize = (MediaQuery.of(context).size.height * 0.2 * 0.55)
        .clamp(40, 96)
        .toDouble();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3B2F77),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Level ${level.index} results',
                style: const TextStyle(color: Colors.white),
              ),
              if (campaignController.campaignId == 'buddha') ...[
                const SizedBox(height: 8),
                Image.asset(
                  'assets/icons/campaigns/buddha.webp',
                  height: iconSize,
                  fit: BoxFit.contain,
                ),
              ],
            ],
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
            ElevatedButton(
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
    final totalLevels = campaignController.totalLevels;
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

        final grid = Column(
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
                      showBuddhaBackground:
                          campaignController.campaignId == 'buddha',
                      onTap: () {
                        final level = campaignController
                            .levelForIndex(rows[rowIndex][i]);
                        if (level == null) return;
                        final status =
                            campaignController.statusForLevel(level.index);
                        if (status == CampaignLevelStatus.locked) {
                          _showLevelDetails(context, level);
                          return;
                        }
                        if (status == CampaignLevelStatus.passed) {
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

        if (campaignController.isUnlocked) {
          return grid;
        }

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            grid,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  color: AppColors.brandGold,
                  size: adjustedNodeSize * 2,
                ),
                const SizedBox(height: 8),
                Text(
                  comingSoonLabel,
                  style: const TextStyle(
                    color: AppColors.brandGold,
                    fontSize: 20.8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
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
  final bool showBuddhaBackground;
  final VoidCallback? onTap;

  const _CampaignNode({
    required this.level,
    required this.size,
    required this.status,
    required this.isFinalLevel,
    required this.showBuddhaBackground,
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
    final DecorationImage? backgroundImage = showBuddhaBackground
        ? const DecorationImage(
            image: AssetImage('assets/icons/campaigns/buddha_face_contur.png'),
            fit: BoxFit.contain,
            opacity: 0.28,
          )
        : null;
    return MouseRegion(
      cursor: onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
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
              image: backgroundImage,
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
      ),
    );
  }
}
