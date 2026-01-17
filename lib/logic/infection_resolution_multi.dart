import '../models/multi_cell_state.dart';
import 'adjacency.dart';
import 'infection_resolution.dart';
import 'game_rules_config.dart';

/// Centralized infection resolution for multi-player boards using MultiCellState.
class MultiInfectionResolution {
  /// Apply ownership transitions to the provided [neighbors] for a placement at
  /// (r,c) by [attacker] on a mutable [board] clone.
  static void applyOwnershipTransitions(
    List<List<MultiCellState>> board,
    int r,
    int c,
    MultiCellState attacker,
    Iterable<(int, int)> neighbors,
    InfectionResolutionMode resolutionMode,
  ) {
    for (final (nr, nc) in neighbors) {
      final s = board[nr][nc];
      // Skip non-empty special tiles if they exist in multi mode (no bombs/walls here)
      if (s == MultiCellState.empty || s == attacker) continue;

      switch (resolutionMode) {
        case InfectionResolutionMode.neutralIntermediary:
          if (s == MultiCellState.neutral) {
            board[nr][nc] = attacker;
          } else {
            // Any opponent player color becomes neutral
            board[nr][nc] = MultiCellState.neutral;
          }
          break;
        case InfectionResolutionMode.directTransfer:
          if (s == MultiCellState.neutral) {
            // Do not interact with neutrals in direct transfer.
            continue;
          } else {
            board[nr][nc] = attacker;
          }
          break;
      }
    }
  }

  /// Convenience overload that uses current GameRulesConfig (adjacency & resolution).
  static void applyUsingDefaults(
    List<List<MultiCellState>> board,
    int r,
    int c,
    MultiCellState attacker,
  ) {
    final neighbors = Adjacency.neighborsOf(r, c);
    applyOwnershipTransitions(
      board,
      r,
      c,
      attacker,
      neighbors,
      GameRulesConfig.current.resolutionMode,
    );
  }
}
