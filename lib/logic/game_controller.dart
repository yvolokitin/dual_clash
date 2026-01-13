import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../models/cell_state.dart';
import 'rules_engine.dart';
import 'ai.dart';
import '../core/colors.dart';
import '../core/constants.dart';
import '../models/game_result.dart';
import '../core/localization.dart';
import '../core/countries.dart';

enum _AiAction {
  place,
  blow,
  greyDrop,
}

class _GameSnapshot {
  final List<List<CellState>> board;
  final List<_BombToken> bombs;
  final Map<CellState, int> lastBombTurns;
  final CellState current;
  final int turnsRed;
  final int turnsBlue;
  final int turnsYellow;
  final int turnsGreen;
  final int bonusRed;
  final int bonusBlue;
  final int lastMovePoints;
  final CellState? lastMoveBy;
  final int redGamePoints;
  _GameSnapshot({
    required this.board,
    required this.bombs,
    required this.lastBombTurns,
    required this.current,
    required this.turnsRed,
    required this.turnsBlue,
    required this.turnsYellow,
    required this.turnsGreen,
    required this.bonusRed,
    required this.bonusBlue,
    required this.lastMovePoints,
    required this.lastMoveBy,
    required this.redGamePoints,
  });
}

class _BombToken {
  final int row;
  final int col;
  final CellState owner;
  final int placedTurn;

  const _BombToken({
    required this.row,
    required this.col,
    required this.owner,
    required this.placedTurn,
  });
}

class TurnStatEntry {
  final int turn; // 1-based red turn index
  final int points; // points gained (can be 0)
  final String desc; // human-readable description
  final int ts; // timestamp ms when logged
  const TurnStatEntry(
      {required this.turn,
      required this.points,
      required this.desc,
      required this.ts});
}

class GameController extends ChangeNotifier {
  // Duel mode: when true, both players are human and AI is disabled
  bool humanVsHuman = false;
  int duelPlayerCount = 2;
  bool allianceMode = false;
  int? campaignRestoreGridSize;
  int? campaignRestoreBoardSize;
  int? campaignRestoreAiLevel;
  bool? campaignRestoreBombsEnabled;
  bool? campaignRestoreHumanVsHuman;
  // --- Analytics & activity ---
  int totalPlayTimeMs = 0;

  // --- Per-game turn statistics (user's turns only) ---
  final List<TurnStatEntry> _turnStats = <TurnStatEntry>[];
  List<TurnStatEntry> get turnStats => List.unmodifiable(_turnStats);
  Map<String, int> dailyPlayCountByDate = <String, int>{}; // key: yyyy-MM-dd
  Map<String, int> dailyPlayTimeByDate = <String, int>{}; // key: yyyy-MM-dd, ms
  // Achievements: completion types
  bool achievedRedRow = false;
  bool achievedRedColumn = false;
  bool achievedRedDiagonal = false;
  bool achievedGamePoints100 = false;
  bool achievedGamePoints1000 = false;
  // --- Playtime tracking for current game ---
  int _playAccumMs =
      0; // accumulated active milliseconds for this game (excludes app downtime)
  int? _playStartMs; // when non-null, counting is running from this timestamp
  int lastGamePlayMs = 0; // finalized duration for the last finished game
  // Generation counter to invalidate any in-flight AI computations when state is reset/loaded
  int _aiGeneration = 0;
  // ---- Saved games data structure (JSON stored in SharedPreferences) ----
  // Each saved game entry:
  // { id: string, ts: int, name: string, state: { board: List<List<String>>, current: String, turnsRed:int, turnsBlue:int, bonusRed:int, bonusBlue:int, lastMovePoints:int, lastMoveBy:String?, startingPlayer:String, aiLevel:int } }
  // End-of-game winner border animation flag
  bool showWinnerBorderAnim = false;
  int winnerBorderAnimMs = 1500;
  // --- Undo support ---
  final List<_GameSnapshot> _undoStack = <_GameSnapshot>[];
  bool get canUndo {
    if (gameOver ||
        isSimulating ||
        isAiThinking ||
        isExploding ||
        isFalling ||
        isQuaking) return false;
    // If it's Red's turn, need at least two snapshots to go back to previous Red turn
    if (current == CellState.red) return _undoStack.length >= 2;
    // If it's Blue's turn (user just acted), one snapshot is enough
    return _undoStack.isNotEmpty;
  }

  // Per-move live points
  int lastMovePoints = 0;
  CellState? lastMoveBy;
  int scorePopupId = 0;
  int scorePopupPoints = 0;
  (int, int)? scorePopupCell;
  // Selection and explosion state
  (int, int)? selectedCell;
  Set<(int, int)> blowPreview = <(int, int)>{};
  Set<(int, int)> explodingCells = <(int, int)>{};
  bool isExploding = false;
  // Falling animation state
  Map<(int, int), int> fallingDistances = <(int, int), int>{};
  bool isFalling = false;
  // Quake animation state (earthquake effect before grey drop)
  bool isQuaking = false;
  int quakeDurationMs = 500;
  // Duration for fall-down animations in milliseconds (used for grey drop and blow fall-out)
  int fallDurationMs = 1000;
  // Profile data
  String nickname = 'Player';
  String country = Countries.defaultCountry;
  int age = 18;
  Set<String> badges = <String>{};
  int redLinesCompletedTotal = 0;
  List<List<CellState>> board = RulesEngine.emptyBoard();
  final List<_BombToken> _bombs = <_BombToken>[];
  final Map<CellState, int> _lastBombTurns = <CellState, int>{};
  bool bombsEnabled = true;
  bool bombMode = false;
  bool bombDragActive = false;
  Set<(int, int)> bombDragTargets = <(int, int)>{};
  Set<(int, int)> bombModeTargets = <(int, int)>{};
  bool bombAutoCountdownActive = false;
  int bombAutoCountdownValue = 0;
  // Who starts the game (persisted in settings); default is RED (human)
  CellState startingPlayer = CellState.red;
  CellState current = CellState.red; // current turn marker
  bool gameOver = false;
  final _ai = SimpleAI();
  bool isAiThinking = false;
  // Simulation progress state
  bool isSimulating = false;
  final _rng = math.Random();

  // Settings persistence keys
  static const _kThemeColorHex = 'themeColorHex';
  static const _kLanguageCode = 'languageCode';
  static const _kBoardSize = 'boardSize';
  static const _kAiLevel = 'aiLevel';
  static const _kBestChallengeScore = 'bestChallengeScore';
  static const _kLastBestChallengeScoreBefore = 'lastBestChallengeScoreBefore';
  static const _kLastGameWasNewBest = 'lastGameWasNewBest';
  static const _kTotalUserScore = 'totalUserScore';
  static const _kStartingPlayer = 'startingPlayer'; // 'red', 'blue', 'yellow', 'green'
  static const _kHistory = 'historyJson';
  static const _kSavedGames = 'savedGamesJson';
  // Profile/achievements keys
  static const _kNickname = 'nickname';
  static const _kCountry = 'country';
  static const _kAge = 'age';
  static const _kBadges = 'badges';
  static const _kRedLinesTotal = 'redLinesCompletedTotal';
  // Analytics keys
  static const _kTotalPlayTimeMs = 'totalPlayTimeMs';
  static const _kDailyPlayCountJson = 'dailyPlayCountJson';
  static const _kDailyPlayTimeJson = 'dailyPlayTimeJson';
  static const _kAchievedRedRow = 'achievedRedRow';
  static const _kAchievedRedColumn = 'achievedRedColumn';
  static const _kAchievedRedDiagonal = 'achievedRedDiagonal';
  static const _kAchievedGamePoints100 = 'achievedGamePoints100';
  static const _kAchievedGamePoints1000 = 'achievedGamePoints1000';
  static final RegExp nicknameRegExp = RegExp(r'^[A-Za-z0-9._-]{1,32}$');

  // In-memory settings
  int themeColorHex = 0xFF38518F; // 0xFF3B7D23;
  String languageCode = 'en';
  int boardSize = 9; // not yet applied to engine (future enhancement)
  int aiLevel = 1; // 1..7

  // Game session stats
  int turnsRed = 0;
  int turnsBlue = 0;
  int turnsYellow = 0;
  int turnsGreen = 0;
  int bonusRed = 0;
  int bonusBlue = 0;
  // Running game points for the user (RED), starting from 0 and accumulating per rules
  int redGamePoints = 0;
  // For results dialog: remember what we added and from which total
  int lastGamePointsAwarded = 0;
  int lastTotalBeforeAward = 0;
  int bestChallengeScore = 0;
  int lastBestChallengeScoreBefore = 0;
  bool lastGameWasNewBest = false;
  bool _endProcessed = false; // bonuses awarded and totals persisted
  bool resultsShown = false; // guard for UI dialog
  Set<(int, int)> goldCells =
      <(int, int)>{}; // cells in full lines to highlight at game end

  // Board pixel width/height from BoardWidget to align UI elements
  double boardPixelSize = 0;

  // Persistent total user (RED) score across games
  int totalUserScore = 0;

  // History of finished games
  List<GameResult> history = <GameResult>[];

  // Deep copy of board
  List<List<CellState>> _copyBoard(List<List<CellState>> src) =>
      List<List<CellState>>.generate(K.n, (i) => List<CellState>.from(src[i]));

  List<_BombToken> _copyBombs(List<_BombToken> src) => src
      .map((bomb) => _BombToken(
            row: bomb.row,
            col: bomb.col,
            owner: bomb.owner,
            placedTurn: bomb.placedTurn,
          ))
      .toList();

  Map<CellState, int> _copyBombTurns(Map<CellState, int> src) =>
      Map<CellState, int>.from(src);

  List<CellState> get activePlayers {
    if (!humanVsHuman) {
      return const [CellState.red, CellState.blue];
    }
    switch (duelPlayerCount) {
      case 3:
        return const [CellState.red, CellState.blue, CellState.yellow];
      case 4:
        return const [CellState.red, CellState.blue, CellState.yellow, CellState.green];
      default:
        return const [CellState.red, CellState.blue];
    }
  }

  bool get isMultiDuel => humanVsHuman && duelPlayerCount > 2;
  bool get usePlayerTokens => isMultiDuel;
  bool get hasAnyTurns =>
      turnsRed > 0 || turnsBlue > 0 || turnsYellow > 0 || turnsGreen > 0;

  CellState _nextPlayer(CellState currentPlayer) {
    final players = activePlayers;
    final index = players.indexOf(currentPlayer);
    if (index == -1) return players.first;
    return players[(index + 1) % players.length];
  }

  bool _isActivePlayer(CellState state) => activePlayers.contains(state);

  void _incrementTurnFor(CellState who) {
    switch (who) {
      case CellState.red:
        turnsRed++;
        break;
      case CellState.blue:
        turnsBlue++;
        break;
      case CellState.yellow:
        turnsYellow++;
        break;
      case CellState.green:
        turnsGreen++;
        break;
      case CellState.bomb:
      case CellState.wall:
      case CellState.neutral:
      case CellState.empty:
        break;
    }
  }

