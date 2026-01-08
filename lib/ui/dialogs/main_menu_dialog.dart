import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dual_clash/core/feature_flags.dart';
import 'package:dual_clash/core/localization.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/core/constants.dart';
import 'package:dual_clash/ui/dialogs/save_game_dialog.dart';
import 'package:dual_clash/ui/pages/help_page.dart';
import 'package:dual_clash/ui/pages/settings_page.dart';
import 'package:dual_clash/ui/pages/profile_page.dart';
import 'package:dual_clash/ui/pages/history_page.dart';
import 'package:dual_clash/ui/pages/statistics_page.dart';
import 'package:dual_clash/models/cell_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal, independent "Main Menu" dialog styled like Profile dialog
/// but with a solid #FFA213 background as requested.
class MenuDialogConfig {
  final bool showStatistics;
  final bool showSettings;
  final bool showSaveGame;
  final bool showSimulateGame;
  final bool showRemoveAds;
  final bool showRestorePurchases;
  final bool confirmReturnToMenu;
  final bool confirmRestart;

  const MenuDialogConfig({
    this.showStatistics = true,
    this.showSettings = true,
    this.showSaveGame = true,
    this.showSimulateGame = true,
    this.showRemoveAds = true,
    this.showRestorePurchases = true,
    this.confirmReturnToMenu = true,
    this.confirmRestart = true,
  });

  const MenuDialogConfig.duel()
      : showStatistics = false,
        showSettings = true,
        showSaveGame = false,
        showSimulateGame = true,
        showRemoveAds = true,
        showRestorePurchases = true,
        confirmReturnToMenu = true,
        confirmRestart = true;
}

class MainMenuDialog extends StatefulWidget {
  final GameController controller;
  final MenuDialogConfig config;
  const MainMenuDialog({
    super.key,
    required this.controller,
    this.config = const MenuDialogConfig(),
  });

  @override
  State<MainMenuDialog> createState() => _MainMenuDialogState();
}

class _MainMenuDialogState extends State<MainMenuDialog> {
  static const Color _menuBg = Color(0xFF38518F); // 0xFFFFA213);
  static const String _premiumProductId = 'premium_upgrade';

  InAppPurchase? _iap;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  ProductDetails? _premiumProduct;
  bool _iapAvailable = false;
  bool _handledPurchase = false;

