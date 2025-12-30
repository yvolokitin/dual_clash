import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../logic/game_controller.dart';
import '../pages/history_page.dart';
import '../pages/profile_page.dart';

Future<void> showAnimatedSettingsMenuDialog({
  required BuildContext context,
  required GameController controller,
}) async {
  final bg = AppColors.bg;
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Settings',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
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
                    sigmaY: sigma * anim.value,
                  ),
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
                        colors: [bg, bg],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.dialogShadow,
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        )
                      ],
                      border: Border.all(
                        color: AppColors.dialogOutline,
                        width: 1,
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 520, maxHeight: 480),
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
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _MenuTile(
                              icon: Icons.person_outline,
                              label: 'Profile',
                              onTap: () async {
                                Navigator.of(context).pop();
                                await showAnimatedProfileDialog(
                                  context: context,
                                  controller: controller,
                                );
                              },
                            ),
                            _MenuTile(
                              icon: Icons.language,
                              label: 'Language',
                              onTap: () async {
                                Navigator.of(context).pop();
                                await showAnimatedLanguageDialog(
                                  context: context,
                                  controller: controller,
                                );
                              },
                            ),
                            _MenuTile(
                              icon: Icons.history,
                              label: 'History',
                              onTap: () async {
                                Navigator.of(context).pop();
                                await showAnimatedHistoryDialog(
                                  context: context,
                                  controller: controller,
                                );
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

Future<void> showAnimatedLanguageDialog({
  required BuildContext context,
  required GameController controller,
}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Language',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
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
                    sigmaY: sigma * anim.value,
                  ),
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
                child: _LanguageDialog(controller: controller),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _LanguageDialog extends StatefulWidget {
  final GameController controller;
  const _LanguageDialog({required this.controller});

  @override
  State<_LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<_LanguageDialog> {
  late String _language;

  @override
  void initState() {
    super.initState();
    _language = widget.controller.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bg;
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
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 520),
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
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
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
              ],
            ),
          ),
        ),
      ),
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

  Widget _choiceTile({
    required bool selected,
    required String label,
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

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
