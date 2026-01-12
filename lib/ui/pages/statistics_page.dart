import 'dart:ui' as ui;

import 'package:dual_clash/core/localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dual_clash/ui/widgets/dialog_header.dart';
import 'package:dual_clash/ui/widgets/responsive_dialog.dart';
import '../../logic/game_controller.dart';
import '../../core/colors.dart';

class StatisticsDialog extends StatefulWidget {
  final GameController controller;
  const StatisticsDialog({super.key, required this.controller});

  @override
  State<StatisticsDialog> createState() => _StatisticsDialogState();
}

class _StatisticsDialogState extends State<StatisticsDialog> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = context.l10n;
    final scale = dialogTextScale(context);
    final bool isMobilePlatform = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final bool isMobileFullscreen = isMobilePlatform;
    final bg = AppColors.bg;
    // Prepare lists: original order and reversed (latest first)
    final original = widget.controller.turnStats;
    final items = original.reversed.toList(growable: false);
    return ResponsiveDialog(
      insetPadding: isMobileFullscreen
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: size.width * 0.1, vertical: size.height * 0.1),
      borderRadius: BorderRadius.circular(isMobileFullscreen ? 0 : 22),
      fullscreen: isMobileFullscreen,
      forceHeight: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobileFullscreen ? 0 : 22),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bg, bg]),
          boxShadow: const [
            BoxShadow(
                color: AppColors.dialogShadow,
                blurRadius: 24,
                offset: Offset(0, 12))
          ],
          border: Border.all(color: AppColors.dialogOutline, width: 1),
        ),
        child: Padding(
          padding: scaleInsets(const EdgeInsets.all(18), scale),
          child: Column(
            children: [
              DialogHeader(
                title: l10n.statisticsTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
                onClose: () => Navigator.of(context).pop(),
              ),
              SizedBox(height: 12 * scale),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(l10n.noTurnsYetMessage,
                            style: const TextStyle(color: Colors.white70)))
                    : Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        controller: _scrollCtrl,
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final it = items[index];
                            final isLatest = index == 0; // first is the latest
                            // Compute cumulative total up to this turn from original list
                            final totalAtTurn = original
                                .where((e) => e.turn <= it.turn)
                                .fold<int>(0, (sum, e) => sum + e.points);
                            return _StatTile(
                              turn: it.turn,
                              desc: it.desc,
                              points: it.points,
                              total: totalAtTurn,
                              showUndo: isLatest,
                              canUndo: widget.controller.canUndo,
                              onUndo: widget.controller.canUndo
                                  ? () {
                                      // Close statistics then undo
                                      Navigator.of(context).pop();
                                      widget.controller.undoToPreviousUserTurn();
                                    }
                                  : null,
                            );
                          },
                        ),
                      ),
              ),
              SizedBox(height: 12 * scale),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGold,
                    foregroundColor: const Color(0xFF2B221D),
                    shadowColor: Colors.black54,
                    elevation: 4,
                    padding: EdgeInsets.symmetric(
                        horizontal: 20 * scale, vertical: 12 * scale),
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
    );
  }
}

class _StatTile extends StatelessWidget {
  final int turn;
  final String desc;
  final int points;
  final int total;
  final bool showUndo;
  final bool canUndo;
  final VoidCallback? onUndo;
  const _StatTile(
      {required this.turn,
      required this.desc,
      required this.points,
      required this.total,
      this.showUndo = false,
      this.canUndo = false,
      this.onUndo});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Color borderTint = Colors.white24;
    final Color bgTint = Colors.white.withOpacity(0.06);
    return Container(
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderTint, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white38, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag_outlined,
                    size: 18, color: Colors.white70),
                const SizedBox(width: 6),
                Text(l10n.turnLabel(turn),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(desc, style: const TextStyle(color: Colors.white70)),
          ),
          const SizedBox(width: 10),
          if (showUndo)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(canUndo ? 0.10 : 0.04),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24)),
              child: IconButton(
                tooltip: l10n.undoLastActionTooltip,
                padding: EdgeInsets.zero,
                iconSize: 20,
                onPressed: canUndo ? onUndo : null,
                icon: const Icon(Icons.undo, color: Colors.white70),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:
                  (points >= 0 ? Colors.green : Colors.red).withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: (points >= 0 ? Colors.green : Colors.red)
                      .withOpacity(0.6),
                  width: 1),
            ),
            child: Text(
              '${points >= 0 ? '+' : ''}$points',
              style: TextStyle(
                  color: points >= 0 ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brandGold.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brandGold, width: 1),
            ),
            child: Text(
              '$total',
              style: const TextStyle(
                  color: AppColors.brandGold, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showAnimatedStatisticsDialog(
    {required BuildContext context, required GameController controller}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.statisticsTitle,
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic);
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
                      sigmaX: sigma * anim.value, sigmaY: sigma * anim.value),
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
                child: Builder(
                  builder: (context) {
                    return StatisticsDialog(controller: controller);
                  },
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
