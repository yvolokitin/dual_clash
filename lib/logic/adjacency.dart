import '../core/constants.dart';

/// Axis 2: Infection Adjacency Mode — defines which neighbors are considered
/// adjacent for infection-related operations.
enum InfectionAdjacencyMode {
  /// 4-way orthogonal neighbors: up, down, left, right.
  orthogonal4,

  /// 8-way neighbors: orthogonal plus diagonals.
  orthogonalPlusDiagonal8,
}

/// Centralized adjacency provider — the single source of truth for enumerating
/// neighboring cells. This is intentionally reusable by rules, AI, and UI.
class Adjacency {
  /// Global default mode. Do not wire runtime configuration in this step.
  /// Keep default to orthogonal4 to preserve current behavior.
  static InfectionAdjacencyMode mode = InfectionAdjacencyMode.orthogonal4;

  /// In-bounds check using current board size [K.n].
  static bool inBounds(int r, int c) => r >= 0 && r < K.n && c >= 0 && c < K.n;

  /// Return neighbors for the current [mode].
  static Iterable<(int, int)> neighborsOf(int r, int c) =>
      neighborsOfMode(r, c, mode);

  /// Return neighbors for the specified [adjMode]. This can be used by logic
  /// that must remain strictly 4-way even if the global default changes,
  /// e.g., certain explosion/activation rules.
  static Iterable<(int, int)> neighborsOfMode(
      int r, int c, InfectionAdjacencyMode adjMode) sync* {
    switch (adjMode) {
      case InfectionAdjacencyMode.orthogonal4:
        if (inBounds(r - 1, c)) yield (r - 1, c);
        if (inBounds(r + 1, c)) yield (r + 1, c);
        if (inBounds(r, c - 1)) yield (r, c - 1);
        if (inBounds(r, c + 1)) yield (r, c + 1);
        break;
      case InfectionAdjacencyMode.orthogonalPlusDiagonal8:
        // Orthogonal
        if (inBounds(r - 1, c)) yield (r - 1, c);
        if (inBounds(r + 1, c)) yield (r + 1, c);
        if (inBounds(r, c - 1)) yield (r, c - 1);
        if (inBounds(r, c + 1)) yield (r, c + 1);
        // Diagonals
        if (inBounds(r - 1, c - 1)) yield (r - 1, c - 1);
        if (inBounds(r - 1, c + 1)) yield (r - 1, c + 1);
        if (inBounds(r + 1, c - 1)) yield (r + 1, c - 1);
        if (inBounds(r + 1, c + 1)) yield (r + 1, c + 1);
        break;
    }
  }
}
