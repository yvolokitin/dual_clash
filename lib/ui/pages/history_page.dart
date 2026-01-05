import 'dart:ui' as ui;

import 'package:dual_clash/core/localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../logic/game_controller.dart';
import '../../models/game_result.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';

class HistoryDialog extends StatefulWidget {
  final GameController controller;
  const HistoryDialog({super.key, required this.controller});

  @override
  State<HistoryDialog> createState() => _HistoryDialogState();
}

class _HistoryDialogState extends State<HistoryDialog> {
  late final ScrollController _scrollCtrl;
  late final ScrollController _dailyScrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _dailyScrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _dailyScrollCtrl.dispose();
    super.dispose();
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
    final bg = AppColors.bg;
    final items = widget.controller.history.reversed.toList();
    final EdgeInsets dialogInsetPadding = isPhoneFullscreen
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(
            horizontal: size.width * 0.1, vertical: size.height * 0.1);
    final BorderRadius dialogRadius =
        BorderRadius.circular(isPhoneFullscreen ? 0 : 22);
    final EdgeInsets contentPadding =
        const EdgeInsets.fromLTRB(18, 20, 18, 18);
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
          border: Border.all(color: AppColors.dialogOutline, width: 1),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isPhoneFullscreen ? size.width : size.width * 0.8,
            maxHeight: isPhoneFullscreen ? size.height : size.height * 0.8,
            minWidth: isPhoneFullscreen ? size.width : 0,
            minHeight: isPhoneFullscreen ? size.height : 0,
          ),
          child: SafeArea(
            top: isPhoneFullscreen,
            bottom: isPhoneFullscreen,
            child: Padding(
              padding: contentPadding,
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        Text(l10n.historyTitle,
                            style: const TextStyle(
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
                              border: Border.all(color: Colors.white24)),
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
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12))),
                      child: TabBar(
                        indicator: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        tabs: [
                          Tab(text: l10n.historyTabGames),
                          Tab(text: l10n.historyTabDailyActivity),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildGamesTab(items),
                          _buildDailyActivityTab(items),
                        ],
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
      ),
    );
  }

  Widget _buildGamesTab(List<GameResult> items) {
    if (items.isEmpty) {
      return Center(
          child: Text(context.l10n.noFinishedGamesYet,
              style: const TextStyle(color: Colors.white70)));
    }
    return Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      controller: _scrollCtrl,
      child: ListView.separated(
        controller: _scrollCtrl,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final gr = items[index];
          return _HistoryTile(gr: gr);
        },
      ),
    );
  }

  Widget _buildDailyActivityTab(List<GameResult> items) {
    final activity = _aggregateDaily(items);
    if (activity.isEmpty) {
      return Center(
          child: Text(context.l10n.noFinishedGamesYet,
              style: const TextStyle(color: Colors.white70)));
    }
    return Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      controller: _dailyScrollCtrl,
      child: ListView.separated(
        controller: _dailyScrollCtrl,
        itemCount: activity.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final entry = activity[index];
          return _DailyActivityTile(entry: entry);
        },
      ),
    );
  }

  List<_DailyActivity> _aggregateDaily(List<GameResult> items) {
    if (items.isEmpty) return const [];
    final Map<String, _DailyAccumulator> byDate = {};
    DateTime earliest =
        DateTime.fromMillisecondsSinceEpoch(items.first.timestampMs);
    for (final gr in items) {
      final dt = DateTime.fromMillisecondsSinceEpoch(gr.timestampMs);
      final dateOnly = DateTime(dt.year, dt.month, dt.day);
      if (dateOnly.isBefore(earliest)) {
        earliest = dateOnly;
      }
      final key = _dateKey(dateOnly);
      byDate.putIfAbsent(key, () => _DailyAccumulator(dateOnly));
      final acc = byDate[key]!;
      acc.games += 1;
      if (gr.winner == 'red') {
        acc.wins += 1;
      } else if (gr.winner == 'blue') {
        acc.losses += 1;
      } else {
        acc.draws += 1;
      }
      acc.totalMs += gr.playMs;
    }
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final List<_DailyActivity> result = [];
    for (DateTime d = todayOnly;
        !d.isBefore(earliest);
        d = d.subtract(const Duration(days: 1))) {
      final key = _dateKey(d);
      final acc = byDate[key];
      result.add(_DailyActivity(
          date: d,
          games: acc?.games ?? 0,
          wins: acc?.wins ?? 0,
          losses: acc?.losses ?? 0,
          draws: acc?.draws ?? 0,
          totalMs: acc?.totalMs ?? 0));
    }
    return result;
  }
}

