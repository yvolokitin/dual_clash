import 'dart:async';

import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/core/constants.dart';
import 'package:dual_clash/core/feature_flags.dart';
import 'package:dual_clash/core/localization.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/logic/rules_engine.dart';
import 'package:dual_clash/models/campaign_result_action.dart';
import 'package:dual_clash/core/navigation.dart';
import 'package:dual_clash/logic/app_audio.dart';
import 'package:dual_clash/logic/audio_intent_resolver.dart' show RouteContext, NavigationPhase;
import 'package:dual_clash/models/campaign_level.dart';
import 'package:dual_clash/models/game_outcome.dart';
import 'package:dual_clash/models/cell_state.dart';
import 'package:dual_clash/logic/game_rules_config.dart';
import 'package:dual_clash/logic/infection_resolution.dart';
import 'package:dual_clash/logic/adjacency.dart';
import 'package:dual_clash/ui/dialogs/ai_difficulty_dialog.dart';
import 'package:dual_clash/ui/dialogs/main_menu_dialog.dart' as mmd;
import 'package:dual_clash/ui/dialogs/results_dialog.dart';
import 'package:dual_clash/ui/widgets/board_widget.dart';
import 'package:dual_clash/ui/widgets/bomb_action_row.dart';
import 'package:dual_clash/ui/widgets/game_page_ai_level_row.dart';
import 'package:dual_clash/ui/widgets/game_page_score_row.dart';
import 'package:dual_clash/ui/widgets/support_links_bar.dart';
import 'package:dual_clash/ui/widgets/game_layout_metrics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dual_clash/core/platforms.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'statistics_page.dart';

class GamePage extends StatefulWidget {
  final GameController controller;
  final CampaignLevel? challengeConfig;
  final void Function(GameOutcome outcome, CampaignResultAction action)?
      onCampaignAction;
  final String? campaignId;
  final int? campaignTotalLevels;
  const GamePage({
    super.key,
    required this.controller,
    this.challengeConfig,
    this.onCampaignAction,
    this.campaignId,
    this.campaignTotalLevels,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with RouteAware { 
  BannerAd? _bannerAd;
  AdSize? _adaptiveBannerSize;
  bool _isAdLoaded = false;
  bool _hasPremium = false;
  bool _isLoadingAd = false;
  bool _routeSubscribed = false;
  Timer? _adRetryTimer;
  bool _reportedOutcome = false;
  bool _shouldRestoreConfig = true;
  int? _previousBoardSize;
  int? _previousGridSize;
  int? _previousAiLevel;
  bool? _previousBombsEnabled;
  bool? _previousHumanVsHuman;
  bool _isApplyingChallengeConfig = false;
  InfectionResolutionMode? _prevResolutionMode;
  InfectionAdjacencyMode? _prevAdjacencyMode;

  GameController get controller => widget.controller;
  bool get _isAndroidOrIOS => isMobile;
  String? _campaignMenuIconAsset() {
    switch (widget.campaignId) {
      case 'shiva':
        return 'assets/icons/campaigns/shiva.png';
      case 'buddha':
        return 'assets/icons/campaigns/buddha.webp';
      case 'ganesha':
        return 'assets/icons/campaigns/ganesha.png';
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.challengeConfig != null) {
      _isApplyingChallengeConfig = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _applyChallengeConfig();
        setState(() {
          _isApplyingChallengeConfig = false;
        });
      });
    }
    if (FF_ADS) {
      _loadPremiumAndMaybeAd();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeSubscribed) return;
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      routeObserver.subscribe(this, route);
      _routeSubscribed = true;
      if (route.isCurrent) {
        AppAudio.coordinator?.onGameplayEntered(active: widget.challengeConfig == null);
        AppAudio.coordinator?.onNavigationPhaseChanged(NavigationPhase.idle);
      }
    }
  }

  @override
  void didPush() {
    AppAudio.coordinator?.onGameplayEntered(active: widget.challengeConfig == null);
    AppAudio.coordinator?.onNavigationPhaseChanged(NavigationPhase.idle);
  }

  @override
  void didPopNext() {
    AppAudio.coordinator?.onGameplayEntered(active: widget.challengeConfig == null);
    AppAudio.coordinator?.onNavigationPhaseChanged(NavigationPhase.idle);
  }

  @override
  void didPushNext() {
    AppAudio.coordinator?.onNavigationPhaseChanged(NavigationPhase.transitioning);
  }

