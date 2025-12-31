import 'dart:async';
import 'dart:io';

import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/core/constants.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/logic/rules_engine.dart';
import 'package:dual_clash/models/cell_state.dart';
import 'package:dual_clash/ui/dialogs/ai_difficulty_dialog.dart';
import 'package:dual_clash/ui/dialogs/main_menu_dialog.dart' as mmd;
import 'package:dual_clash/ui/dialogs/results_dialog.dart';
import 'package:dual_clash/ui/widgets/board_widget.dart';
import 'package:dual_clash/ui/widgets/game_page_ai_level_row.dart';
import 'package:dual_clash/ui/widgets/game_page_score_row.dart';
import 'package:dual_clash/ui/widgets/support_links_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'statistics_page.dart';

class GamePage extends StatefulWidget {
  final GameController controller;
  const GamePage({super.key, required this.controller});

  @override
  State<GamePage> createState() => _GamePageState();
}

/// Layout values derived from the board size and platform characteristics.
///
/// Centralizing these calculations keeps the UI consistent across widgets and
/// avoids accidental drift from the board sizing logic.
class GamePageLayoutMetrics {
  final bool isMobile;
  final double boardCellSize;
  final double scoreItemSize;
  final double scoreTopPadding;
  final double menuIconSize;
  final double pointsItemSize;
  final TextStyle scoreTextStyle;
  final TextStyle pointsTextStyle;
  final double? boardWidth;

  const GamePageLayoutMetrics({
    required this.isMobile,
    required this.boardCellSize,
    required this.scoreItemSize,
    required this.scoreTopPadding,
    required this.menuIconSize,
    required this.pointsItemSize,
    required this.scoreTextStyle,
    required this.pointsTextStyle,
    required this.boardWidth,
  });

  factory GamePageLayoutMetrics.from(
      BuildContext context, GameController controller) {
    final bool isMobile = Platform.isAndroid || Platform.isIOS;
    final bool isTallMobile =
        isMobile && MediaQuery.of(context).size.height > 1200;

    // Match score row icon sizes relative to exact board cell size.
    // Keep the border and grid spacing in sync with BoardWidget.
    const double boardBorderPx = 3.0;
    final double gridSpacingPx = K.n == 9 ? 2.0 : 0.0;
    final bool hasBoardSize = controller.boardPixelSize > 0;
    final double innerBoardSide =
        hasBoardSize ? controller.boardPixelSize - 2 * boardBorderPx : 0;
    final double boardCellSize = hasBoardSize
        ? (innerBoardSide - gridSpacingPx * (K.n - 1)) / K.n
        : 22.0;
    final double scoreItemSize = boardCellSize * 0.595;
    final double scoreFontScale = isTallMobile ? 0.9 : 1.0;
    final double scoreTopPadding = isTallMobile ? 20.0 : 0.0;

    final scoreTextStyle = TextStyle(
      fontSize: scoreItemSize * scoreFontScale,
      height: 1.0,
      fontWeight: FontWeight.w800,
      color: const Color(0xFFE5AD3A),
    );

    final double menuIconSize =
        isMobile ? boardCellSize * 1.2 : boardCellSize;
    final double pointsItemSize =
        isMobile ? scoreItemSize * 1.2 : scoreItemSize;

    final TextStyle pointsTextStyle = isMobile
        ? scoreTextStyle.copyWith(
            fontSize: scoreTextStyle.fontSize! * 1.2,
            fontWeight: FontWeight.w900,
          )
        : scoreTextStyle;

    return GamePageLayoutMetrics(
      isMobile: isMobile,
      boardCellSize: boardCellSize,
      scoreItemSize: scoreItemSize,
      scoreTopPadding: scoreTopPadding,
      menuIconSize: menuIconSize,
      pointsItemSize: pointsItemSize,
      scoreTextStyle: scoreTextStyle,
      pointsTextStyle: pointsTextStyle,
      boardWidth: hasBoardSize ? controller.boardPixelSize : null,
    );
  }
}

class _GamePageState extends State<GamePage> {
  BannerAd? _bannerAd;
  AdSize? _adaptiveBannerSize;
  bool _isAdLoaded = false;
  bool _hasPremium = false;
  bool _isLoadingAd = false;
  Timer? _adRetryTimer;

  GameController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _loadPremiumAndMaybeAd();
  }

  @override
  void dispose() {
    _adRetryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _maybeShowResultsDialog(BuildContext context) {
    if (controller.gameOver && !controller.resultsShown) {
      controller.resultsShown = true; // guard
      // Wait so player can see the winner border animation
      Future.delayed(Duration(milliseconds: controller.winnerBorderAnimMs), () {
        if (!context.mounted) return;
        showAnimatedResultsDialog(context: context, controller: controller);
      });
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
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    if (_hasPremium) return;
    if (_bannerAd != null || _isLoadingAd) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _resolveAdaptiveBannerSize(context);
      _loadBannerIfEligible(context);
    });
  }

  Widget _buildBottomBar(BuildContext context) {
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
        final metrics = GamePageLayoutMetrics.from(context, controller);
        final bool isMobile = metrics.isMobile;

        Future<void> openStatistics() async {
          await showAnimatedStatisticsDialog(
              context: context, controller: controller);
        }

        // Auto-show end results dialog once
        _maybeShowResultsDialog(context);

        return Scaffold(
          backgroundColor: AppColors.bg,
          bottomNavigationBar: _buildBottomBar(context),
          body: SafeArea(
            child: Column(
              children: [

                // Score row before the board — kept width-aligned with board.
                GamePageScoreRow(
                  isMobile: isMobile,
                  boardWidth: metrics.boardWidth,
                  scoreTopPadding: metrics.scoreTopPadding,
                  menuIconSize: metrics.menuIconSize,
                  scoreItemSize: metrics.scoreItemSize,
                  pointsItemSize: metrics.pointsItemSize,
                  scoreTextStyle: metrics.scoreTextStyle,
                  pointsTextStyle: metrics.pointsTextStyle,
                  redBase: redBase,
                  neutralCount: neutralsCount,
                  blueBase: blueBase,
                  redGamePoints: controller.redGamePoints,
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
                                            ? 'Simulating game...'
                                            : 'AI is thinking...',
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
              ],
            ),
          ),
        );
      },
    );
  }
}
