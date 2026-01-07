import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Two Touch {size}'**
  String appTitle(Object size);

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @playLabel.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playLabel;

  /// No description provided for @leaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveLabel;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @mainMenuBarrierLabel.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get mainMenuBarrierLabel;

  /// No description provided for @mainMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get mainMenuTooltip;

  /// No description provided for @gameMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Menu'**
  String get gameMenuTitle;

  /// No description provided for @returnToMainMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Return to main menu'**
  String get returnToMainMenuLabel;

  /// No description provided for @returnToMainMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Return to main menu'**
  String get returnToMainMenuTitle;

  /// No description provided for @returnToMainMenuMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to return to the main menu?\n\nProgress will not be saved.'**
  String get returnToMainMenuMessage;

  /// No description provided for @restartGameLabel.
  ///
  /// In en, this message translates to:
  /// **'Restart/Start the game'**
  String get restartGameLabel;

  /// No description provided for @restartGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart game'**
  String get restartGameTitle;

  /// No description provided for @restartGameMessage.
  ///
  /// In en, this message translates to:
  /// **'Restart the game from scratch?\n\nCurrent progress will be lost.'**
  String get restartGameMessage;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get helpTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @saveGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Save game'**
  String get saveGameTitle;

  /// No description provided for @saveGameNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name for this save'**
  String get saveGameNameLabel;

  /// No description provided for @saveGameNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name...'**
  String get saveGameNameHint;

  /// No description provided for @saveGameBarrierLabel.
  ///
  /// In en, this message translates to:
  /// **'Save Game'**
  String get saveGameBarrierLabel;

  /// No description provided for @gameSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Game saved'**
  String get gameSavedMessage;

  /// No description provided for @simulateGameLabel.
  ///
  /// In en, this message translates to:
  /// **'Simulate game'**
  String get simulateGameLabel;

  /// No description provided for @simulateGameHumanWinLabel.
  ///
  /// In en, this message translates to:
  /// **'Simulate game (human win)'**
  String get simulateGameHumanWinLabel;

  /// No description provided for @simulateGameAiWinLabel.
  ///
  /// In en, this message translates to:
  /// **'Simulate game (AI win)'**
  String get simulateGameAiWinLabel;

  /// No description provided for @simulateGameGreyWinLabel.
  ///
  /// In en, this message translates to:
  /// **'Simulate game (Grey win)'**
  String get simulateGameGreyWinLabel;

  /// No description provided for @removeAdsLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads — 1€'**
  String get removeAdsLabel;

  /// No description provided for @restorePurchasesLabel.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchasesLabel;

  /// No description provided for @menuGameShort.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get menuGameShort;

  /// No description provided for @menuGameChallenge.
  ///
  /// In en, this message translates to:
  /// **'Game challange'**
  String get menuGameChallenge;

  /// No description provided for @menuDuelShort.
  ///
  /// In en, this message translates to:
  /// **'Duel'**
  String get menuDuelShort;

  /// No description provided for @menuDuelMode.
  ///
  /// In en, this message translates to:
  /// **'Duel mode'**
  String get menuDuelMode;

  /// No description provided for @menuLoadShort.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get menuLoadShort;

  /// No description provided for @menuLoadGame.
  ///
  /// In en, this message translates to:
  /// **'Load game'**
  String get menuLoadGame;

  /// No description provided for @menuHubShort.
  ///
  /// In en, this message translates to:
  /// **'Hub'**
  String get menuHubShort;

  /// No description provided for @menuPlayerHub.
  ///
  /// In en, this message translates to:
  /// **'Player Hub'**
  String get menuPlayerHub;

  /// No description provided for @menuTripleShort.
  ///
  /// In en, this message translates to:
  /// **'Triple'**
  String get menuTripleShort;

  /// No description provided for @menuTripleThreat.
  ///
  /// In en, this message translates to:
  /// **'Triple Threat'**
  String get menuTripleThreat;

  /// No description provided for @menuQuadShort.
  ///
  /// In en, this message translates to:
  /// **'Quad'**
  String get menuQuadShort;

  /// No description provided for @menuQuadClash.
  ///
  /// In en, this message translates to:
  /// **'Quad Clash'**
  String get menuQuadClash;

  /// No description provided for @playerHubBarrierLabel.
  ///
  /// In en, this message translates to:
  /// **'Player Hub'**
  String get playerHubBarrierLabel;

  /// No description provided for @modesBarrierLabel.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get modesBarrierLabel;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @userProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfileLabel;

  /// No description provided for @gameChallengeLabel.
  ///
  /// In en, this message translates to:
  /// **'Game challenge'**
  String get gameChallengeLabel;

  /// No description provided for @gameChallengeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Game Challenge is coming soon'**
  String get gameChallengeComingSoon;

  /// No description provided for @loadGameBarrierLabel.
  ///
  /// In en, this message translates to:
  /// **'Load Game'**
  String get loadGameBarrierLabel;

  /// No description provided for @noSavedGamesMessage.
  ///
  /// In en, this message translates to:
  /// **'No saved games'**
  String get noSavedGamesMessage;

  /// No description provided for @savedGameDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Saved game'**
  String get savedGameDefaultName;

  /// No description provided for @savedGameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{when} • Turn: {turn}'**
  String savedGameSubtitle(Object when, Object turn);

  /// No description provided for @helpGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get helpGoalTitle;

  /// No description provided for @helpGoalBody.
  ///
  /// In en, this message translates to:
  /// **'Fill the {board} board by taking turns with the AI. You are Red, the AI is Blue. The player with the higher TOTAL score wins.'**
  String helpGoalBody(Object board);

  /// No description provided for @helpTurnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Turns & Placement'**
  String get helpTurnsTitle;

  /// No description provided for @helpTurnsBody.
  ///
  /// In en, this message translates to:
  /// **'Tap any empty cell to place your color. After your move, the AI places blue. The starting player can be changed in Settings.'**
  String get helpTurnsBody;

  /// No description provided for @helpScoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Scoring'**
  String get helpScoringTitle;

  /// No description provided for @helpScoringBase.
  ///
  /// In en, this message translates to:
  /// **'Base Score: number of cells of your color on the board when the game ends.'**
  String get helpScoringBase;

  /// No description provided for @helpScoringBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus: +50 points for every full row or full column filled with your color.'**
  String get helpScoringBonus;

  /// No description provided for @helpScoringTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Score: Base Score + Bonus.'**
  String get helpScoringTotal;

  /// No description provided for @helpScoringEarning.
  ///
  /// In en, this message translates to:
  /// **'Earning Points During Play (Red): +1 for each placement, +2 extra if placed in a corner, +2 for each Blue turned Neutral, +3 for each Neutral turned Red, +50 for each new full Red row/column.'**
  String get helpScoringEarning;

  /// No description provided for @helpScoringCumulative.
  ///
  /// In en, this message translates to:
  /// **'Your cumulative trophy counter only increases. Points are added after each finished game based on your Red Total. Opponent actions never reduce your cumulative total.'**
  String get helpScoringCumulative;

  /// No description provided for @helpWinningTitle.
  ///
  /// In en, this message translates to:
  /// **'Winning'**
  String get helpWinningTitle;

  /// No description provided for @helpWinningBody.
  ///
  /// In en, this message translates to:
  /// **'When the board has no empty cells, the game ends. The player with the higher Total Score wins. Draws are possible.'**
  String get helpWinningBody;

  /// No description provided for @helpAiLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Level'**
  String get helpAiLevelTitle;

  /// No description provided for @helpAiLevelBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the AI difficulty in Settings (1–7). Higher levels think further ahead but take longer.'**
  String get helpAiLevelBody;

  /// No description provided for @helpHistoryProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'History & Profile'**
  String get helpHistoryProfileTitle;

  /// No description provided for @helpHistoryProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Your finished games are saved in History with all details.'**
  String get helpHistoryProfileBody;

  /// No description provided for @aiDifficultyTitle.
  ///
  /// In en, this message translates to:
  /// **'AI difficulty'**
  String get aiDifficultyTitle;

  /// No description provided for @aiDifficultyTipBeginner.
  ///
  /// In en, this message translates to:
  /// **'White — Beginner: makes random moves.'**
  String get aiDifficultyTipBeginner;

  /// No description provided for @aiDifficultyTipEasy.
  ///
  /// In en, this message translates to:
  /// **'Yellow — Easy: prefers immediate gains.'**
  String get aiDifficultyTipEasy;

  /// No description provided for @aiDifficultyTipNormal.
  ///
  /// In en, this message translates to:
  /// **'Orange — Normal: greedy with basic positioning.'**
  String get aiDifficultyTipNormal;

  /// No description provided for @aiDifficultyTipChallenging.
  ///
  /// In en, this message translates to:
  /// **'Green — Challenging: shallow search with some foresight.'**
  String get aiDifficultyTipChallenging;

  /// No description provided for @aiDifficultyTipHard.
  ///
  /// In en, this message translates to:
  /// **'Blue — Hard: deeper search with pruning.'**
  String get aiDifficultyTipHard;

  /// No description provided for @aiDifficultyTipExpert.
  ///
  /// In en, this message translates to:
  /// **'Brown — Expert: advanced pruning and caching.'**
  String get aiDifficultyTipExpert;

  /// No description provided for @aiDifficultyTipMaster.
  ///
  /// In en, this message translates to:
  /// **'Black — Master: strongest and most calculating.'**
  String get aiDifficultyTipMaster;

  /// No description provided for @aiDifficultyTipSelect.
  ///
  /// In en, this message translates to:
  /// **'Select a belt level.'**
  String get aiDifficultyTipSelect;

  /// No description provided for @aiDifficultyDetailBeginner.
  ///
  /// In en, this message translates to:
  /// **'White — Beginner: random empty cells. Unpredictable but weak.'**
  String get aiDifficultyDetailBeginner;

  /// No description provided for @aiDifficultyDetailEasy.
  ///
  /// In en, this message translates to:
  /// **'Yellow — Easy: greedy takes that maximize immediate gain.'**
  String get aiDifficultyDetailEasy;

  /// No description provided for @aiDifficultyDetailNormal.
  ///
  /// In en, this message translates to:
  /// **'Orange — Normal: greedy with center tie-break to prefer stronger positions.'**
  String get aiDifficultyDetailNormal;

  /// No description provided for @aiDifficultyDetailChallenging.
  ///
  /// In en, this message translates to:
  /// **'Green — Challenging: shallow minimax search (depth 2), no pruning.'**
  String get aiDifficultyDetailChallenging;

  /// No description provided for @aiDifficultyDetailHard.
  ///
  /// In en, this message translates to:
  /// **'Blue — Hard: deeper minimax with alpha–beta pruning and move ordering.'**
  String get aiDifficultyDetailHard;

  /// No description provided for @aiDifficultyDetailExpert.
  ///
  /// In en, this message translates to:
  /// **'Brown — Expert: deeper minimax with pruning + transposition table.'**
  String get aiDifficultyDetailExpert;

  /// No description provided for @aiDifficultyDetailMaster.
  ///
  /// In en, this message translates to:
  /// **'Black — Master: Monte Carlo Tree Search (~1500 rollouts within time limit).'**
  String get aiDifficultyDetailMaster;

  /// No description provided for @aiDifficultyDetailSelect.
  ///
  /// In en, this message translates to:
  /// **'Select AI difficulty to see details.'**
  String get aiDifficultyDetailSelect;

  /// No description provided for @currentAiLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Current AI Level'**
  String get currentAiLevelLabel;

  /// No description provided for @aiLevelDisplay.
  ///
  /// In en, this message translates to:
  /// **'{belt} ({level})'**
  String aiLevelDisplay(Object belt, Object level);

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get resultsTitle;

  /// No description provided for @timePlayedLabel.
  ///
  /// In en, this message translates to:
  /// **'Time played'**
  String get timePlayedLabel;

  /// No description provided for @redTurnsLabel.
  ///
  /// In en, this message translates to:
  /// **'Red turns'**
  String get redTurnsLabel;

  /// No description provided for @blueTurnsLabel.
  ///
  /// In en, this message translates to:
  /// **'Blue turns'**
  String get blueTurnsLabel;

  /// No description provided for @yellowTurnsLabel.
  ///
  /// In en, this message translates to:
  /// **'Yellow turns'**
  String get yellowTurnsLabel;

  /// No description provided for @greenTurnsLabel.
  ///
  /// In en, this message translates to:
  /// **'Green turns'**
  String get greenTurnsLabel;

  /// No description provided for @playerTurnsLabel.
  ///
  /// In en, this message translates to:
  /// **'Player turns'**
  String get playerTurnsLabel;

  /// No description provided for @aiTurnsLabel.
  ///
  /// In en, this message translates to:
  /// **'AI turns'**
  String get aiTurnsLabel;

  /// No description provided for @newBestScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'New Best Score'**
  String get newBestScoreLabel;

  /// No description provided for @pointsBelowBestScore.
  ///
  /// In en, this message translates to:
  /// **'{points} points below best score'**
  String pointsBelowBestScore(Object points);

  /// No description provided for @youWinReachedScore.
  ///
  /// In en, this message translates to:
  /// **'You win and reached {score} score points'**
  String youWinReachedScore(Object score);

  /// No description provided for @redTerritoryControlled.
  ///
  /// In en, this message translates to:
  /// **'Red player territory controlled.'**
  String get redTerritoryControlled;

  /// No description provided for @blueTerritoryControlled.
  ///
  /// In en, this message translates to:
  /// **'Blue player territory controlled.'**
  String get blueTerritoryControlled;

  /// No description provided for @neutralTerritoryControlled.
  ///
  /// In en, this message translates to:
  /// **'Neutral territory controlled.'**
  String get neutralTerritoryControlled;

  /// No description provided for @territoryBalanced.
  ///
  /// In en, this message translates to:
  /// **'Territory balanced.'**
  String get territoryBalanced;

  /// No description provided for @performanceLost.
  ///
  /// In en, this message translates to:
  /// **'You lost. Strategy required.'**
  String get performanceLost;

  /// No description provided for @performanceBrilliantEndgame.
  ///
  /// In en, this message translates to:
  /// **'Brilliant Endgame'**
  String get performanceBrilliantEndgame;

  /// No description provided for @performanceGreatControl.
  ///
  /// In en, this message translates to:
  /// **'Great Control'**
  String get performanceGreatControl;

  /// No description provided for @performanceRiskyEffective.
  ///
  /// In en, this message translates to:
  /// **'Risky, but Effective'**
  String get performanceRiskyEffective;

  /// No description provided for @performanceSolidStrategy.
  ///
  /// In en, this message translates to:
  /// **'Solid Strategy'**
  String get performanceSolidStrategy;

  /// No description provided for @playAgainLabel.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgainLabel;

  /// No description provided for @continueNextAiLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue to Next AI Level'**
  String get continueNextAiLevelLabel;

  /// No description provided for @playLowerAiLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Play Lower AI Level'**
  String get playLowerAiLevelLabel;

  /// No description provided for @replaySameLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Replay Same Level'**
  String get replaySameLevelLabel;

  /// No description provided for @aiThinkingLabel.
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiThinkingLabel;

  /// No description provided for @simulatingGameLabel.
  ///
  /// In en, this message translates to:
  /// **'Simulating game...'**
  String get simulatingGameLabel;

  /// No description provided for @noTurnsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No turns yet for this game'**
  String get noTurnsYetMessage;

  /// No description provided for @turnLabel.
  ///
  /// In en, this message translates to:
  /// **'Turn {turn}'**
  String turnLabel(Object turn);

  /// No description provided for @undoLastActionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Undo last action'**
  String get undoLastActionTooltip;

  /// No description provided for @historyTabGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get historyTabGames;

  /// No description provided for @historyTabDailyActivity.
  ///
  /// In en, this message translates to:
  /// **'Daily activity'**
  String get historyTabDailyActivity;

  /// No description provided for @noFinishedGamesYet.
  ///
  /// In en, this message translates to:
  /// **'No finished games yet'**
  String get noFinishedGamesYet;

  /// No description provided for @gamesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Games: {count}'**
  String gamesCountLabel(Object count);

  /// No description provided for @winsLabel.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get winsLabel;

  /// No description provided for @lossesLabel.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get lossesLabel;

  /// No description provided for @drawsLabel.
  ///
  /// In en, this message translates to:
  /// **'Draws'**
  String get drawsLabel;

  /// No description provided for @totalTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get totalTimeLabel;

  /// No description provided for @resultDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get resultDraw;

  /// No description provided for @resultPlayerWins.
  ///
  /// In en, this message translates to:
  /// **'Player Wins'**
  String get resultPlayerWins;

  /// No description provided for @resultAiWins.
  ///
  /// In en, this message translates to:
  /// **'AI Wins'**
  String get resultAiWins;

  /// No description provided for @aiLabelWithName.
  ///
  /// In en, this message translates to:
  /// **'AI: {name}'**
  String aiLabelWithName(Object name);

  /// No description provided for @winnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Winner: {result}'**
  String winnerLabel(Object result);

  /// No description provided for @yourScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Your score'**
  String get yourScoreLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @redBaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Red base'**
  String get redBaseLabel;

  /// No description provided for @blueBaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Blue base'**
  String get blueBaseLabel;

  /// No description provided for @totalBlueLabel.
  ///
  /// In en, this message translates to:
  /// **'Total B'**
  String get totalBlueLabel;

  /// No description provided for @turnsRedLabel.
  ///
  /// In en, this message translates to:
  /// **'Turns R'**
  String get turnsRedLabel;

  /// No description provided for @turnsBlueLabel.
  ///
  /// In en, this message translates to:
  /// **'Turns B'**
  String get turnsBlueLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @nicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameLabel;

  /// No description provided for @enterNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter nickname'**
  String get enterNicknameHint;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @beltsTitle.
  ///
  /// In en, this message translates to:
  /// **'Belts'**
  String get beltsTitle;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achievementFullRow.
  ///
  /// In en, this message translates to:
  /// **'Full Row'**
  String get achievementFullRow;

  /// No description provided for @achievementFullColumn.
  ///
  /// In en, this message translates to:
  /// **'Full Column'**
  String get achievementFullColumn;

  /// No description provided for @achievementDiagonal.
  ///
  /// In en, this message translates to:
  /// **'Diagonal'**
  String get achievementDiagonal;

  /// No description provided for @achievement100GamePoints.
  ///
  /// In en, this message translates to:
  /// **'100 Game Points'**
  String get achievement100GamePoints;

  /// No description provided for @achievement1000GamePoints.
  ///
  /// In en, this message translates to:
  /// **'1000 Game Points'**
  String get achievement1000GamePoints;

  /// No description provided for @nicknameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Nickname is required'**
  String get nicknameRequiredError;

  /// No description provided for @nicknameMaxLengthError.
  ///
  /// In en, this message translates to:
  /// **'Maximum 32 characters allowed'**
  String get nicknameMaxLengthError;

  /// No description provided for @nicknameInvalidCharsError.
  ///
  /// In en, this message translates to:
  /// **'Use letters, numbers, dot, dash, or underscore'**
  String get nicknameInvalidCharsError;

  /// No description provided for @nicknameUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Nickname updated'**
  String get nicknameUpdatedMessage;

  /// No description provided for @noBeltsEarnedYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No belts earned yet.'**
  String get noBeltsEarnedYetMessage;

  /// No description provided for @whoStartsFirstLabel.
  ///
  /// In en, this message translates to:
  /// **'Who starts first'**
  String get whoStartsFirstLabel;

  /// No description provided for @startingPlayerHuman.
  ///
  /// In en, this message translates to:
  /// **'Human (Red)'**
  String get startingPlayerHuman;

  /// No description provided for @startingPlayerAi.
  ///
  /// In en, this message translates to:
  /// **'AI (Blue)'**
  String get startingPlayerAi;

  /// No description provided for @leaveDuelBarrierLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave duel'**
  String get leaveDuelBarrierLabel;

  /// No description provided for @leaveDuelTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave duel'**
  String get leaveDuelTitle;

  /// No description provided for @leaveDuelMessage.
  ///
  /// In en, this message translates to:
  /// **'Leave duel mode and return to the main menu?\n\nProgress will not be saved.'**
  String get leaveDuelMessage;

  /// No description provided for @leaveBarrierLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveBarrierLabel;

  /// No description provided for @leaveModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave {mode}'**
  String leaveModeTitle(Object mode);

  /// No description provided for @leaveMultiModeMessage.
  ///
  /// In en, this message translates to:
  /// **'Return to the main menu?\n\nProgress will not be saved.'**
  String get leaveMultiModeMessage;

  /// No description provided for @colorRedLabel.
  ///
  /// In en, this message translates to:
  /// **'RED'**
  String get colorRedLabel;

  /// No description provided for @colorBlueLabel.
  ///
  /// In en, this message translates to:
  /// **'BLUE'**
  String get colorBlueLabel;

  /// No description provided for @colorYellowLabel.
  ///
  /// In en, this message translates to:
  /// **'YELLOW'**
  String get colorYellowLabel;

  /// No description provided for @colorGreenLabel.
  ///
  /// In en, this message translates to:
  /// **'GREEN'**
  String get colorGreenLabel;

  /// No description provided for @redShortLabel.
  ///
  /// In en, this message translates to:
  /// **'R'**
  String get redShortLabel;

  /// No description provided for @blueShortLabel.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get blueShortLabel;

  /// No description provided for @yellowShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Y'**
  String get yellowShortLabel;

  /// No description provided for @greenShortLabel.
  ///
  /// In en, this message translates to:
  /// **'G'**
  String get greenShortLabel;

  /// No description provided for @supportTheDevLabel.
  ///
  /// In en, this message translates to:
  /// **'Support the dev'**
  String get supportTheDevLabel;

  /// No description provided for @aiBeltWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get aiBeltWhite;

  /// No description provided for @aiBeltYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get aiBeltYellow;

  /// No description provided for @aiBeltOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get aiBeltOrange;

  /// No description provided for @aiBeltGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get aiBeltGreen;

  /// No description provided for @aiBeltBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get aiBeltBlue;

  /// No description provided for @aiBeltBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get aiBeltBrown;

  /// No description provided for @aiBeltBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get aiBeltBlack;

  /// No description provided for @scorePlace.
  ///
  /// In en, this message translates to:
  /// **'+1 place'**
  String get scorePlace;

  /// No description provided for @scoreCorner.
  ///
  /// In en, this message translates to:
  /// **'+2 corner'**
  String get scoreCorner;

  /// No description provided for @scoreBlueToGrey.
  ///
  /// In en, this message translates to:
  /// **'+2 x{count} blue→grey'**
  String scoreBlueToGrey(Object count);

  /// No description provided for @scoreGreyToRed.
  ///
  /// In en, this message translates to:
  /// **'+3 x{count} grey→red'**
  String scoreGreyToRed(Object count);

  /// No description provided for @scorePlaceShort.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get scorePlaceShort;

  /// No description provided for @scoreZeroBlow.
  ///
  /// In en, this message translates to:
  /// **'0 blow'**
  String get scoreZeroBlow;

  /// No description provided for @scoreZeroGreyDrop.
  ///
  /// In en, this message translates to:
  /// **'0 grey drop'**
  String get scoreZeroGreyDrop;

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String durationSeconds(Object seconds);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String durationMinutesSeconds(Object minutes, Object seconds);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(Object hours, Object minutes);

  /// No description provided for @countryName.
  ///
  /// In en, this message translates to:
  /// **'{country, select, Afghanistan{Afghanistan} Albania{Albania} Algeria{Algeria} Andorra{Andorra} Angola{Angola} Antigua_and_Barbuda{Antigua and Barbuda} Argentina{Argentina} Armenia{Armenia} Australia{Australia} Austria{Austria} Azerbaijan{Azerbaijan} Bahamas{Bahamas} Bahrain{Bahrain} Bangladesh{Bangladesh} Barbados{Barbados} Belarus{Belarus} Belgium{Belgium} Belize{Belize} Benin{Benin} Bhutan{Bhutan} Bolivia{Bolivia} Bosnia_and_Herzegovina{Bosnia and Herzegovina} Botswana{Botswana} Brazil{Brazil} Brunei{Brunei} Bulgaria{Bulgaria} Burkina_Faso{Burkina Faso} Burundi{Burundi} Cabo_Verde{Cabo Verde} Cambodia{Cambodia} Cameroon{Cameroon} Canada{Canada} Central_African_Republic{Central African Republic} Chad{Chad} Chile{Chile} China{China} Colombia{Colombia} Comoros{Comoros} Congo_Congo_Brazzaville{Congo (Congo-Brazzaville)} Costa_Rica{Costa Rica} Croatia{Croatia} Cuba{Cuba} Cyprus{Cyprus} Czechia{Czechia} Democratic_Republic_of_the_Congo{Democratic Republic of the Congo} Denmark{Denmark} Djibouti{Djibouti} Dominica{Dominica} Dominican_Republic{Dominican Republic} Ecuador{Ecuador} Egypt{Egypt} El_Salvador{El Salvador} Equatorial_Guinea{Equatorial Guinea} Eritrea{Eritrea} Estonia{Estonia} Eswatini{Eswatini} Ethiopia{Ethiopia} Fiji{Fiji} Finland{Finland} France{France} Gabon{Gabon} Gambia{Gambia} Georgia{Georgia} Germany{Germany} Ghana{Ghana} Greece{Greece} Grenada{Grenada} Guatemala{Guatemala} Guinea{Guinea} Guinea_Bissau{Guinea-Bissau} Guyana{Guyana} Haiti{Haiti} Honduras{Honduras} Hungary{Hungary} Iceland{Iceland} India{India} Indonesia{Indonesia} Iran{Iran} Iraq{Iraq} Ireland{Ireland} Israel{Israel} Italy{Italy} Jamaica{Jamaica} Japan{Japan} Jordan{Jordan} Kazakhstan{Kazakhstan} Kenya{Kenya} Kiribati{Kiribati} Kuwait{Kuwait} Kyrgyzstan{Kyrgyzstan} Laos{Laos} Latvia{Latvia} Lebanon{Lebanon} Lesotho{Lesotho} Liberia{Liberia} Libya{Libya} Liechtenstein{Liechtenstein} Lithuania{Lithuania} Luxembourg{Luxembourg} Madagascar{Madagascar} Malawi{Malawi} Malaysia{Malaysia} Maldives{Maldives} Mali{Mali} Malta{Malta} Marshall_Islands{Marshall Islands} Mauritania{Mauritania} Mauritius{Mauritius} Mexico{Mexico} Micronesia{Micronesia} Moldova{Moldova} Monaco{Monaco} Mongolia{Mongolia} Montenegro{Montenegro} Morocco{Morocco} Mozambique{Mozambique} Myanmar{Myanmar} Namibia{Namibia} Nauru{Nauru} Nepal{Nepal} Netherlands{Netherlands} New_Zealand{New Zealand} Nicaragua{Nicaragua} Niger{Niger} Nigeria{Nigeria} North_Korea{North Korea} North_Macedonia{North Macedonia} Norway{Norway} Oman{Oman} Pakistan{Pakistan} Palau{Palau} Panama{Panama} Papua_New_Guinea{Papua New Guinea} Paraguay{Paraguay} Peru{Peru} Philippines{Philippines} Poland{Poland} Portugal{Portugal} Qatar{Qatar} Romania{Romania} Russia{Russia} Rwanda{Rwanda} Saint_Kitts_and_Nevis{Saint Kitts and Nevis} Saint_Lucia{Saint Lucia} Saint_Vincent_and_the_Grenadines{Saint Vincent and the Grenadines} Samoa{Samoa} San_Marino{San Marino} Sao_Tome_and_Principe{Sao Tome and Principe} Saudi_Arabia{Saudi Arabia} Senegal{Senegal} Serbia{Serbia} Seychelles{Seychelles} Sierra_Leone{Sierra Leone} Singapore{Singapore} Slovakia{Slovakia} Slovenia{Slovenia} Solomon_Islands{Solomon Islands} Somalia{Somalia} South_Africa{South Africa} South_Korea{South Korea} South_Sudan{South Sudan} Spain{Spain} Sri_Lanka{Sri Lanka} Sudan{Sudan} Suriname{Suriname} Sweden{Sweden} Switzerland{Switzerland} Syria{Syria} Taiwan{Taiwan} Tajikistan{Tajikistan} Tanzania{Tanzania} Thailand{Thailand} Timor_Leste{Timor-Leste} Togo{Togo} Tonga{Tonga} Trinidad_and_Tobago{Trinidad and Tobago} Tunisia{Tunisia} Turkey{Turkey} Turkmenistan{Turkmenistan} Tuvalu{Tuvalu} Uganda{Uganda} Ukraine{Ukraine} United_Arab_Emirates{United Arab Emirates} United_Kingdom{United Kingdom} United_States{United States} Uruguay{Uruguay} Uzbekistan{Uzbekistan} Vanuatu{Vanuatu} Vatican_City{Vatican City} Venezuela{Venezuela} Vietnam{Vietnam} Yemen{Yemen} Zambia{Zambia} Zimbabwe{Zimbabwe} other{Wakanda}}'**
  String countryName(String country);

  /// No description provided for @deleteSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete save?'**
  String get deleteSaveTitle;

  /// No description provided for @deleteSaveMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this saved game?'**
  String get deleteSaveMessage;

  /// No description provided for @failedToDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDeleteMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
