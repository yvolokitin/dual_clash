import 'package:flutter/material.dart';
import '../models/multi_cell_state.dart';
import '../logic/multi_rules_engine.dart';
import '../core/constants.dart';
import '../core/colors.dart';

/// Minimal controller for 3- and 4-human modes.
/// Keeps logic separate from the existing GameController (2 players + AI).
class MultiGameController extends ChangeNotifier {
  final int playersCount; // 3 or 4
  final List<MultiCellState> players;

  List<List<MultiCellState>> board = MultiRulesEngine.emptyBoard();

  int currentIndex = 0; // index in players

  // UI helpers similar to the original controller
  bool isExploding = false;
  bool isFalling = false;
  bool isQuaking = false;
  int quakeDurationMs = 500;
  int fallDurationMs = 1000;
  double boardPixelSize = 0;

  Set<(int, int)> blowPreview = <(int, int)>{};
  (int, int)? selectedCell;
  Set<(int, int)> explodingCells = <(int, int)>{};
  Map<(int, int), int> fallingDistances = <(int, int), int>{};

  bool gameOver = false;

  MultiGameController.triple()
      : playersCount = 3,
        players = const [
          MultiCellState.red,
          MultiCellState.blue,
          MultiCellState.yellow,
        ];

  MultiGameController.quad()
      : playersCount = 4,
        players = const [
          MultiCellState.red,
          MultiCellState.blue,
          MultiCellState.yellow,
          MultiCellState.green,
        ];

  MultiCellState get current => players[currentIndex];

  void newGame() {
    board = MultiRulesEngine.emptyBoard();
    currentIndex = 0;
    gameOver = false;
    blowPreview.clear();
    selectedCell = null;
    notifyListeners();
  }

  void setBoardPixelSize(double px) {
    if (boardPixelSize != px) {
      boardPixelSize = px;
    }
  }

  Color colorFor(MultiCellState s) {
    switch (s) {
      case MultiCellState.red:
        return AppColors.red;
      case MultiCellState.blue:
        return AppColors.blue;
      case MultiCellState.yellow:
        return AppColors.accentYellow;
      case MultiCellState.green:
        return const Color(0xFF35A853);
      case MultiCellState.neutral:
        return AppColors.neutral;
      case MultiCellState.empty:
        return AppColors.cellDark;
    }
  }

  void _nextTurn() {
    currentIndex = (currentIndex + 1) % playersCount;
  }

  void _checkEnd() {
    if (!MultiRulesEngine.hasEmpty(board)) {
      gameOver = true;
    }
  }

  void onCellTap(int r, int c) {
    if (gameOver || isExploding || isFalling || isQuaking) return;
    final s = board[r][c];

    // Grey tap: select to preview all grey boxes; tap again to drop them
    if (s == MultiCellState.neutral) {
      if (selectedCell == (r, c)) {
        _performGreyDrop();
      } else {
        selectedCell = (r, c);
        blowPreview = _allNeutralCells();
        notifyListeners();
      }
      return;
    }

    if (s == MultiCellState.empty) {
      selectedCell = null;
      blowPreview.clear();
      final next = MultiRulesEngine.place(board, r, c, current);
      if (next != null) {
        board = next;
        _nextTurn();
        _checkEnd();
        notifyListeners();
      }
      return;
    }

    // Tapping own piece to blow
    if (s == current) {
      if (selectedCell == (r, c)) {
        _performBlow(r, c);
      } else {
        selectedCell = (r, c);
        blowPreview = MultiRulesEngine.blowAffected(board, r, c);
        notifyListeners();
      }
      return;
    }

    // otherwise deselect
    if (selectedCell != null) {
      selectedCell = null;
      blowPreview.clear();
      notifyListeners();
    }
  }

  Set<(int, int)> _allNeutralCells() {
    final set = <(int, int)>{};
    for (int i = 0; i < K.n; i++) {
      for (int j = 0; j < K.n; j++) {
        if (board[i][j] == MultiCellState.neutral) set.add((i, j));
      }
    }
    return set;
  }

  Future<void> _performGreyDrop() async {
    // quake effect
    isQuaking = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: quakeDurationMs));
    isQuaking = false;

    // remove all neutrals
    board = MultiRulesEngine.removeAllNeutrals(board);

    // apply gravity
    final res = MultiRulesEngine.applyGravity(board);
    board = res.$1;
    fallingDistances = res.$2;
    isFalling = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: fallDurationMs));

    isFalling = false;
    fallingDistances.clear();
    selectedCell = null;
    blowPreview.clear();

    _checkEnd();
    notifyListeners();
  }

  Future<void> _performBlow(int r, int c) async {
    isExploding = true;
    explodingCells = MultiRulesEngine.blowAffected(board, r, c);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 320));

    board = MultiRulesEngine.blow(board, explodingCells);
    explodingCells.clear();

    // fall
    final res = MultiRulesEngine.applyGravity(board);
    board = res.$1;
    fallingDistances = res.$2;
    isFalling = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: fallDurationMs));

    isFalling = false;
    fallingDistances.clear();
    selectedCell = null;
    blowPreview.clear();

    _checkEnd();
    notifyListeners();

    if (!gameOver) {
      _nextTurn();
      notifyListeners();
    }
  }
}