String _pad2(int v) => v.toString().padLeft(2, '0');

String _formatDuration(int ms) {
  final l10n = appLocalizations();
  if (l10n == null) {
    if (ms <= 0) return '0s';
    int seconds = (ms / 1000).floor();
    int hours = seconds ~/ 3600;
    seconds %= 3600;
    int minutes = seconds ~/ 60;
    seconds %= 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
  return formatDurationShort(l10n, ms);
}

class _DailyActivity {
  final DateTime date;
  final int games;
  final int wins;
  final int losses;
  final int draws;
  final int totalMs;

  const _DailyActivity(
      {required this.date,
      required this.games,
      required this.wins,
      required this.losses,
      required this.draws,
      required this.totalMs});
}

class _DailyAccumulator {
  final DateTime date;
  int games = 0;
  int wins = 0;
  int losses = 0;
  int draws = 0;
  int totalMs = 0;

  _DailyAccumulator(this.date);
}

class _DailyActivityTile extends StatelessWidget {
  final _DailyActivity entry;
  const _DailyActivityTile({required this.entry});

  String _formatDate(DateTime dt) =>
      '${dt.year}-${_pad2(dt.month)}-${_pad2(dt.day)}';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(entry.date),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(l10n.gamesCountLabel(entry.games),
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _chip(l10n.winsLabel, entry.wins.toString(),
                    color: AppColors.red),
                _chip(l10n.lossesLabel, entry.losses.toString(),
                    color: AppColors.blue),
                _chip(l10n.drawsLabel, entry.draws.toString()),
                _chip(l10n.totalTimeLabel, _formatDuration(entry.totalMs)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: (color ?? Colors.white).withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w700)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

String _dateKey(DateTime dt) =>
    '${dt.year}-${_pad2(dt.month)}-${_pad2(dt.day)}';

class _HistoryTile extends StatelessWidget {
  final GameResult gr;
  const _HistoryTile({required this.gr});

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.fromMillisecondsSinceEpoch(gr.timestampMs);
    final when = _formatDateTime(dt);
    final l10n = context.l10n;
    final resultLabel = gr.winner == 'draw'
        ? l10n.resultDraw
        : (gr.winner == 'red' ? l10n.resultPlayerWins : l10n.resultAiWins);
    // Subtle background tint by winner: red/blue/grey
    final bool redWon = gr.winner == 'red';
    final bool blueWon = gr.winner == 'blue';
    final Color bgTint = redWon
        ? AppColors.red.withOpacity(0.12)
        : blueWon
            ? AppColors.blue.withOpacity(0.12)
            : Colors.white.withOpacity(0.06);
    final Color borderTint = redWon
        ? AppColors.red.withOpacity(0.5)
        : blueWon
            ? AppColors.blue.withOpacity(0.5)
            : Colors.white24;
    return Container(
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderTint, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(when,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                    l10n.aiLabelWithName(
                        aiBeltName(l10n, gr.aiLevel)),
                    style: const TextStyle(color: Colors.white70)),
                Text(l10n.winnerLabel(resultLabel),
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _chip(l10n.yourScoreLabel, gr.redTotal.toString(),
                    color: AppColors.red),
                _chip(l10n.timeLabel, _formatDuration(gr.playMs)),
                _chip(l10n.redBaseLabel, gr.redBase.toString(),
                    color: AppColors.red),
                _chip(l10n.blueBaseLabel, gr.blueBase.toString(),
                    color: AppColors.blue),
                _chip(l10n.totalBlueLabel, gr.blueTotal.toString(),
                    color: AppColors.blue),
                _chip(l10n.turnsRedLabel, gr.turnsRed.toString()),
                _chip(l10n.turnsBlueLabel, gr.turnsBlue.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${_pad2(dt.month)}-${_pad2(dt.day)}  ${_pad2(dt.hour)}:${_pad2(dt.minute)}';
  }

  Widget _chip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: (color ?? Colors.white).withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w700)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

Future<void> showAnimatedHistoryDialog(
    {required BuildContext context, required GameController controller}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.historyTitle,
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
                child: HistoryDialog(controller: controller),
              ),
            ),
          ),
        ],
      );
    },
  );
}
