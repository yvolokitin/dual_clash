import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../logic/game_controller.dart';
import '../../core/colors.dart';
import 'history_page.dart';
import 'profile_page.dart';

Future<void> showAnimatedMainMenuDialog(
    {required BuildContext context, required GameController controller}) async {
  final bg = AppColors.bg;
  await showGeneralDialog<void>(
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
                child: Dialog(
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
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
                      border:
                          Border.all(color: AppColors.dialogOutline, width: 1),
                    ),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 520, maxHeight: 560),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Spacer(),
                                const Text('Game Menu',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800)),
                                const Spacer(),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: Colors.white24)),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 20,
                                    icon: const Icon(Icons.close,
                                        color: Colors.white70),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _StatsAnimatedBox(
                                totalScore: controller.totalUserScore,
                                totalPlayTimeMs: controller.totalPlayTimeMs),
                            const SizedBox(height: 16),
                            _MenuTile(
                              icon: Icons.flash_on,
                              label: 'Game challenge',
                              onTap: () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Game Challenge is coming soon')));
                              },
                            ),
                            _MenuTile(
                              icon: Icons.folder_open,
                              label: 'Load game',
                              onTap: () async {
                                await showLoadGameDialog(
                                    context: context, controller: controller);
                              },
                            ),
                            _MenuTile(
                              icon: Icons.history,
                              label: 'History',
                              onTap: () async {
                                await showAnimatedHistoryDialog(
                                    context: context, controller: controller);
                              },
                            ),
                            _MenuTile(
                              icon: Icons.person_outline,
                              label: 'User Profile',
                              onTap: () async {
                                await showAnimatedProfileDialog(
                                    context: context, controller: controller);
                              },
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
}

class _StatsAnimatedBox extends StatelessWidget {
  final int totalScore;
  final int totalPlayTimeMs;
  const _StatsAnimatedBox(
      {required this.totalScore, required this.totalPlayTimeMs});

