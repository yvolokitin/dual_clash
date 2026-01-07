// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String appTitle(Object size) {
    return 'Two Touch $size';
  }

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonConfirm => 'Bestätigen';

  @override
  String get commonYes => 'Ja';

  @override
  String get commonNo => 'Nein';

  @override
  String get deleteLabel => 'Löschen';

  @override
  String get playLabel => 'Spielen';

  @override
  String get leaveLabel => 'Verlassen';

  @override
  String get menuTitle => 'Menü';

  @override
  String get mainMenuBarrierLabel => 'Hauptmenü';

  @override
  String get mainMenuTooltip => 'Hauptmenü';

  @override
  String get gameMenuTitle => 'Spielmenü';

  @override
  String get returnToMainMenuLabel => 'Zum Hauptmenü zurück';

  @override
  String get returnToMainMenuTitle => 'Zum Hauptmenü zurück';

  @override
  String get returnToMainMenuMessage =>
      'Möchtest du zum Hauptmenü zurückkehren?\n\nDer Fortschritt wird nicht gespeichert.';

  @override
  String get restartGameLabel => 'Spiel neu starten/Starten';

  @override
  String get restartGameTitle => 'Spiel neu starten';

  @override
  String get restartGameMessage =>
      'Spiel von vorne neu starten?\n\nDer aktuelle Fortschritt geht verloren.';

  @override
  String get statisticsTitle => 'Statistiken';

  @override
  String get helpTitle => 'So spielt man';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get profileTitle => 'Profil';

  @override
  String get historyTitle => 'Verlauf';

  @override
  String get saveGameTitle => 'Spiel speichern';

  @override
  String get saveGameNameLabel => 'Name für diese Speicherung';

  @override
  String get saveGameNameHint => 'Name eingeben...';

  @override
  String get saveGameBarrierLabel => 'Spiel speichern';

  @override
  String get gameSavedMessage => 'Spiel gespeichert';

  @override
  String get simulateGameLabel => 'Spiel simulieren';

  @override
  String get simulateGameHumanWinLabel => 'Spiel simulieren (Mensch gewinnt)';

  @override
  String get simulateGameAiWinLabel => 'Spiel simulieren (KI gewinnt)';

  @override
  String get simulateGameGreyWinLabel => 'Spiel simulieren (Grau gewinnt)';

  @override
  String get removeAdsLabel => 'Werbung entfernen — 1€';

  @override
  String get restorePurchasesLabel => 'Käufe wiederherstellen';

  @override
  String get menuGameShort => 'Spiel';

  @override
  String get menuGameChallenge => 'Spiel-Herausforderung';

  @override
  String get menuDuelShort => 'Duell';

  @override
  String get menuDuelMode => 'Duellmodus';

  @override
  String get menuLoadShort => 'Laden';

  @override
  String get menuLoadGame => 'Spiel laden';

  @override
  String get menuHubShort => 'Hub';

  @override
  String get menuPlayerHub => 'Spieler-Hub';

  @override
  String get menuTripleShort => 'Triple';

  @override
  String get menuTripleThreat => 'Dreifache Bedrohung';

  @override
  String get menuQuadShort => 'Quad';

  @override
  String get menuQuadClash => 'Vierfacher Clash';

  @override
  String get menuAlliance2v2 => 'Alliance 2vs2';

  @override
  String get playerHubBarrierLabel => 'Spieler-Hub';

  @override
  String get modesBarrierLabel => 'Modi';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get userProfileLabel => 'Benutzerprofil';

  @override
  String get gameChallengeLabel => 'Spiel-Herausforderung';

  @override
  String get gameChallengeComingSoon => 'Der Herausforderungsmodus kommt bald';

  @override
  String get loadGameBarrierLabel => 'Spiel laden';

  @override
  String get noSavedGamesMessage => 'Keine gespeicherten Spiele';

  @override
  String get savedGameDefaultName => 'Gespeichertes Spiel';

  @override
  String savedGameSubtitle(Object when, Object turn) {
    return '$when • Zug: $turn';
  }

  @override
  String get helpGoalTitle => 'Ziel';

  @override
  String helpGoalBody(Object board) {
    return 'Fülle das $board-Brett abwechselnd mit der KI. Du bist Rot, die KI ist Blau. Gewinnt, wer die höhere GESAMTpunktzahl hat.';
  }

  @override
  String get helpTurnsTitle => 'Züge & Platzierung';

  @override
  String get helpTurnsBody =>
      'Tippe auf eine leere Zelle, um deine Farbe zu platzieren. Nach deinem Zug setzt die KI Blau. Wer beginnt, kann in den Einstellungen geändert werden.';

  @override
  String get helpScoringTitle => 'Punkte';

  @override
  String get helpScoringBase =>
      'Basis-Punkte: Anzahl der Zellen deiner Farbe am Spielende.';

  @override
  String get helpScoringBonus =>
      'Bonus: +50 Punkte für jede volle Reihe oder Spalte deiner Farbe.';

  @override
  String get helpScoringTotal => 'Gesamtpunkte: Basis + Bonus.';

  @override
  String get helpScoringEarning =>
      'Punkte während des Spiels (Rot): +1 pro Platzierung, +2 extra für eine Ecke, +2 für jedes Blau zu Neutral, +3 für jedes Neutral zu Rot, +50 für jede neue volle rote Reihe/Spalte.';

  @override
  String get helpScoringCumulative =>
      'Dein Trophäen-Zähler steigt nur. Punkte werden nach jedem Spiel anhand deiner roten Gesamtpunkte addiert. Aktionen des Gegners verringern deinen Gesamtwert nie.';

  @override
  String get helpWinningTitle => 'Sieg';

  @override
  String get helpWinningBody =>
      'Wenn das Brett keine leeren Zellen mehr hat, endet das Spiel. Gewinnt, wer die höhere Gesamtpunktzahl hat. Unentschieden sind möglich.';

  @override
  String get helpAiLevelTitle => 'KI-Stufe';

  @override
  String get helpAiLevelBody =>
      'Wähle die KI-Schwierigkeit in den Einstellungen (1–7). Höhere Stufen denken weiter voraus, brauchen aber länger.';

  @override
  String get helpHistoryProfileTitle => 'Verlauf & Profil';

  @override
  String get helpHistoryProfileBody =>
      'Deine abgeschlossenen Spiele werden im Verlauf mit allen Details gespeichert.';

  @override
  String get aiDifficultyTitle => 'KI-Schwierigkeit';

  @override
  String get aiDifficultyTipBeginner =>
      'Weiß — Anfänger: macht zufällige Züge.';

  @override
  String get aiDifficultyTipEasy =>
      'Gelb — Leicht: bevorzugt sofortige Gewinne.';

  @override
  String get aiDifficultyTipNormal =>
      'Orange — Normal: gierig mit grundlegendem Positioning.';

  @override
  String get aiDifficultyTipChallenging =>
      'Grün — Herausfordernd: flache Suche mit etwas Voraussicht.';

  @override
  String get aiDifficultyTipHard => 'Blau — Schwer: tiefere Suche mit Pruning.';

  @override
  String get aiDifficultyTipExpert =>
      'Braun — Experte: fortgeschrittenes Pruning und Caching.';

  @override
  String get aiDifficultyTipMaster =>
      'Schwarz — Meister: am stärksten und berechnend.';

  @override
  String get aiDifficultyTipSelect => 'Wähle ein Gürtel-Level.';

  @override
  String get aiDifficultyDetailBeginner =>
      'Weiß — Anfänger: zufällige leere Zellen. Unberechenbar, aber schwach.';

  @override
  String get aiDifficultyDetailEasy =>
      'Gelb — Leicht: gierige Züge für maximale Sofortgewinne.';

  @override
  String get aiDifficultyDetailNormal =>
      'Orange — Normal: gierig mit Zentrum-Tiebreak für stärkere Positionen.';

  @override
  String get aiDifficultyDetailChallenging =>
      'Grün — Herausfordernd: flacher Minimax (Tiefe 2), ohne Pruning.';

  @override
  String get aiDifficultyDetailHard =>
      'Blau — Schwer: tieferer Minimax mit Alpha-Beta-Pruning und Zugreihenfolge.';

  @override
  String get aiDifficultyDetailExpert =>
      'Braun — Experte: tieferer Minimax mit Pruning + Transpositionstabelle.';

  @override
  String get aiDifficultyDetailMaster =>
      'Schwarz — Meister: Monte-Carlo-Tree-Search (~1500 Simulationen im Zeitlimit).';

  @override
  String get aiDifficultyDetailSelect =>
      'Wähle eine KI-Schwierigkeit, um Details zu sehen.';

  @override
  String get currentAiLevelLabel => 'Aktuelle KI-Stufe';

  @override
  String aiLevelDisplay(Object belt, Object level) {
    return '$belt ($level)';
  }

  @override
  String get resultsTitle => 'Ergebnisse';

  @override
  String get timePlayedLabel => 'Spielzeit';

  @override
  String get redTurnsLabel => 'Rote Züge';

  @override
  String get blueTurnsLabel => 'Blaue Züge';

  @override
  String get yellowTurnsLabel => 'Gelbe Züge';

  @override
  String get greenTurnsLabel => 'Grüne Züge';

  @override
  String get playerTurnsLabel => 'Spieler-Züge';

  @override
  String get aiTurnsLabel => 'KI-Züge';

  @override
  String get newBestScoreLabel => 'Neuer Bestwert';

  @override
  String pointsBelowBestScore(Object points) {
    return '$points Punkte unter Bestwert';
  }

  @override
  String youWinReachedScore(Object score) {
    return 'Du hast gewonnen und $score Punkte erreicht';
  }

  @override
  String get redTerritoryControlled =>
      'Gebiet des roten Spielers kontrolliert.';

  @override
  String get blueTerritoryControlled =>
      'Gebiet des blauen Spielers kontrolliert.';

  @override
  String get neutralTerritoryControlled => 'Neutrales Gebiet kontrolliert.';

  @override
  String get territoryBalanced => 'Gebiet ausgeglichen.';

  @override
  String get performanceLost => 'Du hast verloren. Strategie erforderlich.';

  @override
  String get performanceBrilliantEndgame => 'Brillantes Endspiel';

  @override
  String get performanceGreatControl => 'Große Kontrolle';

  @override
  String get performanceRiskyEffective => 'Riskant, aber effektiv';

  @override
  String get performanceSolidStrategy => 'Solide Strategie';

  @override
  String get playAgainLabel => 'Erneut spielen';

  @override
  String get continueNextAiLevelLabel => 'Zum nächsten KI-Level';

  @override
  String get playLowerAiLevelLabel => 'Niedrigeres KI-Level spielen';

  @override
  String get replaySameLevelLabel => 'Gleiches Level wiederholen';

  @override
  String get aiThinkingLabel => 'Die KI denkt...';

  @override
  String get simulatingGameLabel => 'Spiel wird simuliert...';

  @override
  String get noTurnsYetMessage => 'Noch keine Züge in diesem Spiel';

  @override
  String turnLabel(Object turn) {
    return 'Zug $turn';
  }

  @override
  String get undoLastActionTooltip => 'Letzte Aktion rückgängig machen';

  @override
  String get historyTabGames => 'Spiele';

  @override
  String get historyTabDailyActivity => 'Tägliche Aktivität';

  @override
  String get noFinishedGamesYet => 'Noch keine abgeschlossenen Spiele';

  @override
  String gamesCountLabel(Object count) {
    return 'Spiele: $count';
  }

  @override
  String get winsLabel => 'Siege';

  @override
  String get lossesLabel => 'Niederlagen';

  @override
  String get drawsLabel => 'Unentschieden';

  @override
  String get totalTimeLabel => 'Gesamtzeit';

  @override
  String get resultDraw => 'Unentschieden';

  @override
  String get resultPlayerWins => 'Spieler gewinnt';

  @override
  String get resultAiWins => 'KI gewinnt';

  @override
  String aiLabelWithName(Object name) {
    return 'KI: $name';
  }

  @override
  String winnerLabel(Object result) {
    return 'Sieger: $result';
  }

  @override
  String get yourScoreLabel => 'Deine Punkte';

  @override
  String get timeLabel => 'Zeit';

  @override
  String get redBaseLabel => 'Rot-Basis';

  @override
  String get blueBaseLabel => 'Blau-Basis';

  @override
  String get totalBlueLabel => 'Blau gesamt';

  @override
  String get turnsRedLabel => 'Züge R';

  @override
  String get turnsBlueLabel => 'Züge B';

  @override
  String get ageLabel => 'Alter';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get enterNicknameHint => 'Nickname eingeben';

  @override
  String get countryLabel => 'Land';

  @override
  String get beltsTitle => 'Gürtel';

  @override
  String get achievementsTitle => 'Erfolge';

  @override
  String get achievementFullRow => 'Volle Reihe';

  @override
  String get achievementFullColumn => 'Volle Spalte';

  @override
  String get achievementDiagonal => 'Diagonale';

  @override
  String get achievement100GamePoints => '100 Spielpunkte';

  @override
  String get achievement1000GamePoints => '1000 Spielpunkte';

  @override
  String get nicknameRequiredError => 'Nickname ist erforderlich';

  @override
  String get nicknameMaxLengthError => 'Maximal 32 Zeichen';

  @override
  String get nicknameInvalidCharsError =>
      'Verwende Buchstaben, Zahlen, Punkt, Bindestrich oder Unterstrich';

  @override
  String get nicknameUpdatedMessage => 'Nickname aktualisiert';

  @override
  String get noBeltsEarnedYetMessage => 'Noch keine Gürtel verdient.';

  @override
  String get whoStartsFirstLabel => 'Wer beginnt';

  @override
  String get startingPlayerHuman => 'Mensch (Rot)';

  @override
  String get startingPlayerAi => 'KI (Blau)';

  @override
  String get leaveDuelBarrierLabel => 'Duell verlassen';

  @override
  String get leaveDuelTitle => 'Duell verlassen';

  @override
  String get leaveDuelMessage =>
      'Duellmodus verlassen und zum Hauptmenü zurückkehren?\n\nDer Fortschritt wird nicht gespeichert.';

  @override
  String get leaveBarrierLabel => 'Verlassen';

  @override
  String leaveModeTitle(Object mode) {
    return '$mode verlassen';
  }

  @override
  String get leaveMultiModeMessage =>
      'Zum Hauptmenü zurückkehren?\n\nDer Fortschritt wird nicht gespeichert.';

  @override
  String get colorRedLabel => 'ROT';

  @override
  String get colorBlueLabel => 'BLAU';

  @override
  String get colorYellowLabel => 'GELB';

  @override
  String get colorGreenLabel => 'GRÜN';

  @override
  String get redShortLabel => 'R';

  @override
  String get blueShortLabel => 'B';

  @override
  String get yellowShortLabel => 'G';

  @override
  String get greenShortLabel => 'Gr';

  @override
  String get supportTheDevLabel => 'Unterstütze den Entwickler';

  @override
  String get aiBeltWhite => 'Weiß';

  @override
  String get aiBeltYellow => 'Gelb';

  @override
  String get aiBeltOrange => 'Orange';

  @override
  String get aiBeltGreen => 'Grün';

  @override
  String get aiBeltBlue => 'Blau';

  @override
  String get aiBeltBrown => 'Braun';

  @override
  String get aiBeltBlack => 'Schwarz';

  @override
  String get scorePlace => '+1 Platzierung';

  @override
  String get scoreCorner => '+2 Ecke';

  @override
  String scoreBlueToGrey(Object count) {
    return '+2 x$count blau→grau';
  }

  @override
  String scoreGreyToRed(Object count) {
    return '+3 x$count grau→rot';
  }

  @override
  String get scorePlaceShort => 'Platzieren';

  @override
  String get scoreZeroBlow => '0 Treffer';

  @override
  String get scoreZeroGreyDrop => '0 grauer Abwurf';

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
        'Albania': 'Albanien',
        'Algeria': 'Algerien',
        'Andorra': 'Andorra',
        'Angola': 'Angola',
        'Antigua_and_Barbuda': 'Antigua und Barbuda',
        'Argentina': 'Argentinien',
        'Armenia': 'Armenien',
        'Australia': 'Australien',
        'Austria': 'Österreich',
        'Azerbaijan': 'Aserbaidschan',
        'Bahamas': 'Bahamas',
        'Bahrain': 'Bahrain',
        'Bangladesh': 'Bangladesch',
        'Barbados': 'Barbados',
        'Belarus': 'Belarus',
        'Belgium': 'Belgien',
        'Belize': 'Belize',
        'Benin': 'Benin',
        'Bhutan': 'Bhutan',
        'Bolivia': 'Bolivien',
        'Bosnia_and_Herzegovina': 'Bosnien und Herzegowina',
        'Botswana': 'Botsuana',
        'Brazil': 'Brasilien',
        'Brunei': 'Brunei',
        'Bulgaria': 'Bulgarien',
        'Burkina_Faso': 'Burkina Faso',
        'Burundi': 'Burundi',
        'Cabo_Verde': 'Cabo Verde',
        'Cambodia': 'Kambodscha',
        'Cameroon': 'Kamerun',
        'Canada': 'Kanada',
        'Central_African_Republic': 'Zentralafrikanische Republik',
        'Chad': 'Tschad',
        'Chile': 'Chile',
        'China': 'China',
        'Colombia': 'Kolumbien',
        'Comoros': 'Komoren',
        'Congo_Congo_Brazzaville': 'Kongo (Brazzaville)',
        'Costa_Rica': 'Costa Rica',
        'Croatia': 'Kroatien',
        'Cuba': 'Kuba',
        'Cyprus': 'Zypern',
        'Czechia': 'Tschechien',
        'Democratic_Republic_of_the_Congo': 'Demokratische Republik Kongo',
        'Denmark': 'Dänemark',
        'Djibouti': 'Dschibuti',
        'Dominica': 'Dominica',
        'Dominican_Republic': 'Dominikanische Republik',
        'Ecuador': 'Ecuador',
        'Egypt': 'Ägypten',
        'El_Salvador': 'El Salvador',
        'Equatorial_Guinea': 'Äquatorialguinea',
        'Eritrea': 'Eritrea',
        'Estonia': 'Estland',
        'Eswatini': 'Eswatini',
        'Ethiopia': 'Äthiopien',
        'Fiji': 'Fidschi',
        'Finland': 'Finnland',
        'France': 'Frankreich',
        'Gabon': 'Gabun',
        'Gambia': 'Gambia',
        'Georgia': 'Georgien',
        'Germany': 'Deutschland',
        'Ghana': 'Ghana',
        'Greece': 'Griechenland',
        'Grenada': 'Grenada',
        'Guatemala': 'Guatemala',
        'Guinea': 'Guinea',
        'Guinea_Bissau': 'Guinea-Bissau',
        'Guyana': 'Guyana',
        'Haiti': 'Haiti',
        'Honduras': 'Honduras',
        'Hungary': 'Ungarn',
        'Iceland': 'Island',
        'India': 'Indien',
        'Indonesia': 'Indonesien',
        'Iran': 'Iran',
        'Iraq': 'Irak',
        'Ireland': 'Irland',
        'Israel': 'Israel',
        'Italy': 'Italien',
        'Jamaica': 'Jamaika',
        'Japan': 'Japan',
        'Jordan': 'Jordanien',
        'Kazakhstan': 'Kasachstan',
        'Kenya': 'Kenia',
        'Kiribati': 'Kiribati',
        'Kuwait': 'Kuwait',
        'Kyrgyzstan': 'Kirgisistan',
        'Laos': 'Laos',
        'Latvia': 'Lettland',
        'Lebanon': 'Libanon',
        'Lesotho': 'Lesotho',
        'Liberia': 'Liberia',
        'Libya': 'Libyen',
        'Liechtenstein': 'Liechtenstein',
        'Lithuania': 'Litauen',
        'Luxembourg': 'Luxemburg',
        'Madagascar': 'Madagaskar',
        'Malawi': 'Malawi',
        'Malaysia': 'Malaysia',
        'Maldives': 'Malediven',
        'Mali': 'Mali',
        'Malta': 'Malta',
        'Marshall_Islands': 'Marshallinseln',
        'Mauritania': 'Mauretanien',
        'Mauritius': 'Mauritius',
        'Mexico': 'Mexiko',
        'Micronesia': 'Mikronesien',
        'Moldova': 'Moldau',
        'Monaco': 'Monaco',
        'Mongolia': 'Mongolei',
        'Montenegro': 'Montenegro',
        'Morocco': 'Marokko',
        'Mozambique': 'Mosambik',
        'Myanmar': 'Myanmar',
        'Namibia': 'Namibia',
        'Nauru': 'Nauru',
        'Nepal': 'Nepal',
        'Netherlands': 'Niederlande',
        'New_Zealand': 'Neuseeland',
        'Nicaragua': 'Nicaragua',
        'Niger': 'Niger',
        'Nigeria': 'Nigeria',
        'North_Korea': 'Nordkorea',
        'North_Macedonia': 'Nordmazedonien',
        'Norway': 'Norwegen',
        'Oman': 'Oman',
        'Pakistan': 'Pakistan',
        'Palau': 'Palau',
        'Panama': 'Panama',
        'Papua_New_Guinea': 'Papua-Neuguinea',
        'Paraguay': 'Paraguay',
        'Peru': 'Peru',
        'Philippines': 'Philippinen',
        'Poland': 'Polen',
        'Portugal': 'Portugal',
        'Qatar': 'Katar',
        'Romania': 'Rumänien',
        'Russia': 'Russland',
        'Rwanda': 'Ruanda',
        'Saint_Kitts_and_Nevis': 'St. Kitts und Nevis',
        'Saint_Lucia': 'St. Lucia',
        'Saint_Vincent_and_the_Grenadines': 'St. Vincent und die Grenadinen',
        'Samoa': 'Samoa',
        'San_Marino': 'San Marino',
        'Sao_Tome_and_Principe': 'São Tomé und Príncipe',
        'Saudi_Arabia': 'Saudi-Arabien',
        'Senegal': 'Senegal',
        'Serbia': 'Serbien',
        'Seychelles': 'Seychellen',
        'Sierra_Leone': 'Sierra Leone',
        'Singapore': 'Singapur',
        'Slovakia': 'Slowakei',
        'Slovenia': 'Slowenien',
        'Solomon_Islands': 'Salomonen',
        'Somalia': 'Somalia',
        'South_Africa': 'Südafrika',
        'South_Korea': 'Südkorea',
        'South_Sudan': 'Südsudan',
        'Spain': 'Spanien',
        'Sri_Lanka': 'Sri Lanka',
        'Sudan': 'Sudan',
        'Suriname': 'Suriname',
        'Sweden': 'Schweden',
        'Switzerland': 'Schweiz',
        'Syria': 'Syrien',
        'Taiwan': 'Taiwan',
        'Tajikistan': 'Tadschikistan',
        'Tanzania': 'Tansania',
        'Thailand': 'Thailand',
        'Timor_Leste': 'Timor-Leste',
        'Togo': 'Togo',
        'Tonga': 'Tonga',
        'Trinidad_and_Tobago': 'Trinidad und Tobago',
        'Tunisia': 'Tunesien',
        'Turkey': 'Türkei',
        'Turkmenistan': 'Turkmenistan',
        'Tuvalu': 'Tuvalu',
        'Uganda': 'Uganda',
        'Ukraine': 'Ukraine',
        'United_Arab_Emirates': 'Vereinigte Arabische Emirate',
        'United_Kingdom': 'Vereinigtes Königreich',
        'United_States': 'Vereinigte Staaten',
        'Uruguay': 'Uruguay',
        'Uzbekistan': 'Usbekistan',
        'Vanuatu': 'Vanuatu',
        'Vatican_City': 'Vatikanstadt',
        'Venezuela': 'Venezuela',
        'Vietnam': 'Vietnam',
        'Yemen': 'Jemen',
        'Zambia': 'Sambia',
        'Zimbabwe': 'Simbabwe',
        'other': 'Wakanda',
      },
    );
    return '$_temp0';
  }

  @override
  String get deleteSaveTitle => 'Speicherung löschen?';

  @override
  String get deleteSaveMessage =>
      'Möchtest du dieses gespeicherte Spiel wirklich löschen?';

  @override
  String get failedToDeleteMessage => 'Löschen fehlgeschlagen';
}
