import 'dart:ui' as ui;

import 'package:dual_clash/core/localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../logic/game_controller.dart';

class LanguageDialog extends StatefulWidget {
  final GameController controller;
  const LanguageDialog({super.key, required this.controller});

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  late String _language;
  late String _initialLanguage;

  @override
  void initState() {
    super.initState();
    _language = widget.controller.languageCode;
    _initialLanguage = _language;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = context.l10n;
    final bool isMobilePlatform = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final bool isMobileFullscreen = isMobilePlatform;
    final bool isNarrowMobile = isMobilePlatform && size.width < 700;
    final EdgeInsets dialogInsetPadding = isMobileFullscreen
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(
            horizontal: size.width * 0.1, vertical: size.height * 0.1);
    final BorderRadius dialogRadius =
        BorderRadius.circular(isMobileFullscreen ? 0 : 22);
    final EdgeInsets contentPadding =
        const EdgeInsets.fromLTRB(18, 20, 18, 18);
    final bool hasPendingChanges = _language != _initialLanguage;
    final double languageTileScale = isMobileFullscreen
        ? (isNarrowMobile ? 0.9 : 0.87)
        : 1.0;
    final bg = AppColors.bg;
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
            colors: [bg, bg],
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
            maxWidth: isMobileFullscreen ? size.width : size.width * 0.8,
            maxHeight: isMobileFullscreen ? size.height : size.height * 0.8,
            minWidth: isMobileFullscreen ? size.width : 0,
            minHeight: isMobileFullscreen ? size.height : 0,
          ),
          child: SafeArea(
            top: isMobileFullscreen,
            bottom: isMobileFullscreen,
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
                        l10n.languageTitle,
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
                                scale: languageTileScale,
                                onTap: () => setState(() => _language = code),
                              );
                            }).toList(),
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
                            await widget.controller.setLanguage(_language);
                            _initialLanguage = _language;
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
                ],
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

  List<(String, String, String)> _languageOptions() {
    return const [
      ('en', 'English', 'assets/icons/languages/lang_en.jpg'),
      ('de', 'Deutsch', 'assets/icons/languages/lang_de.jpg'),
      ('es', 'Español', 'assets/icons/languages/lang_es.jpg'),
      ('fr', 'Français', 'assets/icons/languages/lang_fr.jpg'),
      ('nl', 'Nederlands', 'assets/icons/languages/lang_nl.jpg'),
      ('pl', 'Polski', 'assets/icons/languages/lang_pl.jpg'),
      ('ru', 'Русский', 'assets/icons/languages/lang_ru.jpg'),
      ('uk', 'Українська', 'assets/icons/languages/lang_ua.jpg'),
    ];
  }

  Widget _languageTile({
    required bool selected,
    required String label,
    required String asset,
    double scale = 1.0,
    VoidCallback? onTap,
  }) {
    final double tileWidth = 110 * scale;
    final double tileHeight = 72 * scale;
    final double borderWidth = 3 * scale;
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
                  : BoxDecoration(
                      borderRadius: tileRadius,
                      border: Border.all(
                        color: Colors.transparent,
                        width: borderWidth,
                      ),
                    ),
              padding: EdgeInsets.all(borderWidth),
              child: Container(
                width: tileWidth,
                height: tileHeight,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: tileRadius,
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
            SizedBox(height: 6 * scale),
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
                  fontSize: 12 * scale,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAnimatedLanguageDialog(
    {required BuildContext context, required GameController controller}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.languageTitle,
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
                child: LanguageDialog(controller: controller),
              ),
            ),
          ),
        ],
      );
    },
  );
}
