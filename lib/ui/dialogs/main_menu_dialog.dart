import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/core/constants.dart';
import 'package:dual_clash/ui/dialogs/save_game_dialog.dart';
import 'package:dual_clash/ui/pages/help_page.dart';
import 'package:dual_clash/ui/pages/settings_page.dart';
import 'package:dual_clash/ui/pages/profile_page.dart';
import 'package:dual_clash/ui/pages/history_page.dart';
import 'package:dual_clash/ui/pages/statistics_page.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal, independent "Main Menu" dialog styled like Profile dialog
/// but with a solid #FFA213 background as requested.
class MainMenuDialog extends StatefulWidget {
  final GameController controller;
  const MainMenuDialog({super.key, required this.controller});

  @override
  State<MainMenuDialog> createState() => _MainMenuDialogState();
}

class _MainMenuDialogState extends State<MainMenuDialog> {
  static const Color _menuBg = Color(0xFF38518F); // 0xFFFFA213);
  static const String _premiumProductId = 'premium_upgrade';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  ProductDetails? _premiumProduct;
  bool _iapAvailable = false;
  bool _handledPurchase = false;

  GameController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _purchaseSub = _iap.purchaseStream.listen(
      _handlePurchases,
      onError: (_) {},
    );
    _loadProducts();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final available = await _iap.isAvailable();
    if (!mounted) return;
    setState(() {
      _iapAvailable = available;
    });
    if (!available) return;
    final response = await _iap.queryProductDetails({_premiumProductId});
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
          await _iap.completePurchase(purchase);
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else if (purchase.status == PurchaseStatus.error &&
          purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _buyPremium() async {
    if (!_iapAvailable || _premiumProduct == null) {
      return;
    }
    final purchaseParam = PurchaseParam(productDetails: _premiumProduct!);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _saveGame(BuildContext context) async {
    final red = controller.scoreRedBase();
    final blue = controller.scoreBlueBase();
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final belt = AiBelt.nameFor(controller.aiLevel).replaceAll(' ', '_');
    final defaultName =
        '${now.year}-${two(now.month)}-${two(now.day)}-${two(now.hour)}-${two(now.minute)}-${two(now.second)}-AI_${belt}-RED-${red}-BLUE-${blue}';
    await showAnimatedSaveGameDialog(
      context: context,
      initialName: defaultName,
      onSave: (name) async {
        await controller.saveCurrentGame(name: name);
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Game saved')));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
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
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'Menu',
                      style: TextStyle(
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
                          label: 'Return to main menu',
                          onTap: () async {
                            // Use captured navigator to avoid disposed context
                            final nav = Navigator.of(context);
                            // Close menu dialog
                            nav.pop();
                            await Future.delayed(const Duration(milliseconds: 30));
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
                          label: 'Restart/Start the game',
                          onTap: () async {
                            Navigator.of(context).pop();
                            await Future.delayed(const Duration(milliseconds: 30));
                            controller.newGame();
                          },
                        ),
                        const SizedBox(height: 6),
                        _menuTile(
                          context,
                          icon: Icons.bar_chart,
                          label: 'Statistics',
                          onTap: () async {
                            Navigator.of(context).pop();
                            await Future.delayed(const Duration(milliseconds: 30));
                            await showAnimatedStatisticsDialog(
                              context: context,
                              controller: controller,
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        _menuTile(
                          context,
                          icon: Icons.help_outline,
                          label: 'Help',
                          onTap: () async {
                            Navigator.of(context).pop();
                            await Future.delayed(const Duration(milliseconds: 30));
                            await showAnimatedHelpDialog(context: context, controller: controller);
                          },
                        ),
                        const SizedBox(height: 6),
                        _menuTile(
                          context,
                          icon: Icons.settings,
                          label: 'Settings',
                          onTap: () async {
                            Navigator.of(context).pop();
                            await Future.delayed(const Duration(milliseconds: 30));
                            await showAnimatedSettingsDialog(context: context, controller: controller);
                          },
                        ),
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
                        const SizedBox(height: 6),
                        _menuTile(
                          context,
                          icon: Icons.save_alt,
                          label: 'Save game',
                          onTap: () async {
                            Navigator.of(context).pop();
                            await Future.delayed(const Duration(milliseconds: 30));
                            await _saveGame(context);
                          },
                        ),
                        const SizedBox(height: 6),
                        _menuTile(
                          context,
                          icon: Icons.auto_awesome,
                          label: 'Simulate game',
                          onTap: () async {
                            Navigator.of(context).pop();
                            await Future.delayed(const Duration(milliseconds: 30));
                            await controller.simulateGame();
                          },
                        ),
                        const SizedBox(height: 6),
                        _menuTile(
                          context,
                          icon: Icons.block,
                          label: 'Remove Ads — 1€',
                          onTap: () async {
                            await _buyPremium();
                          },
                        ),
                        if (Platform.isIOS) ...[
                          const SizedBox(height: 6),
                          _menuTile(
                            context,
                            icon: Icons.restore,
                            label: 'Restore Purchases',
                            onTap: () async {
                              await _iap.restorePurchases();
                            },
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
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Main Menu',
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
                child: MainMenuDialog(controller: controller),
              ),
            ),
          ),
        ],
      );
    },
  );
}
