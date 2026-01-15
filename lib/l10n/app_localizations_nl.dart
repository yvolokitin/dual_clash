// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String appTitle(Object size) {
    return 'Dual Clash';
  }

  @override
  String get commonClose => 'Sluiten';

  @override
  String get commonCancel => 'Annuleren';

  @override
  String get commonSave => 'Opslaan';

  @override
  String get commonConfirm => 'Bevestigen';

  @override
  String get commonYes => 'Ja';

  @override
  String get commonNo => 'Nee';

  @override
  String get deleteLabel => 'Verwijderen';

  @override
  String get playLabel => 'Spelen';

  @override
  String get leaveLabel => 'Verlaten';

  @override
  String get menuTitle => 'Menu';

  @override
  String get mainMenuBarrierLabel => 'Hoofdmenu';

  @override
  String get mainMenuTooltip => 'Hoofdmenu';

  @override
  String get gameMenuTitle => 'Spelmenu';

  @override
  String get returnToMainMenuLabel => 'Terug naar hoofdmenu';

  @override
  String get returnToMainMenuTitle => 'Terug naar hoofdmenu';

  @override
  String get returnToMainMenuMessage =>
      'Wil je terugkeren naar het hoofdmenu?\n\nVoortgang wordt niet opgeslagen.';

  @override
  String get restartGameLabel => 'Spel herstarten/starten';

  @override
  String get restartGameTitle => 'Spel herstarten';

  @override
  String get restartGameMessage =>
      'Het spel helemaal opnieuw starten?\n\nHuidige voortgang gaat verloren.';

  @override
  String get adminModeEnableTitle => 'Beheermodus inschakelen';

  @override
  String get adminModeEnableMessage =>
      'Beheermodus inschakelen op dit apparaat?\n\nSimulatie-opties worden zichtbaar.';

  @override
  String get statisticsTitle => 'Statistieken';

  @override
  String get helpTitle => 'Help';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get settingsMusicLabel => 'Muziek';

  @override
  String get settingsSoundsLabel => 'Geluiden';

  @override
  String get profileTitle => 'Profiel';

  @override
  String get historyTitle => 'Geschiedenis';

  @override
  String get saveGameTitle => 'Spel opslaan';

  @override
  String get saveGameNameLabel => 'Naam voor deze opslag';

  @override
  String get saveGameNameHint => 'Naam invoeren...';

  @override
  String get saveGameBarrierLabel => 'Spel opslaan';

  @override
  String get gameSavedMessage => 'Spel opgeslagen';

  @override
  String get simulateGameLabel => 'Spel simuleren';

  @override
  String get simulateGameHumanWinLabel => 'Spel simuleren (mens wint)';

  @override
  String get simulateGameAiWinLabel => 'Spel simuleren (AI wint)';

  @override
  String get simulateGameGreyWinLabel => 'Spel simuleren (grijs wint)';

  @override
  String get removeAdsLabel => 'Advertenties verwijderen — 1€';

  @override
  String get restorePurchasesLabel => 'Aankopen herstellen';

  @override
  String get menuGameShort => 'Spel';

  @override
  String get menuGameChallenge => 'Speluitdaging';

  @override
  String get menuDuelShort => 'Duel';

  @override
  String get menuDuelMode => 'Duelmodus';

  @override
  String get menuLoadShort => 'Laden';

  @override
  String get menuLoadGame => 'Spel laden';

  @override
  String get menuCampaignShort => 'Camp.';

  @override
  String get menuCampaign => 'Campaign';

  @override
  String get buddhaCampaignTitle => 'Boeddha-campagne';

  @override
  String get buddhaCampaignDescription =>
      'De Boeddha-campagne is een reis van kalmte, controle en strategische helderheid. Elk niveau daagt je uit het bord te lezen, met precisie te handelen en te winnen door balans in plaats van kracht.';

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
  String get menuPlayerHub => 'Spelershub';

  @override
  String get menuTripleShort => 'Triple';

  @override
  String get menuTripleThreat => 'Drievoudige dreiging';

  @override
  String get menuQuadShort => 'Quad';

  @override
  String get menuQuadClash => 'Quad Clash';

  @override
  String get menuAlliance2v2 => 'Alliantie 2-tegen-2';

  @override
  String get menuAlliance2v2Short => 'Alliantie';

  @override
  String get playerHubBarrierLabel => 'Spelershub';

  @override
  String get modesBarrierLabel => 'Modi';

  @override
  String get languageTitle => 'Taal';

  @override
  String get userProfileLabel => 'Gebruikersprofiel';

  @override
  String get gameChallengeLabel => 'Speluitdaging';

  @override
  String get gameChallengeComingSoon => 'Speluitdaging komt binnenkort';

  @override
  String get loadGameBarrierLabel => 'Spel laden';

  @override
  String get noSavedGamesMessage => 'Geen opgeslagen spellen';

  @override
  String get savedGameDefaultName => 'Opgeslagen spel';

  @override
  String savedGameSubtitle(Object when, Object turn) {
    return '$when • Beurt: $turn';
  }

  @override
  String get helpGoalTitle => 'Doel';

  @override
  String helpGoalBody(Object board) {
    return 'Vul het $board-bord door om de beurt met de AI te spelen. Jij bent Rood, de AI is Blauw. De speler met de hoogste TOTALE score wint.';
  }

  @override
  String get helpTurnsTitle => 'Beurten & Plaatsing';

  @override
  String get helpTurnsBody =>
      'Tik op een lege cel om je kleur te plaatsen. Na jouw zet plaatst de AI blauw. De startspeler kan in Instellingen worden gewijzigd.';

  @override
  String get helpScoringTitle => 'Scoren';

  @override
  String get helpScoringBase =>
      'Basisscore: aantal cellen van jouw kleur op het bord wanneer het spel eindigt.';

  @override
  String get helpScoringBonus =>
      'Bonus: +50 punten voor elke volle rij of kolom die met jouw kleur is gevuld.';

  @override
  String get helpScoringTotal => 'Totaalscore: Basisscore + Bonus.';

  @override
  String get helpScoringEarning =>
      'Punten verdienen tijdens het spel (Rood): +1 voor elke plaatsing, +2 extra als je in een hoek plaatst, +2 voor elke Blauwe die naar Neutraal wordt, +3 voor elke Neutrale die naar Rood wordt, +50 voor elke nieuwe volle Rode rij/kolom.';

  @override
  String get helpScoringCumulative =>
      'Je cumulatieve trofeëteller neemt alleen toe. Punten worden na elk beëindigd spel toegevoegd op basis van je Rode totaal. Acties van de tegenstander verlagen je cumulatieve totaal nooit.';

  @override
  String get helpWinningTitle => 'Winnen';

  @override
  String get helpWinningBody =>
      'Wanneer het bord geen lege cellen meer heeft, eindigt het spel. De speler met de hoogste totaalscore wint. Gelijkspel is mogelijk.';

  @override
  String get helpAiLevelTitle => 'AI-niveau';

  @override
  String get helpAiLevelBody =>
      'Kies de AI-moeilijkheid in Instellingen (1–7). Hogere niveaus denken verder vooruit maar duren langer.';

  @override
  String get helpHistoryProfileTitle => 'Geschiedenis & Profiel';

  @override
  String get helpHistoryProfileBody =>
      'Je voltooide spellen worden in Geschiedenis opgeslagen met alle details.';

  @override
  String get aiDifficultyTitle => 'AI-moeilijkheid';

  @override
  String get aiDifficultyTipBeginner =>
      'Wit — Beginner: maakt willekeurige zetten.';

  @override
  String get aiDifficultyTipEasy =>
      'Geel — Makkelijk: geeft de voorkeur aan directe winst.';

  @override
  String get aiDifficultyTipNormal =>
      'Oranje — Normaal: gretig met basispositionering.';

  @override
  String get aiDifficultyTipChallenging =>
      'Groen — Uitdagend: ondiepe zoekdiepte met wat vooruitblik.';

  @override
  String get aiDifficultyTipHard =>
      'Blauw — Moeilijk: diepere zoekactie met snoeien.';

  @override
  String get aiDifficultyTipExpert =>
      'Bruin — Expert: geavanceerd snoeien en caching.';

  @override
  String get aiDifficultyTipMaster =>
      'Zwart — Meester: sterkst en meest berekenend.';

  @override
  String get aiDifficultyTipSelect => 'Selecteer een bandniveau.';

  @override
  String get aiDifficultyDetailBeginner =>
      'Wit — Beginner: willekeurige lege cellen. Onvoorspelbaar maar zwak.';

  @override
  String get aiDifficultyDetailEasy =>
      'Geel — Makkelijk: gretig kiest zetten die directe winst maximaliseren.';

  @override
  String get aiDifficultyDetailNormal =>
      'Oranje — Normaal: gretig met tie-break voor het centrum om sterkere posities te prefereren.';

  @override
  String get aiDifficultyDetailChallenging =>
      'Groen — Uitdagend: ondiepe minimax-zoekopdracht (diepte 2), geen snoeien.';

  @override
  String get aiDifficultyDetailHard =>
      'Blauw — Moeilijk: diepere minimax met alpha–beta-snoeien en zetvolgorde.';

  @override
  String get aiDifficultyDetailExpert =>
      'Bruin — Expert: diepere minimax met snoeien + transpositietabel.';

  @override
  String get aiDifficultyDetailMaster =>
      'Zwart — Meester: Monte Carlo Tree Search (~1500 rollouts binnen tijdslimiet).';

  @override
  String get aiDifficultyDetailSelect =>
      'Selecteer AI-moeilijkheid om details te zien.';

  @override
  String get currentAiLevelLabel => 'Huidig AI-niveau';

  @override
  String aiLevelDisplay(Object belt, Object level) {
    return '$belt ($level)';
  }

  @override
  String get resultsTitle => 'Resultaten';

  @override
  String get timePlayedLabel => 'Speeltijd';

  @override
  String get redTurnsLabel => 'Rode beurten';

  @override
  String get blueTurnsLabel => 'Blauwe beurten';

  @override
  String get yellowTurnsLabel => 'Gele beurten';

  @override
  String get greenTurnsLabel => 'Groene beurten';

  @override
  String get playerTurnsLabel => 'Spelerbeurten';

  @override
  String get aiTurnsLabel => 'AI-beurten';

  @override
  String playerTurnStatus(Object player) {
    return '$player player turn';
  }

  @override
  String get newBestScoreLabel => 'Nieuwe beste score';

  @override
  String pointsBelowBestScore(Object points) {
    return '$points punten onder beste score';
  }

  @override
  String youWinReachedScore(Object score) {
    return 'Je wint en behaalde $score punten';
  }

  @override
  String get redTerritoryControlled => 'Rood gebied gecontroleerd.';

  @override
  String get blueTerritoryControlled => 'Blauw gebied gecontroleerd.';

  @override
  String get neutralTerritoryControlled => 'Neutraal gebied gecontroleerd.';

  @override
  String get territoryBalanced => 'Gebied in balans.';

  @override
  String get performanceLost => 'Je hebt verloren. Strategie vereist.';

  @override
  String get performanceBrilliantEndgame => 'Briljante eindfase';

  @override
  String get performanceGreatControl => 'Geweldige controle';

  @override
  String get performanceRiskyEffective => 'Riskant, maar effectief';

  @override
  String get performanceSolidStrategy => 'Solide strategie';

  @override
  String get playAgainLabel => 'Opnieuw spelen';

  @override
  String get continueNextAiLevelLabel => 'Ga door naar volgend AI-niveau';

  @override
  String get playLowerAiLevelLabel => 'Speel een lager AI-niveau';

  @override
  String get replaySameLevelLabel => 'Speel hetzelfde niveau opnieuw';

  @override
  String get aiThinkingLabel => 'AI denkt...';

  @override
  String get simulatingGameLabel => 'Spel simuleren...';

  @override
  String get noTurnsYetMessage => 'Nog geen beurten voor dit spel';

  @override
  String turnLabel(Object turn) {
    return 'Beurt $turn';
  }

  @override
  String get undoLastActionTooltip => 'Laatste actie ongedaan maken';

  @override
  String get historyTabGames => 'Spellen';

  @override
  String get historyTabDailyActivity => 'Dagelijkse activiteit';

  @override
  String get noFinishedGamesYet => 'Nog geen voltooide spellen';

  @override
  String gamesCountLabel(Object count) {
    return 'Spellen: $count';
  }

  @override
  String get winsLabel => 'Overwinningen';

  @override
  String get lossesLabel => 'Nederlagen';

  @override
  String get drawsLabel => 'Gelijkspelen';

  @override
  String get totalTimeLabel => 'Totale tijd';

  @override
  String get resultDraw => 'Gelijkspel';

  @override
  String get resultPlayerWins => 'Speler wint';

  @override
  String get resultAiWins => 'AI wint';

  @override
  String aiLabelWithName(Object name) {
    return 'AI: $name';
  }

  @override
  String winnerLabel(Object result) {
    return 'Winnaar: $result';
  }

  @override
  String get yourScoreLabel => 'Jouw score';

  @override
  String get timeLabel => 'Tijd';

  @override
  String get redBaseLabel => 'Rode basis';

  @override
  String get blueBaseLabel => 'Blauwe basis';

  @override
  String get totalBlueLabel => 'Totaal B';

  @override
  String get turnsRedLabel => 'Beurten R';

  @override
  String get turnsBlueLabel => 'Beurten B';

  @override
  String get ageLabel => 'Leeftijd';

  @override
  String get nicknameLabel => 'Bijnaam';

  @override
  String get enterNicknameHint => 'Bijnaam invoeren';

  @override
  String get countryLabel => 'Land';

  @override
  String get beltsTitle => 'Banden';

  @override
  String get achievementsTitle => 'Prestaties';

  @override
  String get achievementFullRow => 'Volle rij';

  @override
  String get achievementFullColumn => 'Volle kolom';

  @override
  String get achievementDiagonal => 'Diagonaal';

  @override
  String get achievement100GamePoints => '100 spelpunten';

  @override
  String get achievement1000GamePoints => '1000 spelpunten';

  @override
  String get nicknameRequiredError => 'Bijnaam is verplicht';

  @override
  String get nicknameMaxLengthError => 'Maximaal 32 tekens toegestaan';

  @override
  String get nicknameInvalidCharsError =>
      'Gebruik letters, cijfers, punt, streepje of underscore';

  @override
  String get nicknameUpdatedMessage => 'Bijnaam bijgewerkt';

  @override
  String get noBeltsEarnedYetMessage => 'Nog geen banden verdiend.';

  @override
  String get whoStartsFirstLabel => 'Wie begint';

  @override
  String get whoStartsFirstTip =>
      'If no turns have been made, changes apply immediately; otherwise they take effect in the next game.';

  @override
  String get startingPlayerHuman => 'Mens (Rood)';

  @override
  String get startingPlayerAi => 'AI (Blauw)';

  @override
  String get leaveDuelBarrierLabel => 'Duel verlaten';

  @override
  String get leaveDuelTitle => 'Duel verlaten';

  @override
  String get leaveDuelMessage =>
      'Duelmodus verlaten en terugkeren naar het hoofdmenu?\n\nVoortgang wordt niet opgeslagen.';

  @override
  String get leaveBarrierLabel => 'Verlaten';

  @override
  String leaveModeTitle(Object mode) {
    return 'Verlaat $mode';
  }

  @override
  String get leaveMultiModeMessage =>
      'Terug naar het hoofdmenu?\n\nVoortgang wordt niet opgeslagen.';

  @override
  String get colorRedLabel => 'ROOD';

  @override
  String get colorBlueLabel => 'BLAUW';

  @override
  String get colorYellowLabel => 'GEEL';

  @override
  String get colorGreenLabel => 'GROEN';

  @override
  String get redShortLabel => 'R';

  @override
  String get blueShortLabel => 'B';

  @override
  String get yellowShortLabel => 'Ge';

  @override
  String get greenShortLabel => 'Gr';

  @override
  String get supportTheDevLabel => 'Steun de ontwikkelaar';

  @override
  String get aiBeltWhite => 'Wit';

  @override
  String get aiBeltYellow => 'Geel';

  @override
  String get aiBeltOrange => 'Oranje';

  @override
  String get aiBeltGreen => 'Groen';

  @override
  String get aiBeltBlue => 'Blauw';

  @override
  String get aiBeltBrown => 'Bruin';

  @override
  String get aiBeltBlack => 'Zwart';

  @override
  String get scorePlace => '+1 plaatsing';

  @override
  String get scoreCorner => '+2 hoek';

  @override
  String scoreBlueToGrey(Object count) {
    return '+2 x$count blauw→grijs';
  }

  @override
  String scoreGreyToRed(Object count) {
    return '+3 x$count grijs→rood';
  }

  @override
  String get scorePlaceShort => 'Plaats';

  @override
  String get scoreZeroBlow => '0 klap';

  @override
  String get scoreZeroGreyDrop => '0 grijze val';

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
    return '${hours}u ${minutes}m';
  }

  @override
  String countryName(String country) {
    String _temp0 = intl.Intl.selectLogic(
      country,
      {
        'Afghanistan': 'Afghanistan',
        'Albania': 'Albanië',
        'Algeria': 'Algerije',
        'Andorra': 'Andorra',
        'Angola': 'Angola',
        'Antigua_and_Barbuda': 'Antigua en Barbuda',
        'Argentina': 'Argentinië',
        'Armenia': 'Armenië',
        'Australia': 'Australië',
        'Austria': 'Oostenrijk',
        'Azerbaijan': 'Azerbeidzjan',
        'Bahamas': 'Bahama\'s',
        'Bahrain': 'Bahrein',
        'Bangladesh': 'Bangladesh',
        'Barbados': 'Barbados',
        'Belarus': 'Belarus',
        'Belgium': 'België',
        'Belize': 'Belize',
        'Benin': 'Benin',
        'Bhutan': 'Bhutan',
        'Bolivia': 'Bolivia',
        'Bosnia_and_Herzegovina': 'Bosnië en Herzegovina',
        'Botswana': 'Botswana',
        'Brazil': 'Brazilië',
        'Brunei': 'Brunei',
        'Bulgaria': 'Bulgarije',
        'Burkina_Faso': 'Burkina Faso',
        'Burundi': 'Burundi',
        'Cabo_Verde': 'Cabo Verde',
        'Cambodia': 'Cambodja',
        'Cameroon': 'Kameroen',
        'Canada': 'Canada',
        'Central_African_Republic': 'Centraal-Afrikaanse Republiek',
        'Chad': 'Tsjaad',
        'Chile': 'Chili',
        'China': 'China',
        'Colombia': 'Colombia',
        'Comoros': 'Comoren',
        'Congo_Congo_Brazzaville': 'Congo (Brazzaville)',
        'Costa_Rica': 'Costa Rica',
        'Croatia': 'Kroatië',
        'Cuba': 'Cuba',
        'Cyprus': 'Cyprus',
        'Czechia': 'Tsjechië',
        'Democratic_Republic_of_the_Congo': 'Democratische Republiek Congo',
        'Denmark': 'Denemarken',
        'Djibouti': 'Djibouti',
        'Dominica': 'Dominica',
        'Dominican_Republic': 'Dominicaanse Republiek',
        'Ecuador': 'Ecuador',
        'Egypt': 'Egypte',
        'El_Salvador': 'El Salvador',
        'Equatorial_Guinea': 'Equatoriaal-Guinea',
        'Eritrea': 'Eritrea',
        'Estonia': 'Estland',
        'Eswatini': 'Eswatini',
        'Ethiopia': 'Ethiopië',
        'Fiji': 'Fiji',
        'Finland': 'Finland',
        'France': 'Frankrijk',
        'Gabon': 'Gabon',
        'Gambia': 'Gambia',
        'Georgia': 'Georgië',
        'Germany': 'Duitsland',
        'Ghana': 'Ghana',
        'Greece': 'Griekenland',
        'Grenada': 'Grenada',
        'Guatemala': 'Guatemala',
        'Guinea': 'Guinee',
        'Guinea_Bissau': 'Guinee-Bissau',
        'Guyana': 'Guyana',
        'Haiti': 'Haïti',
        'Honduras': 'Honduras',
        'Hungary': 'Hongarije',
        'Iceland': 'IJsland',
        'India': 'India',
        'Indonesia': 'Indonesië',
        'Iran': 'Iran',
        'Iraq': 'Irak',
        'Ireland': 'Ierland',
        'Israel': 'Israël',
        'Italy': 'Italië',
        'Jamaica': 'Jamaica',
        'Japan': 'Japan',
        'Jordan': 'Jordanië',
        'Kazakhstan': 'Kazachstan',
        'Kenya': 'Kenia',
        'Kiribati': 'Kiribati',
        'Kuwait': 'Koeweit',
        'Kyrgyzstan': 'Kirgizië',
        'Laos': 'Laos',
        'Latvia': 'Letland',
        'Lebanon': 'Libanon',
        'Lesotho': 'Lesotho',
        'Liberia': 'Liberia',
        'Libya': 'Libië',
        'Liechtenstein': 'Liechtenstein',
        'Lithuania': 'Litouwen',
        'Luxembourg': 'Luxemburg',
        'Madagascar': 'Madagaskar',
        'Malawi': 'Malawi',
        'Malaysia': 'Maleisië',
        'Maldives': 'Maldiven',
        'Mali': 'Mali',
        'Malta': 'Malta',
        'Marshall_Islands': 'Marshalleilanden',
        'Mauritania': 'Mauritanië',
        'Mauritius': 'Mauritius',
        'Mexico': 'Mexico',
        'Micronesia': 'Micronesië',
        'Moldova': 'Moldavië',
        'Monaco': 'Monaco',
        'Mongolia': 'Mongolië',
        'Montenegro': 'Montenegro',
        'Morocco': 'Marokko',
        'Mozambique': 'Mozambique',
        'Myanmar': 'Myanmar',
        'Namibia': 'Namibië',
        'Nauru': 'Nauru',
        'Nepal': 'Nepal',
        'Netherlands': 'Nederland',
        'New_Zealand': 'Nieuw-Zeeland',
        'Nicaragua': 'Nicaragua',
        'Niger': 'Niger',
        'Nigeria': 'Nigeria',
        'North_Korea': 'Noord-Korea',
        'North_Macedonia': 'Noord-Macedonië',
        'Norway': 'Noorwegen',
        'Oman': 'Oman',
        'Pakistan': 'Pakistan',
        'Palau': 'Palau',
        'Panama': 'Panama',
        'Papua_New_Guinea': 'Papoea-Nieuw-Guinea',
        'Paraguay': 'Paraguay',
        'Peru': 'Peru',
        'Philippines': 'Filipijnen',
        'Poland': 'Polen',
        'Portugal': 'Portugal',
        'Qatar': 'Qatar',
        'Romania': 'Roemenië',
        'Russia': 'Rusland',
        'Rwanda': 'Rwanda',
        'Saint_Kitts_and_Nevis': 'Saint Kitts en Nevis',
        'Saint_Lucia': 'Saint Lucia',
        'Saint_Vincent_and_the_Grenadines': 'Saint Vincent en de Grenadines',
        'Samoa': 'Samoa',
        'San_Marino': 'San Marino',
        'Sao_Tome_and_Principe': 'Sao Tomé en Principe',
        'Saudi_Arabia': 'Saoedi-Arabië',
        'Senegal': 'Senegal',
        'Serbia': 'Servië',
        'Seychelles': 'Seychellen',
        'Sierra_Leone': 'Sierra Leone',
        'Singapore': 'Singapore',
        'Slovakia': 'Slowakije',
        'Slovenia': 'Slovenië',
        'Solomon_Islands': 'Salomonseilanden',
        'Somalia': 'Somalië',
        'South_Africa': 'Zuid-Afrika',
        'South_Korea': 'Zuid-Korea',
        'South_Sudan': 'Zuid-Soedan',
        'Spain': 'Spanje',
        'Sri_Lanka': 'Sri Lanka',
        'Sudan': 'Soedan',
        'Suriname': 'Suriname',
        'Sweden': 'Zweden',
        'Switzerland': 'Zwitserland',
        'Syria': 'Syrië',
        'Taiwan': 'Taiwan',
        'Tajikistan': 'Tadzjikistan',
        'Tanzania': 'Tanzania',
        'Thailand': 'Thailand',
        'Timor_Leste': 'Timor-Leste',
        'Togo': 'Togo',
        'Tonga': 'Tonga',
        'Trinidad_and_Tobago': 'Trinidad en Tobago',
        'Tunisia': 'Tunesië',
        'Turkey': 'Turkije',
        'Turkmenistan': 'Turkmenistan',
        'Tuvalu': 'Tuvalu',
        'Uganda': 'Oeganda',
        'Ukraine': 'Oekraïne',
        'United_Arab_Emirates': 'Verenigde Arabische Emiraten',
        'United_Kingdom': 'Verenigd Koninkrijk',
        'United_States': 'Verenigde Staten',
        'Uruguay': 'Uruguay',
        'Uzbekistan': 'Oezbekistan',
        'Vanuatu': 'Vanuatu',
        'Vatican_City': 'Vaticaanstad',
        'Venezuela': 'Venezuela',
        'Vietnam': 'Vietnam',
        'Yemen': 'Jemen',
        'Zambia': 'Zambia',
        'Zimbabwe': 'Zimbabwe',
        'other': 'Wakanda',
      },
    );
    return '$_temp0';
  }

  @override
  String get deleteSaveTitle => 'Opslag verwijderen?';

  @override
  String get deleteSaveMessage =>
      'Weet je zeker dat je dit opgeslagen spel wilt verwijderen?';

  @override
  String get failedToDeleteMessage => 'Verwijderen mislukt';

  @override
  String get webSaveGameNote =>
      'Web-opmerking: je opslag wordt opgeslagen in de lokale opslag van deze browser voor deze site. Het synchroniseert niet tussen apparaten of privévensters.';

  @override
  String get webLoadGameNote =>
      'Web-opmerking: de onderstaande lijst komt uit de lokale opslag van deze browser voor deze site (niet gedeeld tussen andere browsers of privévensters).';
}
