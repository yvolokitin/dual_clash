import 'dart:math' as math;
import '../models/cell_state.dart';
import '../core/constants.dart';
import 'rules_engine.dart';
import 'adjacency.dart';
import 'game_rules_config.dart';
import 'infection_resolution.dart';

/// Centralized, mode-aware AI evaluation utilities.
/// This module separates move generation (done by the caller)
/// from move evaluation (scoring), and uses the centralized
/// adjacency and infection resolution logic indirectly via
/// RulesEngine.place.
class AiDecisionModel {
  /// Evaluate a potential placement by [attacker] at (r,c).
  /// Returns a double score where higher is better for [attacker].
  /// The scoring is mode-aware:
  /// - Resolution: in neutralIntermediary, neutrals are mildly valuable buffers.
  /// - Adjacency: in 8-way mode, multi-capture potential and local change count
  ///   are weighted a bit higher.
  /// - Bomb risk: penalize placing adjacent (orthogonally) to enemy bombs.
  static double evaluatePlacement(
    List<List<CellState>> board,
    int r,
    int c,
    CellState attacker, {
    List<({int row, int col, CellState owner})> bombs = const [],
  }) {
    if (board[r][c] != CellState.empty) return double.negativeInfinity;
    final beforeBlue = RulesEngine.countOf(board, CellState.blue);
    final beforeRed = RulesEngine.countOf(board, CellState.red);
    final beforeNeutral = RulesEngine.countOf(board, CellState.neutral);

    // Simulate using centralized placement which composes adjacency+resolution.
    final sim = RulesEngine.place(board, r, c, attacker);
    if (sim == null) return double.negativeInfinity;

    final afterBlue = RulesEngine.countOf(sim, CellState.blue);
    final afterRed = RulesEngine.countOf(sim, CellState.red);
    final afterNeutral = RulesEngine.countOf(sim, CellState.neutral);

    // Base swing is measured Blue vs Red perspective. If attacker is Red, flip sign.
    int swingBlue = (afterBlue - beforeBlue) - (afterRed - beforeRed);
    if (attacker == CellState.red) swingBlue = -swingBlue;

    double score = swingBlue.toDouble();

    // Mode-aware adjustments
    final resMode = GameRulesConfig.current.resolutionMode;
    final adjMode = GameRulesConfig.current.adjacencyMode;

    if (resMode == InfectionResolutionMode.neutralIntermediary) {
      // Value neutrals as tactical buffers when we are Blue, or devalue when Red.
      final deltaNeutrals = afterNeutral - beforeNeutral;
      // Buffers are mildly useful: +0.6 per new neutral for Blue attacker, symmetric for Red.
      final neutralWeight = 0.6;
      score += (attacker == CellState.blue ? 1 : -1) * deltaNeutrals * neutralWeight;
    }

    // Local multi-capture/change density around the move coordinate.
    // Count number of neighbor cells that changed due to this placement.
    int localChanges = 0;
    for (final (nr, nc) in Adjacency.neighborsOf(r, c)) {
      if (RulesEngine.inBounds(nr, nc)) {
        if (board[nr][nc] != sim[nr][nc]) localChanges++;
      }
    }
    // Adjacency-aware bonus: in 8-way, emphasize multi-capture potential more.
    final densityWeight = (adjMode == InfectionAdjacencyMode.orthogonalPlusDiagonal8) ? 0.7 : 0.35;
    score += localChanges * densityWeight;

    // Slight center preference to improve board control.
    final center = (K.n - 1) / 2.0;
    final dist2 = (r - center) * (r - center) + (c - center) * (c - center);
    score += -0.05 * dist2;

    // Bomb risk: avoid placing adjacent (orthogonally) to opponent bombs;
    // explosion shape is cross-based regardless of adjacency mode.
    if (bombs.isNotEmpty) {
      final opponent = _opponentOf(attacker);
      int adjacentEnemyBombs = 0;
      for (final (nr, nc) in RulesEngine.neighbors4(r, c)) {
        for (final b in bombs) {
          if (b.owner == opponent && b.row == nr && b.col == nc) {
            adjacentEnemyBombs++;
          }
        }
      }
      if (adjacentEnemyBombs > 0) {
        // Penalty scales with number of adjacent bombs; bigger on large boards.
        final penalty = (adjacentEnemyBombs * (K.n >= 9 ? 3.5 : 3.0));
        score -= penalty;
      }
    }

    // Direct capture aggression: increase weight for immediate territory.
    if (resMode == InfectionResolutionMode.directTransfer) {
      score *= 1.15; // small aggressive tilt
    }

    return score;
  }

