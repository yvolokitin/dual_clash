import 'package:flutter/material.dart';
import '../../models/cell_state.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';

class CellWidget extends StatefulWidget {
  final CellState state;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius; // optional custom radius per-cell
  final bool usePlayerTokens;

  const CellWidget(
      {super.key,
      required this.state,
      this.onTap,
      this.onLongPress,
      this.borderRadius,
      this.usePlayerTokens = false});

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget> {
  CellState? _prev;
  late CellState _displayState;
  bool _flashing = false;

  @override
  void initState() {
    super.initState();
    _displayState = widget.state;
  }

  @override
  void didUpdateWidget(covariant CellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prev = oldWidget.state;

    final oldState = oldWidget.state;
    final newState = widget.state;

    final isColorChange = oldState != CellState.empty &&
        newState != CellState.empty &&
        oldState != newState;

    if (isColorChange) {
      // Show flash with the old color first, then update to the new color to animate tween
      _displayState = oldState;
      _flashing = true;
      // Schedule end of flash, then update to new color
      Future.delayed(const Duration(milliseconds: 140), () {
        if (!mounted) return;
        setState(() {
          _flashing = false;
          _displayState = newState;
        });
      });
    } else {
      // Default: mirror the incoming state immediately
      _displayState = newState;
      _flashing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlacement = widget.state != CellState.empty &&
        (_prev == null || _prev == CellState.empty);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (currentChild, previousChildren) => Stack(
          fit: StackFit.expand,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        ),
        transitionBuilder: (child, animation) {
          // Apply a scale pop-in when a new tile is placed (empty -> filled)
          final keyVal =
              (child.key is ValueKey) ? (child.key as ValueKey).value : null;
          final isFilledChild = keyVal == 'filled';
          if (isPlacement && isFilledChild) {
            return ScaleTransition(scale: animation, child: child);
          }
          return FadeTransition(opacity: animation, child: child);
        },
        child: _buildForState(_displayState),
      ),
    );
  }

  Widget _buildForState(CellState state) {
    String _assetFor(CellState state) {
      final bool usePlayer = widget.usePlayerTokens ||
          state == CellState.yellow ||
          state == CellState.green;
      switch (state) {
        case CellState.red:
          return 'assets/icons/box_red.png';
        case CellState.blue:
          return 'assets/icons/box_blue.png';
        case CellState.yellow:
          return 'assets/icons/box_yellow.png';
        case CellState.green:
          return 'assets/icons/box_green.png';
        case CellState.neutral:
          return 'assets/icons/box_grey.png';
        case CellState.bomb:
        case CellState.wall:
        case CellState.empty:
          return '';
      }
    }

    switch (state) {
      case CellState.empty:
        return _EmptyCell(
            key: const ValueKey('empty'),
            radius: widget.borderRadius ?? BorderRadius.circular(8));
      case CellState.red:
        return _InsetTile(
            color: AppColors.red,
            radius: widget.borderRadius ?? BorderRadius.circular(8),
            asset: _assetFor(state),
            flashing: _flashing,
            key: const ValueKey('filled'));
      case CellState.blue:
        return _InsetTile(
            color: AppColors.blue,
            radius: widget.borderRadius ?? BorderRadius.circular(8),
            asset: _assetFor(state),
            flashing: _flashing,
            key: const ValueKey('filled'));
      case CellState.yellow:
        return _InsetTile(
            color: AppColors.yellow,
            radius: widget.borderRadius ?? BorderRadius.circular(8),
            asset: _assetFor(state),
            flashing: _flashing,
            key: const ValueKey('filled'));
      case CellState.green:
        return _InsetTile(
            color: AppColors.green,
            radius: widget.borderRadius ?? BorderRadius.circular(8),
            asset: _assetFor(state),
            flashing: _flashing,
            key: const ValueKey('filled'));
      case CellState.neutral:
        return _InsetTile(
            color: AppColors.neutral,
            radius: widget.borderRadius ?? BorderRadius.circular(8),
            asset: _assetFor(state),
            flashing: _flashing,
            key: const ValueKey('filled'));
      case CellState.bomb:
        return _BombTile(
          radius: widget.borderRadius ?? BorderRadius.circular(8),
          flashing: _flashing,
          key: const ValueKey('bomb'),
        );
      case CellState.wall:
        return _InsetTile(
          color: AppColors.cellDark,
          radius: widget.borderRadius ?? BorderRadius.circular(8),
          asset: _assetFor(state),
          flashing: _flashing,
          key: const ValueKey('wall'),
        );
    }
  }
}

class _EmptyCell extends StatelessWidget {
  final BorderRadius radius;
  const _EmptyCell({super.key, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base dark panel
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2547),
            borderRadius: radius,
            border: null,
          ),
        ),

        // Subtle inner rim highlight at the top to imply depth
        Positioned.fill(
          child: ClipRRect(
            borderRadius: radius,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x22FFFFFF), Color(0x00000000)],
                  stops: [0.0, 0.25],
                ).createShader(rect);
              },
              blendMode: BlendMode.srcATop,
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // Bottom inner shadow to seat the tile
        Positioned.fill(
          child: ClipRRect(
            borderRadius: radius,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0x22000000), Color(0x00000000)],
                  stops: [0.0, 0.35],
                ).createShader(rect);
              },
              blendMode: BlendMode.srcATop,
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // Soft vignette around edges to make cell look inset
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: const [
                  BoxShadow(color: Color(0x11000000), blurRadius: 2),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BombTile extends StatelessWidget {
  final BorderRadius radius;
  final bool flashing;
  const _BombTile({super.key, required this.radius, required this.flashing});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _InsetTile(
          color: const Color(0xFF2A2F45),
          radius: radius,
          asset: 'assets/icons/bomb.png',
          flashing: flashing,
        ),
      ],
    );
  }
}

/// Generic beveled tile with slight top highlight and bottom inner shadow.
/// Rendered inset within the cell to look "inside" the board.
class _InsetTile extends StatelessWidget {
  final Color color; // kept for backward compatibility (unused for image fill)
  final bool flashing;
  final BorderRadius radius;
  final String asset;
  const _InsetTile(
      {required this.color,
      required this.radius,
      required this.asset,
      this.flashing = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    // Draw the tile content without any outer padding/border to avoid
    // the dark rim showing through at rounded corners.
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base image. Disable linear sampling to avoid dark fringe
            // around transparent pixels when the image is scaled.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Image.asset(
                asset,
                key: ValueKey(asset),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),
            ),

            // Flash overlay when color is changing
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: flashing ? 0.9 : 0.0,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      // warm white flash with slight radial falloff via gradient
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.2,
                        colors: [Color(0xCCFFFFFF), Color(0x00FFFFFF)],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Removed extra highlight/shadow overlays to prevent any rim or darkening
            // bleeding into the transparent corners of the tile image.
          ],
        ),
      ),
    );
  }
}
