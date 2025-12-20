import 'package:flutter/material.dart';
import 'dart:ui' as ui;
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
    final bg = AppColors.bg;
    final items = widget.controller.history.reversed.toList();
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
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
          border: Border.all(color: AppColors.dialogOutline, width: 1),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      const Text('History',
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
                        border:
                            Border.all(color: Colors.white.withOpacity(0.12))),
                    child: const TabBar(
                      indicator: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: [
                        Tab(text: 'Games'),
                        Tab(text: 'Daily activity'),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGamesTab(List<GameResult> items) {
    if (items.isEmpty) {
      return const Center(
          child: Text('No finished games yet',
              style: TextStyle(color: Colors.white70)));
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
      return const Center(
          child: Text('No finished games yet',
              style: TextStyle(color: Colors.white70)));
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
                Text('Games: ${entry.games}',
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
                _chip('Wins', entry.wins.toString(), color: AppColors.red),
                _chip('Losses', entry.losses.toString(),
                    color: AppColors.blue),
                _chip('Draws', entry.draws.toString()),
                _chip('Total time', _formatDuration(entry.totalMs)),
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
    final resultLabel = gr.winner == 'draw'
        ? 'Draw'
        : (gr.winner == 'red' ? 'Player Wins' : 'AI Wins');
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
                Text('AI: ${AiBelt.nameFor(gr.aiLevel)}',
                    style: const TextStyle(color: Colors.white70)),
                Text('Winner: $resultLabel',
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
                _chip('Your score', gr.redTotal.toString(),
                    color: AppColors.red),
                _chip('Time', _formatDuration(gr.playMs)),
                _chip('Red base', gr.redBase.toString(), color: AppColors.red),
                _chip('Blue base', gr.blueBase.toString(),
                    color: AppColors.blue),
                _chip('Total B', gr.blueTotal.toString(),
                    color: AppColors.blue),
                _chip('Turns R', gr.turnsRed.toString()),
                _chip('Turns B', gr.turnsBlue.toString()),
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
    barrierLabel: 'History',
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