  /// Evaluate placing a bomb at (r,c) for [owner]. Higher is better for [owner].
  /// Heuristic considers expected blast value (enemies vs self), centrality,
  /// and slight boost in dense areas when 8-adjacency is enabled (higher swing risks/opportunities).
  static double evaluateBombPlacement(
    List<List<CellState>> board,
    int r,
    int c,
    CellState owner,
  ) {
    if (board[r][c] != CellState.empty) return double.negativeInfinity;
    final affected = RulesEngine.bombBlastAffected(board, r, c);
    int enemyCount = 0;
    int selfCount = 0;
    int nonEmpty = 0;
    for (final (ar, ac) in affected) {
      final s = board[ar][ac];
      if (s != CellState.empty) nonEmpty++;
      if (s == owner) selfCount++;
      // Opponent colors considered as enemies (red vs blue only for 2P AI)
      if (_isEnemy(owner, s)) enemyCount++;
    }
    // Base score: enemies minus self harm.
    double score = enemyCount.toDouble() - selfCount.toDouble();

    // Slight centrality bonus to prefer flexible blast positions.
    final center = (K.n - 1) / 2.0;
    final dist = (r - center).abs() + (c - center).abs();
    score += -0.2 * dist;

    // In 8-adjacency games, boards tend to cluster; prioritize bombs in denser spots.
    if (GameRulesConfig.current.adjacencyMode ==
        InfectionAdjacencyMode.orthogonalPlusDiagonal8) {
      score += 0.15 * nonEmpty; // small density boost
      if (enemyCount >= 3) score += 0.5; // extra nudge for multi-hits
    }

    return score;
  }

  /// Helper to search the best placement for [attacker] by scanning empties.
  /// Returns (row,col,score) or null if no legal placements.
  static ({int r, int c, double score})? bestPlacement(
    List<List<CellState>> board,
    CellState attacker, {
    List<({int row, int col, CellState owner})> bombs = const [],
  }) {
    double best = double.negativeInfinity;
    (int, int)? bestCell;
    for (int r = 0; r < K.n; r++) {
      for (int c = 0; c < K.n; c++) {
        if (board[r][c] != CellState.empty) continue;
        final score = evaluatePlacement(board, r, c, attacker, bombs: bombs);
        if (score > best) {
          best = score;
          bestCell = (r, c);
        } else if (score == best) {
          if (bestCell == null || r < bestCell.$1 || (r == bestCell.$1 && c < bestCell.$2)) {
            best = score;
            bestCell = (r, c);
          }
        }
      }
    }
    if (bestCell == null) return null;
    return (r: bestCell.$1, c: bestCell.$2, score: best);
  }

  static CellState _opponentOf(CellState s) {
    return s == CellState.blue ? CellState.red : CellState.blue;
  }

  static bool _isEnemy(CellState owner, CellState s) {
    if (s == CellState.empty || s == CellState.neutral || s == CellState.bomb || s == CellState.wall) return false;
    if (owner == CellState.blue) return s == CellState.red;
    if (owner == CellState.red) return s == CellState.blue;
    // For future multi-player AI, treat any other active color as enemy.
    return s != owner && s != CellState.empty && s != CellState.neutral;
  }
}
