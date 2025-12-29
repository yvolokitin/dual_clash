import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../pages/profile_page.dart';
import '../../../logic/game_controller.dart';

class ProfileFullScreen extends StatelessWidget {
  final GameController controller;
  const ProfileFullScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ProfileDialog(controller: controller),
        ),
      ),
    );
  }
}
