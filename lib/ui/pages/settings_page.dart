import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../logic/game_controller.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../models/cell_state.dart';

class SettingsDialog extends StatefulWidget {
  final GameController controller;
  const SettingsDialog({super.key, required this.controller});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

/// Helper to show the SettingsDialog with Block Blast-like animated transition
Future<void> showAnimatedSettingsDialog({required BuildContext context, required GameController controller}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Settings',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, anim1, anim2) {
      // The actual page contents are built in transitionBuilder
      return const SizedBox.shrink();
    },
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
      return Stack(
        children: [
          // Subtle background blur like Block Blast
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 6),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              builder: (context, sigma, _) {
                return BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: sigma * anim.value, sigmaY: sigma * anim.value),
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
                child: SettingsDialog(controller: controller),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _SettingsDialogState extends State<SettingsDialog> {
  // Local working copies to reflect dropdown selections immediately
  late String _language;
  late int _boardSize;
  late int _aiLevel;
  late CellState _startingPlayer;

  @override
  void initState() {
    super.initState();
    _language = widget.controller.languageCode;
    _boardSize = widget.controller.boardSize;
    _aiLevel = widget.controller.aiLevel;
    _startingPlayer = widget.controller.startingPlayer;
  }

  @override
  Widget build(BuildContext context) {
    // Dialog background: exactly the same as main background
    final bg = AppColors.bg;
    final Color dialogTop = bg;
    final Color dialogBottom = bg;
    // The dialog window — centered, not fullscreen. showDialog will dim the background.
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
            colors: [dialogTop, dialogBottom],
          ),
          boxShadow: const [
            BoxShadow(color: AppColors.dialogShadow, blurRadius: 24, offset: Offset(0, 12)),
          ],
          border: Border.all(color: AppColors.dialogOutline, width: 1),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'Settings',
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

                // Language selector
                _label('Language'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _languageOptions().map((opt) {
                    final code = opt.$1;
                    final title = opt.$2;
                    return _choiceTile(
                      selected: _language == code,
                      label: title,
                      onTap: () async {
                        setState(() => _language = code);
                        await widget.controller.setLanguage(code);
                      },
                    );
                  }).toList(),
                ),
                // separator between sections
                _separator(),

                // Board size selector (removed as per spec)
                // Intentionally removed UI for board size to simplify settings.
                // The game continues using controller.boardSize; changes may come from elsewhere if needed.
                const SizedBox(height: 0),

                // AI difficulty
                _label('AI difficulty'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(7, (i) => i + 1).map((lvl) {
                    return _choiceTile(
                      selected: _aiLevel == lvl,
                      label: AiBelt.nameFor(lvl),
                      colorDot: AiBelt.colorFor(lvl),
                      onTap: () async {
                        setState(() => _aiLevel = lvl);
                        await widget.controller.setAiLevel(lvl);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                Text(
                  _aiLevelDescription(_aiLevel),
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.2),
                ),
                _separator(),

                // Who starts selector
                _label('Who starts first'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _choiceTile(
                      selected: _startingPlayer == CellState.red,
                      label: 'Red (Player)',
                      colorDot: AppColors.red,
                      onTap: () async {
                        setState(() => _startingPlayer = CellState.red);
                        await widget.controller.setStartingPlayer(CellState.red);
                      },
                    ),
                    _choiceTile(
                      selected: _startingPlayer == CellState.blue,
                      label: 'Blue (AI)',
                      colorDot: AppColors.blue,
                      onTap: () async {
                        setState(() => _startingPlayer = CellState.blue);
                        await widget.controller.setStartingPlayer(CellState.blue);
                      },
                    ),
                  ],
                ),

                const Spacer(),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandGold,
                      foregroundColor: const Color(0xFF2B221D),
                      shadowColor: Colors.black54,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ], // Added closing bracket here
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6.0),
    child: Text(text, style: const TextStyle(color: AppColors.dialogSubtitle, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
  );

  InputDecoration _fieldDecoration() => const InputDecoration(
    filled: true,
    fillColor: AppColors.dialogFieldBg,
    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  // subtle horizontal separator between settings sections
  Widget _separator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        height: 1,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  List<(String, String)> _languageOptions() {
    // English + 10 most used EU languages
    return const [
      ('en', 'English'),
      ('de', 'Deutsch'),
      ('fr', 'Français'),
      ('it', 'Italiano'),
      ('es', 'Español'),
      ('pl', 'Polski'),
      ('ro', 'Română'),
      ('nl', 'Nederlands'),
      ('pt', 'Português'),
      ('el', 'Ελληνικά'),
      ('hu', 'Magyar'),
    ];
  }

  Widget _choiceTile({
    required bool selected,
    required String label,
    Color? colorDot,
    VoidCallback? onTap,
  }) {
    final bg = selected ? Colors.white.withOpacity(0.12) : AppColors.dialogFieldBg;
    final border = selected ? AppColors.brandGold : Colors.white12;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (colorDot != null) ...[
                Container(width: 10, height: 10, decoration: BoxDecoration(color: colorDot, shape: BoxShape.circle)),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _aiLevelDescription(int lvl) {
    switch (lvl) {
      case 1:
        return 'White — Beginner: random empty cells. Unpredictable but weak.';
      case 2:
        return 'Orange — Easy: greedy takes that maximize immediate blue gain.';
      case 3:
        return 'Red — Normal: greedy with center tie-break to prefer strong positions.';
      case 4:
        return 'Green — Challenging: shallow minimax search (depth 2), no pruning.';
      case 5:
        return 'Blue — Hard: deeper minimax with alpha–beta pruning and move ordering.';
      case 6:
        return 'Brown — Expert: deeper minimax with pruning + transposition table.';
      case 7:
        return 'Black — Master: Monte Carlo Tree Search (~1500 rollouts within time limit).';
      default:
        return 'Select AI difficulty to see details.';
    }
  }
}