  @override
  void dispose() {
    _adRetryTimer?.cancel();
    _bannerAd?.dispose();
    _restoreChallengeConfig();
    // Global audio: leaving gameplay
    if (_routeSubscribed) {
      routeObserver.unsubscribe(this);
      _routeSubscribed = false;
    }
    AppAudio.coordinator?.onNavigationPhaseChanged(NavigationPhase.transitioning);
    AppAudio.coordinator?.onGameplayExited(next: RouteContext.other);
    AppAudio.coordinator?.onChallengeEnded();
    // Cleanup complete
    super.dispose();
  }

  void _applyChallengeConfig() {
    final config = widget.challengeConfig;
    if (config == null) return;
    // Save restore points for controller fields
    controller.campaignRestoreGridSize ??= K.n;
    controller.campaignRestoreBoardSize ??= controller.boardSize;
    controller.campaignRestoreAiLevel ??= controller.aiLevel;
    controller.campaignRestoreBombsEnabled ??= controller.bombsEnabled;
    controller.campaignRestoreHumanVsHuman ??= controller.humanVsHuman;
    // Save global rules to restore later
    _prevResolutionMode ??= GameRulesConfig.current.resolutionMode;
    _prevAdjacencyMode ??= GameRulesConfig.current.adjacencyMode;

    _previousGridSize = controller.campaignRestoreGridSize;
    _previousBoardSize = controller.campaignRestoreBoardSize;
    _previousAiLevel = controller.campaignRestoreAiLevel;
    _previousBombsEnabled = controller.campaignRestoreBombsEnabled;
    _previousHumanVsHuman = controller.campaignRestoreHumanVsHuman;

    // Enforce 7x7 campaign board size from level config
    K.n = config.boardSize;
    controller.boardSize = config.boardSize;
    controller.aiLevel = config.aiLevel;
    controller.humanVsHuman = false;

    // Remember active campaign for persistence
    _persistActiveCampaignId();

    // Apply per-campaign rule presets (fixed within each campaign)
    switch (widget.campaignId) {
      case 'shiva':
        GameRulesConfig.current.resolutionMode = InfectionResolutionMode.directTransfer;
        GameRulesConfig.current.adjacencyMode = InfectionAdjacencyMode.orthogonalPlusDiagonal8;
        break;
      case 'ganesha':
        GameRulesConfig.current.resolutionMode = InfectionResolutionMode.neutralIntermediary;
        GameRulesConfig.current.adjacencyMode = InfectionAdjacencyMode.orthogonalPlusDiagonal8;
        break;
      case 'buddha':
      default:
        GameRulesConfig.current.resolutionMode = InfectionResolutionMode.neutralIntermediary;
        GameRulesConfig.current.adjacencyMode = InfectionAdjacencyMode.orthogonal4;
        break;
    }

    // Bomb availability overrides per campaign philosophy
    bool bombs;
    switch (widget.campaignId) {
      case 'shiva':
        // Bombs are core in Shiva — always enabled
        bombs = true;
        break;
      case 'buddha':
        // Buddha: calm control — disable or very limited; enforce disabled
        bombs = false;
        break;
      case 'ganesha':
      default:
        // Ganesha: limited tools — use per-level flag
        bombs = config.bombsEnabled;
        break;
    }
    controller.setBombsEnabled(bombs);

    final fixedState = config.fixedState;
    if (fixedState != null && _isValidFixedState(config, fixedState)) {
      controller.loadStateFromMap(fixedState);
    } else {
      controller.newGame();
    }
  }

  bool _isValidFixedState(
      CampaignLevel config, Map<String, dynamic> fixedState) {
    final board = fixedState['board'];
    if (board is! List) return false;
    if (board.length != config.boardSize) return false;
    for (final row in board) {
      if (row is! List) return false;
      if (row.length != config.boardSize) return false;
    }
    return true;
  }

  Future<void> _persistActiveCampaignId() async {
    final id = widget.campaignId;
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activeCampaignId', id);
  }

  void _restoreChallengeConfig() {
    if (widget.challengeConfig == null || !_shouldRestoreConfig) return;
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
      controller.setBombsEnabled(_previousBombsEnabled!, notify: false);
    }
    if (_previousHumanVsHuman != null) {
      controller.humanVsHuman = _previousHumanVsHuman!;
    }
    // Restore global campaign rule presets
    if (_prevResolutionMode != null) {
      GameRulesConfig.current.resolutionMode = _prevResolutionMode!;
    }
    if (_prevAdjacencyMode != null) {
      GameRulesConfig.current.adjacencyMode = _prevAdjacencyMode!;
    }

