import 'dart:async';
import 'dart:io';

import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/core/constants.dart';
import 'package:dual_clash/core/feature_flags.dart';
import 'package:dual_clash/core/localization.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/logic/rules_engine.dart';
import 'package:dual_clash/models/campaign_level.dart';
import 'package:dual_clash/models/game_outcome.dart';
import 'package:dual_clash/models/cell_state.dart';
import 'package:dual_clash/ui/dialogs/ai_difficulty_dialog.dart';
import 'package:dual_clash/ui/dialogs/main_menu_dialog.dart' as mmd;
import 'package:dual_clash/ui/dialogs/results_dialog.dart';
import 'package:dual_clash/ui/widgets/board_widget.dart';
import 'package:dual_clash/ui/widgets/bomb_action_row.dart';
import 'package:dual_clash/ui/widgets/game_page_ai_level_row.dart';
import 'package:dual_clash/ui/widgets/game_page_score_row.dart';
import 'package:dual_clash/ui/widgets/support_links_bar.dart';
import 'package:dual_clash/ui/widgets/game_layout_metrics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'statistics_page.dart';

class GamePage extends StatefulWidget {
  final GameController controller;
  final CampaignLevel? challengeConfig;
  final ValueChanged<GameOutcome>? onGameCompleted;
  const GamePage({
    super.key,
    required this.controller,
    this.challengeConfig,
    this.onGameCompleted,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  BannerAd? _bannerAd;
  AdSize? _adaptiveBannerSize;
  bool _isAdLoaded = false;
  bool _hasPremium = false;
  bool _isLoadingAd = false;
  Timer? _adRetryTimer;
  bool _reportedOutcome = false;
  int? _previousBoardSize;
  int? _previousGridSize;
  int? _previousAiLevel;
  bool? _previousBombsEnabled;
  bool? _previousHumanVsHuman;

  GameController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _applyChallengeConfig();
    if (FF_ADS) {
      _loadPremiumAndMaybeAd();
    }
  }

  @override
  void dispose() {
    _adRetryTimer?.cancel();
    _bannerAd?.dispose();
    _restoreChallengeConfig();
    super.dispose();
  }

  void _applyChallengeConfig() {
    final config = widget.challengeConfig;
    if (config == null) return;
    _previousGridSize = K.n;
    _previousBoardSize = controller.boardSize;
    _previousAiLevel = controller.aiLevel;
    _previousBombsEnabled = controller.bombsEnabled;
    _previousHumanVsHuman = controller.humanVsHuman;
    K.n = config.boardSize;
    controller.boardSize = config.boardSize;
    controller.aiLevel = config.aiLevel;
    controller.humanVsHuman = false;
    controller.setBombsEnabled(config.bombsEnabled);
    controller.newGame();
  }

  void _restoreChallengeConfig() {
    if (widget.challengeConfig == null) return;
    if (_previousGridSize != null) {
      K.n = _previousGridSize!;
    }
    if (_previousBoardSize != null) {
      controller.boardSize = _previousBoardSize!;
    }
    if (_previousAiLevel != null) {
      controller.aiLevel = _previousAiLevel!;
    }
    if (_previousBombsEnabled != null) {
      controller.setBombsEnabled(_previousBombsEnabled!);
    }
    if (_previousHumanVsHuman != null) {
      controller.humanVsHuman = _previousHumanVsHuman!;
    }
  }

  Future<void> _loadPremiumAndMaybeAd() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPremium = prefs.getBool('has_premium') ?? false;
    if (!mounted) return;
    setState(() {
      _hasPremium = hasPremium;
    });
    if (!hasPremium) {
      _startAdRetryTimer();
    }
  }

