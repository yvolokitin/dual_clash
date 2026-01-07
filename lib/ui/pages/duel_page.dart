import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui; // for potential future effects
import 'package:dual_clash/core/localization.dart';
import 'package:dual_clash/logic/game_controller.dart';
import 'package:dual_clash/core/colors.dart';
import 'package:dual_clash/models/cell_state.dart';
import 'package:dual_clash/logic/rules_engine.dart';
import 'package:dual_clash/ui/widgets/board_widget.dart';
import 'package:dual_clash/ui/widgets/game_layout_metrics.dart';
import 'package:dual_clash/ui/dialogs/main_menu_dialog.dart' as mmd;
import 'package:dual_clash/ui/dialogs/results_dialog.dart' as results;

class DuelPage extends StatefulWidget {
  final GameController controller;
  final int playerCount;
  const DuelPage({super.key, required this.controller, this.playerCount = 2});

  @override
  State<DuelPage> createState() => _DuelPageState();
}

class _DuelPageState extends State<DuelPage> {
  Future<bool> _confirmLeaveDuel(BuildContext context) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.leaveDuelBarrierLabel,
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 260),
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
                  scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
                  child: Dialog(
                    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
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
                        border: Border.all(color: AppColors.dialogOutline, width: 1),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 320),
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
                                    context.l10n.leaveDuelTitle,
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
                                      icon: const Icon(Icons.close, color: Colors.white70),
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                context.l10n.leaveDuelMessage,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  height: 1.2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.white.withOpacity(0.08),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: const BorderSide(color: Colors.white24),
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      child: Text(context.l10n.commonCancel),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.brandGold,
                                        foregroundColor: const Color(0xFF2B221D),
                                        shadowColor: Colors.black54,
                                        elevation: 4,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      child: Text(context.l10n.leaveLabel),
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
  void initState() {
    super.initState();
    // Enable human vs human and start a fresh game
    widget.controller.humanVsHuman = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.controller.setDuelPlayerCount(widget.playerCount);
      // Ensure AI doesn't schedule at start
      widget.controller.newGame();
    });
  }

  @override
  void dispose() {
    // Restore default mode when leaving Duel page
    widget.controller.humanVsHuman = false;
    widget.controller.setDuelPlayerCount(2);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final redBase = controller.scoreRedBase();
        final blueBase = controller.scoreBlueBase();
        final yellowBase = controller.scoreYellowBase();
        final greenBase = controller.scoreGreenBase();
        final neutralsCount = RulesEngine.countOf(controller.board, CellState.neutral);
        final metrics = GameLayoutMetrics.from(context, controller);
        final boardCellSize = metrics.boardCellSize;
        final scoreItemSize = metrics.scoreItemSize;
        final scoreTopPadding = metrics.scoreTopPadding;
        final menuIconSize = metrics.menuIconSize;
        final textStyle = metrics.scoreTextStyle;
        final isMobile = metrics.isMobile;

        results.maybeShowResultsDialog(
          context: context,
          controller: controller,
        );

        return WillPopScope(
          onWillPop: () => _confirmLeaveDuel(context),
          child: Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                if (Platform.isAndroid || Platform.isIOS)
                  const SizedBox(height: 20),
                // Score row (no game points, only back to main menu)
                Padding(
                  padding: EdgeInsets.only(
                      top: 4.0 + scoreTopPadding,
                      bottom: 14.0,
                      left: 16.0,
                      right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: metrics.boardWidth,
                      child: Builder(
                        builder: (context) {
                          final playerCountsRow = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!controller.isMultiDuel) ...[
                                Text('$redBase', style: textStyle),
                                const SizedBox(width: 6),
                                Image.asset('assets/icons/player_red.png',
                                    width: scoreItemSize, height: scoreItemSize),
                                const SizedBox(width: 18),
                                Text('$neutralsCount', style: textStyle),
                                const SizedBox(width: 6),
                                Image.asset('assets/icons/player_grey.png',
                                    width: scoreItemSize, height: scoreItemSize),
                                const SizedBox(width: 18),
                                Text('$blueBase', style: textStyle),
                                const SizedBox(width: 6),
                                Image.asset('assets/icons/player_blue.png',
                                    width: scoreItemSize, height: scoreItemSize),
                              ] else ...[
                                Text('$redBase', style: textStyle),
                                const SizedBox(width: 6),
                                Image.asset('assets/icons/player_red.png',
                                    width: scoreItemSize, height: scoreItemSize),
                                const SizedBox(width: 14),
                                Text('$blueBase', style: textStyle),
                                const SizedBox(width: 6),
                                Image.asset('assets/icons/player_blue.png',
                                    width: scoreItemSize, height: scoreItemSize),
                                const SizedBox(width: 14),
                                Text('$yellowBase', style: textStyle),
                                const SizedBox(width: 6),
                                Image.asset('assets/icons/player_yellow.png',
                                    width: scoreItemSize, height: scoreItemSize),
                                if (controller.duelPlayerCount >= 4) ...[
                                  const SizedBox(width: 14),
                                  Text('$greenBase', style: textStyle),
                                  const SizedBox(width: 6),
                                  Image.asset('assets/icons/player_green.png',
                                      width: scoreItemSize, height: scoreItemSize),
                                ],
                                const SizedBox(width: 14),
                                Text('$neutralsCount', style: textStyle),
                                const SizedBox(width: 6),
                                Image.asset('assets/icons/player_grey.png',
                                    width: scoreItemSize, height: scoreItemSize),
                              ],
                            ],
                          );

                          if (isMobile) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints.tightFor(
                                        width: menuIconSize,
                                        height: menuIconSize,
                                      ),
                                      icon: Image.asset(
                                        'assets/icons/menu_pvai.png',
                                        width: menuIconSize,
                                        height: menuIconSize,
                                      ),
                                      tooltip: context.l10n.menuTitle,
                                      onPressed: () async {
                                        await mmd.showAnimatedMainMenuDialog(
                                            context: context,
                                            controller: controller,
                                            config:
                                                const mmd.MenuDialogConfig.duel());
                                      },
                                    ),
                                    const SizedBox(width: 1),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Center(child: playerCountsRow),
                              ],
                            );
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left side: main menu button pops back directly
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints.tightFor(
                                      width: menuIconSize,
                                      height: menuIconSize,
                                    ),
                                    icon: Image.asset(
                                      'assets/icons/menu_pvai.png',
                                      width: menuIconSize,
                                      height: menuIconSize,
                                    ),
                                    tooltip: context.l10n.menuTitle,
                                    onPressed: () async {
                                      await mmd.showAnimatedMainMenuDialog(
                                          context: context,
                                          controller: controller,
                                          config: const mmd.MenuDialogConfig.duel());
                                    },
                                  ),
                                ],
                              ),
                              // Middle: turn indicator moved to bottom row
                              const SizedBox.shrink(),
                              // Right side: counts only (number -> icon) for red, grey, blue
                              playerCountsRow,
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Board centered
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        BoardWidget(controller: controller),
                      ],
                    ),
                  ),
                ),
                // Turn row below the board
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, top: 6.0),
                  child: Center(
                    child: SizedBox(
                      width: metrics.boardWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _TurnBox(
                            label: context.l10n.colorRedLabel,
                            iconPath: 'assets/icons/box_red.png',
                            color: AppColors.red,
                            active: controller.current == CellState.red,
                            size: scoreItemSize,
                          ),
                          const SizedBox(width: 10),
                          _TurnBox(
                            label: context.l10n.colorBlueLabel,
                            iconPath: 'assets/icons/box_blue.png',
                            color: AppColors.blue,
                            active: controller.current == CellState.blue,
                            size: scoreItemSize,
                          ),
                          if (controller.isMultiDuel) ...[
                            const SizedBox(width: 10),
                            _TurnBox(
                              label: context.l10n.colorYellowLabel,
                              iconPath: 'assets/icons/box_yellow.png',
                              color: AppColors.yellow,
                              active: controller.current == CellState.yellow,
                              size: scoreItemSize,
                            ),
                            if (controller.duelPlayerCount >= 4) ...[
                              const SizedBox(width: 10),
                              _TurnBox(
                                label: context.l10n.colorGreenLabel,
                                iconPath: 'assets/icons/box_green.png',
                                color: AppColors.green,
                                active: controller.current == CellState.green,
                                size: scoreItemSize,
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // No simulate/statistics/undo row in duel mode
              ],
            ),
          ),
        ),
      );
      },
    );
  }
}


class _TurnBox extends StatelessWidget {
  final String label;
  final String iconPath;
  final Color color;
  final bool active;
  final double size;
  const _TurnBox({
    super.key,
    required this.label,
    required this.iconPath,
    required this.color,
    required this.active,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = active ? color : Colors.transparent;
    final bg = Colors.white.withOpacity(active ? 0.10 : 0.06);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: size, height: size),
          // Optional label:
          // const SizedBox(width: 6),
          // Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
