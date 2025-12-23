import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../logic/multi_game_controller.dart';
import '../../models/multi_cell_state.dart';
import '../../core/constants.dart';
import '../../core/colors.dart';
import 'multi_cell_widget.dart';

class MultiBoardWidget extends StatelessWidget {
  final MultiGameController controller;
  const MultiBoardWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = math.min(constraints.maxWidth, constraints.maxHeight);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setBoardPixelSize(size);
      });
      final cellSize = size / K.n;
      return Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 14)),
              BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.bg, HSLColor.fromColor(AppColors.bg).withLightness( (HSLColor.fromColor(AppColors.bg).lightness + 0.2).clamp(0.0,1.0)).toColor()],
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: K.n == 9 ? EdgeInsets.zero : const EdgeInsets.only(bottom: 6),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: K.n,
                mainAxisSpacing: K.n == 9 ? 2 : 0,
                crossAxisSpacing: K.n == 9 ? 2 : 0,
              ),
              itemCount: K.n * K.n,
              itemBuilder: (context, index) {
                final r = index ~/ K.n;
                final c = index % K.n;
                final st = controller.board[r][c];
                final radius = BorderRadius.circular(K.n == 9 ? 2 : 8);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    MultiCellWidget(
                      state: st,
                      borderRadius: radius,
                      onTap: () => controller.onCellTap(r, c),
                    ),
                    if (controller.blowPreview.contains((r, c)))
                      const _AffectedHighlight(),
                    if (controller.selectedCell == (r, c) && st != MultiCellState.empty)
                      const _SelectedBorder(),
                  ],
                );
              },
            ),
          ),
        ),
      );
    });
  }
}

class _AffectedHighlight extends StatelessWidget {
  const _AffectedHighlight();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white24, width: 1),
        ),
      ),
    );
  }
}

class _SelectedBorder extends StatelessWidget {
  const _SelectedBorder();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.brandGold, width: 2),
        ),
      ),
    );
  }
}
