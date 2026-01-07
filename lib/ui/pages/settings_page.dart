import 'dart:ui' as ui;

import 'package:dual_clash/core/localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
Future<void> showAnimatedSettingsDialog(
    {required BuildContext context, required GameController controller}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.settingsTitle,
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, anim1, anim2) {
      // The actual page contents are built in transitionBuilder
      return const SizedBox.shrink();
    },
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic);
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
  late String _initialLanguage;
  late CellState _initialStartingPlayer;

  @override
  void initState() {
    super.initState();
    _language = widget.controller.languageCode;
    _boardSize = widget.controller.boardSize;
    _aiLevel = widget.controller.aiLevel;
    _startingPlayer = widget.controller.startingPlayer;
    _initialLanguage = _language;
    _initialStartingPlayer = _startingPlayer;
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
    // Dialog background: exactly the same as main background
    final bg = AppColors.bg;
    final Color dialogTop = bg;
    final Color dialogBottom = bg;
    final EdgeInsets dialogInsetPadding = isPhoneFullscreen
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(
            horizontal: size.width * 0.1, vertical: size.height * 0.1);
    final BorderRadius dialogRadius =
        BorderRadius.circular(isPhoneFullscreen ? 0 : 22);
    final EdgeInsets contentPadding =
        const EdgeInsets.fromLTRB(18, 20, 18, 18);
    final bool hasPendingChanges =
        _language != _initialLanguage ||
        _startingPlayer != _initialStartingPlayer;
    // The dialog window — centered, not fullscreen. showDialog will dim the background.
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
            colors: [dialogTop, dialogBottom],
          ),
          boxShadow: const [
            BoxShadow(
                color: AppColors.dialogShadow,
                blurRadius: 24,
                offset: Offset(0, 12)),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        l10n.settingsTitle,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Language selector
                          _label(l10n.languageTitle),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _languageOptions().map((opt) {
                              final code = opt.$1;
                              final title = opt.$2;
                              final asset = opt.$3;
                              return _languageTile(
                                selected: _language == code,
                                label: title,
                                asset: asset,
                                onTap: () => setState(() => _language = code),
                              );
                            }).toList(),
                          ),
                          // separator between sections
                          _separator(),

                          // Board size selector (removed as per spec)
                          // Intentionally removed UI for board size to simplify settings.
                          // The game continues using controller.boardSize; changes may come from elsewhere if needed.
                          const SizedBox(height: 0),

                          // Who starts selector
                          _label(l10n.whoStartsFirstLabel),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _startingPlayerTile(
                                selected: _startingPlayer == CellState.red,
                                label: l10n.startingPlayerHuman,
                                asset: 'assets/icons/human.png',
                                accent: AppColors.red,
                                onTap: () => setState(
                                    () => _startingPlayer = CellState.red),
                              ),
                              _startingPlayerTile(
                                selected: _startingPlayer == CellState.blue,
                                label: l10n.startingPlayerAi,
                                asset: 'assets/icons/ai.png',
                                accent: AppColors.blue,
                                onTap: () => setState(
                                    () => _startingPlayer = CellState.blue),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (hasPendingChanges)
                        ElevatedButton(
                          onPressed: () async {
                            if (_language != _initialLanguage) {
                              await widget.controller.setLanguage(_language);
                              _initialLanguage = _language;
                            }
                            if (_startingPlayer != _initialStartingPlayer) {
                              await widget.controller
                                  .setStartingPlayer(_startingPlayer);
                              _initialStartingPlayer = _startingPlayer;
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.black54,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2),
                          ),
                          child: Text(l10n.commonSave),
                        ),
                      const Spacer(),
                      ElevatedButton(
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
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2),
                        ),
                        child: Text(l10n.commonClose),
                      ),
                    ],
                  ),
                ], // Added closing bracket here
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.dialogSubtitle,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2)),
      );

  InputDecoration _fieldDecoration() => const InputDecoration(
        filled: true,
        fillColor: AppColors.dialogFieldBg,
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(12))),
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

  List<(String, String, String)> _languageOptions() {
    return const [
      ('en', 'English', 'assets/icons/lang_en.png'),
      ('de', 'Deutsch', 'assets/icons/lang_de.png'),
      ('es', 'Español', 'assets/icons/lang_es.png'),
      ('fr', 'Français', 'assets/icons/lang_fr.png'),
      ('pl', 'Polski', 'assets/icons/lang_pl.png'),
      ('ru', 'Русский', 'assets/icons/lang_ru.png'),
      ('uk', 'Українська', 'assets/icons/lang_ua.png'),
    ];
  }

  Widget _choiceTile({
    required bool selected,
    required String label,
    Color? colorDot,
    VoidCallback? onTap,
  }) {
    final bg =
        selected ? Colors.white.withOpacity(0.12) : AppColors.dialogFieldBg;
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
                Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: colorDot, shape: BoxShape.circle)),
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

  Widget _languageTile({
    required bool selected,
    required String label,
    required String asset,
    VoidCallback? onTap,
  }) {
    const double tileWidth = 110;
    const double tileHeight = 72;
    const double borderWidth = 3;
    const BorderRadius tileRadius = BorderRadius.all(Radius.circular(12));
    const LinearGradient selectedBorderGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFE29A),
        Color(0xFFB7771B),
      ],
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: tileRadius,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: selected
                  ? const BoxDecoration(
                      gradient: selectedBorderGradient,
                      borderRadius: tileRadius,
                    )
                  : null,
              padding: EdgeInsets.all(selected ? borderWidth : 0),
              child: Container(
                width: tileWidth,
                height: tileHeight,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: tileRadius,
                  border: selected
                      ? null
                      : Border.all(color: Colors.white12, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: tileRadius,
                  child: SizedBox.expand(
                    child: Image.asset(
                      asset,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: tileWidth,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _startingPlayerTile({
    required bool selected,
    required String label,
    required String asset,
    required Color accent,
    VoidCallback? onTap,
  }) {
    const double tileWidth = 120;
    const double tileHeight = 72;
    const double borderWidth = 3;
    const BorderRadius tileRadius = BorderRadius.all(Radius.circular(12));
    const LinearGradient selectedBorderGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFE29A),
        Color(0xFFB7771B),
      ],
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: tileRadius,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: selected
                  ? const BoxDecoration(
                      gradient: selectedBorderGradient,
                      borderRadius: tileRadius,
                    )
                  : null,
              padding: EdgeInsets.all(selected ? borderWidth : 0),
              child: Container(
                width: tileWidth,
                height: tileHeight,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: tileRadius,
                  border: selected
                      ? null
                      : Border.all(color: Colors.white12, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: tileRadius,
                  child: SizedBox.expand(
                    child: Image.asset(
                      asset,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: tileWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: accent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Belt tile with image and highlight
  Widget _beltTile({
    required int level,
    required bool selected,
    VoidCallback? onTap,
  }) {
    final l10n = context.l10n;
    final String label = aiBeltName(l10n, level);
    final String asset = AiBelt.assetFor(level);
    final Color border = selected ? AppColors.brandGold : Colors.white12;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 84,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.dialogFieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Belt image centered
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    height: 54,
                  ),
                ),
              ),
              // Label at bottom with subtle gradient
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.35),
                      ],
                    ),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _aiLevelShortTip(int lvl) {
    final l10n = context.l10n;
    switch (lvl) {
      case 1:
        return l10n.aiDifficultyTipBeginner;
      case 2:
        return l10n.aiDifficultyTipEasy;
      case 3:
        return l10n.aiDifficultyTipNormal;
      case 4:
        return l10n.aiDifficultyTipChallenging;
      case 5:
        return l10n.aiDifficultyTipHard;
      case 6:
        return l10n.aiDifficultyTipExpert;
      case 7:
        return l10n.aiDifficultyTipMaster;
      default:
        return l10n.aiDifficultyTipSelect;
    }
  }

  String _aiLevelDescription(int lvl) {
    final l10n = context.l10n;
    switch (lvl) {
      case 1:
        return l10n.aiDifficultyDetailBeginner;
      case 2:
        return l10n.aiDifficultyDetailEasy;
      case 3:
        return l10n.aiDifficultyDetailNormal;
      case 4:
        return l10n.aiDifficultyDetailChallenging;
      case 5:
        return l10n.aiDifficultyDetailHard;
      case 6:
        return l10n.aiDifficultyDetailExpert;
      case 7:
        return l10n.aiDifficultyDetailMaster;
      default:
        return l10n.aiDifficultyDetailSelect;
    }
  }
}
