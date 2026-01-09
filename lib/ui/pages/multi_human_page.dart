import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../logic/multi_game_controller.dart';
import '../../core/localization.dart';
import '../widgets/multi_board_widget.dart';
import '../../models/multi_cell_state.dart';

class TripleThreatPage extends StatefulWidget {
  const TripleThreatPage({super.key});

  @override
  State<TripleThreatPage> createState() => _TripleThreatPageState();
}

class QuadClashPage extends StatefulWidget {
  const QuadClashPage({super.key});

  @override
  State<QuadClashPage> createState() => _QuadClashPageState();
}

class _TripleThreatPageState extends State<TripleThreatPage> {
  late final MultiGameController controller;

  @override
  void initState() {
    super.initState();
    controller = MultiGameController.triple()..newGame();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MultiScaffold(
        controller: controller,
        title: context.l10n.menuTripleThreat);
  }
}

class _QuadClashPageState extends State<QuadClashPage> {
  late final MultiGameController controller;

  @override
  void initState() {
    super.initState();
    controller = MultiGameController.quad()..newGame();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MultiScaffold(
        controller: controller,
        title: context.l10n.menuQuadClash);
  }
}

class _MultiScaffold extends StatefulWidget {
  final MultiGameController controller;
  final String title;
  const _MultiScaffold({required this.controller, required this.title});

  @override
  State<_MultiScaffold> createState() => _MultiScaffoldState();
}

class _MultiScaffoldState extends State<_MultiScaffold> {
  Future<bool> _confirmLeave(BuildContext context) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.leaveBarrierLabel,
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
                                    context.l10n.leaveModeTitle(widget.title),
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
                                context.l10n.leaveMultiModeMessage,
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
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        return WillPopScope(
          onWillPop: () => _confirmLeave(context),
          child: Scaffold(
            backgroundColor: AppColors.bg,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 14.0, left: 16.0, right: 16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Image.asset('assets/icons/menu_121.png', width: 28, height: 28),
                          tooltip: context.l10n.mainMenuTooltip,
                          onPressed: () async {
                            final ok = await _confirmLeave(context);
                            if (ok && context.mounted) Navigator.of(context).pop();
                          },
                        ),
                        const Spacer(),
                        SizedBox.shrink(),
                        const Spacer(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Center(child: MultiBoardWidget(controller: c)),
                    ),
                  ),
                  // Turn row below the board
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0, top: 6.0),
                    child: Center(
                      child: SizedBox(
                        width: c.boardPixelSize > 0 ? c.boardPixelSize : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _turnChip(
                                c, MultiCellState.red, context.l10n.redShortLabel),
                            const SizedBox(width: 8),
                            _turnChip(
                                c, MultiCellState.blue, context.l10n.blueShortLabel),
                            const SizedBox(width: 8),
                            _turnChip(
                                c,
                                MultiCellState.yellow,
                                context.l10n.yellowShortLabel),
                            if (c.playersCount == 4) const SizedBox(width: 8),
                            if (c.playersCount == 4)
                              _turnChip(
                                  c,
                                  MultiCellState.green,
                                  context.l10n.greenShortLabel),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _turnChip(MultiGameController c, MultiCellState who, String label) {
    final isTurn = c.current == who;
    final color = c.colorFor(who);
    final inner = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white24, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
    if (!isTurn) return inner;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brandGold, width: 2),
      ),
      child: inner,
    );
  }
}
