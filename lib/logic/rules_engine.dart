import '../models/cell_state.dart';
import '../core/constants.dart';

class RulesEngine {
  static List<CellState> emptyRow() =>
      List<CellState>.filled(K.n, CellState.empty);
  static List<List<CellState>> emptyBoard() =>
      List.generate(K.n, (_) => emptyRow());

  static bool inBounds(int r, int c) => r >= 0 && r < K.n && c >= 0 && c < K.n;

  static Iterable<(int, int)> neighbors4(int r, int c) sync* {
    if (inBounds(r - 1, c)) yield (r - 1, c);
    if (inBounds(r + 1, c)) yield (r + 1, c);
    if (inBounds(r, c - 1)) yield (r, c - 1);
    if (inBounds(r, c + 1)) yield (r, c + 1);
  }

  /// Placement rules:
  /// - Place attacker into empty cell.
  /// - Any orthogonal opponent neighbor becomes Neutral.
  /// - Any orthogonal Neutral neighbor becomes attacker's color.
  static List<List<CellState>>? place(
      List<List<CellState>> board, int r, int c, CellState attacker) {
    if (!inBounds(r, c)) return null;
    if (board[r][c] != CellState.empty) return null;

    // clone
    final next = List<List<CellState>>.generate(
      K.n,
      (i) => List<CellState>.from(board[i]),
    );

    // 1) place attacker
    next[r][c] = attacker;

    // 2) process 4-neighbors
    for (final (nr, nc) in neighbors4(r, c)) {
      final s = next[nr][nc];

      if (s == CellState.bomb || s == CellState.wall) {
        continue;
      }
      if (s != attacker && s != CellState.empty && s != CellState.neutral) {
        next[nr][nc] = CellState.neutral;
      } else if (s == CellState.neutral) {
        next[nr][nc] = attacker;
      }
    }

    return next;
  }

  /// Cells that would be blown if detonating a piece at (r,c): the cell itself
  /// and any non-empty orthogonal neighbors.
  static Set<(int, int)> blowAffected(
      List<List<CellState>> board, int r, int c) {
    final set = <(int, int)>{};
    if (!inBounds(r, c)) return set;
    if (board[r][c] == CellState.empty) return set;
    set.add((r, c));
    for (final (nr, nc) in neighbors4(r, c)) {
      if (board[nr][nc] != CellState.empty) set.add((nr, nc));
    }
    return set;
  }

  /// Apply blow-up: set all affected cells to empty and return new board.
  static List<List<CellState>> blow(
      List<List<CellState>> board, Set<(int, int)> affected) {
    final next = List<List<CellState>>.generate(
      K.n,
      (i) => List<CellState>.from(board[i]),
    );
    for (final (r, c) in affected) {
      if (inBounds(r, c)) {
        next[r][c] = CellState.empty;
      }
    }
    return next;
  }

  /// Remove all neutral (grey) boxes from the board (set to empty)
  static List<List<CellState>> removeAllNeutrals(List<List<CellState>> board) {
    final next = List<List<CellState>>.generate(
      K.n,
      (i) => List<CellState>.from(board[i]),
    );
    for (int r = 0; r < K.n; r++) {
      for (int c = 0; c < K.n; c++) {
        if (next[r][c] == CellState.neutral) next[r][c] = CellState.empty;
      }
    }
    return next;
  }

  /// Apply gravity to make boxes fall down in each column.
  /// Returns a tuple: (newBoard, map of destination cell to drop distance in cells).
  static (List<List<CellState>> board, Map<(int, int), int> dropMap)
      applyGravity(List<List<CellState>> board) {
    final next = List<List<CellState>>.generate(
        K.n, (_) => List<CellState>.filled(K.n, CellState.empty));
    final drops = <(int, int), int>{};
    for (int c = 0; c < K.n; c++) {
      int writeR = K.n - 1;
      for (int r = K.n - 1; r >= 0; r--) {
        final s = board[r][c];
        if (s == CellState.empty) continue;
        if (s == CellState.bomb || s == CellState.wall) {
          next[r][c] = s;
          writeR = r - 1;
          continue;
        }
        // Only red/blue/neutral, but neutrals may be present when just falling after blow
        // We keep whatever non-empty state; falling does not change colors.
        if (writeR >= 0) {
          next[writeR][c] = s;
          final dropDist = writeR - r;
          if (dropDist > 0) {
            drops[(writeR, c)] = dropDist;
          }
          writeR--;
        }
      }
    }
    return (next, drops);
  }

  /// Cells affected by a bomb explosion in a cross pattern.
  static Set<(int, int)> bombBlastAffected(
      List<List<CellState>> board, int r, int c) {
    final set = <(int, int)>{};
    if (!inBounds(r, c)) return set;
    set.add((r, c));
    const dirs = <(int, int)>[
      (-1, 0),
      (1, 0),
      (0, -1),
      (0, 1),
    ];
    for (final dir in dirs) {
      int nr = r + dir.$1;
      int nc = c + dir.$2;
      while (inBounds(nr, nc)) {
        set.add((nr, nc));
        if (board[nr][nc] == CellState.wall) {
          break;
        }
        nr += dir.$1;
        nc += dir.$2;
      }
    }
    return set;
  }

  static int countOf(List<List<CellState>> board, CellState s) {
    int cnt = 0;
    for (final row in board) {
      for (final cell in row) {
        if (cell == s) cnt++;
      }
    }
    return cnt;
  }

  static bool hasEmpty(List<List<CellState>> board) {
    for (final row in board) {
      for (final cell in row) {
        if (cell == CellState.empty) return true;
      }
    }
    return false;
  }
}
