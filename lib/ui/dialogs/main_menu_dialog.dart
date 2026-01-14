import 'dart:async';
import 'dart:ui' as ui;
import 'package:dual_clash/core/feature_flags.dart';
import 'package:dual_clash/core/localization.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/core/constants.dart';
import 'package:dual_clash/l10n/app_localizations.dart';
import 'package:dual_clash/ui/dialogs/save_game_dialog.dart';
import 'package:dual_clash/ui/pages/help_page.dart';
import 'package:dual_clash/ui/pages/settings_page.dart';
import 'package:dual_clash/ui/pages/statistics_page.dart';
import 'package:dual_clash/ui/dialogs/confirm_action_dialog.dart';
import 'package:dual_clash/models/cell_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dual_clash/core/platforms.dart';
import 'package:dual_clash/logic/admin_mode_service.dart';

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

class _MenuEntry {
  final IconData icon;
  final String label;
  final Future<void> Function() onTap;
  final bool requiresAdmin;

  const _MenuEntry({
    required this.icon,
    required this.label,
    required this.onTap,
    this.requiresAdmin = false,
  });
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
    if (FF_ADS && isMobile) {
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

  final AdminModeService _adminModeService = AdminModeService.instance;

  List<_MenuEntry> _buildMenuEntries(BuildContext context) {
    final l10n = context.l10n;
    final entries = <_MenuEntry>[
      _MenuEntry(
        icon: Icons.arrow_back,
        label: l10n.returnToMainMenuLabel,
        onTap: () async {
          final nav = Navigator.of(context);
          nav.pop();
          await Future.delayed(const Duration(milliseconds: 30));
          if (config.confirmReturnToMenu) {
            final confirmed = await showConfirmActionDialog(
              context: context,
              title: l10n.returnToMainMenuTitle,
              message: l10n.returnToMainMenuMessage,
              confirmLabel: l10n.commonYes,
              cancelLabel: l10n.commonNo,
            );
            if (!confirmed) return;
          }
          if (nav.canPop()) {
            nav.pop();
          }
        },
      ),
      _MenuEntry(
        icon: Icons.refresh,
        label: l10n.restartGameLabel,
        onTap: () async {
          Navigator.of(context).pop();
          await Future.delayed(const Duration(milliseconds: 30));
          if (config.confirmRestart) {
            final confirmed = await showConfirmActionDialog(
              context: context,
              title: l10n.restartGameTitle,
              message: l10n.restartGameMessage,
              confirmLabel: l10n.commonYes,
              cancelLabel: l10n.commonNo,
            );
            if (!confirmed) return;
          }
          controller.newGame();
        },
      ),
      if (config.showStatistics)
        _MenuEntry(
          icon: Icons.bar_chart,
          label: l10n.statisticsTitle,
          onTap: () async {
            Navigator.of(context).pop();
            await Future.delayed(const Duration(milliseconds: 30));
            await showAnimatedStatisticsDialog(
              context: context,
              controller: controller,
            );
          },
        ),
      _MenuEntry(
        icon: Icons.help_outline,
        label: l10n.helpTitle,
        onTap: () async {
          Navigator.of(context).pop();
          await Future.delayed(const Duration(milliseconds: 30));
          await showAnimatedHelpDialog(context: context, controller: controller);
        },
      ),
      if (config.showSettings)
        _MenuEntry(
          icon: Icons.settings,
          label: l10n.settingsTitle,
          onTap: () async {
            Navigator.of(context).pop();
            await Future.delayed(const Duration(milliseconds: 30));
            await showAnimatedSettingsDialog(
                context: context, controller: controller);
          },
        ),
      if (config.showSaveGame)
        _MenuEntry(
          icon: Icons.save_alt,
          label: l10n.saveGameTitle,
          onTap: () async {
            Navigator.of(context).pop();
            await Future.delayed(const Duration(milliseconds: 30));
            await _saveGame(context);
          },
        ),
      if (config.showSimulateGame)
        ..._buildSimulationEntries(context, l10n),
      if (FF_ADS && config.showRemoveAds)
        _MenuEntry(
          icon: Icons.block,
          label: l10n.removeAdsLabel,
          onTap: () async {
            await _buyPremium();
          },
        ),
      if (FF_ADS && config.showRestorePurchases && isIOS)
        _MenuEntry(
          icon: Icons.restore,
          label: l10n.restorePurchasesLabel,
          onTap: () async {
            await _iap?.restorePurchases();
          },
        ),
    ];
    return entries;
  }

  List<_MenuEntry> _buildSimulationEntries(
      BuildContext context, AppLocalizations l10n) {
    if (controller.humanVsHuman) {
      return [
        _MenuEntry(
          icon: Icons.auto_awesome,
          label: l10n.simulateGameLabel,
          requiresAdmin: true,
          onTap: () async {
            Navigator.of(context).pop();
            await Future.delayed(const Duration(milliseconds: 30));
            await controller.simulateGame();
          },
        ),
      ];
    }
    return [
      _MenuEntry(
        icon: Icons.auto_awesome,
        label: l10n.simulateGameHumanWinLabel,
        requiresAdmin: true,
        onTap: () async {
          Navigator.of(context).pop();
          await Future.delayed(const Duration(milliseconds: 30));
          await controller.simulateGame(forcedWinner: CellState.red);
        },
      ),
      _MenuEntry(
        icon: Icons.auto_awesome,
        label: l10n.simulateGameAiWinLabel,
        requiresAdmin: true,
        onTap: () async {
          Navigator.of(context).pop();
          await Future.delayed(const Duration(milliseconds: 30));
          await controller.simulateGame(forcedWinner: CellState.blue);
        },
      ),
      _MenuEntry(
        icon: Icons.auto_awesome,
        label: l10n.simulateGameGreyWinLabel,
        requiresAdmin: true,
        onTap: () async {
          Navigator.of(context).pop();
          await Future.delayed(const Duration(milliseconds: 30));
          await controller.simulateGame(forcedWinner: CellState.neutral);
        },
      ),
    ];
  }

  List<Widget> _buildMenuTiles(
      BuildContext context, List<_MenuEntry> entries) {
    final tiles = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      if (i > 0) {
        tiles.add(const SizedBox(height: 6));
      }
      tiles.add(_menuTile(
        context,
        icon: entries[i].icon,
        label: entries[i].label,
        onTap: entries[i].onTap,
      ));
    }
    return tiles;
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
                          ValueListenableBuilder<bool>(
                            valueListenable:
                                AdminModeService.adminEnabledListenable,
                            builder: (context, _, child) {
                              final entries = _buildMenuEntries(context);
                              final visibleEntries = entries
                                  .where(
                                    (entry) => _adminModeService
                                        .canShowMenuItem(
                                            requiresAdmin: entry.requiresAdmin),
                                  )
                                  .toList();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children:
                                    _buildMenuTiles(context, visibleEntries),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
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
                            fontWeight: FontWeight.w800, letterSpacing: 0.2),
                      ),
                      child: Text(l10n.commonClose),
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
      required Future<void> Function() onTap}) {
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
        onTap: () {
          unawaited(onTap());
        },
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