    controller.newGame(notify: false, skipAi: true);
    controller.campaignRestoreGridSize = null;
    controller.campaignRestoreBoardSize = null;
    controller.campaignRestoreAiLevel = null;
    controller.campaignRestoreBombsEnabled = null;
    controller.campaignRestoreHumanVsHuman = null;
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
    if (!_isAndroidOrIOS) return;
    if (_hasPremium) return;
    if (_adRetryTimer?.isActive ?? false) return;
    _adRetryTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (_hasPremium || _isAdLoaded || _bannerAd != null) return;
      if (!mounted) return;
      await _loadBannerIfEligible(context);
    });
  }

  // Removed network pre-check to keep web-safe and rely on AdMob callbacks

  Future<void> _loadBannerIfEligible(BuildContext context) async {
    if (!FF_ADS) return;
    if (!_isAndroidOrIOS) return;
    if (_hasPremium) return;
    if (_bannerAd != null) return;
    if (_isLoadingAd) return;
    final bannerWidth = MediaQuery.of(context).size.width.truncate();
    if (bannerWidth <= 0) return;
    _isLoadingAd = true;
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
    final adUnitId = isAndroid
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
    if (!_isAndroidOrIOS) return;
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
    _shouldRestoreConfig = true;
    final outcome = _outcomeForChallenge();
    widget.onCampaignAction?.call(outcome, CampaignResultAction.continueNext);
    _reportedOutcome = true;
  }

  void _handleCampaignAction(CampaignResultAction action) {
    if (_reportedOutcome) return;
    if (action == CampaignResultAction.backToCampaign) {
      _shouldRestoreConfig = true;
    } else if (action == CampaignResultAction.continueNext) {
      final hasNextLevel = widget.campaignTotalLevels != null &&
          widget.challengeConfig != null &&
          widget.challengeConfig!.index < widget.campaignTotalLevels!;
      _shouldRestoreConfig = !hasNextLevel;
    } else {
      _shouldRestoreConfig = false;
    }
    final outcome = _outcomeForChallenge();
    widget.onCampaignAction?.call(outcome, action);
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
    if (_isAndroidOrIOS) {
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
    if (_isApplyingChallengeConfig) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
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
          onClosed:
              widget.onCampaignAction == null ? _handleGameCompleted : null,
          campaignLevelIndex: widget.challengeConfig?.index,
          campaignOutcome:
              widget.challengeConfig == null ? null : _outcomeForChallenge(),
          campaignId: widget.campaignId,
          campaignTotalLevels: widget.campaignTotalLevels,
          onCampaignContinue: widget.onCampaignAction == null
              ? null
              : () {
                  Navigator.of(context).pop();
                  _handleCampaignAction(CampaignResultAction.continueNext);
                },
          onCampaignRetry: widget.onCampaignAction == null
              ? null
              : () {
                  Navigator.of(context).pop();
                  _handleCampaignAction(CampaignResultAction.retry);
                },
          onCampaignBack: widget.onCampaignAction == null
              ? null
              : () {
                  Navigator.of(context).pop();
                  _handleCampaignAction(CampaignResultAction.backToCampaign);
                  Navigator.of(context).pop();
                },
        );

        final bool isCampaignMode = widget.onCampaignAction != null ||
            widget.campaignId != null ||
            widget.campaignTotalLevels != null;
        final String? campaignMenuIcon =
            isCampaignMode ? _campaignMenuIconAsset() : null;

        return Scaffold(
          backgroundColor: AppColors.bg,
          bottomNavigationBar: _buildBottomBar(context),
          body: SafeArea(
            child: Column(
              children: [
                if (_isAndroidOrIOS)
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
                  menuIconAsset: campaignMenuIcon,
                  scoreTextStyle: metrics.scoreTextStyle,
                  pointsTextStyle: metrics.pointsTextStyle,
                  redBase: redBase,
                  neutralCount: neutralsCount,
                  blueBase: blueBase,
                  redGamePoints: controller.redGamePoints,
                  showLeaderShadow: !controller.humanVsHuman,
                  aiSelectorEnabled: widget.challengeConfig == null,
                  showNeutral: GameRulesConfig.current.resolutionMode == InfectionResolutionMode.neutralIntermediary,
                  onOpenMenu: () async {
                    await mmd.showAnimatedMainMenuDialog(
                        context: context,
                        controller: controller,
                        config: mmd.MenuDialogConfig(
                            showSaveGame: !isCampaignMode,
                            showSettings: !isCampaignMode));
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