  int _turnIndexFor(CellState who) {
    switch (who) {
      case CellState.red:
        return turnsRed + 1;
      case CellState.blue:
        return turnsBlue + 1;
      case CellState.yellow:
        return turnsYellow + 1;
      case CellState.green:
        return turnsGreen + 1;
      case CellState.neutral:
      case CellState.empty:
      case CellState.bomb:
      case CellState.wall:
        return 0;
    }
  }

  int _turnsFor(CellState who) {
    switch (who) {
      case CellState.red:
        return turnsRed;
      case CellState.blue:
        return turnsBlue;
      case CellState.yellow:
        return turnsYellow;
      case CellState.green:
        return turnsGreen;
      case CellState.neutral:
      case CellState.empty:
      case CellState.bomb:
      case CellState.wall:
        return 0;
    }
  }

  int _bombCooldownFor(CellState owner) {
    final (base, min, threshold, _) = _bombConfigForBoard();
    final score = scoreFor(owner);
    final reduction = (score / threshold).floor();
    final cooldown = base - reduction;
    return cooldown < min ? min : cooldown;
  }

  (int base, int min, int threshold, int maxBombs) _bombConfigForBoard() {
    switch (K.n) {
      case 7:
        return (10, 10, 140, 1);
      case 8:
        return (10, 10, 180, 2);
      case 9:
      default:
        return (10, 10, 220, 2);
    }
  }

  int _maxBombsOnField() => _bombConfigForBoard().$4;

  _BombToken? _bombAt(int r, int c) {
    for (final bomb in _bombs) {
      if (bomb.row == r && bomb.col == c) return bomb;
    }
    return null;
  }

  CellState? bombOwnerAt(int r, int c) => _bombAt(r, c)?.owner;

  bool _hasEnemyAdjacent(int r, int c, CellState owner) {
    for (final (nr, nc) in RulesEngine.neighbors4(r, c)) {
      final s = board[nr][nc];
      if (_isActivePlayer(s) && s != owner) {
        return true;
      }
    }
    return false;
  }

  bool _canActivateBombToken(_BombToken bomb) {
    if (bomb.owner != current) return false;
    return _hasEnemyAdjacent(bomb.row, bomb.col, bomb.owner);
  }

  bool get canActivateAnyBomb =>
      bombsEnabled && _bombs.any((bomb) => _canActivateBombToken(bomb));

  bool get canPlaceBomb {
    if (!bombsEnabled) return false;
    if (gameOver || isAiThinking || isExploding || isFalling || isQuaking) {
      return false;
    }
    if (!humanVsHuman && current != CellState.red) return false;
    if (!_isActivePlayer(current)) return false;
    if (_turnsFor(current) == 0) return false;
    if (_bombs.length >= _maxBombsOnField()) return false;
    if (!RulesEngine.hasEmpty(board)) return false;
    final lastTurn = _lastBombTurns[current];
    if (lastTurn == null) return true;
    final cooldown = _bombCooldownFor(current);
    return _turnIndexFor(current) - lastTurn >= cooldown;
  }

  bool get bombActionEnabled => canPlaceBomb || canActivateAnyBomb;

  bool get isBombCooldownActive {
    final lastTurn = _lastBombTurns[current];
    if (lastTurn == null) return false;
    final cooldown = _bombCooldownFor(current);
    return _turnIndexFor(current) - lastTurn < cooldown;
  }

  CellState get bombVisualOwner => humanVsHuman ? current : CellState.red;

  bool get isBombCooldownVisual {
    final player = bombVisualOwner;
    final lastTurn = _lastBombTurns[player];
    if (lastTurn != null) {
      final cooldown = _bombCooldownFor(player);
      if (_turnIndexFor(player) - lastTurn < cooldown) {
        return true;
      }
    }
    return _turnsFor(player) == 0;
  }

  String? get bombDragHint {
    if (!bombDragActive) return null;
    if (bombDragTargets.isEmpty) {
      return 'No valid cells. Drop bombs next to an enemy.';
    }
    return 'Drag the bomb onto a highlighted cell next to an enemy.';
  }

  String? get bombActionHint {
    if (bombDragActive) return bombDragHint;
    final lastTurn = _lastBombTurns[current];
    if (lastTurn != null) {
      final cooldown = _bombCooldownFor(current);
      final remaining = cooldown - (_turnIndexFor(current) - lastTurn);
      if (remaining > 0) {
        return 'Wait $remaining turn${remaining == 1 ? '' : 's'} for cooldown.';
      }
    }
    if (bombActionEnabled) return null;
    if (gameOver) return 'Game over';
    if (!humanVsHuman && current != CellState.red) {
      return 'Wait for your turn to use a bomb.';
    }
    if (_turnsFor(current) == 0) {
      return 'Place at least one box before using a bomb.';
    }
    if (_bombs.length >= _maxBombsOnField()) {
      return 'Detonate a bomb to place another.';
    }
    if (!RulesEngine.hasEmpty(board)) {
      return 'Detonate a bomb to clear space.';
    }
    return 'Place a bomb on an empty cell.';
  }

  void setBombsEnabled(bool enabled, {bool notify = true}) {
    if (bombsEnabled == enabled) return;
    bombsEnabled = enabled;
    if (!enabled) {
      for (int r = 0; r < board.length; r++) {
        for (int c = 0; c < board[r].length; c++) {
          if (board[r][c] == CellState.bomb) {
            board[r][c] = CellState.empty;
          }
        }
      }
      _bombs.clear();
      _lastBombTurns.clear();
      bombMode = false;
      bombDragActive = false;
      bombDragTargets = <(int, int)>{};
      bombModeTargets = <(int, int)>{};
      bombAutoCountdownActive = false;
      bombAutoCountdownValue = 0;
    }
    if (notify) {
      notifyListeners();
    }
  }

  void startBombDrag() {
    if (!canPlaceBomb) return;
    bombDragActive = true;
    bombDragTargets = _validBombDropTargets();
    notifyListeners();
  }

  void endBombDrag() {
    if (!bombDragActive) return;
    bombDragActive = false;
    bombDragTargets = <(int, int)>{};
    notifyListeners();
  }

  bool isBombPlacementTarget(int r, int c) =>
      (bombMode && bombModeTargets.contains((r, c))) ||
      isBombDropTarget(r, c);

  bool isBombDropTarget(int r, int c) =>
      bombDragActive && bombDragTargets.contains((r, c));

  Set<(int, int)> _validBombDropTargets() {
    final targets = <(int, int)>{};
    if (!canPlaceBomb) return targets;
    for (int r = 0; r < K.n; r++) {
      for (int c = 0; c < K.n; c++) {
        if (board[r][c] != CellState.empty) continue;
        if (_hasEnemyAdjacent(r, c, current)) {
          targets.add((r, c));
        }
      }
    }
    return targets;
  }

  void handleBombDrop(int r, int c) {
    if (!isBombDropTarget(r, c)) return;
    _performBombPlacement(r, c, current);
    endBombDrag();
  }

  void toggleBombMode() {
    if (!bombActionEnabled) return;
    bombMode = !bombMode;
    if (bombMode) {
      selectedCell = null;
      blowPreview.clear();
      bombModeTargets = _validBombDropTargets();
    } else {
      bombModeTargets = <(int, int)>{};
    }
    notifyListeners();
  }

  void _handleTurnStart(CellState who) {
    if (bombMode) {
      bombMode = false;
      bombModeTargets = <(int, int)>{};
    }
  }

  // ---- Saved games helpers ----
  String _cellToStr(CellState s) {
    switch (s) {
      case CellState.red:
        return 'r';
      case CellState.blue:
        return 'b';
      case CellState.yellow:
        return 'y';
      case CellState.green:
        return 'g';
      case CellState.neutral:
        return 'n';
      case CellState.bomb:
        return 'o';
      case CellState.wall:
        return 'w';
      case CellState.empty:
      default:
        return 'e';
    }
  }

  CellState _strToCell(String s) {
    switch (s) {
      case 'r':
        return CellState.red;
      case 'b':
        return CellState.blue;
      case 'y':
        return CellState.yellow;
      case 'g':
        return CellState.green;
      case 'n':
        return CellState.neutral;
      case 'o':
        return CellState.bomb;
      case 'w':
        return CellState.wall;
      case 'e':
      default:
        return CellState.empty;
    }
  }

  String _ownerKey(CellState s) {
    switch (s) {
      case CellState.red:
        return 'red';
      case CellState.blue:
        return 'blue';
      case CellState.yellow:
        return 'yellow';
      case CellState.green:
        return 'green';
      default:
        return 'other';
    }
  }

  CellState _ownerFromKey(String s) {
    switch (s) {
      case 'red':
        return CellState.red;
      case 'blue':
        return CellState.blue;
      case 'yellow':
        return CellState.yellow;
      case 'green':
        return CellState.green;
      default:
        return CellState.neutral;
    }
  }

