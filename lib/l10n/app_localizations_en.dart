// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String appTitle(Object size) {
    return 'Dual Clash';
  }

  @override
  String get commonClose => 'Close';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get playLabel => 'Play';

  @override
  String get leaveLabel => 'Leave';

  @override
  String get menuTitle => 'Menu';

  @override
  String get mainMenuBarrierLabel => 'Main Menu';

  @override
  String get mainMenuTooltip => 'Main Menu';

  @override
  String get gameMenuTitle => 'Game Menu';

  @override
  String get returnToMainMenuLabel => 'Back to menu';

  @override
  String get returnToMainMenuTitle => 'Back to menu';

  @override
  String get returnToMainMenuMessage =>
      'Do you want to return to the main menu?\n\nProgress will not be saved.';

  @override
  String get restartGameLabel => 'Restart game';

  @override
  String get restartGameTitle => 'Restart game';

  @override
  String get restartGameMessage =>
      'Restart the game from scratch?\n\nCurrent progress will be lost.';

  @override
  String get adminModeEnableTitle => 'Enable admin mode';

  @override
  String get adminModeEnableMessage =>
      'Enable admin mode on this device?\n\nSimulation menu items will become visible.';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get helpTitle => 'Help';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsMusicLabel => 'Main menu music';
  @override
  String get settingsSoundsLabel => 'Sounds';

  @override
  String get profileTitle => 'Profile';

  @override
  String get historyTitle => 'History';

  @override
  String get saveGameTitle => 'Save Game';

  @override
  String get saveGameNameLabel => 'Name for this save';

  @override
  String get saveGameNameHint => 'Enter name...';

  @override
  String get saveGameBarrierLabel => 'Save Game';

  @override
  String get gameSavedMessage => 'Game saved';

  @override
  String get simulateGameLabel => 'Simulate game';

  @override
  String get simulateGameHumanWinLabel => 'Simulate game (human win)';

  @override
  String get simulateGameAiWinLabel => 'Simulate game (AI win)';

  @override
  String get simulateGameGreyWinLabel => 'Simulate game (Grey win)';

  @override
  String get removeAdsLabel => 'Remove Ads — 1€';

  @override
  String get restorePurchasesLabel => 'Restore Purchases';

  @override
  String get menuGameShort => 'Game';

  @override
  String get menuGameChallenge => 'Game Challenge';

  @override
  String get menuDuelShort => 'Duel';

  @override
  String get menuDuelMode => 'Duel mode';

  @override
  String get menuLoadShort => 'Load';

  @override
  String get menuLoadGame => 'Load game';

  @override
  String get menuCampaignShort => 'Camp.';

  @override
  String get menuCampaign => 'Campaign';

  @override
  String get buddhaCampaignTitle => 'Buddha Campaign';

  @override
  String get buddhaCampaignDescription =>
      'Buddha Campaign is a journey of calm, control, and strategic clarity. Each level challenges you to read the board, act with precision, and win through balance rather than force.';

  @override
  String get shivaCampaignTitle => 'Shiva Campaign';

  @override
  String get shivaCampaignDescription =>
      'Shiva Campaign embraces destruction, aggression, and relentless pressure. Bombs become central tools, the board shifts rapidly, and decisive strikes define victory. Coming Soon.';

  @override
  String get ganeshaCampaignTitle => 'Ganesha Campaign';

  @override
  String get ganeshaCampaignDescription =>
      'Ganesha Campaign challenges perception through obstacles, clever positioning, and unconventional rules. Success depends on adaptability, foresight, and finding paths where none seem obvious. Coming Soon.';

  @override
  String get campaignComingSoon => 'Coming Soon';

  @override
  String get menuHubShort => 'Hub';

  @override
  String get menuPlayerHub => 'Player Hub';

  @override
  String get menuTripleShort => 'Triple';

  @override
  String get menuTripleThreat => 'Triple Threat';

  @override
  String get menuQuadShort => 'Quad';

  @override
  String get menuQuadClash => 'Quad Clash';

  @override
  String get menuAlliance2v2 => 'Alliance 2vs2';

  @override
  String get menuAlliance2v2Short => 'Alliance';

  @override
  String get playerHubBarrierLabel => 'Player Hub';

  @override
  String get modesBarrierLabel => 'Modes';

  @override
  String get languageTitle => 'Language';

  @override
  String get userProfileLabel => 'User Profile';

  @override
  String get gameChallengeLabel => 'Game challenge';

  @override
  String get gameChallengeComingSoon => 'Game Challenge is coming soon';

  @override
  String get loadGameBarrierLabel => 'Load Game';

  @override
  String get noSavedGamesMessage => 'No saved games';

  @override
  String get savedGameDefaultName => 'Saved game';

  @override
  String savedGameSubtitle(Object when, Object turn) {
    return '$when • Turn: $turn';
  }

  @override
  String get helpGoalTitle => 'Goal';

  @override
  String helpGoalBody(Object board) {
    return 'Fill the $board board by taking turns with the AI. You are Red, the AI is Blue. The player with the higher TOTAL score wins.';
  }

  @override
  String get helpTurnsTitle => 'Turns & Placement';

  @override
  String get helpTurnsBody =>
      'Tap any empty cell to place your color. After your move, the AI places blue. The starting player can be changed in Settings.';

  @override
  String get helpScoringTitle => 'Scoring';

  @override
  String get helpScoringBase =>
      'Base Score: number of cells of your color on the board when the game ends.';

  @override
  String get helpScoringBonus =>
      'Bonus: +50 points for every full row or full column filled with your color.';

  @override
  String get helpScoringTotal => 'Total Score: Base Score + Bonus.';

  @override
  String get helpScoringEarning =>
      'Earning Points During Play (Red): +1 for each placement, +2 extra if placed in a corner, +2 for each Blue turned Neutral, +3 for each Neutral turned Red, +50 for each new full Red row/column.';

  @override
  String get helpScoringCumulative =>
      'Your cumulative trophy counter only increases. Points are added after each finished game based on your Red Total. Opponent actions never reduce your cumulative total.';

  @override
  String get helpWinningTitle => 'Winning';

  @override
  String get helpWinningBody =>
      'When the board has no empty cells, the game ends. The player with the higher Total Score wins. Draws are possible.';

  @override
  String get helpAiLevelTitle => 'AI Level';

  @override
  String get helpAiLevelBody =>
      'Choose the AI difficulty in Settings (1–7). Higher levels think further ahead but take longer.';

  @override
  String get helpHistoryProfileTitle => 'History & Profile';

  @override
  String get helpHistoryProfileBody =>
      'Your finished games are saved in History with all details.';

  @override
  String get aiDifficultyTitle => 'AI Difficulty';

  @override
  String get aiDifficultyTipBeginner => 'White — Beginner: makes random moves.';

  @override
  String get aiDifficultyTipEasy => 'Yellow — Easy: prefers immediate gains.';

  @override
  String get aiDifficultyTipNormal =>
      'Orange — Normal: greedy with basic positioning.';

  @override
  String get aiDifficultyTipChallenging =>
      'Green — Challenging: shallow search with some foresight.';

  @override
  String get aiDifficultyTipHard => 'Blue — Hard: deeper search with pruning.';

  @override
  String get aiDifficultyTipExpert =>
      'Brown — Expert: advanced pruning and caching.';

  @override
  String get aiDifficultyTipMaster =>
      'Black — Master: strongest and most calculating.';

  @override
  String get aiDifficultyTipSelect => 'Select a belt level.';

  @override
  String get aiDifficultyDetailBeginner =>
      'White — Beginner: random empty cells. Unpredictable but weak.';

  @override
  String get aiDifficultyDetailEasy =>
      'Yellow — Easy: greedy takes that maximize immediate gain.';

  @override
  String get aiDifficultyDetailNormal =>
      'Orange — Normal: greedy with center tie-break to prefer stronger positions.';

  @override
  String get aiDifficultyDetailChallenging =>
      'Green — Challenging: shallow minimax search (depth 2), no pruning.';

  @override
  String get aiDifficultyDetailHard =>
      'Blue — Hard: deeper minimax with alpha–beta pruning and move ordering.';

  @override
  String get aiDifficultyDetailExpert =>
      'Brown — Expert: deeper minimax with pruning + transposition table.';

  @override
  String get aiDifficultyDetailMaster =>
      'Black — Master: Monte Carlo Tree Search (~1500 rollouts within time limit).';

  @override
  String get aiDifficultyDetailSelect => 'Select AI difficulty to see details.';

  @override
  String get currentAiLevelLabel => 'Current AI Level';

  @override
  String aiLevelDisplay(Object belt, Object level) {
    return '$belt ($level)';
  }

  @override
  String get resultsTitle => 'Results';

  @override
  String get timePlayedLabel => 'Time played';

  @override
  String get redTurnsLabel => 'Red turns';

  @override
  String get blueTurnsLabel => 'Blue turns';

  @override
  String get yellowTurnsLabel => 'Yellow turns';

  @override
  String get greenTurnsLabel => 'Green turns';

  @override
  String get playerTurnsLabel => 'Player turns';

  @override
  String get aiTurnsLabel => 'AI turns';

  @override
  String playerTurnStatus(Object player) {
    return '$player player turn';
  }

  @override
  String get newBestScoreLabel => 'New Best Score';

  @override
  String pointsBelowBestScore(Object points) {
    return '$points points below best score';
  }

  @override
  String youWinReachedScore(Object score) {
    return 'ou won and scored $score points';
  }

  @override
  String get redTerritoryControlled => 'Red player territory controlled.';

  @override
  String get blueTerritoryControlled => 'Blue player territory controlled.';

  @override
  String get neutralTerritoryControlled => 'Neutral territory controlled.';

  @override
  String get territoryBalanced => 'Territory balanced.';

  @override
  String get performanceLost => 'You lost. Strategy required.';

  @override
  String get performanceBrilliantEndgame => 'Brilliant Endgame';

  @override
  String get performanceGreatControl => 'Great Control';

  @override
  String get performanceRiskyEffective => 'Risky, but Effective';

  @override
  String get performanceSolidStrategy => 'Solid Strategy';

  @override
  String get playAgainLabel => 'Play again';

  @override
  String get continueNextAiLevelLabel => 'Continue to Next AI Level';

  @override
  String get playLowerAiLevelLabel => 'Play Lower AI Level';

  @override
  String get replaySameLevelLabel => 'Replay Same Level';

  @override
  String get aiThinkingLabel => 'AI is thinking...';

  @override
  String get simulatingGameLabel => 'Simulating game...';

  @override
  String get noTurnsYetMessage => 'No turns yet for this game';

  @override
  String turnLabel(Object turn) {
    return 'Turn $turn';
  }

  @override
  String get undoLastActionTooltip => 'Undo last action';

  @override
  String get historyTabGames => 'Games';

  @override
  String get historyTabDailyActivity => 'Daily activity';

  @override
  String get noFinishedGamesYet => 'No finished games yet';

  @override
  String gamesCountLabel(Object count) {
    return 'Games: $count';
  }

  @override
  String get winsLabel => 'Wins';

  @override
  String get lossesLabel => 'Losses';

  @override
  String get drawsLabel => 'Draws';

  @override
  String get totalTimeLabel => 'Total time';

  @override
  String get resultDraw => 'Draw';

  @override
  String get resultPlayerWins => 'Player Wins';

  @override
  String get resultAiWins => 'AI Wins';

  @override
  String aiLabelWithName(Object name) {
    return 'AI: $name';
  }

  @override
  String winnerLabel(Object result) {
    return 'Winner: $result';
  }

  @override
  String get yourScoreLabel => 'Your score';

  @override
  String get timeLabel => 'Time';

  @override
  String get redBaseLabel => 'Red base';

  @override
  String get blueBaseLabel => 'Blue base';

  @override
  String get totalBlueLabel => 'Total B';

  @override
  String get turnsRedLabel => 'Turns R';

  @override
  String get turnsBlueLabel => 'Turns B';

  @override
  String get ageLabel => 'Age';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get enterNicknameHint => 'Enter nickname';

  @override
  String get countryLabel => 'Country';

  @override
  String get beltsTitle => 'Belts';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get achievementFullRow => 'Full Row';

  @override
  String get achievementFullColumn => 'Full Column';

  @override
  String get achievementDiagonal => 'Diagonal';

  @override
  String get achievement100GamePoints => '100 Game Points';

  @override
  String get achievement1000GamePoints => '1000 Game Points';

  @override
  String get nicknameRequiredError => 'Nickname is required';

  @override
  String get nicknameMaxLengthError => 'Maximum 32 characters allowed';

  @override
  String get nicknameInvalidCharsError =>
      'Use letters, numbers, dot, dash, or underscore';

  @override
  String get nicknameUpdatedMessage => 'Nickname updated';

  @override
  String get noBeltsEarnedYetMessage => 'No belts earned yet.';

  @override
  String get whoStartsFirstLabel => 'Who starts first';

  @override
  String get whoStartsFirstTip =>
      'If no turns have been made, changes apply immediately; otherwise they take effect in the next game.';

  @override
  String get startingPlayerHuman => 'Human (Red)';

  @override
  String get startingPlayerAi => 'AI (Blue)';

  @override
  String get leaveDuelBarrierLabel => 'Leave duel';

  @override
  String get leaveDuelTitle => 'Leave duel';

  @override
  String get leaveDuelMessage =>
      'Leave duel mode and return to the main menu?\n\nProgress will not be saved.';

  @override
  String get leaveBarrierLabel => 'Leave';

  @override
  String leaveModeTitle(Object mode) {
    return 'Leave $mode';
  }

  @override
  String get leaveMultiModeMessage =>
      'Return to the main menu?\n\nProgress will not be saved.';

  @override
  String get colorRedLabel => 'RED';

  @override
  String get colorBlueLabel => 'BLUE';

  @override
  String get colorYellowLabel => 'YELLOW';

  @override
  String get colorGreenLabel => 'GREEN';

  @override
  String get redShortLabel => 'R';

  @override
  String get blueShortLabel => 'B';

  @override
  String get yellowShortLabel => 'Y';

  @override
  String get greenShortLabel => 'G';

  @override
  String get supportTheDevLabel => 'Support the dev';

  @override
  String get aiBeltWhite => 'White';

  @override
  String get aiBeltYellow => 'Yellow';

  @override
  String get aiBeltOrange => 'Orange';

  @override
  String get aiBeltGreen => 'Green';

  @override
  String get aiBeltBlue => 'Blue';

  @override
  String get aiBeltBrown => 'Brown';

  @override
  String get aiBeltBlack => 'Black';

  @override
  String get scorePlace => '+1 place';

  @override
  String get scoreCorner => '+2 corner';

  @override
  String scoreBlueToGrey(Object count) {
    return '+2 x$count blue→grey';
  }

  @override
  String scoreGreyToRed(Object count) {
    return '+3 x$count grey→red';
  }

  @override
  String get scorePlaceShort => 'Place';

  @override
  String get scoreZeroBlow => '0 blow';

  @override
  String get scoreZeroGreyDrop => '0 grey drop';

  @override
  String durationSeconds(Object seconds) {
    return '${seconds}s';
  }

  @override
  String durationMinutesSeconds(Object minutes, Object seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String durationHoursMinutes(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String countryName(String country) {
    String _temp0 = intl.Intl.selectLogic(
      country,
      {
        'Afghanistan': 'Afghanistan',
        'Albania': 'Albania',
        'Algeria': 'Algeria',
        'Andorra': 'Andorra',
        'Angola': 'Angola',
        'Antigua_and_Barbuda': 'Antigua and Barbuda',
        'Argentina': 'Argentina',
        'Armenia': 'Armenia',
        'Australia': 'Australia',
        'Austria': 'Austria',
        'Azerbaijan': 'Azerbaijan',
        'Bahamas': 'Bahamas',
        'Bahrain': 'Bahrain',
        'Bangladesh': 'Bangladesh',
        'Barbados': 'Barbados',
        'Belarus': 'Belarus',
        'Belgium': 'Belgium',
        'Belize': 'Belize',
        'Benin': 'Benin',
        'Bhutan': 'Bhutan',
        'Bolivia': 'Bolivia',
        'Bosnia_and_Herzegovina': 'Bosnia and Herzegovina',
        'Botswana': 'Botswana',
        'Brazil': 'Brazil',
        'Brunei': 'Brunei',
        'Bulgaria': 'Bulgaria',
        'Burkina_Faso': 'Burkina Faso',
        'Burundi': 'Burundi',
        'Cabo_Verde': 'Cabo Verde',
        'Cambodia': 'Cambodia',
        'Cameroon': 'Cameroon',
        'Canada': 'Canada',
        'Central_African_Republic': 'Central African Republic',
        'Chad': 'Chad',
        'Chile': 'Chile',
        'China': 'China',
        'Colombia': 'Colombia',
        'Comoros': 'Comoros',
        'Congo_Congo_Brazzaville': 'Congo (Congo-Brazzaville)',
        'Costa_Rica': 'Costa Rica',
        'Croatia': 'Croatia',
        'Cuba': 'Cuba',
        'Cyprus': 'Cyprus',
        'Czechia': 'Czechia',
        'Democratic_Republic_of_the_Congo': 'Democratic Republic of the Congo',
        'Denmark': 'Denmark',
        'Djibouti': 'Djibouti',
        'Dominica': 'Dominica',
        'Dominican_Republic': 'Dominican Republic',
        'Ecuador': 'Ecuador',
        'Egypt': 'Egypt',
        'El_Salvador': 'El Salvador',
        'Equatorial_Guinea': 'Equatorial Guinea',
        'Eritrea': 'Eritrea',
        'Estonia': 'Estonia',
        'Eswatini': 'Eswatini',
        'Ethiopia': 'Ethiopia',
        'Fiji': 'Fiji',
        'Finland': 'Finland',
        'France': 'France',
        'Gabon': 'Gabon',
        'Gambia': 'Gambia',
        'Georgia': 'Georgia',
        'Germany': 'Germany',
        'Ghana': 'Ghana',
        'Greece': 'Greece',
        'Grenada': 'Grenada',
        'Guatemala': 'Guatemala',
        'Guinea': 'Guinea',
        'Guinea_Bissau': 'Guinea-Bissau',
        'Guyana': 'Guyana',
        'Haiti': 'Haiti',
        'Honduras': 'Honduras',
        'Hungary': 'Hungary',
        'Iceland': 'Iceland',
        'India': 'India',
        'Indonesia': 'Indonesia',
        'Iran': 'Iran',
        'Iraq': 'Iraq',
        'Ireland': 'Ireland',
        'Israel': 'Israel',
        'Italy': 'Italy',
        'Jamaica': 'Jamaica',
        'Japan': 'Japan',
        'Jordan': 'Jordan',
        'Kazakhstan': 'Kazakhstan',
        'Kenya': 'Kenya',
        'Kiribati': 'Kiribati',
        'Kuwait': 'Kuwait',
        'Kyrgyzstan': 'Kyrgyzstan',
        'Laos': 'Laos',
        'Latvia': 'Latvia',
        'Lebanon': 'Lebanon',
        'Lesotho': 'Lesotho',
        'Liberia': 'Liberia',
        'Libya': 'Libya',
        'Liechtenstein': 'Liechtenstein',
        'Lithuania': 'Lithuania',
        'Luxembourg': 'Luxembourg',
        'Madagascar': 'Madagascar',
        'Malawi': 'Malawi',
        'Malaysia': 'Malaysia',
        'Maldives': 'Maldives',
        'Mali': 'Mali',
        'Malta': 'Malta',
        'Marshall_Islands': 'Marshall Islands',
        'Mauritania': 'Mauritania',
        'Mauritius': 'Mauritius',
        'Mexico': 'Mexico',
        'Micronesia': 'Micronesia',
        'Moldova': 'Moldova',
        'Monaco': 'Monaco',
        'Mongolia': 'Mongolia',
        'Montenegro': 'Montenegro',
        'Morocco': 'Morocco',
        'Mozambique': 'Mozambique',
        'Myanmar': 'Myanmar',
        'Namibia': 'Namibia',
        'Nauru': 'Nauru',
        'Nepal': 'Nepal',
        'Netherlands': 'Netherlands',
        'New_Zealand': 'New Zealand',
        'Nicaragua': 'Nicaragua',
        'Niger': 'Niger',
        'Nigeria': 'Nigeria',
        'North_Korea': 'North Korea',
        'North_Macedonia': 'North Macedonia',
        'Norway': 'Norway',
        'Oman': 'Oman',
        'Pakistan': 'Pakistan',
        'Palau': 'Palau',
        'Panama': 'Panama',
        'Papua_New_Guinea': 'Papua New Guinea',
        'Paraguay': 'Paraguay',
        'Peru': 'Peru',
        'Philippines': 'Philippines',
        'Poland': 'Poland',
        'Portugal': 'Portugal',
        'Qatar': 'Qatar',
        'Romania': 'Romania',
        'Russia': 'Russia',
        'Rwanda': 'Rwanda',
        'Saint_Kitts_and_Nevis': 'Saint Kitts and Nevis',
        'Saint_Lucia': 'Saint Lucia',
        'Saint_Vincent_and_the_Grenadines': 'Saint Vincent and the Grenadines',
        'Samoa': 'Samoa',
        'San_Marino': 'San Marino',
        'Sao_Tome_and_Principe': 'Sao Tome and Principe',
        'Saudi_Arabia': 'Saudi Arabia',
        'Senegal': 'Senegal',
        'Serbia': 'Serbia',
        'Seychelles': 'Seychelles',
        'Sierra_Leone': 'Sierra Leone',
        'Singapore': 'Singapore',
        'Slovakia': 'Slovakia',
        'Slovenia': 'Slovenia',
        'Solomon_Islands': 'Solomon Islands',
        'Somalia': 'Somalia',
        'South_Africa': 'South Africa',
        'South_Korea': 'South Korea',
        'South_Sudan': 'South Sudan',
        'Spain': 'Spain',
        'Sri_Lanka': 'Sri Lanka',
        'Sudan': 'Sudan',
        'Suriname': 'Suriname',
        'Sweden': 'Sweden',
        'Switzerland': 'Switzerland',
        'Syria': 'Syria',
        'Taiwan': 'Taiwan',
        'Tajikistan': 'Tajikistan',
        'Tanzania': 'Tanzania',
        'Thailand': 'Thailand',
        'Timor_Leste': 'Timor-Leste',
        'Togo': 'Togo',
        'Tonga': 'Tonga',
        'Trinidad_and_Tobago': 'Trinidad and Tobago',
        'Tunisia': 'Tunisia',
        'Turkey': 'Turkey',
        'Turkmenistan': 'Turkmenistan',
        'Tuvalu': 'Tuvalu',
        'Uganda': 'Uganda',
        'Ukraine': 'Ukraine',
        'United_Arab_Emirates': 'United Arab Emirates',
        'United_Kingdom': 'United Kingdom',
        'United_States': 'United States',
        'Uruguay': 'Uruguay',
        'Uzbekistan': 'Uzbekistan',
        'Vanuatu': 'Vanuatu',
        'Vatican_City': 'Vatican City',
        'Venezuela': 'Venezuela',
        'Vietnam': 'Vietnam',
        'Yemen': 'Yemen',
        'Zambia': 'Zambia',
        'Zimbabwe': 'Zimbabwe',
        'other': 'Wakanda',
      },
    );
    return '$_temp0';
  }

  @override
  String get deleteSaveTitle => 'Delete save?';

  @override
  String get deleteSaveMessage =>
      'Are you sure you want to delete this saved game?';

  @override
  String get failedToDeleteMessage => 'Failed to delete';

  @override
  String get webSaveGameNote =>
      'Web note: your save will be stored in this browser’s local storage for this site. It won’t sync across devices or private windows.';

  @override
  String get webLoadGameNote =>
      'Web note: the list below comes from this browser’s local storage for this site (not shared across other browsers or private windows).';
}
