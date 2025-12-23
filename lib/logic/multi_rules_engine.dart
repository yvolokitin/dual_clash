import '../models/multi_cell_state.dart';
import '../core/constants.dart';

class MultiRulesEngine {
  static List<MultiCellState> emptyRow() =>
      List<MultiCellState>.filled(K.n, MultiCellState.empty);
  static List<List<MultiCellState>> emptyBoard() =>
      List.generate(K.n, (_) => emptyRow());

  static bool inBounds(int r, int c) => r >= 0 && r < K.n && c >= 0 && c < K.n;

  static Iterable<(int, int)> neighbors4(int r, int c) sync* {
    if (inBounds(r - 1, c)) yield (r - 1, c);
    if (inBounds(r + 1, c)) yield (r + 1, c);
    if (inBounds(r, c - 1)) yield (r, c - 1);
    if (inBounds(r, c + 1)) yield (r, c + 1);
  }

  /// Generalized placement for N players:
  /// - Place attacker if cell empty.
  /// - Any orthogonal neighbor that is a different player color becomes Neutral (grey).
  /// - Any orthogonal Neutral neighbor becomes attacker's color.
  static List<List<MultiCellState>>? place(
      List<List<MultiCellState>> board, int r, int c, MultiCellState attacker) {
    if (!inBounds(r, c)) return null;
    if (board[r][c] != MultiCellState.empty) return null;

    // clone
    final next = List<List<MultiCellState>>.generate(
      K.n,
      (i) => List<MultiCellState>.from(board[i]),
    );

    // place attacker
    next[r][c] = attacker;

    for (final (nr, nc) in neighbors4(r, c)) {
      final s = next[nr][nc];
      if (s == MultiCellState.neutral) {
        next[nr][nc] = attacker;
      } else if (s != MultiCellState.empty && s != attacker) {
        next[nr][nc] = MultiCellState.neutral;
      }
    }

    return next;
  }

  static Set<(int, int)> blowAffected(
      List<List<MultiCellState>> board, int r, int c) {
    final set = <(int, int)>{};
    if (!inBounds(r, c)) return set;
    if (board[r][c] == MultiCellState.empty) return set;
    set.add((r, c));
    for (final (nr, nc) in neighbors4(r, c)) {
      if (board[nr][nc] != MultiCellState.empty) set.add((nr, nc));
    }
    return set;
  }

  static List<List<MultiCellState>> blow(
      List<List<MultiCellState>> board, Set<(int, int)> affected) {
    final next = List<List<MultiCellState>>.generate(
      K.n,
      (i) => List<MultiCellState>.from(board[i]),
    );
    for (final (r, c) in affected) {
      if (inBounds(r, c)) {
        next[r][c] = MultiCellState.empty;
      }
    }
    return next;
  }

  static List<List<MultiCellState>> removeAllNeutrals(
      List<List<MultiCellState>> board) {
    final next = List<List<MultiCellState>>.generate(
      K.n,
      (i) => List<MultiCellState>.from(board[i]),
    );
    for (int r = 0; r < K.n; r++) {
      for (int c = 0; c < K.n; c++) {
        if (next[r][c] == MultiCellState.neutral) next[r][c] = MultiCellState.empty;
      }
    }
    return next;
  }

  static (List<List<MultiCellState>> board, Map<(int, int), int> dropMap)
      applyGravity(List<List<MultiCellState>> board) {
    final next = List<List<MultiCellState>>.generate(
        K.n, (_) => List<MultiCellState>.filled(K.n, MultiCellState.empty));
    final drops = <(int, int), int>{};
    for (int c = 0; c < K.n; c++) {
      int writeR = K.n - 1;
      for (int r = K.n - 1; r >= 0; r--) {
        final s = board[r][c];
        if (s == MultiCellState.empty) continue;
        next[writeR][c] = s;
        final dropDist = writeR - r;
        if (dropDist > 0) {
          drops[(writeR, c)] = dropDist;
        }
        writeR--;
      }
    }
    return (next, drops);
  }

  static int countOf(List<List<MultiCellState>> board, MultiCellState s) {
    int cnt = 0;
    for (final row in board) {
      for (final cell in row) {
        if (cell == s) cnt++;
      }
    }
    return cnt;
  }

  static bool hasEmpty(List<List<MultiCellState>> board) {
    for (final row in board) {
      for (final cell in row) {
        if (cell == MultiCellState.empty) return true;
      }
    }
    return false;
  }
}