  int _currentAccumMs() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_playStartMs != null) return _playAccumMs + (now - _playStartMs!);
    return _playAccumMs;
  }

  Map<String, dynamic> _stateToMap() {
    return {
      'board': board.map((row) => row.map(_cellToStr).toList()).toList(),
      'current': current == CellState.red
          ? 'red'
          : (current == CellState.blue
              ? 'blue'
              : (current == CellState.yellow
                  ? 'yellow'
                  : (current == CellState.green
                      ? 'green'
                      : (current == CellState.neutral ? 'neutral' : 'empty')))),
      'turnsRed': turnsRed,
      'turnsBlue': turnsBlue,
      'turnsYellow': turnsYellow,
      'turnsGreen': turnsGreen,
      'bonusRed': bonusRed,
      'bonusBlue': bonusBlue,
      'lastMovePoints': lastMovePoints,
      'lastMoveBy': lastMoveBy == null
          ? null
          : (lastMoveBy == CellState.red
              ? 'red'
              : (lastMoveBy == CellState.blue
                  ? 'blue'
                  : (lastMoveBy == CellState.yellow
                      ? 'yellow'
                      : 'green'))),
      'startingPlayer': startingPlayer == CellState.blue
          ? 'blue'
          : (startingPlayer == CellState.yellow
              ? 'yellow'
              : (startingPlayer == CellState.green ? 'green' : 'red')),
      'aiLevel': aiLevel,
      'gameOver': gameOver,
      'redGamePoints': redGamePoints,
      'lastGamePointsAwarded': lastGamePointsAwarded,
      'lastTotalBeforeAward': lastTotalBeforeAward,
      'bestChallengeScore': bestChallengeScore,
      'lastBestChallengeScoreBefore': lastBestChallengeScoreBefore,
      'lastGameWasNewBest': lastGameWasNewBest,
      'playAccumMs': _currentAccumMs(),
      'bombs': _bombs
          .map((bomb) => {
                'r': bomb.row,
                'c': bomb.col,
                'o': _ownerKey(bomb.owner),
                't': bomb.placedTurn,
              })
          .toList(),
      'lastBombTurns': _lastBombTurns.map(
        (key, value) => MapEntry(_ownerKey(key), value),
      ),
    };
  }

  void _applyStateMap(Map<String, dynamic> m) {
    // Invalidate any in-flight AI computations from previous state
    _aiGeneration++;
    final b = m['board'] as List<dynamic>;
    board = List<List<CellState>>.generate(K.n, (r) {
      final row = b[r] as List<dynamic>;
      return List<CellState>.generate(K.n, (c) => _strToCell(row[c] as String));
    });
    _bombs
      ..clear()
      ..addAll(
        ((m['bombs'] as List<dynamic>?) ?? const <dynamic>[])
            .map((entry) => entry as Map<String, dynamic>)
            .map(
              (entry) => _BombToken(
                row: entry['r'] as int,
                col: entry['c'] as int,
                owner: _ownerFromKey(entry['o'] as String),
                placedTurn: entry['t'] as int,
              ),
            ),
      );
    for (final bomb in _bombs) {
      if (RulesEngine.inBounds(bomb.row, bomb.col)) {
        board[bomb.row][bomb.col] = CellState.bomb;
      }
    }
    _lastBombTurns
      ..clear()
      ..addAll(
        ((m['lastBombTurns'] as Map<String, dynamic>?) ??
                const <String, dynamic>{})
            .map((key, value) => MapEntry(_ownerFromKey(key), value as int)),
      );
    // Restore playtime accumulator from saved state; resume counting if game not over
    _playAccumMs = (m['playAccumMs'] as int?) ?? 0;
    _playStartMs = (m['gameOver'] as bool? ?? false)
        ? null
        : DateTime.now().millisecondsSinceEpoch;
    bombMode = false;
    bombModeTargets = <(int, int)>{};
    bombDragActive = false;
    bombDragTargets = <(int, int)>{};
    bombAutoCountdownActive = false;
    bombAutoCountdownValue = 0;
    final cur = m['current'] as String;
    current = cur == 'red'
        ? CellState.red
        : (cur == 'blue'
            ? CellState.blue
            : (cur == 'yellow'
                ? CellState.yellow
                : (cur == 'green'
                    ? CellState.green
                    : (cur == 'neutral' ? CellState.neutral : CellState.empty))));
    turnsRed = m['turnsRed'] as int;
    turnsBlue = m['turnsBlue'] as int;
    turnsYellow = m['turnsYellow'] as int? ?? 0;
    turnsGreen = m['turnsGreen'] as int? ?? 0;
    bonusRed = m['bonusRed'] as int;
    bonusBlue = m['bonusBlue'] as int;
    lastMovePoints = m['lastMovePoints'] as int;
    final lmb = m['lastMoveBy'];
    if (lmb == null) {
      lastMoveBy = null;
    } else {
      final last = lmb as String;
      lastMoveBy = last == 'red'
          ? CellState.red
          : (last == 'blue'
              ? CellState.blue
              : (last == 'yellow'
                  ? CellState.yellow
                  : CellState.green));
    }
    final startingKey = m['startingPlayer'] as String? ?? 'red';
    startingPlayer = startingKey == 'blue'
        ? CellState.blue
        : (startingKey == 'yellow'
            ? CellState.yellow
            : (startingKey == 'green' ? CellState.green : CellState.red));
    aiLevel = m['aiLevel'] as int;
    gameOver = m['gameOver'] as bool? ?? false;
    // Optional fields for points accounting
    redGamePoints = m['redGamePoints'] as int? ?? redGamePoints;
    lastGamePointsAwarded = m['lastGamePointsAwarded'] as int? ?? 0;
    lastTotalBeforeAward = m['lastTotalBeforeAward'] as int? ?? totalUserScore;
    bestChallengeScore = m['bestChallengeScore'] as int? ?? bestChallengeScore;
    lastBestChallengeScoreBefore =
        m['lastBestChallengeScoreBefore'] as int? ?? bestChallengeScore;
    lastGameWasNewBest = m['lastGameWasNewBest'] as bool? ?? false;

    // Clear transient/animation states
    _clearScorePopup();
    selectedCell = null;
    blowPreview.clear();
    explodingCells.clear();
    isExploding = false;
    fallingDistances.clear();
    isFalling = false;
    isQuaking = false;
    _endProcessed = false;
    resultsShown = false;
    goldCells.clear();
    isSimulating = false;
    // Ensure AI thinking overlay is not left active after loading a saved game
    isAiThinking = false;
    _handleTurnStart(current);

    notifyListeners();
    // If it's Blue's turn after loading (and game is not over), schedule AI automatically
    if (!humanVsHuman && !gameOver && current == CellState.blue) {
      // Defer to next microtask to avoid racing with dialog/pop animations
      Future.microtask(() {
        if (!humanVsHuman && !gameOver && current == CellState.blue) {
          _scheduleAi();
        }
      });
    }
  }

  void loadStateFromMap(Map<String, dynamic> state) {
    _applyStateMap(state);
  }

  Future<void> saveCurrentGame({String? name}) async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getString(_kSavedGames);
    List<dynamic> list = <dynamic>[];
    if (listJson != null && listJson.isNotEmpty) {
      try {
        list = jsonDecode(listJson) as List<dynamic>;
      } catch (_) {
        list = <dynamic>[];
      }
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = '${now}_${turnsRed + turnsBlue}';
    final entry = <String, dynamic>{
      'id': id,
      'ts': now,
      'name': name ?? 'Saved game',
      'current': current == CellState.red
          ? 'red'
          : (current == CellState.blue
              ? 'blue'
              : (current == CellState.yellow
                  ? 'yellow'
                  : (current == CellState.green ? 'green' : 'other'))),
      'state': _stateToMap(),
    };
    list.add(entry);
    // Keep only last 50 saves to avoid unbounded growth
    if (list.length > 50) {
      list = list.sublist(list.length - 50);
    }
    await prefs.setString(_kSavedGames, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> listSavedGames() async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getString(_kSavedGames);
    if (listJson == null || listJson.isEmpty) return <Map<String, dynamic>>[];
    try {
      final raw = jsonDecode(listJson) as List<dynamic>;
      // Newest first
      final items = raw.map((e) => e as Map<String, dynamic>).toList();
      items.sort((a, b) => (b['ts'] as int).compareTo(a['ts'] as int));
      return items;
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> loadSavedGameById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getString(_kSavedGames);
    if (listJson == null || listJson.isEmpty) return;
    try {
      final raw = jsonDecode(listJson) as List<dynamic>;
      for (final e in raw) {
        final m = e as Map<String, dynamic>;
        if (m['id'] == id) {
          final state = m['state'] as Map<String, dynamic>;
          _applyStateMap(state);
          return;
        }
      }
    } catch (_) {
      // ignore
    }
  }

  Future<bool> deleteSavedGameById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getString(_kSavedGames);
    if (listJson == null || listJson.isEmpty) return false;
    try {
      final raw = jsonDecode(listJson) as List<dynamic>;
      raw.removeWhere((e) => (e as Map<String, dynamic>)['id'] == id);
      await prefs.setString(_kSavedGames, jsonEncode(raw));
      return true;
    } catch (_) {
      return false;
    }
  }

  // Returns the JSON map string for a single saved game entry (not the whole list), or null.
  Future<String?> getSavedGameJsonById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getString(_kSavedGames);
    if (listJson == null || listJson.isEmpty) return null;
    try {
      final raw = jsonDecode(listJson) as List<dynamic>;
      for (final e in raw) {
        final m = e as Map<String, dynamic>;
        if (m['id'] == id) {
          return jsonEncode(m);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Import a saved game JSON (single entry). Generates a new id and timestamp.
  Future<bool> importSavedGameFromJson(String json) async {
    try {
      final entry = jsonDecode(json) as Map<String, dynamic>;
      // Basic validation
      if (!entry.containsKey('state')) return false;
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getString(_kSavedGames);
      List<dynamic> list = <dynamic>[];
      if (listJson != null && listJson.isNotEmpty) {
        try {
          list = jsonDecode(listJson) as List<dynamic>;
        } catch (_) {}
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      entry['id'] =
          '${now}_${(entry['state'] as Map<String, dynamic>)['turnsRed'] ?? 0}_${(entry['state'] as Map<String, dynamic>)['turnsBlue'] ?? 0}';
      entry['ts'] = now;
      list.add(entry);
      // Keep only last 50
      if (list.length > 50) {
        list = list.sublist(list.length - 50);
      }
      await prefs.setString(_kSavedGames, jsonEncode(list));
      return true;
    } catch (_) {
      return false;
    }
  }

  void _saveUndoPoint() {
    if (isSimulating) return;
    // Capture state at the beginning of Red's turn
    final snap = _GameSnapshot(
      board: _copyBoard(board),
      bombs: _copyBombs(_bombs),
      lastBombTurns: _copyBombTurns(_lastBombTurns),
      current: current,
      turnsRed: turnsRed,
      turnsBlue: turnsBlue,
      turnsYellow: turnsYellow,
      turnsGreen: turnsGreen,
      bonusRed: bonusRed,
      bonusBlue: bonusBlue,
      lastMovePoints: lastMovePoints,
      lastMoveBy: lastMoveBy,
      redGamePoints: redGamePoints,
    );
    _undoStack.add(snap);
  }

  void undoToPreviousUserTurn() {
    if (!canUndo) return;

    // We save snapshots at the START of each Red turn.
    // Undo semantics:
    // - If it's Blue's turn now, user just moved -> restore the TOP snapshot (start of this Red turn).
    // - If it's Red's turn now, AI has already moved after user's last move ->
    //   drop the TOP snapshot (current Red turn start) and restore the PREVIOUS snapshot.
    if (_undoStack.isEmpty) return;

    _GameSnapshot? snap;
    if (current == CellState.red) {
      // Move one step back in time by discarding the current Red turn's snapshot
      _undoStack.removeLast();
      if (_undoStack.isEmpty) return; // nothing to restore
      snap = _undoStack
          .last; // restore previous start-of-Red snapshot (do not remove it)
    } else {
      // Blue to move -> restore the current turn's snapshot
      snap = _undoStack
          .last; // do not remove, so consecutive undos can continue stepping back
    }

    // Remove last statistics entry to reflect undoing user's last completed turn
    if (_turnStats.isNotEmpty) {
      _turnStats.removeLast();
    }

    board = _copyBoard(snap.board);
    _bombs
      ..clear()
      ..addAll(_copyBombs(snap.bombs));
    _lastBombTurns
      ..clear()
      ..addAll(_copyBombTurns(snap.lastBombTurns));
    current = snap.current;
    turnsRed = snap.turnsRed;
    turnsBlue = snap.turnsBlue;
    turnsYellow = snap.turnsYellow;
    turnsGreen = snap.turnsGreen;
    bonusRed = snap.bonusRed;
    bonusBlue = snap.bonusBlue;
    lastMovePoints = snap.lastMovePoints;
    lastMoveBy = snap.lastMoveBy;
    redGamePoints = snap.redGamePoints;

    // Clear transient/animation states
    _clearScorePopup();
    selectedCell = null;
    blowPreview.clear();
    explodingCells.clear();
    isExploding = false;
    fallingDistances.clear();
    isFalling = false;
    isQuaking = false;
    bombMode = false;
    bombModeTargets = <(int, int)>{};
    bombDragActive = false;
    bombDragTargets = <(int, int)>{};
    bombAutoCountdownActive = false;
    bombAutoCountdownValue = 0;
    gameOver = false;
    _endProcessed = false;
    resultsShown = false;
    goldCells.clear();

    notifyListeners();
  }

  Future<void> loadSettingsAndApply() async {
    final prefs = await SharedPreferences.getInstance();
    themeColorHex = prefs.getInt(_kThemeColorHex) ?? themeColorHex;

    // One-time migration: if old default indigo was persisted, switch to new green
    if (themeColorHex == 0xFF4B0082) {
      themeColorHex = 0xFF3B7D23;
      // Persist migrated value so it sticks next launch
      await prefs.setInt(_kThemeColorHex, themeColorHex);
    }

    languageCode = prefs.getString(_kLanguageCode) ?? languageCode;
    boardSize = prefs.getInt(_kBoardSize) ?? boardSize;
    aiLevel = prefs.getInt(_kAiLevel) ?? aiLevel;
    totalUserScore = prefs.getInt(_kTotalUserScore) ?? 0;
    bestChallengeScore = prefs.getInt(_kBestChallengeScore) ?? 0;
    lastBestChallengeScoreBefore =
        prefs.getInt(_kLastBestChallengeScoreBefore) ?? bestChallengeScore;
    lastGameWasNewBest = prefs.getBool(_kLastGameWasNewBest) ?? false;
    // Starting player
    final sp = prefs.getString(_kStartingPlayer);
    switch (sp) {
      case 'blue':
        startingPlayer = CellState.blue;
        break;
      case 'yellow':
        startingPlayer = CellState.yellow;
        break;
      case 'green':
        startingPlayer = CellState.green;
        break;
      default:
        startingPlayer = CellState.red; // default
        break;
    }
    // Profile
    nickname = prefs.getString(_kNickname) ?? nickname;
    country = Countries.normalize(prefs.getString(_kCountry) ?? country);
    age = prefs.getInt(_kAge) ?? age;
    redLinesCompletedTotal = prefs.getInt(_kRedLinesTotal) ?? 0;
    final badgesList = prefs.getStringList(_kBadges) ?? const <String>[];
    badges = badgesList.toSet();
    // History
    final histJson = prefs.getString(_kHistory);
    if (histJson != null && histJson.isNotEmpty) {
      try {
        history = GameResult.decodeList(histJson);
      } catch (_) {
        history = <GameResult>[];
      }
    }

    // Analytics/activity
    totalPlayTimeMs = prefs.getInt(_kTotalPlayTimeMs) ?? 0;
    try {
      final cjson = prefs.getString(_kDailyPlayCountJson);
      if (cjson != null && cjson.isNotEmpty) {
        final Map<String, dynamic> m =
            jsonDecode(cjson) as Map<String, dynamic>;
        dailyPlayCountByDate = m.map((k, v) => MapEntry(k, (v as num).toInt()));
      }
    } catch (_) {}
    try {
      final tjson = prefs.getString(_kDailyPlayTimeJson);
      if (tjson != null && tjson.isNotEmpty) {
        final Map<String, dynamic> m =
            jsonDecode(tjson) as Map<String, dynamic>;
        dailyPlayTimeByDate = m.map((k, v) => MapEntry(k, (v as num).toInt()));
      }
    } catch (_) {}
    achievedRedRow = prefs.getBool(_kAchievedRedRow) ?? achievedRedRow;
    achievedRedColumn = prefs.getBool(_kAchievedRedColumn) ?? achievedRedColumn;
    achievedRedDiagonal =
        prefs.getBool(_kAchievedRedDiagonal) ?? achievedRedDiagonal;
    achievedGamePoints100 =
        prefs.getBool(_kAchievedGamePoints100) ?? achievedGamePoints100;
    achievedGamePoints1000 =
        prefs.getBool(_kAchievedGamePoints1000) ?? achievedGamePoints1000;

    // Apply theme immediately
    AppColors.bg = Color(themeColorHex);
    // Apply starting player to current game session (fresh board at startup)
    current = startingPlayer;

    // Start playtime for initial fresh session if not started yet (app startup case)
    final bool _freshBoard = RulesEngine.countOf(board, CellState.red) == 0 &&
        RulesEngine.countOf(board, CellState.blue) == 0;
    if (!gameOver && _freshBoard && _playStartMs == null) {
      _playAccumMs = 0;
      _playStartMs = DateTime.now().millisecondsSinceEpoch;
    }

    // If Blue starts and the board is empty, schedule AI first move
    if (!humanVsHuman && !gameOver && current == CellState.blue && _freshBoard) {
      _scheduleAi();
    }
    notifyListeners();
  }

  Future<void> applySettings({required int themeColorHex}) async {
    // Backward-compatible method used by existing UI
    await setThemeColor(themeColorHex);
  }

  Future<void> setThemeColor(int hex) async {
    themeColorHex = hex;
    AppColors.bg = Color(hex);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeColorHex, hex);
  }

  Future<void> setLanguage(String code) async {
    languageCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguageCode, code);
  }

  Future<void> setAge(int value) async {
    if (value < 3 || value > 99) return;
    age = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAge, value);
  }

  Future<bool> setNickname(String value) async {
    final trimmed = value.trim();
    if (!nicknameRegExp.hasMatch(trimmed)) return false;
    nickname = trimmed;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNickname, nickname);
    return true;
  }

  Future<void> setBoardSize(int size) async {
    boardSize = size;
    // Note: Changing board size does not rebuild current game yet.
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBoardSize, size);
  }

  Future<void> setAiLevel(int level) async {
    aiLevel = level;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAiLevel, level);
  }

  Future<void> setStartingPlayer(CellState who) async {
    startingPlayer = who;
    if (!hasAnyTurns && _isActivePlayer(who)) {
      current = who;
      if (!humanVsHuman && current == CellState.blue && !isAiThinking) {
        _scheduleAi();
      }
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final stored = switch (who) {
      CellState.blue => 'blue',
      CellState.yellow => 'yellow',
      CellState.green => 'green',
      _ => 'red',
    };
    await prefs.setString(_kStartingPlayer, stored);
  }

  Future<void> setCountry(String value) async {
    country = Countries.normalize(value);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCountry, country);
  }

  void setDuelPlayerCount(int count) {
    duelPlayerCount = count.clamp(2, 4);
    notifyListeners();
  }

  void newGame({bool notify = true, bool skipAi = false}) {
    _turnStats.clear();
    _undoStack.clear();
    lastMovePoints = 0;
    lastMoveBy = null;
    _clearScorePopup();
    board = RulesEngine.emptyBoard();
    _bombs.clear();
    _lastBombTurns.clear();
    bombMode = false;
    bombModeTargets = <(int, int)>{};
    bombDragActive = false;
    bombDragTargets = <(int, int)>{};
    bombAutoCountdownActive = false;
    bombAutoCountdownValue = 0;
    current = startingPlayer;
    gameOver = false;
    turnsRed = 0;
    turnsBlue = 0;
    turnsYellow = 0;
    turnsGreen = 0;
    bonusRed = 0;
    bonusBlue = 0;
    redGamePoints = 0;
    lastGamePointsAwarded = 0;
    lastTotalBeforeAward = totalUserScore;
    goldCells.clear();
    _endProcessed = false;
    resultsShown = false;
    showWinnerBorderAnim = false;
    // reset selection/explosion/falling
    selectedCell = null;
    blowPreview.clear();
    explodingCells.clear();
    isExploding = false;
    fallingDistances.clear();
    isFalling = false;
    isQuaking = false;
    isSimulating = false;
    // reset and start playtime tracking
    _playAccumMs = 0;
    _playStartMs = DateTime.now().millisecondsSinceEpoch;
    lastGamePlayMs = 0;
    // Save undo point at the very start of Red's turn
    if (current == CellState.red) {
      _saveUndoPoint();
    }
    if (notify) {
      notifyListeners();
    }
    // If AI (Blue) starts, let it make the first move
    if (!skipAi && !humanVsHuman && current == CellState.blue) {
      _scheduleAi();
    }
  }

  void _registerScorePopup(int r, int c, CellState who) {
    if (humanVsHuman) return;
    if (who != CellState.red) return;
    if (lastMovePoints <= 0) return;
    scorePopupPoints = lastMovePoints;
    scorePopupCell = (r, c);
    scorePopupId++;
  }

  void _clearScorePopup() {
    scorePopupPoints = 0;
    scorePopupCell = null;
  }

  /// Simulate a game instantly with a random winner (red or blue) and a plausible random duration.
  /// This builds a random full board biased to the chosen winner, then finalizes the game.
  Future<void> simulateGame({CellState? forcedWinner}) async {
    if (isSimulating) return;
    isSimulating = true;
    notifyListeners();

    // Small delay so the overlay is visible
    await Future.delayed(const Duration(milliseconds: 50));

    // Reset to a clean state
    newGame();
    resultsShown = false; // allow results dialog after end
    isSimulating = true; // newGame() resets flags

    final rnd = math.Random();
    final int n = K.n;
    final int total = n * n;

    if (humanVsHuman) {
      final players = activePlayers;
      final int playerCount = players.length;
      int neutralCountTarget = rnd.nextInt(math.max(1, total ~/ 8 + 1));
      int remaining = total - neutralCountTarget;
      const int minPerPlayer = 1;
      if (remaining < playerCount * minPerPlayer) {
        neutralCountTarget = 0;
        remaining = total;
      }

      final CellState winner = players.contains(forcedWinner)
          ? forcedWinner!
          : players[rnd.nextInt(playerCount)];
      final int bias = 1 + rnd.nextInt(math.max(2, remaining ~/ 10));
      final int maxWinner = remaining - (playerCount - 1) * minPerPlayer;
      int winnerCount = (remaining ~/ playerCount) + bias;
      if (winnerCount > maxWinner) {
        winnerCount = maxWinner;
      }

      final List<int> counts = List<int>.filled(playerCount, minPerPlayer);
      final int winnerIndex = players.indexOf(winner);
      counts[winnerIndex] = winnerCount;
      int remainingForOthers =
          remaining - winnerCount - minPerPlayer * (playerCount - 1);
      while (remainingForOthers > 0) {
        final int idx = rnd.nextInt(playerCount - 1);
        final int targetIndex = idx >= winnerIndex ? idx + 1 : idx;
        counts[targetIndex] += 1;
        remainingForOthers--;
      }

      final flat = <CellState>[];
      for (int i = 0; i < players.length; i++) {
        flat.addAll(List<CellState>.filled(counts[i], players[i]));
      }
      flat.addAll(
          List<CellState>.filled(neutralCountTarget, CellState.neutral));
      flat.shuffle(rnd);

      final newBoard = List<List<CellState>>.generate(
          n, (_) => List<CellState>.filled(n, CellState.empty));
      for (int i = 0; i < total; i++) {
        final r = i ~/ n;
        final c = i % n;
        newBoard[r][c] = flat[i];
      }
      board = newBoard;

      startingPlayer = players[rnd.nextInt(playerCount)];
      current = startingPlayer;

      turnsRed = players.contains(CellState.red)
          ? counts[players.indexOf(CellState.red)]
          : 0;
      turnsBlue = players.contains(CellState.blue)
          ? counts[players.indexOf(CellState.blue)]
          : 0;
      turnsYellow = players.contains(CellState.yellow)
          ? counts[players.indexOf(CellState.yellow)]
          : 0;
      turnsGreen = players.contains(CellState.green)
          ? counts[players.indexOf(CellState.green)]
          : 0;
    } else {
      // Choose a random winner (no draws) or honor a forced winner.
      final Set<CellState> allowedWinners = {
        CellState.red,
        CellState.blue,
        CellState.neutral
      };
      final CellState? winner =
          allowedWinners.contains(forcedWinner) ? forcedWinner : null;
      final bool neutralWins = winner == CellState.neutral;
      final bool redWins = winner == CellState.red
          ? true
          : winner == CellState.blue
              ? false
              : rnd.nextBool();

      // Optionally randomize who started this simulated game
      startingPlayer = rnd.nextBool() ? CellState.red : CellState.blue;
      current = startingPlayer;

      // Build a random full board with slightly more cells for the chosen winner
      int redCountTarget;
      int blueCountTarget;
      int neutralCountTarget = 0;
      final int totalPlayable;
      final int bias = 1 + rnd.nextInt(math.max(2, total ~/ 10));

      if (neutralWins) {
        neutralCountTarget = (total ~/ 2) + bias;
        if (neutralCountTarget > total - 2) {
          neutralCountTarget = total - 2;
        }
        final int remaining = total - neutralCountTarget;
        redCountTarget = remaining ~/ 2;
        blueCountTarget = remaining - redCountTarget;
        totalPlayable = remaining;
      } else {
        totalPlayable = total;
        // Ensure at least 1-cell advantage for the winner; bias by up to ~10% of board
        if (redWins) {
          redCountTarget = (totalPlayable ~/ 2) + bias;
          blueCountTarget = totalPlayable - redCountTarget;
        } else {
          blueCountTarget = (totalPlayable ~/ 2) + bias;
          redCountTarget = totalPlayable - blueCountTarget;
        }
        // Clamp just in case
        redCountTarget = redCountTarget.clamp(0, totalPlayable);
        blueCountTarget = totalPlayable - redCountTarget;
      }

      // Create flat list and shuffle
      final flat = <CellState>[]
        ..addAll(List<CellState>.filled(redCountTarget, CellState.red))
        ..addAll(List<CellState>.filled(blueCountTarget, CellState.blue))
        ..addAll(
            List<CellState>.filled(neutralCountTarget, CellState.neutral));
      flat.shuffle(rnd);

      // Fill board
      final newBoard = List<List<CellState>>.generate(
          n, (_) => List<CellState>.filled(n, CellState.empty));
      for (int i = 0; i < total; i++) {
        final r = i ~/ n;
        final c = i % n;
        newBoard[r][c] = flat[i];
      }
      board = newBoard;

      // Plausible turns counts: alternate moves starting from startingPlayer
      final int redTurns = startingPlayer == CellState.red
          ? (totalPlayable + 1) ~/ 2
          : totalPlayable ~/ 2;
      final int blueTurns = totalPlayable - redTurns;
      turnsRed = redTurns;
      turnsBlue = blueTurns;
    }

    // Randomize "played" duration: 45s .. 45 days
    final int minSec = 45;
    final int maxSec = 45 * 24 * 60 * 60; // 45 days in seconds
    final int durationSec = minSec + rnd.nextInt(maxSec - minSec + 1);
    _playAccumMs = durationSec * 1000;
    _playStartMs = null; // not actively counting; fixed duration snapshot

    // No per-move points simulated; end-of-game will add line bonuses into redGamePoints if any
    lastMovePoints = 0;
    lastMoveBy = null;

    // Finalize immediately
    _checkEnd(force: true);

    // Wrap up simulation
    isSimulating = false;
    notifyListeners();
  }

  /// Legacy direct placement API used earlier by BoardWidget. Kept for compatibility.
  bool playerMove(int r, int c) {
    if (gameOver || isAiThinking || isExploding) return false;
    if (current != CellState.red) return false; // ensure turn order
    // Clear any selection when placing
    selectedCell = null;
    blowPreview.clear();
    final before = board;
    final next = RulesEngine.place(board, r, c, CellState.red);
    if (next == null) return false;
    board = next;
    // compute per-move points
    lastMovePoints = _computeMovePoints(before, next, r, c, CellState.red);
    lastMoveBy = CellState.red;
    redGamePoints += lastMovePoints;
    _registerScorePopup(r, c, CellState.red);
    turnsRed++;
    // Log statistics for this red turn with detailed reasons
    {
      // Build concise breakdown: +1 place, +2 corner, +2 xN infect blue→grey, +3 xN claim grey→red
      final List<String> parts = <String>[];
      final l10n = appLocalizations();
      parts.add(l10n?.scorePlace ?? '+1 place');
      final bool isCorner = (r == 0 && c == 0) ||
          (r == 0 && c == K.n - 1) ||
          (r == K.n - 1 && c == 0) ||
          (r == K.n - 1 && c == K.n - 1);
      if (isCorner) {
        parts.add(l10n?.scoreCorner ?? '+2 corner');
      }
      int blueToNeutral = 0;
      int neutralToRed = 0;
      for (int i = 0; i < K.n; i++) {
        for (int j = 0; j < K.n; j++) {
          final b = before[i][j];
          final a = next[i][j];
          if (b == CellState.blue && a == CellState.neutral) blueToNeutral++;
          if (b == CellState.neutral && a == CellState.red) neutralToRed++;
        }
      }
      if (blueToNeutral > 0) {
        parts.add(l10n?.scoreBlueToGrey(blueToNeutral) ??
            '+2 x$blueToNeutral blue→grey');
      }
      if (neutralToRed > 0) {
        parts.add(l10n?.scoreGreyToRed(neutralToRed) ??
            '+3 x$neutralToRed grey→red');
      }
      final desc = parts.join('; ');
      _turnStats.add(TurnStatEntry(
        turn: turnsRed,
        points: lastMovePoints,
        desc: desc.isEmpty ? (l10n?.scorePlaceShort ?? 'Place') : desc,
        ts: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    if (humanVsHuman) {
      current = _nextPlayer(CellState.red);
    } else {
      current = CellState.blue;
    }
    _handleTurnStart(current);
    _checkEnd();
    notifyListeners();
    if (!humanVsHuman && !gameOver) _scheduleAi();
    return true;
  }

  bool _performHumanPlacement(int r, int c, CellState who) {
    final before = board;
    final next = RulesEngine.place(board, r, c, who);
    if (next == null) return false;
    board = next;
    if (who == CellState.red || who == CellState.blue) {
      lastMovePoints = _computeMovePoints(before, next, r, c, who);
    } else {
      lastMovePoints = 0;
    }
    lastMoveBy = who;
    _incrementTurnFor(who);
    if (who == CellState.red) {
      redGamePoints += lastMovePoints;
      _registerScorePopup(r, c, who);
      // Log statistics for this red turn with detailed reasons
      final List<String> parts = <String>[];
      final l10n = appLocalizations();
      parts.add(l10n?.scorePlace ?? '+1 place');
      final bool isCorner = (r == 0 && c == 0) ||
          (r == 0 && c == K.n - 1) ||
          (r == K.n - 1 && c == 0) ||
          (r == K.n - 1 && c == K.n - 1);
      if (isCorner) {
        parts.add(l10n?.scoreCorner ?? '+2 corner');
      }
      int blueToNeutral = 0;
      int neutralToRed = 0;
      for (int i = 0; i < K.n; i++) {
        for (int j = 0; j < K.n; j++) {
          final b = before[i][j];
          final a = next[i][j];
          if (b == CellState.blue && a == CellState.neutral) blueToNeutral++;
          if (b == CellState.neutral && a == CellState.red) neutralToRed++;
        }
      }
      if (blueToNeutral > 0) {
        parts.add(l10n?.scoreBlueToGrey(blueToNeutral) ??
            '+2 x$blueToNeutral blue→grey');
      }
      if (neutralToRed > 0) {
        parts.add(l10n?.scoreGreyToRed(neutralToRed) ??
            '+3 x$neutralToRed grey→red');
      }
      final desc = parts.join('; ');
      _turnStats.add(TurnStatEntry(
        turn: turnsRed,
        points: lastMovePoints,
        desc: desc.isEmpty ? (l10n?.scorePlaceShort ?? 'Place') : desc,
        ts: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    current = _nextPlayer(who);
    _handleTurnStart(current);
    _checkEnd();
    notifyListeners();
    return true;
  }

  // Unified tap handler to support selection and blowing up existing pieces.
  void onCellTap(int r, int c) {
    if (gameOver || isAiThinking || isExploding || isFalling || isQuaking)
      return;
    if (bombAutoCountdownActive) return;
    if (selectedCell != null && selectedCell != (r, c)) {
      selectedCell = null;
      blowPreview.clear();
      notifyListeners();
      return;
    }
    final s = board[r][c];

    // In normal mode only Red (human) acts; in Duel mode current side acts
    if (!humanVsHuman && current != CellState.red) return;

    if (s == CellState.bomb) {
      final bomb = _bombAt(r, c);
      if (bomb == null) return;
      if (selectedCell == (r, c)) {
        _performBombActivation(bomb);
        return;
      }
      if (_canActivateBombToken(bomb)) {
        selectedCell = (r, c);
        blowPreview = RulesEngine.bombBlastAffected(board, r, c);
        notifyListeners();
      }
      return;
    }

    if (bombMode) {
      if (s == CellState.empty && canPlaceBomb) {
        _performBombPlacement(r, c, current);
      }
      return;
    }

    // Grey tap: select to preview all grey boxes; tap same again to drop them
    if (s == CellState.neutral) {
      if (selectedCell == (r, c)) {
        if (humanVsHuman) {
          _performGreyDropFor(current);
        } else if (current == CellState.red) {
          _performGreyDropFor(CellState.red);
        }
      } else {
        selectedCell = (r, c);
        blowPreview = _allNeutralCells();
        notifyListeners();
      }
      return;
    }

    // If tapping empty - attempt placement; clear selection first
    if (s == CellState.empty) {
      selectedCell = null;
      blowPreview.clear();
      if (current == CellState.red) {
        playerMove(r, c);
      } else if (humanVsHuman && _isActivePlayer(current)) {
        _performHumanPlacement(r, c, current);
      }
      return;
    }

    // Tapping a colored piece -> select/deselect or blow
    if (_isActivePlayer(s)) {
      // In duel mode, a player may only blow up their own color on their turn.
      // In normal mode (vs AI), only RED may act on RED pieces during RED's turn.
      if (humanVsHuman) {
        if (s != current) {
          // Not the current player's own color — ignore tap.
          return;
        }
      } else {
        if (s != CellState.red || current != CellState.red) {
          return;
        }
      }

      if (selectedCell == (r, c)) {
        // tap again -> perform blow by current side
        _performBlow(r, c, current);
      } else {
        selectedCell = (r, c);
        blowPreview = RulesEngine.blowAffected(board, r, c);
        notifyListeners();
      }
      return;
    }

    // Tapping anything else -> deselect
    if (selectedCell != null) {
      selectedCell = null;
      blowPreview.clear();
      notifyListeners();
    }
  }

  void deselectSelection() {
    // Block deselection during animations or AI thinking to prevent state changes while
    // grey boxes are falling or explosions are playing. This keeps the preview visible
    // and ensures no user action is processed mid-animation.
    if (isFalling || isExploding || isAiThinking || isQuaking) {
      return;
    }
    if (selectedCell != null) {
      selectedCell = null;
      blowPreview.clear();
      notifyListeners();
    }
  }

  void _performBombPlacement(int r, int c, CellState who) {
    if (!canPlaceBomb) return;
    if (board[r][c] != CellState.empty) return;
    selectedCell = null;
    blowPreview.clear();
    board[r][c] = CellState.bomb;
    final placedTurn = _turnIndexFor(who);
    _bombs.add(
      _BombToken(
        row: r,
        col: c,
        owner: who,
        placedTurn: placedTurn,
      ),
    );
    _lastBombTurns[who] = placedTurn;
    lastMovePoints = 0;
    lastMoveBy = who;
    _incrementTurnFor(who);
    if (who == CellState.red) {
      _turnStats.add(TurnStatEntry(
        turn: turnsRed,
        points: 0,
        desc: appLocalizations()?.scoreZeroBlow ?? '0 bomb',
        ts: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    current = humanVsHuman
        ? _nextPlayer(who)
        : (who == CellState.red ? CellState.blue : CellState.red);
    bombMode = false;
    bombModeTargets = <(int, int)>{};
    bombAutoCountdownActive = false;
    bombAutoCountdownValue = 0;
    _checkEnd();
    _handleTurnStart(current);
    notifyListeners();
    if (!humanVsHuman && !gameOver && current == CellState.blue) {
      _scheduleAi();
    }
  }

  Future<void> _performBombActivation(_BombToken bomb,
      {bool autoTriggered = false}) async {
    if (gameOver || isExploding || isFalling) return;
    if (!autoTriggered && !_canActivateBombToken(bomb)) return;
    isExploding = true;
    explodingCells =
        RulesEngine.bombBlastAffected(board, bomb.row, bomb.col);
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 420));

    final affected = Set<(int, int)>.from(explodingCells);
    final before = board;
    final after = RulesEngine.blow(before, affected);
    _bombs.removeWhere((b) => affected.contains((b.row, b.col)));
    isExploding = false;
    explodingCells.clear();
    selectedCell = null;
    blowPreview.clear();
    bombMode = false;

    board = after;
    lastMovePoints = 0;
    lastMoveBy = bomb.owner;
    _incrementTurnFor(bomb.owner);
    if (bomb.owner == CellState.red) {
      _turnStats.add(TurnStatEntry(
        turn: turnsRed,
        points: 0,
        desc: appLocalizations()?.scoreZeroBlow ?? '0 bomb',
        ts: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    current = humanVsHuman
        ? _nextPlayer(bomb.owner)
        : (bomb.owner == CellState.red ? CellState.blue : CellState.red);
    _checkEnd();
    _handleTurnStart(current);
    notifyListeners();
    if (!humanVsHuman && !gameOver && current == CellState.blue) {
      _scheduleAi();
    }
  }

  Future<void> _performBlow(int r, int c, CellState who) async {
    if (gameOver || isExploding || isFalling) return;
    final affected = RulesEngine.blowAffected(board, r, c);
    if (affected.isEmpty) return;
    isExploding = true;
    explodingCells = affected;
    notifyListeners();
    // Brief explosion animation window
    await Future.delayed(const Duration(milliseconds: 420));

    final before = board;
    final after =
        RulesEngine.blow(board, affected); // compute post-removal board
    _bombs.removeWhere((bomb) => affected.contains((bomb.row, bomb.col)));

    // Per spec, blowing up does not award points to the user; set lastMovePoints = 0 for both sides
    lastMovePoints = 0;
    lastMoveBy = who;
    _incrementTurnFor(who);
    if (who == CellState.red) {
      // Log statistics for this red turn (blow)
      _turnStats.add(TurnStatEntry(
        turn: turnsRed,
        points: lastMovePoints,
        desc: appLocalizations()?.scoreZeroBlow ?? '0 blow',
        ts: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    current = humanVsHuman
        ? _nextPlayer(who)
        : (who == CellState.red ? CellState.blue : CellState.red);
    _handleTurnStart(current);

    // Clear explosion overlay and selection, then remove immediately (no fall animation for blow)
    isExploding = false;
    explodingCells.clear();
    selectedCell = null;
    blowPreview.clear();

    // Apply the removal right after explosion completes
    board = after;

    _checkEnd();
    notifyListeners();

    // schedule AI if needed
    if (!humanVsHuman && !gameOver && current == CellState.blue) {
      _scheduleAi();
    }
  }

  Future<void> _applyGravityAnimation() async {
    // Compute gravity result and map of drop distances
    final (gBoard, drops) = RulesEngine.applyGravity(board);
    // If nothing moves, just return
    if (drops.isEmpty) return;
    isFalling = true;
    fallingDistances = drops;
    board = gBoard;
    notifyListeners();
    // Play falling animation
    await Future.delayed(const Duration(milliseconds: 300));
    // Clear falling state
    fallingDistances = <(int, int), int>{};
    isFalling = false;
    notifyListeners();
  }

  Set<(int, int)> _allNeutralCells() {
    final set = <(int, int)>{};
    for (int r = 0; r < K.n; r++) {
      for (int c = 0; c < K.n; c++) {
        if (board[r][c] == CellState.neutral) set.add((r, c));
      }
    }
    return set;
  }

  Future<void> _performGreyDropFor(CellState who) async {
    if (gameOver || isExploding || isFalling || isQuaking) return;
    if (humanVsHuman) {
      if (current != who) return;
    } else if (who != CellState.red || current != CellState.red) {
      return;
    }
    _clearScorePopup();
    // Determine all neutral cells to drop
    final neutrals = _allNeutralCells();
    if (neutrals.isEmpty) return;

    // Phase 1: Earthquake shake to signal the action
    isQuaking = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: quakeDurationMs));
    isQuaking = false;

    // Phase 2: Animate only neutrals falling out
    isFalling = true;
    fallingDistances = {for (final rc in neutrals) rc: K.n};
    // Keep preview while animating for clarity
    notifyListeners();
    await Future.delayed(Duration(milliseconds: fallDurationMs));

    // Now remove all neutral tiles, keep others in place
    board = RulesEngine.removeAllNeutrals(board);

    // Clear states
    selectedCell = null;
    blowPreview.clear();
    fallingDistances = <(int, int), int>{};
    isFalling = false;

    // No direct points for grey drop
    lastMovePoints = 0;
    lastMoveBy = who;
    _incrementTurnFor(who);
    if (who == CellState.red) {
      // Log statistics for this red turn (grey drop)
      _turnStats.add(TurnStatEntry(
        turn: turnsRed,
        points: lastMovePoints,
        desc: appLocalizations()?.scoreZeroGreyDrop ?? '0 grey drop',
        ts: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    current = humanVsHuman
        ? _nextPlayer(who)
        : (who == CellState.red ? CellState.blue : CellState.red);
    _handleTurnStart(current);

    _checkEnd();
    notifyListeners();
    if (!humanVsHuman && !gameOver && current == CellState.blue) {
      _scheduleAi();
    }
  }

  int _computeMovePoints(List<List<CellState>> before,
      List<List<CellState>> after, int r, int c, CellState attacker) {
    // Compute delta points from RED player's perspective, per last move.
    // If RED moved: award positives (place +1, corner +2, Blue->Neutral +2, Neutral->Red +3, new Red full lines +50).
    // If BLUE moved: apply negatives to RED (Red->Neutral -2, Neutral->Blue -3). Opponent placement/corner/lines do not subtract.
    int points = 0;
    if (attacker == CellState.red) {
      // Placement
      points += 1;
      // Corner bonus
      if ((r == 0 && c == 0) ||
          (r == 0 && c == K.n - 1) ||
          (r == K.n - 1 && c == 0) ||
          (r == K.n - 1 && c == K.n - 1)) {
        points += 2;
      }
      int blueToNeutral = 0;
      int neutralToRed = 0;
      for (int i = 0; i < K.n; i++) {
        for (int j = 0; j < K.n; j++) {
          final b = before[i][j];
          final a = after[i][j];
          if (b == CellState.blue && a == CellState.neutral) blueToNeutral++;
          if (b == CellState.neutral && a == CellState.red) neutralToRed++;
        }
      }
      points += blueToNeutral * 2;
      points += neutralToRed * 3;
      // Note: End-of-game line bonuses are awarded separately at game end, not per-move.
    } else if (attacker == CellState.blue) {
      int redToNeutral = 0;
      int neutralToBlue = 0;
      for (int i = 0; i < K.n; i++) {
        for (int j = 0; j < K.n; j++) {
          final b = before[i][j];
          final a = after[i][j];
          if (b == CellState.red && a == CellState.neutral) redToNeutral++;
          if (b == CellState.neutral && a == CellState.blue) neutralToBlue++;
        }
      }
      points -= redToNeutral * 2;
      points -= neutralToBlue * 3;
    }
    return points;
  }

  void setBoardPixelSize(double s) {
    if ((boardPixelSize - s).abs() > 0.5) {
      boardPixelSize = s;
      notifyListeners();
    }
  }

  void _scheduleAi() async {
    // Capture generation to cancel any outdated AI runs when state is reloaded
    final int gen = _aiGeneration;
    if (gameOver) return;
    isAiThinking = true;
    notifyListeners();

    // Brief delay for UX and to let UI show overlay
    await Future.delayed(const Duration(milliseconds: 200));
    // If state changed (e.g., user loaded a game), cancel this run safely
    if (gen != _aiGeneration || gameOver) {
      isAiThinking = false;
      notifyListeners();
      return;
    }

    // Evaluate best placement via existing AI
    final mv =
        await Future<(int, int)?>(() => _ai.chooseMoveLevel(board, aiLevel));
    // Cancel if state changed during AI computation
    if (gen != _aiGeneration || gameOver) {
      isAiThinking = false;
      notifyListeners();
      return;
    }

    // Also evaluate best blow for BLUE
    int bestBlowSwing = -0x7fffffff;
    (int, int)? bestBlowCell;
    final blowCandidates = <({
      (int, int) cell,
      Set<(int, int)> affected,
      int swing
    })>[];
    final redBefore = RulesEngine.countOf(board, CellState.red);
    final blueBefore = RulesEngine.countOf(board, CellState.blue);
    for (int r = 0; r < K.n; r++) {
      for (int c = 0; c < K.n; c++) {
        if (board[r][c] != CellState.blue) continue;
        final affected = RulesEngine.blowAffected(board, r, c);
        if (affected.isEmpty) continue;
        // Skip trivial blow that only removes self
        if (affected.length <= 1) continue;
        final after = RulesEngine.blow(board, affected);
        final redAfter = RulesEngine.countOf(after, CellState.red);
        final blueAfter = RulesEngine.countOf(after, CellState.blue);
        final swing = (blueAfter - blueBefore) - (redAfter - redBefore);
        blowCandidates.add((
          cell: (r, c),
          affected: affected,
          swing: swing,
        ));
        if (swing > bestBlowSwing) {
          bestBlowSwing = swing;
          bestBlowCell = (r, c);
        }
      }
    }

    if (gameOver) {
      isAiThinking = false;
      notifyListeners();
      return;
    }

    // Compute best placement swing baseline
    int bestPlaceSwing = -0x7fffffff;
    (int, int)? placeChoice = mv;
    List<List<CellState>>? placeSim;
    if (mv != null) {
      final (pr, pc) = mv;
      placeSim = RulesEngine.place(board, pr, pc, CellState.blue);
      if (placeSim != null) {
        final redAfter = RulesEngine.countOf(placeSim, CellState.red);
        final blueAfter = RulesEngine.countOf(placeSim, CellState.blue);
        bestPlaceSwing = (blueAfter - blueBefore) - (redAfter - redBefore);
      }
    }

    // Consider AI grey-drop option if neutrals exist and other options are not strictly beneficial
    final neutralsExist = _allNeutralCells().isNotEmpty;
    int bestGreySwing = -0x7fffffff;
    if (neutralsExist) {
      final after = RulesEngine.removeAllNeutrals(board);
      final redAfter = RulesEngine.countOf(after, CellState.red);
      final blueAfter = RulesEngine.countOf(after, CellState.blue);
      bestGreySwing = (blueAfter - blueBefore) - (redAfter - redBefore);
    }

    _AiAction? strategicAction;
    (int, int)? strategicBlowCell;
    if (aiLevel >= 7) {
      double bestWinRate = -1.0;
      double? placeWinRate;
      const minWinRateEdge = 0.08;
      const minPositiveSwing = 2;
      if (placeSim != null) {
        final rate = _ai.estimateWinRate(placeSim, CellState.red,
            rollouts: 220, timeLimitMs: 200);
        bestWinRate = rate;
        strategicAction = _AiAction.place;
        placeWinRate = rate;
      }
      if (blowCandidates.isNotEmpty) {
        final sorted = [...blowCandidates]
          ..sort((a, b) => b.swing.compareTo(a.swing));
        final limit = math.min(3, sorted.length);
        for (int i = 0; i < limit; i++) {
          final candidate = sorted[i];
          final after = RulesEngine.blow(board, candidate.affected);
          final rate = _ai.estimateWinRate(after, CellState.red,
              rollouts: 220, timeLimitMs: 200);
          final improvesWinRate = placeWinRate == null ||
              rate >= placeWinRate + minWinRateEdge;
          final strongSwing = candidate.swing >= minPositiveSwing;
          if ((strongSwing && rate >= bestWinRate) ||
              (improvesWinRate && rate > bestWinRate)) {
            bestWinRate = rate;
            strategicAction = _AiAction.blow;
            strategicBlowCell = candidate.cell;
          }
        }
      }
      if (neutralsExist) {
        final after = RulesEngine.removeAllNeutrals(board);
        final rate = _ai.estimateWinRate(after, CellState.red,
            rollouts: 220, timeLimitMs: 200);
        final improvesWinRate = placeWinRate == null ||
            rate >= placeWinRate + minWinRateEdge;
        final strongSwing = bestGreySwing >= minPositiveSwing;
        if ((strongSwing && rate >= bestWinRate) ||
            (improvesWinRate && rate > bestWinRate)) {
          bestWinRate = rate;
          strategicAction = _AiAction.greyDrop;
        }
      }
    }

    _AiAction? action;
    (int, int)? blowChoice = bestBlowCell;
    final actionScores = <_AiAction, int>{};
    if (placeChoice != null) {
      actionScores[_AiAction.place] = bestPlaceSwing;
    }
    if (bestBlowCell != null) {
      actionScores[_AiAction.blow] = bestBlowSwing;
    }
    if (neutralsExist) {
      actionScores[_AiAction.greyDrop] = bestGreySwing;
    }

    _AiAction? bestAction;
    int bestActionScore = -0x7fffffff;
    for (final entry in actionScores.entries) {
      final score = entry.value;
      if (score > bestActionScore ||
          (score == bestActionScore && _rng.nextBool())) {
        bestActionScore = score;
        bestAction = entry.key;
      }
    }

    _AiAction? bestNonPlaceAction;
    int bestNonPlaceScore = -0x7fffffff;
    for (final entry in actionScores.entries) {
      if (entry.key == _AiAction.place) continue;
      final score = entry.value;
      if (score > bestNonPlaceScore ||
          (score == bestNonPlaceScore && _rng.nextBool())) {
        bestNonPlaceScore = score;
        bestNonPlaceAction = entry.key;
      }
    }

    switch (aiLevel) {
      case 1:
        action = placeChoice != null ? _AiAction.place : null;
        break;
      case 2:
        if (bestNonPlaceAction != null &&
            bestNonPlaceScore > 0 &&
            _rng.nextDouble() < 0.35) {
          action = bestNonPlaceAction;
        } else {
          action = placeChoice != null ? _AiAction.place : bestAction;
        }
        break;
      case 3:
        if (bestNonPlaceAction != null &&
            bestNonPlaceScore > 0 &&
            (actionScores[_AiAction.place] == null ||
                bestNonPlaceScore >= actionScores[_AiAction.place]!)) {
          action = bestNonPlaceAction;
        } else {
          action = placeChoice != null ? _AiAction.place : bestAction;
        }
        break;
      case 4:
        if (bestAction != null && bestActionScore > 0) {
          action = bestAction;
        } else {
          action = placeChoice != null ? _AiAction.place : bestAction;
        }
        break;
      case 5:
        if (bestAction != null &&
            bestActionScore >= 0 &&
            (actionScores[_AiAction.place] == null ||
                bestActionScore >= actionScores[_AiAction.place]!)) {
          action = bestAction;
        } else {
          action = placeChoice != null ? _AiAction.place : bestAction;
        }
        break;
      case 6:
        action = bestAction ?? (placeChoice != null ? _AiAction.place : null);
        break;
      default:
        if (bestBlowCell != null &&
            (placeChoice == null || bestBlowSwing > bestPlaceSwing)) {
          action = _AiAction.blow;
        } else if (neutralsExist &&
            (placeChoice == null ||
                (bestPlaceSwing <= 0 && bestBlowSwing <= 0))) {
          action = _AiAction.greyDrop;
        } else if (placeChoice != null) {
          action = _AiAction.place;
        }
        break;
    }

    if (aiLevel >= 7 && strategicAction != null) {
      bool isValid = false;
      if (strategicAction == _AiAction.place) {
        isValid = placeChoice != null;
      } else if (strategicAction == _AiAction.blow) {
        isValid = strategicBlowCell != null;
      } else if (strategicAction == _AiAction.greyDrop) {
        isValid = neutralsExist;
      }
      if (isValid) {
        action = strategicAction;
        blowChoice = strategicBlowCell ?? blowChoice;
      }
    }

    if (action == null || placeChoice == null && action == _AiAction.place) {
      // no moves; end
      _checkEnd(force: true);
      isAiThinking = false;
      notifyListeners();
      return;
    }

    if (action == _AiAction.blow && blowChoice != null) {
      final (br, bc) = blowChoice;
      // Preselect for animation parity with user: show border+icon and affected preview
      selectedCell = (br, bc);
      blowPreview = RulesEngine.blowAffected(board, br, bc);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 280));
      // Animate and perform blow like user
      await _performBlow(br, bc, CellState.blue);
      // After AI completes action and it's Red's turn, save undo point
      if (!gameOver && current == CellState.red) {
        _saveUndoPoint();
      }
      isAiThinking = false;
      notifyListeners();
      return;
    }

    if (action == _AiAction.greyDrop) {
      // Preselect one neutral for clarity and preview all neutrals
      final allNeutrals = _allNeutralCells();
      final sel = allNeutrals.first;
      selectedCell = sel;
      blowPreview = allNeutrals;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 280));
      await _performGreyDropAi();
      // After AI completes action and it's Red's turn, save undo point
      if (!gameOver && current == CellState.red) {
        _saveUndoPoint();
      }
      isAiThinking = false;
      notifyListeners();
      return;
    }

    final (r, c) = placeChoice!;
    final before = board;
    final next = RulesEngine.place(board, r, c, CellState.blue);
    if (next != null) {
      board = next;
      // compute per-move points for AI
      lastMovePoints = _computeMovePoints(before, next, r, c, CellState.blue);
      lastMoveBy = CellState.blue;
      turnsBlue++;
      current = CellState.red;
      _handleTurnStart(current);
      _checkEnd();
      if (!gameOver && current == CellState.red) {
        _saveUndoPoint();
      }
    }
    isAiThinking = false;
    notifyListeners();
  }

  void _checkEnd({bool force = false}) {
    if (force || !RulesEngine.hasEmpty(board)) {
      if (!force && _bombs.isNotEmpty) {
        _startBombAutoCountdown();
        return;
      }
      gameOver = true;
      _processEndOnce();
    }
  }

  void _startBombAutoCountdown() {
    if (bombAutoCountdownActive) return;
    if (_bombs.isEmpty) return;
    bombAutoCountdownActive = true;
    bombAutoCountdownValue = 3;
    notifyListeners();
    Future.microtask(() async {
      for (int i = 3; i >= 1; i--) {
        if (!bombAutoCountdownActive) return;
        bombAutoCountdownValue = i;
        notifyListeners();
        await Future.delayed(const Duration(seconds: 1));
      }
      await _detonateAllBombs();
    });
  }

  Future<void> _detonateAllBombs() async {
    if (_bombs.isEmpty) {
      bombAutoCountdownActive = false;
      bombAutoCountdownValue = 0;
      return;
    }
    final affected = <(int, int)>{};
    for (final bomb in _bombs) {
      affected.addAll(
          RulesEngine.bombBlastAffected(board, bomb.row, bomb.col));
    }
    if (affected.isEmpty) {
      bombAutoCountdownActive = false;
      bombAutoCountdownValue = 0;
      return;
    }
    isExploding = true;
    explodingCells = affected;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 420));
    board = RulesEngine.blow(board, affected);
    _bombs.clear();
    isExploding = false;
    explodingCells.clear();
    selectedCell = null;
    blowPreview.clear();
    bombAutoCountdownActive = false;
    bombAutoCountdownValue = 0;
    _checkEnd();
    notifyListeners();
  }

  void _processEndOnce() async {
    if (_endProcessed) return;
    _endProcessed = true;
    // Finalize playtime for this game
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (_playStartMs != null) {
      _playAccumMs += (nowMs - _playStartMs!);
      _playStartMs = null;
    }
    lastGamePlayMs = _playAccumMs;
    // Compute full-color lines for bonuses and gold highlight cells
    bonusRed = 0;
    bonusBlue = 0;
    goldCells.clear();
    int redLinesInThisGame = 0;
    // Rows
    for (int r = 0; r < K.n; r++) {
      final row = board[r];
      if (row.every((c) => c == CellState.red)) {
        bonusRed += 50;
        redLinesInThisGame += 1;
        for (int c = 0; c < K.n; c++) {
          goldCells.add((r, c));
        }
      } else if (row.every((c) => c == CellState.blue)) {
        bonusBlue += 50;
        for (int c = 0; c < K.n; c++) {
          goldCells.add((r, c));
        }
      } else if (isMultiDuel && row.every((c) => c == CellState.yellow)) {
        for (int c = 0; c < K.n; c++) {
          goldCells.add((r, c));
        }
      } else if (isMultiDuel && row.every((c) => c == CellState.green)) {
        for (int c = 0; c < K.n; c++) {
          goldCells.add((r, c));
        }
      }
    }
    // Columns
    for (int c = 0; c < K.n; c++) {
      bool allRed = true, allBlue = true, allYellow = true, allGreen = true;
      for (int r = 0; r < K.n; r++) {
        final s = board[r][c];
        allRed &= (s == CellState.red);
        allBlue &= (s == CellState.blue);
        allYellow &= (s == CellState.yellow);
        allGreen &= (s == CellState.green);
      }
      if (allRed) {
        bonusRed += 50;
        redLinesInThisGame += 1;
        for (int r = 0; r < K.n; r++) {
          goldCells.add((r, c));
        }
      } else if (allBlue) {
        bonusBlue += 50;
        for (int r = 0; r < K.n; r++) {
          goldCells.add((r, c));
        }
      } else if (isMultiDuel && allYellow) {
        for (int r = 0; r < K.n; r++) {
          goldCells.add((r, c));
        }
      } else if (isMultiDuel && allGreen) {
        for (int r = 0; r < K.n; r++) {
          goldCells.add((r, c));
        }
      }
    }

    if (isMultiDuel) {
      final winner = duelWinner();
      if (winner != null) {
        showWinnerBorderAnim = true;
        notifyListeners();
        Future.delayed(Duration(milliseconds: winnerBorderAnimMs), () {
          showWinnerBorderAnim = false;
          notifyListeners();
        });
      }

      totalPlayTimeMs += lastGamePlayMs;
      DateTime when = DateTime.now().toLocal();
      String dayKey =
          '${when.year.toString().padLeft(4, '0')}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}';
      dailyPlayCountByDate[dayKey] = (dailyPlayCountByDate[dayKey] ?? 0) + 1;
      dailyPlayTimeByDate[dayKey] =
          (dailyPlayTimeByDate[dayKey] ?? 0) + lastGamePlayMs;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kTotalPlayTimeMs, totalPlayTimeMs);
      await prefs.setString(
          _kDailyPlayCountJson, jsonEncode(dailyPlayCountByDate));
      await prefs.setString(
          _kDailyPlayTimeJson, jsonEncode(dailyPlayTimeByDate));
      notifyListeners();
      return;
    }

    // Compute totals for legacy base/bonus scoring
    final redTotal = scoreRedTotal();
    final blueTotal = scoreBlueTotal();
    final neutralTotal = RulesEngine.countOf(board, CellState.neutral);
    final int maxScore = [redTotal, blueTotal, neutralTotal]
        .reduce((a, b) => a > b ? a : b);
    final bool isTie = [
      redTotal,
      blueTotal,
      neutralTotal,
    ].where((score) => score == maxScore).length > 1;

    // Also convert end-of-game red full lines into current-game points per spec (+50 each)
    if (redLinesInThisGame > 0) {
      redGamePoints += redLinesInThisGame * 50;
    }

    // Trigger winner border animation (1.5s) if there is a winner
    final hasWinner = !isTie;
    if (hasWinner) {
      showWinnerBorderAnim = true;
      notifyListeners();
      // Auto-clear after the animation window
      Future.delayed(Duration(milliseconds: winnerBorderAnimMs), () {
        showWinnerBorderAnim = false;
        notifyListeners();
      });
    }

    // Update cumulative red full-line counter
    if (redLinesInThisGame > 0) {
      redLinesCompletedTotal += redLinesInThisGame;
    }

    // Award badge for beating this AI level
    String? newBadge;
    if (redTotal > blueTotal && redTotal > neutralTotal) {
      newBadge = 'Beat AI L$aiLevel';
      badges.add(newBadge);
    }

    // Update persistent total per new rules: award only on win; otherwise unchanged
    lastTotalBeforeAward = totalUserScore;
    if (redTotal > blueTotal && redTotal > neutralTotal) {
      lastGamePointsAwarded = redGamePoints;
      totalUserScore += lastGamePointsAwarded;
    } else if (isTie) {
      lastGamePointsAwarded = redGamePoints ~/ 2;
      totalUserScore += lastGamePointsAwarded;
    } else {
      lastGamePointsAwarded = 0;
    }

    if (!humanVsHuman) {
      lastBestChallengeScoreBefore = bestChallengeScore;
      if (redTotal > bestChallengeScore) {
        bestChallengeScore = redTotal;
        lastGameWasNewBest = true;
      } else {
        lastGameWasNewBest = false;
      }
    }

    // Check diagonals for red achievements (not part of bonus rules, used only for achievements)
    bool anyRedDiag = true;
    for (int i = 0; i < K.n; i++) {
      if (board[i][i] != CellState.red) {
        anyRedDiag = false;
        break;
      }
    }
    bool anyRedAntiDiag = true;
    for (int i = 0; i < K.n; i++) {
      if (board[i][K.n - 1 - i] != CellState.red) {
        anyRedAntiDiag = false;
        break;
      }
    }

    // Update achievement flags (sticky once achieved)
    if (redLinesInThisGame > 0) {
      // Could be row or column; we don't distinguish here, but try detect specifically
      // Detect any full red row
      bool hasRedRow = false;
      for (int r = 0; r < K.n && !hasRedRow; r++) {
        hasRedRow = board[r].every((c) => c == CellState.red);
      }
      // Detect any full red column
      bool hasRedCol = false;
      for (int c = 0; c < K.n && !hasRedCol; c++) {
        bool all = true;
        for (int r = 0; r < K.n; r++) {
          if (board[r][c] != CellState.red) {
            all = false;
            break;
          }
        }
        if (all) hasRedCol = true;
      }
      achievedRedRow = achievedRedRow || hasRedRow;
      achievedRedColumn = achievedRedColumn || hasRedCol;
    }
    if (anyRedDiag || anyRedAntiDiag) {
      achievedRedDiagonal = achievedRedDiagonal || true;
    }
    if (redGamePoints >= 100) {
      achievedGamePoints100 = true;
    }
    if (redGamePoints >= 1000) {
      achievedGamePoints1000 = true;
    }

    // Append to history
    final result = GameResult(
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      redBase: scoreRedBase(),
      blueBase: scoreBlueBase(),
      bonusRed: bonusRed,
      bonusBlue: bonusBlue,
      redTotal: redTotal,
      blueTotal: blueTotal,
      winner: GameResult.winnerFromTotals(redTotal, blueTotal),
      aiLevel: aiLevel,
      turnsRed: turnsRed,
      turnsBlue: turnsBlue,
      playMs: lastGamePlayMs,
    );
    history.add(result);

    // Update analytics: totals and per-day
    totalPlayTimeMs += lastGamePlayMs;
    DateTime when =
        DateTime.fromMillisecondsSinceEpoch(result.timestampMs).toLocal();
    String dayKey =
        '${when.year.toString().padLeft(4, '0')}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}';
    dailyPlayCountByDate[dayKey] = (dailyPlayCountByDate[dayKey] ?? 0) + 1;
    dailyPlayTimeByDate[dayKey] =
        (dailyPlayTimeByDate[dayKey] ?? 0) + lastGamePlayMs;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTotalUserScore, totalUserScore);
    await prefs.setInt(_kBestChallengeScore, bestChallengeScore);
    await prefs.setInt(
        _kLastBestChallengeScoreBefore, lastBestChallengeScoreBefore);
    await prefs.setBool(_kLastGameWasNewBest, lastGameWasNewBest);
    await prefs.setInt(_kRedLinesTotal, redLinesCompletedTotal);
    await prefs.setStringList(_kBadges, badges.toList());
    await prefs.setString(_kHistory, GameResult.encodeList(history));
    await prefs.setInt(_kTotalPlayTimeMs, totalPlayTimeMs);
    await prefs.setString(
        _kDailyPlayCountJson, jsonEncode(dailyPlayCountByDate));
    await prefs.setString(_kDailyPlayTimeJson, jsonEncode(dailyPlayTimeByDate));
    await prefs.setBool(_kAchievedRedRow, achievedRedRow);
    await prefs.setBool(_kAchievedRedColumn, achievedRedColumn);
    await prefs.setBool(_kAchievedRedDiagonal, achievedRedDiagonal);
    await prefs.setBool(_kAchievedGamePoints100, achievedGamePoints100);
    await prefs.setBool(_kAchievedGamePoints1000, achievedGamePoints1000);
    notifyListeners();
  }

  int scoreRedBase() => RulesEngine.countOf(board, CellState.red);
  int scoreBlueBase() => RulesEngine.countOf(board, CellState.blue);
  int scoreYellowBase() => RulesEngine.countOf(board, CellState.yellow);
  int scoreGreenBase() => RulesEngine.countOf(board, CellState.green);
  int scoreRedTotal() => scoreRedBase() + bonusRed;
  int scoreBlueTotal() => scoreBlueBase() + bonusBlue;

  int scoreRed() => RulesEngine.countOf(board, CellState.red);
  int scoreBlue() => RulesEngine.countOf(board, CellState.blue);

  int scoreFor(CellState state) => RulesEngine.countOf(board, state);

  CellState? duelWinner() {
    if (!humanVsHuman) return null;
    final scores = <CellState, int>{
      for (final player in activePlayers) player: scoreFor(player),
    };
    final maxScore = scores.values.reduce(math.max);
    final winners =
        scores.entries.where((entry) => entry.value == maxScore).toList();
    if (winners.length != 1) return null;
    return winners.first.key;
  }

  Future<void> _performGreyDropAi() async {
    if (gameOver || isExploding || isFalling || isQuaking) return;
    _clearScorePopup();
    // Determine all neutral cells to drop
    final neutrals = _allNeutralCells();
    if (neutrals.isEmpty) {
      // Nothing to do
      selectedCell = null;
      blowPreview.clear();
      notifyListeners();
      return;
    }

    // Phase 1: Earthquake shake to signal the action
    isQuaking = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: quakeDurationMs));
    isQuaking = false;

    // Phase 2: Animate only neutrals falling out
    isFalling = true;
    fallingDistances = {for (final rc in neutrals) rc: K.n};
    notifyListeners();
    await Future.delayed(Duration(milliseconds: fallDurationMs));

    // Now remove all neutral tiles, keep others in place
    board = RulesEngine.removeAllNeutrals(board);

    // Clear states
    selectedCell = null;
    blowPreview.clear();
    fallingDistances = <(int, int), int>{};
    isFalling = false;

    // No direct points for grey drop
    lastMovePoints = 0;
    lastMoveBy = CellState.blue;
    turnsBlue++;
    current = CellState.red;
    _handleTurnStart(current);

    _checkEnd();
    notifyListeners();
  }
}