  String _formatDuration(int ms) {
    if (ms <= 0) return '0s';
    int seconds = (ms / 1000).floor();
    final hours = seconds ~/ 3600;
    seconds %= 3600;
    final minutes = seconds ~/ 60;
    seconds %= 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        // Compute a scale factor relative to dialog width; 520 is our max width constraint above
        double t = (maxW / 520.0).clamp(0.7, 1.25);
        final double pad = 12 * t;
        final double radius = 16 * t;
        final double chipPadH = 12 * t;
        final double chipPadV = 8 * t;
        final double iconSize = 18 * t;
        final double gap = 10 * t;
        final double fontSize = (14 * t).clamp(12, 18);

        Widget chip({required Widget icon, required String text}) {
          return Container(
            padding:
                EdgeInsets.symmetric(horizontal: chipPadH, vertical: chipPadV),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white24, width: 1),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6)
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                SizedBox(width: gap * 0.6),
                Text(
                  text,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize),
                ),
              ],
            ),
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white24, width: 1),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))
            ],
          ),
          child: Center(
            child: Wrap(
              spacing: gap,
              runSpacing: gap * 0.7,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                chip(
                  icon: Image.asset('assets/icons/points-removebg.png',
                      width: iconSize, height: iconSize),
                  text: '$totalScore',
                ),
                chip(
                  icon: Image.asset('assets/icons/duration-removebg.png',
                      width: iconSize, height: iconSize),
                  text: _formatDuration(totalPlayTimeMs),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool?> showLoadGameDialog(
    {required BuildContext context, required GameController controller}) async {
  final bg = AppColors.bg;
  return await showGeneralDialog<bool?>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Load Game',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic);
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.listSavedGames(),
        builder: (context, snap) {
          final items = snap.data ?? const <Map<String, dynamic>>[];
          // Local stateful wrapper to allow in-dialog deletion and list refresh
          List<Map<String, dynamic>> initialItems =
              snap.data ?? const <Map<String, dynamic>>[];
          List<Map<String, dynamic>> localItems = initialItems;
          bool initialized = false;
          String? deletingId;
          return StatefulBuilder(
            builder: (context, setState) {
              if (!initialized) {
                // Copy initial items once
                localItems = List<Map<String, dynamic>>.from(initialItems);
                initialized = true;
              }
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
                              sigmaY: sigma * anim.value),
                          child: const SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: FadeTransition(
                      opacity: curved,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.92, end: 1.0)
                            .animate(curved),
                        child: Dialog(
                          insetPadding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 24),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22)),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
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
                              border: Border.all(
                                  color: AppColors.dialogOutline, width: 1),
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: 620, maxHeight: 560),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        const Spacer(),
                                        const Text('Load game',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800)),
                                        const Spacer(),
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.08),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white24)),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            iconSize: 20,
                                            icon: const Icon(Icons.close,
                                                color: Colors.white70),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: localItems.isEmpty
                                          ? const Center(
                                              child: Text('No saved games',
                                                  style: TextStyle(
                                                      color: Colors.white70)))
                                          : ListView.separated(
                                              itemCount: localItems.length,
                                              separatorBuilder: (_, __) =>
                                                  const SizedBox(height: 10),
                                              itemBuilder: (context, index) {
                                                final it = localItems[index];
                                                final when = DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        it['ts'] as int);
                                                final title =
                                                    it['name'] as String? ??
                                                        'Saved game';
                                                final subtitle =
                                                    '${when.toLocal()} • Turn: ${(it['current'] as String)}';
                                                final id = it['id'] as String;
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.06),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: Colors.white24,
                                                        width: 1),
                                                  ),
                                                  child: ListTile(
                                                    title: Text(title,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white)),
                                                    subtitle: Text(subtitle,
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .white70)),
                                                    trailing: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        // Play button opens the saved game (same as tapping the row)
                                                        IconButton(
                                                          tooltip: 'Play',
                                                          icon: Image.asset(
                                                              'assets/icons/play-removebg.png',
                                                              width: 31,
                                                              height: 31),
                                                          onPressed: () async {
                                                            await controller
                                                                .loadSavedGameById(
                                                                    id);
                                                            if (context
                                                                .mounted) {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(true);
                                                            }
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            width: 6),
                                                        // Delete button (30% bigger icon)
                                                        if (deletingId == id)
                                                          const SizedBox(
                                                              width: 31,
                                                              height: 31,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2))
                                                        else
                                                          IconButton(
                                                            tooltip: 'Delete',
                                                            icon: Image.asset(
                                                                'assets/icons/delete-removebg.png',
                                                                width: 31,
                                                                height: 31),
                                                            onPressed:
                                                                () async {
                                                              final confirm =
                                                                  await showDialog<
                                                                      bool>(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (dCtx) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Delete save?'),
                                                                    content:
                                                                        const Text(
                                                                            'Are you sure you want to delete this saved game?'),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed: () => Navigator.of(dCtx).pop(
                                                                              false),
                                                                          child:
                                                                              const Text('Cancel')),
                                                                      TextButton(
                                                                          onPressed: () => Navigator.of(dCtx).pop(
                                                                              true),
                                                                          child:
                                                                              const Text('Delete')),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                              if (confirm ==
                                                                  true) {
                                                                setState(() =>
                                                                    deletingId =
                                                                        id);
                                                                final ok =
                                                                    await controller
                                                                        .deleteSavedGameById(
                                                                            id);
                                                                if (ok) {
                                                                  setState(() {
                                                                    localItems
                                                                        .removeAt(
                                                                            index);
                                                                    deletingId =
                                                                        null;
                                                                  });
                                                                  // Success: intentionally no confirmation notification shown
                                                                } else {
                                                                  setState(() =>
                                                                      deletingId =
                                                                          null);
                                                                  final messenger =
                                                                      ScaffoldMessenger
                                                                          .maybeOf(
                                                                              context);
                                                                  messenger?.showSnackBar(const SnackBar(
                                                                      content: Text(
                                                                          'Failed to delete'),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red));
                                                                }
                                                              }
                                                            },
                                                          ),
                                                      ],
                                                    ),
                                                    onTap: () async {
                                                      await controller
                                                          .loadSavedGameById(
                                                              id);
                                                      if (context.mounted) {
                                                        Navigator.of(context)
                                                            .pop(true);
                                                      }
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
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
        },
      );
    },
  );
}
