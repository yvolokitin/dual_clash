
import 'dart:math';
import '../models/cell_state.dart';
import '../core/constants.dart';
import 'rules_engine.dart';

class SimpleAI {
  final _rng = Random();

  // Public entry: choose by level (L1..L7)
  (int, int)? chooseMoveLevel(List<List<CellState>> board, int level) {
    switch (level) {
      case 1:
        return _l1Random(board);
      case 2:
        return _l2Greedy(board);
      case 3:
        return _l3GreedyCenter(board);
      case 4:
        return _minimaxRoot(board, depth: 2, useAB: false);
      case 5:
        return _minimaxRoot(board, depth: 3, useAB: true, orderMoves: true);
      case 6:
        return _minimaxRoot(board, depth: 4, useAB: true, orderMoves: true, useTT: true);
      case 7:
        return _mcts(board, rollouts: 1500, timeLimitMs: 600);
      default:
        return _l2Greedy(board);
    }
  }

  /// Backward-compat: L2 greedy
  (int, int)? chooseMove(List<List<CellState>> board) => _l2Greedy(board);

  // L1 Random empty
  (int, int)? _l1Random(List<List<CellState>> board) {
    final empties = <(int, int)>[];
    for (int r = 0; r < K.n; r++) {
      for (int c = 0; c < K.n; c++) {
        if (board[r][c] == CellState.empty) empties.add((r, c));
      }
    }
    if (empties.isEmpty) return null;
    return empties[_rng.nextInt(empties.length)];
  }

  // L2 Greedy immediate blue gain
  (int, int)? _l2Greedy(List<List<CellState>> board) {
    int bestScore = -0x7fffffff;
    (int, int)? best;
    final baseBlue = RulesEngine.countOf(board, CellState.blue);
    for (int r = 0; r < K.n; r++) {
      for (int c = 0; c < K.n; c++) {
        if (board[r][c] != CellState.empty) continue;
        final sim = RulesEngine.place(board, r, c, CellState.blue);
        if (sim == null) continue;
        final blueCount = RulesEngine.countOf(sim, CellState.blue);
        final gain = blueCount - baseBlue;
        if (gain > bestScore || (gain == bestScore && _rng.nextBool())) {
          bestScore = gain;
          best = (r, c);
        }
      }
    }
    return best;
  }

  // L3 Greedy + center tie-break
  (int, int)? _l3GreedyCenter(List<List<CellState>> board) {
    int bestScore = -0x7fffffff;
    (int, int)? best;
    double bestDist = double.infinity;
    final baseBlue = RulesEngine.countOf(board, CellState.blue);
    final center = (K.n - 1) / 2.0;
    for (int r = 0; r < K.n; r++) {
      for (int c = 0; c < K.n; c++) {
        if (board[r][c] != CellState.empty) continue;
        final sim = RulesEngine.place(board, r, c, CellState.blue);
        if (sim == null) continue;
        final blueCount = RulesEngine.countOf(sim, CellState.blue);
        final gain = blueCount - baseBlue;
        final dist = (r - center) * (r - center) + (c - center) * (c - center);
        if (gain > bestScore || (gain == bestScore && dist < bestDist)) {
          bestScore = gain;
          bestDist = dist;
          best = (r, c);
        }
      }
    }
    return best;
  }

  // Helpers for search
  int _score(List<List<CellState>> b) => RulesEngine.countOf(b, CellState.blue) - RulesEngine.countOf(b, CellState.red);

  Iterable<(int, int)> _emptyCells(List<List<CellState>> b) sync* {
    for (int r = 0; r < K.n; r++) {
      for (int c = 0; c < K.n; c++) {
        if (b[r][c] == CellState.empty) yield (r, c);
      }
    }
  }

  List<((int, int) move, int gain)> _orderedBlueMovesByGain(List<List<CellState>> b) {
    final base = RulesEngine.countOf(b, CellState.blue);
    final list = <((int, int), int)>[];
    for (final mv in _emptyCells(b)) {
      final sim = RulesEngine.place(b, mv.$1, mv.$2, CellState.blue);
      if (sim == null) continue;
      final gain = RulesEngine.countOf(sim, CellState.blue) - base;
      list.add((mv, gain));
    }
    list.sort((a, b2) => b2.$2.compareTo(a.$2));
    // Limit branching for performance
    final limit = min(10, list.length);
    return list.take(limit).toList();
  }

  String _key(List<List<CellState>> b) {
    final sb = StringBuffer();
    for (int r = 0; r < K.n; r++) {
      for (int c = 0; c < K.n; c++) {
        final s = b[r][c];
        sb.write(s.index);
      }
    }
    return sb.toString();
  }

