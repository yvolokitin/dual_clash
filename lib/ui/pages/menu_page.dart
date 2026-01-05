import 'dart:ui' as ui;

import 'package:dual_clash/core/localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../logic/game_controller.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import 'history_page.dart';
import 'profile_page.dart';

Future<void> showAnimatedMainMenuDialog(
    {required BuildContext context, required GameController controller}) async {
  final bg = AppColors.bg;
  await showGeneralDialog<void>(
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
                  builder: (dialogContext) {
                    final l10n = dialogContext.l10n;
                    final size = MediaQuery.of(dialogContext).size;
                    final bool isMobilePlatform = !kIsWeb &&
                        (defaultTargetPlatform == TargetPlatform.android ||
                            defaultTargetPlatform == TargetPlatform.iOS);
                    final bool isTabletDevice = isTablet(dialogContext);
                    final bool isPhoneFullscreen =
                        isMobilePlatform && !isTabletDevice;
                    final double topInset = isPhoneFullscreen
                        ? MediaQuery.of(dialogContext).padding.top + 20
                        : 0;
                    final EdgeInsets dialogInsetPadding = isPhoneFullscreen
                        ? EdgeInsets.only(top: topInset)
                        : EdgeInsets.symmetric(
                            horizontal: size.width * 0.1,
                            vertical: size.height * 0.1);
                    final BorderRadius dialogRadius =
                        BorderRadius.circular(isPhoneFullscreen ? 0 : 22);
                    return Dialog(
                      insetPadding: dialogInsetPadding,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: dialogRadius),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: dialogRadius,
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
                          constraints: BoxConstraints(
                            maxWidth: isPhoneFullscreen
                                ? size.width
                                : size.width * 0.8,
                            maxHeight: isPhoneFullscreen
                                ? size.height - topInset
                                : size.height * 0.8,
                            minWidth: isPhoneFullscreen ? size.width : 0,
                            minHeight: isPhoneFullscreen
                                ? size.height - topInset
                                : 0,
                          ),
                          child: SafeArea(
                            top: false,
                            bottom: isPhoneFullscreen,
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
                                      Text(l10n.gameMenuTitle,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800)),
                                      const Spacer(),
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.08),
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
                                  _StatsAnimatedBox(
                                      totalScore: controller.totalUserScore,
                                      totalPlayTimeMs:
                                          controller.totalPlayTimeMs),
                                  const SizedBox(height: 16),
                                  _MenuTile(
                                    icon: Icons.flash_on,
                                    label: l10n.gameChallengeLabel,
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  l10n.gameChallengeComingSoon)));
                                    },
                                  ),
                                  _MenuTile(
                                    icon: Icons.folder_open,
                                    label: l10n.menuLoadGame,
                                    onTap: () async {
                                      await showLoadGameDialog(
                                          context: context,
                                          controller: controller);
                                    },
                                  ),
                                  _MenuTile(
                                    icon: Icons.history,
                                    label: l10n.historyTitle,
                                    onTap: () async {
                                      await showAnimatedHistoryDialog(
                                          context: context,
                                          controller: controller);
                                    },
                                  ),
                                  _MenuTile(
                                    icon: Icons.person_outline,
                                    label: l10n.userProfileLabel,
                                    onTap: () async {
                                      await showAnimatedProfileDialog(
                                          context: context,
                                          controller: controller);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
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

class _StatsAnimatedBox extends StatelessWidget {
  final int totalScore;
  final int totalPlayTimeMs;
  const _StatsAnimatedBox(
      {required this.totalScore, required this.totalPlayTimeMs});

  String _formatDuration(int ms) {
    final l10n = appLocalizations();
    if (l10n == null) {
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
    return formatDurationShort(l10n, ms);
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

bool _loadGameDialogOpen = false;

Future<bool?> showLoadGameDialog({
  required BuildContext context,
  required GameController controller,
}) async {
  if (_loadGameDialogOpen) {
    return null;
  }
  _loadGameDialogOpen = true;
  final bg = AppColors.bg;
  try {
    return await showGeneralDialog<bool?>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.loadGameBarrierLabel,
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
            final size = MediaQuery.of(context).size;
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
            final items = snap.data ?? const <Map<String, dynamic>>[];
            // Local stateful wrapper to allow in-dialog deletion and list refresh
            List<Map<String, dynamic>> initialItems =
                snap.data ?? const <Map<String, dynamic>>[];
            List<Map<String, dynamic>> localItems = initialItems;
            bool initialized = false;
            String? deletingId;
            bool closing = false;
            return StatefulBuilder(
              builder: (context, setState) {
                final l10n = context.l10n;
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
                            insetPadding: dialogInsetPadding,
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: dialogRadius),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: dialogRadius,
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
                                constraints: BoxConstraints(
                                  maxWidth: isPhoneFullscreen
                                      ? size.width
                                      : size.width * 0.8,
                                  maxHeight: isPhoneFullscreen
                                      ? size.height
                                      : size.height * 0.8,
                                  minWidth: isPhoneFullscreen ? size.width : 0,
                                  minHeight: isPhoneFullscreen ? size.height : 0,
                                ),
                                child: SafeArea(
                                  top: isPhoneFullscreen,
                                  bottom: isPhoneFullscreen,
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
                                            Text(l10n.menuLoadGame,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.w800)),
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
                                              ? Center(
                                                  child: Text(
                                                      l10n.noSavedGamesMessage,
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.white70)))
                                              : ListView.separated(
                                                  itemCount: localItems.length,
                                                  separatorBuilder: (_, __) =>
                                                      const SizedBox(
                                                          height: 10),
                                                  itemBuilder:
                                                      (context, index) {
                                                    final it =
                                                        localItems[index];
                                                    final when = DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            it['ts'] as int);
                                                    final title =
                                                        it['name'] as String? ??
                                                            l10n.savedGameDefaultName;
                                                    final subtitle =
                                                        l10n.savedGameSubtitle(
                                                            when.toLocal().toString(),
                                                            it['current'] as String);
                                                    final id =
                                                        it['id'] as String;
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.06),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                            color:
                                                                Colors.white24,
                                                            width: 1),
                                                      ),
                                                      child: ListTile(
                                                        title: Text(title,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                        subtitle: Text(subtitle,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white70)),
                                                        trailing: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            // Play button opens the saved game (same as tapping the row)
                                                            IconButton(
                                                              tooltip: l10n.playLabel,
                                                              icon: Image.asset(
                                                                  'assets/icons/play.png',
                                                                  width: 31,
                                                                  height: 31),
                                                              onPressed:
                                                                  () async {
                                                                if (closing) {
                                                                  return;
                                                                }
                                                                closing = true;
                                                                await controller
                                                                    .loadSavedGameById(
                                                                        id);
                                                                if (context
                                                                        .mounted &&
                                                                    Navigator
                                                                        .of(
                                                                      context,
                                                                      rootNavigator:
                                                                          true,
                                                                    ).canPop()) {
                                                                  Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true,
                                                                  ).pop(true);
                                                                }
                                                              },
                                                            ),
                                                            const SizedBox(
                                                                width: 6),
                                                            // Delete button (30% bigger icon)
                                                            if (deletingId ==
                                                                id)
                                                              const SizedBox(
                                                                  width: 31,
                                                                  height: 31,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2))
                                                            else
                                                              IconButton(
                                                                tooltip:
                                                                    l10n.deleteLabel,
                                                                icon:
                                                                    Image.asset(
                                                                        'assets/icons/delete.png',
                                                                        width:
                                                                            31,
                                                                        height:
                                                                            31),
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
                                                                        title: Text(
                                                                            l10n.deleteSaveTitle),
                                                                        content:
                                                                            Text(
                                                                                l10n.deleteSaveMessage),
                                                                        actions: [
                                                                          TextButton(
                                                                              onPressed: () => Navigator.of(dCtx).pop(false),
                                                                              child: Text(l10n.commonCancel)),
                                                                          TextButton(
                                                                              onPressed: () => Navigator.of(dCtx).pop(true),
                                                                              child: Text(l10n.deleteLabel)),
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
                                                                      setState(
                                                                          () {
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
                                                                          content:
                                                                              Text(l10n.failedToDeleteMessage),
                                                                          backgroundColor:
                                                                              Colors.red));
                                                                    }
                                                                  }
                                                                },
                                                              ),
                                                          ],
                                                        ),
                                                        onTap: () async {
                                                          if (closing) return;
                                                          closing = true;
                                                          await controller
                                                              .loadSavedGameById(
                                                                  id);
                                                          if (context.mounted &&
                                                              Navigator.of(
                                                                context,
                                                                rootNavigator:
                                                                    true,
                                                              ).canPop()) {
                                                            Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true,
                                                            ).pop(true);
                                                          }
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                        const SizedBox(height: 12),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.brandGold,
                                              foregroundColor:
                                                  const Color(0xFF2B221D),
                                              shadowColor: Colors.black54,
                                              elevation: 4,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24)),
                                              textStyle: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.2),
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
  } finally {
    _loadGameDialogOpen = false;
  }
}
