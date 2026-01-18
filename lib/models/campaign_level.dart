class CampaignLevel {
  final int index;
  final int boardSize;
  final int aiLevel;
  final bool bombsEnabled;
  final Map<String, dynamic>? fixedState;

  const CampaignLevel({
    required this.index,
    required this.boardSize,
    required this.aiLevel,
    required this.bombsEnabled,
    this.fixedState,
  });
}

List<List<String>> _boardFromRows(List<String> rows) {
  return rows.map((row) => row.split('')).toList();
}

Map<String, dynamic> _fixedState({
  required List<String> boardRows,
  required int aiLevel,
  String current = 'red',
  int turnsRed = 0,
  int turnsBlue = 0,
  int turnsYellow = 0,
  int turnsGreen = 0,
  int bonusRed = 0,
  int bonusBlue = 0,
  int lastMovePoints = 0,
  String? lastMoveBy,
  String startingPlayer = 'red',
  bool gameOver = false,
  int redGamePoints = 0,
  int lastGamePointsAwarded = 0,
  int lastTotalBeforeAward = 0,
  int bestChallengeScore = 0,
  int lastBestChallengeScoreBefore = 0,
  bool lastGameWasNewBest = false,
  int playAccumMs = 0,
  List<Map<String, dynamic>> bombs = const [],
  Map<String, dynamic> lastBombTurns = const {},
}) {
  return {
    'board': _boardFromRows(boardRows),
    'current': current,
    'turnsRed': turnsRed,
    'turnsBlue': turnsBlue,
    'turnsYellow': turnsYellow,
    'turnsGreen': turnsGreen,
    'bonusRed': bonusRed,
    'bonusBlue': bonusBlue,
    'lastMovePoints': lastMovePoints,
    'lastMoveBy': lastMoveBy,
    'startingPlayer': startingPlayer,
    'aiLevel': aiLevel,
    'gameOver': gameOver,
    'redGamePoints': redGamePoints,
    'lastGamePointsAwarded': lastGamePointsAwarded,
    'lastTotalBeforeAward': lastTotalBeforeAward,
    'bestChallengeScore': bestChallengeScore,
    'lastBestChallengeScoreBefore': lastBestChallengeScoreBefore,
    'lastGameWasNewBest': lastGameWasNewBest,
    'playAccumMs': playAccumMs,
    'bombs': bombs,
    'lastBombTurns': lastBombTurns,
  };
}

final List<CampaignLevel> campaignLevels = [
  CampaignLevel(
    index: 1,
    boardSize: 7,
    aiLevel: 1,
    bombsEnabled: false,
    fixedState: _fixedState(
      aiLevel: 1,
      boardRows: [
        'eeeeeee',
        'eeebeee',
        'eerneee',
        'eebbnee',
        'eeenree',
        'eeenbee',
        'eeeeeee',
      ],
    ),
  ),
  CampaignLevel(
    index: 2,
    boardSize: 7,
    aiLevel: 1,
    bombsEnabled: false,
    fixedState: _fixedState(
      aiLevel: 1,
      boardRows: [
        'eeeeeee',
        'eebnbee',
        'eerrree',
        'eenneee',
        'eeebeee',
        'eerneee',
        'eeeeeee',
      ],
    ),
  ),
  CampaignLevel(
    index: 3,
    boardSize: 7,
    aiLevel: 2,
    bombsEnabled: false,
    fixedState: _fixedState(
      aiLevel: 2,
      boardRows: [
        'reeeeer',
        'eebbeee',
        'eenneee',
        'eeeebee',
        'eenneee',
        'eebbeee',
        'reeeeer',
      ],
    ),
  ),
  CampaignLevel(index: 4, boardSize: 7, aiLevel: 2, bombsEnabled: false),
  CampaignLevel(index: 5, boardSize: 7, aiLevel: 3, bombsEnabled: false),
  CampaignLevel(
    index: 6,
    boardSize: 7,
    aiLevel: 3,
    bombsEnabled: false,
    fixedState: _fixedState(
      aiLevel: 3,
      boardRows: [
        'eeebeee',
        'eebbeee',
        'eernree',
        'eeenbee',
        'eebbeee',
        'eeebeee',
        'eeeeeee',
      ],
    ),
  ),
  CampaignLevel(index: 7, boardSize: 7, aiLevel: 3, bombsEnabled: false),
  CampaignLevel(index: 8, boardSize: 7, aiLevel: 4, bombsEnabled: false),
  CampaignLevel(index: 9, boardSize: 7, aiLevel: 4, bombsEnabled: false),
  CampaignLevel(
    index: 10,
    boardSize: 7,
    aiLevel: 4,
    bombsEnabled: false,
    // Fixed state omitted (was 8x8); will start with a standard 7x7 state
  ),
  CampaignLevel(index: 11, boardSize: 7, aiLevel: 4, bombsEnabled: true),
  CampaignLevel(index: 12, boardSize: 7, aiLevel: 5, bombsEnabled: true),
  CampaignLevel(index: 13, boardSize: 7, aiLevel: 5, bombsEnabled: true),
  CampaignLevel(index: 14, boardSize: 7, aiLevel: 5, bombsEnabled: true),
  CampaignLevel(
    index: 15,
    boardSize: 7,
    aiLevel: 5,
    bombsEnabled: true,
    // Fixed state omitted (was 8x8); will start with a standard 7x7 state
  ),
  CampaignLevel(index: 16, boardSize: 7, aiLevel: 6, bombsEnabled: true),
  CampaignLevel(index: 17, boardSize: 7, aiLevel: 6, bombsEnabled: true),
  CampaignLevel(index: 18, boardSize: 7, aiLevel: 6, bombsEnabled: true),
  CampaignLevel(
    index: 19,
    boardSize: 7,
    aiLevel: 6,
    bombsEnabled: true,
  ),
  CampaignLevel(
    index: 20,
    boardSize: 7,
    aiLevel: 6,
    bombsEnabled: true,
    // Fixed state omitted (was 9x9); will start with a standard 7x7 state
  ),
  CampaignLevel(index: 21, boardSize: 7, aiLevel: 6, bombsEnabled: true),
  CampaignLevel(index: 22, boardSize: 7, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(index: 23, boardSize: 7, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(index: 24, boardSize: 7, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(
    index: 25,
    boardSize: 7,
    aiLevel: 7,
    bombsEnabled: true,
    // Fixed state omitted (was 9x9); will start with a standard 7x7 state
  ),
  CampaignLevel(index: 26, boardSize: 7, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(index: 27, boardSize: 7, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(index: 28, boardSize: 7, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(
    index: 29,
    boardSize: 7,
    aiLevel: 7,
    bombsEnabled: true,
    // Fixed state omitted (was 9x9); will start with a standard 7x7 state
  ),
];
