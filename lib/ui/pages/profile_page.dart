import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../../logic/game_controller.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/countries.dart';
import 'history_page.dart';

// --- Shared helpers (top-level) ---
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

Widget _beltCard(String name, Color color, bool achieved) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color:
          achieved ? color.withOpacity(0.25) : Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: achieved ? color : Colors.white24, width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        const Text(' ',
            style:
                TextStyle(fontSize: 0)), // ensure constant first, then dynamic
        Text(name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2)),
        if (achieved) ...[
          const SizedBox(width: 8),
          const Icon(Icons.check_circle,
              color: Colors.lightGreenAccent, size: 16),
        ]
      ],
    ),
  );
}

Widget beltsGridWidget(Set<String> badges) {
  bool achievedLevel(int lvl) => badges.contains('Beat AI L$lvl');
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.dialogFieldBg.withOpacity(0.6),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white24, width: 1),
    ),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int lvl = 1; lvl <= 7; lvl++)
          _beltCard(
              AiBelt.nameFor(lvl), AiBelt.colorFor(lvl), achievedLevel(lvl)),
      ],
    ),
  );
}

Widget dailyActivityList(GameController controller) {
  final counts = controller.dailyPlayCountByDate;
  final times = controller.dailyPlayTimeByDate;
  final keys = counts.keys.toSet()..addAll(times.keys);
  final days = keys.toList()..sort((a, b) => b.compareTo(a)); // desc yyyy-MM-dd
  final show = days.take(10).toList();
  if (show.isEmpty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dialogFieldBg.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: const Text('No activity yet',
          style: TextStyle(color: Colors.white70)),
    );
  }
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.dialogFieldBg.withOpacity(0.6),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white24, width: 1),
    ),
    child: Column(
      children: [
        for (final d in show)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                    child: Text(d,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white24, width: 1)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sports_esports,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text('${counts[d] ?? 0}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white24, width: 1)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/icons/duration-removebg.png',
                          width: 16, height: 16),
                      const SizedBox(width: 6),
                      Text(_formatDuration(times[d] ?? 0),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class ProfileDialog extends StatefulWidget {
  final GameController controller;
  const ProfileDialog({super.key, required this.controller});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  late final TextEditingController _nicknameController;
  String? _nicknameError;
  late String _selectedCountry;

  @override
  void initState() {
    super.initState();
    _nicknameController =
        TextEditingController(text: widget.controller.nickname);
    _selectedCountry = Countries.normalize(widget.controller.country);
    if (_selectedCountry != widget.controller.country) {
      widget.controller.setCountry(_selectedCountry);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  String? _validateNickname(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Nickname is required';
    }
    if (trimmed.length > 32) {
      return 'Maximum 32 characters allowed';
    }
    if (!GameController.nicknameRegExp.hasMatch(trimmed)) {
      return 'Use letters, numbers, dot, dash, or underscore';
    }
    return null;
  }

  Future<void> _saveNickname() async {
    final value = _nicknameController.text;
    final error = _validateNickname(value);
    setState(() {
      _nicknameError = error;
    });
    if (error != null) return;
    final saved = await widget.controller.setNickname(value.trim());
    if (!mounted) return;
    if (!saved) {
      setState(() {
        _nicknameError = 'Use letters, numbers, dot, dash, or underscore';
      });
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nickname updated')),
    );
  }

  Widget _achChip(String text, bool achieved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: achieved
            ? Colors.lightGreenAccent.withOpacity(0.18)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: achieved ? Colors.lightGreenAccent : Colors.white24,
            width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Icon(achieved ? Icons.check : Icons.radio_button_unchecked,
              color: achieved ? Colors.lightGreenAccent : Colors.white38,
              size: 16),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.dialogSubtitle,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.dialogFieldBg.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _nicknameRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 140,
              child: Text('Nickname',
                  style: TextStyle(
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
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    hintText: 'Enter nickname',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _nicknameError = _validateNickname(value);
                    });
                  },
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

  Widget _countryRow() {
    final options = Countries.optionsForSelection(_selectedCountry);
    return Row(
      children: [
        const SizedBox(
          width: 140,
          child: Text('Country',
              style: TextStyle(
                  color: AppColors.dialogSubtitle,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.dialogFieldBg.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountry,
                isExpanded: true,
                dropdownColor: AppColors.dialogFieldBg.withOpacity(0.92),
                iconEnabledColor: Colors.white70,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
                items: options
                    .map((country) => DropdownMenuItem<String>(
                          value: country,
                          enabled: country != Countries.defaultCountry,
                          child: Text(country),
                        ))
                    .toList(),
                onChanged: (value) async {
                  if (value == null || value == _selectedCountry) return;
                  setState(() {
                    _selectedCountry = value;
                  });
                  await widget.controller.setCountry(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bg;
    final controller = widget.controller;
    // Legacy badges are deprecated in UI; keep only Achievements and Belts sections
    // final badges = controller.badges.toList()..sort();
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
                    const Text('Profile',
                        style: TextStyle(
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
                        _countryRow(),
                        const SizedBox(height: 8),
                        _infoRow('Age', controller.age.toString()),
                        const SizedBox(height: 16),
                        _infoRow('Total score',
                            controller.totalUserScore.toString()),
                        const SizedBox(height: 8),
                        _infoRow('Full red lines made',
                            controller.redLinesCompletedTotal.toString()),
                        const SizedBox(height: 16),
                        _infoRow('Total time played',
                            _formatDuration(controller.totalPlayTimeMs)),
                        const SizedBox(height: 16),
                        const Text('Belts',
                            style: TextStyle(
                                color: AppColors.dialogSubtitle,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2)),
                        const SizedBox(height: 8),
                        beltsGridWidget(controller.badges),
                        const SizedBox(height: 16),
                        const Text('Achievements',
                            style: TextStyle(
                                color: AppColors.dialogSubtitle,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _achChip('Full Row', controller.achievedRedRow),
                            _achChip(
                                'Full Column', controller.achievedRedColumn),
                            _achChip(
                                'Diagonal', controller.achievedRedDiagonal),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Daily activity',
                            style: TextStyle(
                                color: AppColors.dialogSubtitle,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2)),
                        const SizedBox(height: 8),
                        dailyActivityList(controller),
                        // Legacy badges section removed as per spec; only Achievements and Belts remain
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
                          backgroundColor: Colors.white.withOpacity(0.12),
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w800, letterSpacing: 0.2),
                        ),
                        child: const Text('History'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _saveNickname,
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
                        child: const Text('Save'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.12),
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w800, letterSpacing: 0.2),
                        ),
                        child: const Text('Close'),
                      ),
                    ],
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

Future<void> showAnimatedProfileDialog(
    {required BuildContext context, required GameController controller}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Profile',
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