  (int, int)? _minimaxRoot(List<List<CellState>> board, {required int depth, required bool useAB, bool orderMoves = false, bool useTT = false}) {
    int bestVal = -0x7fffffff;
    (int, int)? bestMove;
    final tt = useTT ? <String, int>{} : null;

    Iterable<((int, int), int)> movesWithScores;
    if (orderMoves) {
      movesWithScores = _orderedBlueMovesByGain(board);
      if (movesWithScores.isEmpty) return null;
    } else {
      final list = <((int, int), int)>[];
      for (final mv in _emptyCells(board)) {
        list.add((mv, 0));
      }
      if (list.isEmpty) return null;
      movesWithScores = list;
    }

    int alpha = -0x7fffffff, beta = 0x7fffffff;
    for (final entry in movesWithScores) {
      final mv = entry.$1;
      final sim = RulesEngine.place(board, mv.$1, mv.$2, CellState.blue);
      if (sim == null) continue;
      final val = _minimax(sim, depth - 1, false, useAB, alpha, beta, tt);
      if (val > bestVal) {
        bestVal = val;
        bestMove = mv;
      }
      if (useAB) {
        if (val > alpha) alpha = val;
        if (beta <= alpha) break;
      }
    }
    return bestMove;
  }

  int _minimax(List<List<CellState>> b, int depth, bool isMax, bool useAB, int alpha, int beta, Map<String, int>? tt) {
    if (depth == 0 || !_hasEmpty(b)) return _score(b);
    if (tt != null) {
      final k = _key(b);
      final v = tt[k];
      if (v != null) return v;
    }

    if (isMax) {
      int best = -0x7fffffff;
      final moves = _orderedBlueMovesByGain(b);
      for (final e in moves) {
        final (r, c) = e.$1;
        final sim = RulesEngine.place(b, r, c, CellState.blue);
        if (sim == null) continue;
        final val = _minimax(sim, depth - 1, false, useAB, alpha, beta, tt);
        if (val > best) best = val;
        if (useAB) {
          if (val > alpha) alpha = val;
          if (beta <= alpha) break;
        }
      }
      if (tt != null) tt[_key(b)] = best;
      return best;
    } else {
      int best = 0x7fffffff;
      // For minimizing red, we can similarly order by red immediate gain
      final baseRed = RulesEngine.countOf(b, CellState.red);
      final list = <((int, int), int)>[];
      for (final mv in _emptyCells(b)) {
        final sim = RulesEngine.place(b, mv.$1, mv.$2, CellState.red);
        if (sim == null) continue;
        final gain = RulesEngine.countOf(sim, CellState.red) - baseRed;
        list.add((mv, gain));
      }
      list.sort((a, b2) => b2.$2.compareTo(a.$2));
      final limit = min(10, list.length);
      for (final e in list.take(limit)) {
        final (r, c) = e.$1;
        final sim = RulesEngine.place(b, r, c, CellState.red);
        if (sim == null) continue;
        final val = _minimax(sim, depth - 1, true, useAB, alpha, beta, tt);
        if (val < best) best = val;
        if (useAB) {
          if (val < beta) beta = val;
          if (beta <= alpha) break;
        }
      }
      if (tt != null) tt[_key(b)] = best;
      return best;
    }
  }

  bool _hasEmpty(List<List<CellState>> b) => RulesEngine.hasEmpty(b);

  // L7: simple MCTS over candidate first moves for Blue
  (int, int)? _mcts(List<List<CellState>> board, {int rollouts = 1500, int timeLimitMs = 600}) {
    final candidates = _orderedBlueMovesByGain(board);
    if (candidates.isEmpty) return null;
    final wins = List<int>.filled(candidates.length, 0);
    final plays = List<int>.filled(candidates.length, 0);
    final start = DateTime.now();

    int idx = 0;
    while (plays.reduce((a, b) => a + b) < rollouts && DateTime.now().difference(start).inMilliseconds < timeLimitMs) {
      final i = idx % candidates.length;
      idx++;
      final mv = candidates[i].$1;
      final sim = RulesEngine.place(board, mv.$1, mv.$2, CellState.blue);
      if (sim == null) continue;
      final blueWon = _randomPlayout(sim, CellState.red);
      plays[i]++;
      if (blueWon) wins[i]++;
    }

    // Select by best win rate
    double bestRate = -1;
    int bestI = 0;
    for (int i = 0; i < candidates.length; i++) {
      final p = plays[i] == 0 ? 0.0 : wins[i] / plays[i];
      if (p > bestRate) {
        bestRate = p;
        bestI = i;
      }
    }
    return candidates[bestI].$1;
  }

  bool _randomPlayout(List<List<CellState>> b, CellState turn) {
    // Play random until terminal or step cap
    var board = b;
    var current = turn;
    const maxSteps = 200; // cap to avoid long games
    int steps = 0;
    while (RulesEngine.hasEmpty(board) && steps < maxSteps) {
      steps++;
      final mv = _randomMove(board);
      if (mv == null) break;
      final sim = RulesEngine.place(board, mv.$1, mv.$2, current);
      if (sim == null) break;
      board = sim;
      current = current == CellState.red ? CellState.blue : CellState.red;
    }
    return _score(board) > 0; // blue wins if score positive
  }

  (int, int)? _randomMove(List<List<CellState>> b) {
    final xs = <(int, int)>[];
    for (final mv in _emptyCells(b)) xs.add(mv);
    if (xs.isEmpty) return null;
    return xs[_rng.nextInt(xs.length)];
  }
}
