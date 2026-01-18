import 'dart:async';
import 'dart:ui' as ui;
import 'package:dual_clash/core/localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../logic/game_controller.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import 'help_page.dart';
import 'history_page.dart';

class ProfileDialog extends StatefulWidget {
  final GameController controller;
  const ProfileDialog({super.key, required this.controller});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  late final TextEditingController _nicknameController;
  Timer? _saveDebounce;
  String? _nicknameError;
  late int _age;

  @override
  void initState() {
    super.initState();
    _nicknameController =
        TextEditingController(text: widget.controller.nickname);
    _age = widget.controller.age.clamp(3, 99);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _nicknameController.dispose();
    super.dispose();
  }

  String? _validateNickname(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return context.l10n.nicknameRequiredError;
    }
    if (trimmed.length > 32) {
      return context.l10n.nicknameMaxLengthError;
    }
    if (!GameController.nicknameRegExp.hasMatch(trimmed)) {
      return context.l10n.nicknameInvalidCharsError;
    }
    return null;
  }

  Future<void> _saveNickname(String value) async {
    final error = _validateNickname(value);
    setState(() {
      _nicknameError = error;
    });
    if (error != null) return;
    final saved = await widget.controller.setNickname(value.trim());
    if (!mounted) return;
    if (!saved) {
      setState(() {
        _nicknameError = context.l10n.nicknameInvalidCharsError;
      });
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.nicknameUpdatedMessage)),
    );
  }

  void _handleNicknameChanged(String value) {
    final error = _validateNickname(value);
    setState(() {
      _nicknameError = error;
    });
    _saveDebounce?.cancel();
    if (error != null) return;
    final trimmed = value.trim();
    if (trimmed == widget.controller.nickname) return;
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      _saveNickname(trimmed);
    });
  }

  Future<void> _updateAge(int delta) async {
    final next = (_age + delta).clamp(3, 99);
    if (next == _age) return;
    setState(() {
      _age = next;
    });
    await widget.controller.setAge(_age);
  }

  Widget _ageRow() {
    final l10n = context.l10n;
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(l10n.ageLabel,
              style: const TextStyle(
                  color: AppColors.dialogSubtitle,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.dialogFieldBg.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AgeButton(
                    icon: Icons.remove,
                    onPressed: () => _updateAge(-1),
                    enabled: _age > 3),
                Expanded(
                  child: Center(
                    child: Text('$_age',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                  ),
                ),
                _AgeButton(
                    icon: Icons.add,
                    onPressed: () => _updateAge(1),
                    enabled: _age < 99),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _nicknameRow() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(l10n.nicknameLabel,
                  style: const TextStyle(
                      color: AppColors.dialogSubtitle,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.dialogFieldBg.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: TextField(
                  controller: _nicknameController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9._-]')),
                    LengthLimitingTextInputFormatter(32),
                  ],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: l10n.enterNicknameHint,
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                  onChanged: _handleNicknameChanged,
                ),
              ),
            ),
          ],
        ),
        if (_nicknameError != null)
          Padding(
            padding: const EdgeInsets.only(left: 148, top: 4),
            child: Text(_nicknameError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
      ],
    );
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
    final bg = AppColors.bg;
    final controller = widget.controller;
    final EdgeInsets dialogInsetPadding = isMobileFullscreen
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(
            horizontal: size.width * 0.1, vertical: size.height * 0.1);
    final BorderRadius dialogRadius =
        BorderRadius.circular(isMobileFullscreen ? 0 : 22);
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
                      Text(l10n.profileTitle,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dialogTitle,
                              letterSpacing: 0.2)),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1)),
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
                          _nicknameRow(),
                          const SizedBox(height: 8),
                          _ageRow(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isNarrowMobile) ...[
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await Future.delayed(
                                  const Duration(milliseconds: 50));
                              if (context.mounted) {
                                await showAnimatedHistoryDialog(
                                    context: context, controller: controller);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.black54,
                              elevation: 4,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2),
                            ),
                            child: Text(l10n.historyTitle),
                          ),
                          const SizedBox(width: 10),
                        ],
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await Future.delayed(
                                const Duration(milliseconds: 50));
                            if (context.mounted) {
                              await showAnimatedHelpDialog(
                                  context: context, controller: controller);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.black54,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2),
                          ),
                          child: Text(l10n.helpTitle),
                        ),
                        const SizedBox(width: 10),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showAnimatedProfileDialog(
    {required BuildContext context, required GameController controller}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.profileTitle,
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
                child: ProfileDialog(controller: controller),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _AgeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;
  const _AgeButton(
      {required this.icon, required this.onPressed, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon,
            color: enabled ? Colors.white : Colors.white38, size: 18),
        style: IconButton.styleFrom(
          backgroundColor:
              enabled ? Colors.white.withOpacity(0.08) : Colors.white12,
          disabledBackgroundColor: Colors.white12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