  GameController get controller => widget.controller;
  MenuDialogConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    if (FF_ADS && (Platform.isAndroid || Platform.isIOS)) {
      _iap = InAppPurchase.instance;
      _purchaseSub = _iap!.purchaseStream.listen(
        _handlePurchases,
        onError: (_) {},
      );
      _loadProducts();
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final iap = _iap;
    if (iap == null) return;
    final available = await iap.isAvailable();
    if (!mounted) return;
    setState(() {
      _iapAvailable = available;
    });
    if (!available) return;
    final response = await iap.queryProductDetails({_premiumProductId});
    if (!mounted) return;
    if (response.productDetails.isNotEmpty) {
      setState(() {
        _premiumProduct = response.productDetails.first;
      });
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (_handledPurchase) continue;
        _handledPurchase = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_premium', true);
        if (purchase.pendingCompletePurchase) {
          await _iap?.completePurchase(purchase);
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else if (purchase.status == PurchaseStatus.error &&
          purchase.pendingCompletePurchase) {
        await _iap?.completePurchase(purchase);
      }
    }
  }

  Future<void> _buyPremium() async {
    if (!FF_ADS) return;
    if (_iap == null || !_iapAvailable || _premiumProduct == null) {
      return;
    }
    final purchaseParam = PurchaseParam(productDetails: _premiumProduct!);
    await _iap?.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _saveGame(BuildContext context) async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final rootContext = rootNavigator.context;
    final red = controller.scoreRedBase();
    final blue = controller.scoreBlueBase();
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final belt = AiBelt.nameFor(controller.aiLevel).replaceAll(' ', '_');
    final defaultName =
        '${now.year}-${two(now.month)}-${two(now.day)}-${two(now.hour)}-${two(now.minute)}-${two(now.second)}-AI_${belt}-RED-${red}-BLUE-${blue}';
    await showAnimatedSaveGameDialog(
      context: rootContext,
      initialName: defaultName,
      title: rootContext.l10n.saveGameTitle,
      nameLabel: rootContext.l10n.saveGameNameLabel,
      saveButtonLabel: rootContext.l10n.commonSave,
      cancelButtonLabel: rootContext.l10n.commonCancel,
      nameHint: rootContext.l10n.saveGameNameHint,
      onSave: (name) async {
        await controller.saveCurrentGame(name: name);
        final messenger = ScaffoldMessenger.maybeOf(rootContext);
        messenger?.showSnackBar(
          SnackBar(content: Text(rootContext.l10n.gameSavedMessage)),
        );
      },
    );
  }

  Future<bool> _confirmAction({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    final l10n = context.l10n;
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: title,
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, a2, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final bg = AppColors.bg;
        return Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: anim,
                builder: (context, _) => BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: 6 * anim.value,
                    sigmaY: 6 * anim.value,
                  ),
                  child: const SizedBox.shrink(),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                  child: Dialog(
                    insetPadding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [bg, bg],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.dialogShadow,
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          )
                        ],
                        border:
                            Border.all(color: AppColors.dialogOutline, width: 1),
                      ),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: 520, maxHeight: 280),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Spacer(),
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      icon: const Icon(Icons.close,
                                          color: Colors.white70),
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                message,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  height: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            Colors.white.withOpacity(0.08),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          side: const BorderSide(
                                              color: Colors.white24),
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      child: Text(l10n.commonNo),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.brandGold,
                                        foregroundColor: const Color(0xFF2B221D),
                                        shadowColor: Colors.black54,
                                        elevation: 4,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      child: Text(l10n.commonYes),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = context.l10n;
    final bool isMobilePlatform = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final bool isTabletDevice = isTablet(context);
    final bool isPhoneFullscreen = isMobilePlatform && !isTabletDevice;
    final EdgeInsets dialogInsetPadding = isPhoneFullscreen
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(
            horizontal: size.width * 0.1, vertical: size.height * 0.1);
    final BorderRadius dialogRadius =
        BorderRadius.circular(isPhoneFullscreen ? 0 : 22);
    final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
        18, isPhoneFullscreen ? 20 : 18, 18, 18);
    return Dialog(
      insetPadding: dialogInsetPadding,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: dialogRadius),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: dialogRadius,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_menuBg, _menuBg],
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.dialogShadow,
              blurRadius: 24,
              offset: Offset(0, 12),
            )
          ],
          border: Border.all(color: AppColors.dialogOutline, width: 1),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isPhoneFullscreen ? size.width : size.width * 0.8,
            maxHeight:
                isPhoneFullscreen ? size.height : size.height * 0.8,
            minWidth: isPhoneFullscreen ? size.width : 0,
            minHeight: isPhoneFullscreen ? size.height : 0,
          ),
          child: SafeArea(
            top: isPhoneFullscreen,
            bottom: isPhoneFullscreen,
            child: Padding(
              padding: contentPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        l10n.menuTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dialogTitle,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 20,
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _menuTile(
                            context,
                            icon: Icons.arrow_back,
                            label: l10n.returnToMainMenuLabel,
                            onTap: () async {
                              // Use captured navigator to avoid disposed context
                              final nav = Navigator.of(context);
                              // Close menu dialog
                              nav.pop();
                              await Future.delayed(
                                  const Duration(milliseconds: 30));
                              if (config.confirmReturnToMenu) {
                                final confirmed = await _confirmAction(
                                  context: context,
                                  title: l10n.returnToMainMenuTitle,
                                  message: l10n.returnToMainMenuMessage,
                                );
                                if (!confirmed) return;
                              }
                              // Then pop the GamePage route to return to Main Menu
                              if (nav.canPop()) {
                                nav.pop();
                              }
                            },
                          ),
                          const SizedBox(height: 6),
                          _menuTile(
                            context,
                            icon: Icons.refresh,
                            label: l10n.restartGameLabel,
                            onTap: () async {
                              Navigator.of(context).pop();
                              await Future.delayed(
                                  const Duration(milliseconds: 30));
                              if (config.confirmRestart) {
                                final confirmed = await _confirmAction(
                                  context: context,
                                  title: l10n.restartGameTitle,
                                  message: l10n.restartGameMessage,
                                );
                                if (!confirmed) return;
                              }
                              controller.newGame();
                            },
                          ),
                          if (config.showStatistics) ...[
                            const SizedBox(height: 6),
                            _menuTile(
                              context,
                              icon: Icons.bar_chart,
                              label: l10n.statisticsTitle,
                              onTap: () async {
                                Navigator.of(context).pop();
                                await Future.delayed(
                                    const Duration(milliseconds: 30));
                                await showAnimatedStatisticsDialog(
                                  context: context,
                                  controller: controller,
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 6),
                          _menuTile(
                            context,
                            icon: Icons.help_outline,
                            label: l10n.helpTitle,
                            onTap: () async {
                              Navigator.of(context).pop();
                              await Future.delayed(
                                  const Duration(milliseconds: 30));
                              await showAnimatedHelpDialog(
                                  context: context, controller: controller);
                            },
                          ),
                          if (config.showSettings) ...[
                            const SizedBox(height: 6),
                            _menuTile(
                              context,
                              icon: Icons.settings,
                              label: l10n.settingsTitle,
                              onTap: () async {
                                Navigator.of(context).pop();
                                await Future.delayed(
                                    const Duration(milliseconds: 30));
                                await showAnimatedSettingsDialog(
                                    context: context, controller: controller);
                              },
                            ),
                          ],
/*
                        const SizedBox(height: 6),
                        _menuTile(
                          context,
                          icon: Icons.person_outline,
                          label: 'Profile',
                          onTap: () async {
                            Navigator.of(context).pop();
                            await Future.delayed(const Duration(milliseconds: 30));
                            await showAnimatedProfileDialog(context: context, controller: controller);
                          },
                        ),
                        const SizedBox(height: 6),
                        _menuTile(
                          context,
                          icon: Icons.history,
                          label: 'History',
                          onTap: () async {
                            Navigator.of(context).pop();
                            await Future.delayed(const Duration(milliseconds: 30));
                            await showAnimatedHistoryDialog(context: context, controller: controller);
                          },
                        ),
  */
                          if (config.showSaveGame) ...[
                            const SizedBox(height: 6),
                            _menuTile(
                              context,
                              icon: Icons.save_alt,
                              label: l10n.saveGameTitle,
                              onTap: () async {
                                Navigator.of(context).pop();
                                await Future.delayed(
                                    const Duration(milliseconds: 30));
                                await _saveGame(context);
                              },
                            ),
                          ],
                          if (config.showSimulateGame) ...[
                            const SizedBox(height: 6),
                            if (controller.humanVsHuman)
                              _menuTile(
                                context,
                                icon: Icons.auto_awesome,
                                label: l10n.simulateGameLabel,
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await Future.delayed(
                                      const Duration(milliseconds: 30));
                                  await controller.simulateGame();
                                },
                              )
                            else ...[
                              _menuTile(
                                context,
                                icon: Icons.auto_awesome,
                                label: l10n.simulateGameHumanWinLabel,
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await Future.delayed(
                                      const Duration(milliseconds: 30));
                                  await controller.simulateGame(
                                      forcedWinner: CellState.red);
                                },
                              ),
                              const SizedBox(height: 6),
                              _menuTile(
                                context,
                                icon: Icons.auto_awesome,
                                label: l10n.simulateGameAiWinLabel,
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await Future.delayed(
                                      const Duration(milliseconds: 30));
                                  await controller.simulateGame(
                                      forcedWinner: CellState.blue);
                                },
                              ),
                              const SizedBox(height: 6),
                              _menuTile(
                                context,
                                icon: Icons.auto_awesome,
                                label: l10n.simulateGameGreyWinLabel,
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await Future.delayed(
                                      const Duration(milliseconds: 30));
                                  await controller.simulateGame(
                                      forcedWinner: CellState.neutral);
                                },
                              ),
                            ],
                          ],
                          if (FF_ADS && config.showRemoveAds) ...[
                            const SizedBox(height: 6),
                            _menuTile(
                              context,
                              icon: Icons.block,
                              label: l10n.removeAdsLabel,
                              onTap: () async {
                                await _buyPremium();
                              },
                            ),
                          ],
                          if (FF_ADS &&
                              config.showRestorePurchases &&
                              Platform.isIOS) ...[
                            const SizedBox(height: 6),
                            _menuTile(
                              context,
                              icon: Icons.restore,
                              label: l10n.restorePurchasesLabel,
                              onTap: () async {
                                await _iap?.restorePurchases();
                              },
                            ),
                          ],
                          if (isPhoneFullscreen) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandGold,
                                  foregroundColor: const Color(0xFF2B221D),
                                  shadowColor: Colors.black54,
                                  elevation: 4,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2),
                                ),
                                child: Text(l10n.commonClose),
                              ),
                            ),
                          ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _menuTile(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        onTap: onTap,
      ),
    );
  }
}

Future<void> showAnimatedMainMenuDialog({
  required BuildContext context,
  required GameController controller,
  MenuDialogConfig config = const MenuDialogConfig(),
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.mainMenuBarrierLabel,
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return Stack(
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 6),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              builder: (context, sigma, _) {
                return BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: sigma * anim.value,
                    sigmaY: sigma * anim.value,
                  ),
                  child: const SizedBox.shrink(),
                );
              },
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                child: MainMenuDialog(controller: controller, config: config),
              ),
            ),
          ),
        ],
      );
    },
  );
}
