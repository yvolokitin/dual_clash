import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../logic/game_controller.dart';
import 'help_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

class SettingsMenuOverlay extends StatelessWidget {
  final GameController controller;
  final VoidCallback onClose;
  const SettingsMenuOverlay({
    super.key,
    required this.controller,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.dialogGradTop, AppColors.dialogGradBottom],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.dialogShadow,
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                      border: Border.all(color: AppColors.dialogOutline, width: 1),
                    ),
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
                                  onPressed: onClose,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.25,
                            children: [
                              _SettingsMenuTile(
                                color: AppColors.blue,
                                imagePath: 'assets/icons/help-removebg.png',
                                label: 'Help',
                                onTap: () async {
                                  onClose();
                                  await showAnimatedHelpDialog(
                                    context: context,
                                    controller: controller,
                                  );
                                },
                              ),
                              _SettingsMenuTile(
                                color: AppColors.yellow,
                                imagePath: 'assets/icons/simulate-removebg.png',
                                label: 'Language',
                                onTap: () async {
                                  onClose();
                                  await _openLanguageDialog(context, controller);
                                },
                              ),
                              _SettingsMenuTile(
                                color: AppColors.red,
                                imagePath: 'assets/icons/profile-removebg.png',
                                label: 'Profile',
                                onTap: () async {
                                  onClose();
                                  await showAnimatedProfileDialog(
                                    context: context,
                                    controller: controller,
                                  );
                                },
                              ),
                              _SettingsMenuTile(
                                color: AppColors.green,
                                imagePath: 'assets/icons/history-removebg.png',
                                label: 'History',
                                onTap: () async {
                                  onClose();
                                  await showAnimatedHistoryDialog(
                                    context: context,
                                    controller: controller,
                                  );
                                },
                              ),
                              _SettingsMenuTile(
                                color: AppColors.brandGold,
                                imagePath: 'assets/icons/belt_blue.png',
                                label: 'AI difficulty',
                                onTap: () async {
                                  onClose();
                                  await _openAiDifficultySelector(context, controller);
                                },
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
        ],
      ),
    );
  }
}

Future<void> _openLanguageDialog(
    BuildContext context, GameController controller) async {
  String tempLanguage = controller.languageCode;
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Language',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, a2, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
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
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.dialogGradTop, AppColors.dialogGradBottom],
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
                      constraints:
                          const BoxConstraints(maxWidth: 520, maxHeight: 520),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: StatefulBuilder(
                          builder: (ctx2, setState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Spacer(),
                                    const Text(
                                      'Language',
                                      style: TextStyle(
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
                                        icon: const Icon(Icons.close,
                                            color: Colors.white70),
                                        onPressed: () => Navigator.of(ctx).pop(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _languageOptions().map((opt) {
                                    final code = opt.$1;
                                    final title = opt.$2;
                                    return _LanguageChoiceTile(
                                      selected: tempLanguage == code,
                                      label: title,
                                      onTap: () => setState(() {
                                        tempLanguage = code;
                                      }),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              Colors.white.withOpacity(0.08),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            side: const BorderSide(
                                                color: Colors.white24),
                                          ),
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await controller
                                              .setLanguage(tempLanguage);
                                          if (context.mounted) {
                                            Navigator.of(ctx).pop();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.brandGold,
                                          foregroundColor:
                                              const Color(0xFF2B221D),
                                          shadowColor: Colors.black54,
                                          elevation: 4,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          textStyle: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.2),
                                        ),
                                        child: const Text('Confirm'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
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

List<(String, String)> _languageOptions() {
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

class _LanguageChoiceTile extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback? onTap;
  const _LanguageChoiceTile({
    required this.selected,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _openAiDifficultySelector(
    BuildContext context, GameController controller) async {
  int tempLevel = controller.aiLevel;
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'AI difficulty',
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
                      constraints:
                          const BoxConstraints(maxWidth: 560, maxHeight: 520),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: StatefulBuilder(
                          builder: (ctx2, setState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Spacer(),
                                    const Text('AI difficulty',
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
                                        onPressed: () => Navigator.of(ctx).pop(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    for (int lvl = 1; lvl <= 7; lvl++)
                                      Tooltip(
                                        message: _aiLevelShortTip(lvl),
                                        child: _AiLevelChoiceTile(
                                          level: lvl,
                                          selected: tempLevel == lvl,
                                          onTap: () => setState(() {
                                            tempLevel = lvl;
                                          }),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _aiLevelShortTip(tempLevel),
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.2),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              Colors.white.withOpacity(0.08),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              side: const BorderSide(
                                                  color: Colors.white24)),
                                          textStyle: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.2),
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await controller.setAiLevel(tempLevel);
                                          if (context.mounted) {
                                            Navigator.of(ctx).pop();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.brandGold,
                                          foregroundColor:
                                              const Color(0xFF2B221D),
                                          shadowColor: Colors.black54,
                                          elevation: 4,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          textStyle: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.2),
                                        ),
                                        child: const Text('Confirm'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
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

class _AiLevelChoiceTile extends StatelessWidget {
  final int level;
  final bool selected;
  final VoidCallback onTap;
  const _AiLevelChoiceTile({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String label = AiBelt.nameFor(level);
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
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
}

String _aiLevelShortTip(int lvl) {
  switch (lvl) {
    case 1:
      return 'White — Beginner: makes random moves.';
    case 2:
      return 'Yellow — Easy: prefers immediate gains.';
    case 3:
      return 'Orange — Normal: greedy with basic positioning.';
    case 4:
      return 'Green — Challenging: shallow search with some foresight.';
    case 5:
      return 'Blue — Hard: deeper search with pruning.';
    case 6:
      return 'Brown — Expert: advanced pruning and caching.';
    case 7:
      return 'Black — Master: strongest and most calculating.';
    default:
      return 'Select a belt level.';
  }
}

class _SettingsMenuTile extends StatelessWidget {
  final Color color;
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  const _SettingsMenuTile({
    required this.color,
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  Color _darken(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color _lighten(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final outerRadius = BorderRadius.circular(14);
    final innerRadius = BorderRadius.circular(11);
    final Color base = color.withOpacity(1.0);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _darken(base),
        _lighten(base),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: outerRadius,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: outerRadius,
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              color: base.withOpacity(0.9),
              borderRadius: innerRadius,
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(imagePath, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
