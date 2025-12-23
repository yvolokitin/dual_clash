import 'package:flutter/material.dart';
import '../../models/multi_cell_state.dart';
import '../../core/constants.dart';

class MultiCellWidget extends StatelessWidget {
  final MultiCellState state;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  const MultiCellWidget({super.key, required this.state, this.onTap, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _buildForState(state),
    );
  }

  Widget _buildForState(MultiCellState s) {
    switch (s) {
      case MultiCellState.empty:
        return _emptyCell();
      case MultiCellState.red:
        return _tile(const Color(0xFFD84A3A));
      case MultiCellState.blue:
        return _tile(const Color(0xFF1F73D1));
      case MultiCellState.yellow:
        return _tile(const Color(0xFFFFD166));
      case MultiCellState.green:
        return _tile(const Color(0xFF35A853));
      case MultiCellState.neutral:
        return _tile(const Color(0xFF8E8E90));
    }
  }

  Widget _emptyCell() {
    final radius = borderRadius ?? BorderRadius.circular(K.n == 9 ? 2 : 8);
    return Container(
      decoration: BoxDecoration(
        color: K.n == 9 ? const Color(0xFF1F2547) : const Color(0xFF1C4011),
        borderRadius: radius,
        border: K.n == 9 ? null : Border.all(color: const Color(0xFF121317), width: 2),
      ),
    );
  }

  Widget _tile(Color color) {
    final radius = borderRadius ?? BorderRadius.circular(K.n == 9 ? 2 : 8);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
      ),
    );
  }
}
