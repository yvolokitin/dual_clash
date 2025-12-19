import 'package:flutter/material.dart';
import '../../logic/game_controller.dart';
import '../../core/colors.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'menu_page.dart' show showLoadGameDialog; // reuse existing dialog

class MainMenuPage extends StatelessWidget {
  final GameController controller;
  const MainMenuPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Spec: solid green background #22B14C on the Game menu screen
    const Color menuGreen = Color(0xFF22B14C);
    final size = MediaQuery.of(context).size;
    final double topHeroHeight =
        size.height * 0.25; // 25% of top page for the image

    return Scaffold(
      backgroundColor: menuGreen,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top app bar row (back and title)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  const SizedBox.shrink(),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // 25% top hero image
            SizedBox(
              height: topHeroHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: Image.asset(
                    'assets/icons/dual-clash-words-removebg.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Total points + time as one chip card (unified icon/text sizes)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Builder(
                    builder: (context) {
                      const Color darkBlue = Color(0xFF001F5B);
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

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4)),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                      'assets/icons/points-removebg.png',
                                      width: 24,
                                      height: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${controller.totalUserScore}',
                                    style: const TextStyle(
                                        color: darkBlue,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.black12,
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Image.asset(
                                      'assets/icons/duration-removebg.png',
                                      width: 24,
                                      height: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDuration(controller.totalPlayTimeMs),
                                    style: const TextStyle(
                                        color: darkBlue,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Centered menu items
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MenuActionTile(
                          color: Colors.orange,
                          iconPath: 'assets/icons/play-removebg.png',
                          label: 'Game challenge',
                          onTap: () {
                            Navigator.of(context).pop('challenge');
                          },
                        ),
                        const SizedBox(height: 10),
                        _MenuActionTile(
                          color: Colors.blue,
                          iconPath: 'assets/icons/load-removebg.png',
                          label: 'Load game',
                          onTap: () async {
                            final ok = await showLoadGameDialog(
                                context: context, controller: controller);
                            if (ok == true && context.mounted) {
                              Navigator.of(context).pop('loaded');
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        _MenuActionTile(
                          color: const Color(0xFF8B4513), // brown
                          iconPath: 'assets/icons/history-removebg.png',
                          label: 'History',
                          onTap: () async {
                            await showAnimatedHistoryDialog(
                                context: context, controller: controller);
                          },
                        ),
                        const SizedBox(height: 10),
                        _MenuActionTile(
                          color: Colors.red,
                          iconPath: 'assets/icons/profile-removebg.png',
                          label: 'Profile',
                          onTap: () async {
                            await showAnimatedProfileDialog(
                                context: context, controller: controller);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuActionTile extends StatelessWidget {
  final Color color;
  final String iconPath;
  final String label;
  final VoidCallback onTap;
  const _MenuActionTile(
      {required this.color,
      required this.iconPath,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              20, 12, 16, 12), // 20px left margin, ~15% reduced height
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10), // less rounded
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
            ],
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Image.asset(iconPath, fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                textAlign: TextAlign.left,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Route<T> buildMainMenuRoute<T>({required WidgetBuilder builder}) {
  // Cover effect: slide in from left on push, slide out to left on pop
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic);
      final offsetTween =
          Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero);
      return SlideTransition(
          position: offsetTween.animate(curved), child: child);
    },
  );
}