  Future<void> _reloadPremiumStatus(BuildContext context) async {
    if (!FF_ADS) return;
    final prefs = await SharedPreferences.getInstance();
    final hasPremium = prefs.getBool('has_premium') ?? false;
    if (!mounted) return;
    if (hasPremium && !_hasPremium) {
      _adRetryTimer?.cancel();
      _bannerAd?.dispose();
      _bannerAd = null;
      setState(() {
        _hasPremium = true;
        _isAdLoaded = false;
      });
    } else if (!hasPremium && !_hasPremium && _bannerAd == null) {
      _startAdRetryTimer();
      await _loadBannerIfEligible(context);
    }
  }

  void _startAdRetryTimer() {
    if (!FF_ADS) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (_hasPremium) return;
    if (_adRetryTimer?.isActive ?? false) return;
    _adRetryTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (_hasPremium || _isAdLoaded || _bannerAd != null) return;
      if (!mounted) return;
      await _loadBannerIfEligible(context);
    });
  }

  Future<bool> _hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadBannerIfEligible(BuildContext context) async {
    if (!FF_ADS) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    if (_hasPremium) return;
    if (_bannerAd != null) return;
    if (_isLoadingAd) return;
    final bannerWidth = MediaQuery.of(context).size.width.truncate();
    if (bannerWidth <= 0) return;
    _isLoadingAd = true;
    final hasNetwork = await _hasNetwork();
    if (!hasNetwork) {
      _isLoadingAd = false;
      return;
    }
    final adaptiveSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            bannerWidth);
    if (adaptiveSize == null) {
      _isLoadingAd = false;
      return;
    }
    if (mounted && _adaptiveBannerSize != adaptiveSize) {
      setState(() {
        _adaptiveBannerSize = adaptiveSize;
      });
    }
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/9214589741'
        : 'ca-app-pub-3940256099942544/2435281174';
    final banner = BannerAd(
      adUnitId: adUnitId,
      size: adaptiveSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
            _isLoadingAd = false;
          });
          _adRetryTimer?.cancel();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isLoadingAd = false;
        },
      ),
    );
    await banner.load();
  }

  Future<void> _resolveAdaptiveBannerSize(BuildContext context) async {
    if (_adaptiveBannerSize != null) return;
    final bannerWidth = MediaQuery.of(context).size.width.truncate();
    if (bannerWidth <= 0) return;
    final adaptiveSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            bannerWidth);
    if (!mounted || adaptiveSize == null) return;
    if (_adaptiveBannerSize != adaptiveSize) {
      setState(() {
        _adaptiveBannerSize = adaptiveSize;
      });
    }
  }

  void _scheduleBannerLoad(BuildContext context) {
    if (!FF_ADS) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    if (_hasPremium) return;
    if (_bannerAd != null || _isLoadingAd) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _resolveAdaptiveBannerSize(context);
      _loadBannerIfEligible(context);
    });
  }

  void _handleGameCompleted() {
    if (_reportedOutcome) return;
    final outcome = _outcomeForChallenge();
    if (widget.onGameCompleted != null) {
      widget.onGameCompleted!(outcome);
    }
    _reportedOutcome = true;
  }

  GameOutcome _outcomeForChallenge() {
    final redTotal = controller.scoreRedTotal();
    final blueTotal = controller.scoreBlueTotal();
    final neutrals = RulesEngine.countOf(controller.board, CellState.neutral);
    final int maxScore = [redTotal, blueTotal, neutrals]
        .reduce((a, b) => a > b ? a : b);
    final int topCount = [redTotal, blueTotal, neutrals]
        .where((score) => score == maxScore)
        .length;
    if (topCount != 1) {
      return GameOutcome.loss;
    }
    return maxScore == redTotal ? GameOutcome.win : GameOutcome.loss;
  }

  Widget _buildBottomBar(BuildContext context) {
    if (!FF_ADS) {
      return SizedBox(
        height: AdSize.banner.height.toDouble(),
        child: const DecoratedBox(
          decoration: BoxDecoration(color: Colors.transparent),
        ),
      );
    }
    if (_hasPremium) {
      return const SizedBox.shrink();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      if (_isAdLoaded && _bannerAd != null) {
        final bannerWidth = _bannerAd!.size.width.toDouble();
        final bannerHeight = _bannerAd!.size.height.toDouble();
        return SafeArea(
          bottom: true,
          top: false,
          child: SizedBox(
            height: bannerHeight,
            child: Center(
              child: SizedBox(
                width: bannerWidth,
                height: bannerHeight,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          ),
        );
      }
      return SupportLinksBar(
        height: _adaptiveBannerSize?.height.toDouble(),
      );
    }
    return SupportLinksBar();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        _scheduleBannerLoad(context);
        final redBase = controller.scoreRedBase();
        final blueBase = controller.scoreBlueBase();
        final neutralsCount =
            RulesEngine.countOf(controller.board, CellState.neutral);
        final metrics = GameLayoutMetrics.from(context, controller);
        final bool isMobile = metrics.isMobile;

        Future<void> openStatistics() async {
          await showAnimatedStatisticsDialog(
              context: context, controller: controller);
        }

        // Auto-show end results dialog once
        maybeShowResultsDialog(
          context: context,
          controller: controller,
          onClosed: _handleGameCompleted,
        );

        return Scaffold(
          backgroundColor: AppColors.bg,
          bottomNavigationBar: _buildBottomBar(context),
          body: SafeArea(
            child: Column(
              children: [
                if (Platform.isAndroid || Platform.isIOS)
                  const SizedBox(height: 20),

                // Score row before the board — kept width-aligned with board.
                GamePageScoreRow(
                  isMobile: isMobile,
                  boardWidth: metrics.boardWidth,
                  scoreTopPadding: metrics.scoreTopPadding,
                  menuIconSize: metrics.menuIconSize,
                  scoreItemSize: metrics.scoreItemSize,
                  pointsItemSize: metrics.pointsItemSize,
                  boardCellSize: metrics.boardCellSize,
                  scoreTextStyle: metrics.scoreTextStyle,
                  pointsTextStyle: metrics.pointsTextStyle,
                  redBase: redBase,
                  neutralCount: neutralsCount,
                  blueBase: blueBase,
                  redGamePoints: controller.redGamePoints,
                  showLeaderShadow: !controller.humanVsHuman,
                  onOpenMenu: () async {
                    await mmd.showAnimatedMainMenuDialog(
                        context: context, controller: controller);
                    await _reloadPremiumStatus(context);
                  },
                  onOpenStatistics: openStatistics,
                  onOpenAiSelector: () => showAiDifficultyDialog(
                    context: context,
                    controller: controller,
                  ),
                ),

                // Board centered
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              BoardWidget(controller: controller),
                      if (controller.isAiThinking ||
                                  controller.isSimulating)
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(12)),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 8),
                                      const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white)),
                                      const SizedBox(height: 10),
                                      Text(
                                        controller.isSimulating
                                            ? context.l10n.simulatingGameLabel
                                            : context.l10n.aiThinkingLabel,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 15 : 20),
                      if (controller.bombsEnabled)
                        BombActionRow(
                          controller: controller,
                          boardWidth: metrics.boardWidth,
                          boardCellSize: metrics.boardCellSize,
                        ),
                      if (isMobile && !controller.humanVsHuman)
                        GamePageAiLevelRow(
                          controller: controller,
                          boardCellSize: metrics.boardCellSize,
                          boardWidth: metrics.boardWidth,
                          labelStyle: metrics.scoreTextStyle,
                          isMobile: isMobile,
                        ),
                    ],
                  ),
                ),

                // AI level row under the board
                if (!isMobile && !controller.humanVsHuman)
                  GamePageAiLevelRow(
                    controller: controller,
                    boardCellSize: metrics.boardCellSize,
                    boardWidth: metrics.boardWidth,
                    labelStyle: metrics.scoreTextStyle,
                    isMobile: isMobile,
                  ),

                // Bottom actions under the board: Simulate and Undo
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    ],
                  ),
                ),
                if (isMobile) const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}
