// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String appTitle(Object size) {
    return 'Dual Clash';
  }

  @override
  String get commonClose => 'Zamknij';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get commonConfirm => 'Potwierdź';

  @override
  String get commonYes => 'Tak';

  @override
  String get commonNo => 'Nie';

  @override
  String get deleteLabel => 'Usuń';

  @override
  String get playLabel => 'Graj';

  @override
  String get leaveLabel => 'Wyjdź';

  @override
  String get menuTitle => 'Menu';

  @override
  String get mainMenuBarrierLabel => 'Menu główne';

  @override
  String get mainMenuTooltip => 'Menu główne';

  @override
  String get gameMenuTitle => 'Menu gry';

  @override
  String get returnToMainMenuLabel => 'Powrót do menu głównego';

  @override
  String get returnToMainMenuTitle => 'Powrót do menu głównego';

  @override
  String get returnToMainMenuMessage =>
      'Czy chcesz wrócić do menu głównego?\n\nPostęp nie zostanie zapisany.';

  @override
  String get restartGameLabel => 'Zrestartuj/rozpocznij grę';

  @override
  String get restartGameTitle => 'Zrestartuj grę';

  @override
  String get restartGameMessage =>
      'Zrestartować grę od początku?\n\nBieżący postęp zostanie utracony.';

  @override
  String get adminModeEnableTitle => 'Włącz tryb administratora';

  @override
  String get adminModeEnableMessage =>
      'Włączyć tryb administratora na tym urządzeniu?\n\nPokażą się opcje symulacji.';

  @override
  String get statisticsTitle => 'Statystyki';

  @override
  String get helpTitle => 'Pomoc';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsMusicLabel => 'Muzyka menu głównego';

  @override
  String get profileTitle => 'Profil';

  @override
  String get historyTitle => 'Historia';

  @override
  String get saveGameTitle => 'Zapisz grę';

  @override
  String get saveGameNameLabel => 'Nazwa zapisu';

  @override
  String get saveGameNameHint => 'Wpisz nazwę...';

  @override
  String get saveGameBarrierLabel => 'Zapis gry';

  @override
  String get gameSavedMessage => 'Gra zapisana';

  @override
  String get simulateGameLabel => 'Symuluj grę';

  @override
  String get simulateGameHumanWinLabel => 'Symuluj grę (wygrana gracza)';

  @override
  String get simulateGameAiWinLabel => 'Symuluj grę (wygrana SI)';

  @override
  String get simulateGameGreyWinLabel => 'Symuluj grę (wygrana szarych)';

  @override
  String get removeAdsLabel => 'Usuń reklamy — 1€';

  @override
  String get restorePurchasesLabel => 'Przywróć zakupy';

  @override
  String get menuGameShort => 'Gra';

  @override
  String get menuGameChallenge => 'Wyzwanie gry';

  @override
  String get menuDuelShort => 'Pojedynek';

  @override
  String get menuDuelMode => 'Tryb pojedynku';

  @override
  String get menuLoadShort => 'Wczytaj';

  @override
  String get menuLoadGame => 'Wczytaj grę';

  @override
  String get menuCampaignShort => 'Camp.';

  @override
  String get menuCampaign => 'Campaign';

  @override
  String get buddhaCampaignTitle => 'Kampania Buddy';

  @override
  String get buddhaCampaignDescription =>
      'Kampania Buddy to podróż spokoju, kontroli i strategicznej jasności. Każdy poziom stawia przed tobą wyzwanie: czytać planszę, działać precyzyjnie i wygrywać dzięki równowadze, a nie sile.';

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
  String get menuPlayerHub => 'Hub gracza';

  @override
  String get menuTripleShort => 'Potrójny';

  @override
  String get menuTripleThreat => 'Potrójne starcie';

  @override
  String get menuQuadShort => 'Czwórka';

  @override
  String get menuQuadClash => 'Czwórny pojedynek';

  @override
  String get menuAlliance2v2 => 'Alliance 2vs2';

  @override
  String get menuAlliance2v2Short => 'Sojusz';

  @override
  String get playerHubBarrierLabel => 'Hub gracza';

  @override
  String get modesBarrierLabel => 'Tryby';

  @override
  String get languageTitle => 'Język';

  @override
  String get userProfileLabel => 'Profil użytkownika';

  @override
  String get gameChallengeLabel => 'Wyzwanie gry';

  @override
  String get gameChallengeComingSoon => 'Wyzwanie gry już wkrótce';

  @override
  String get loadGameBarrierLabel => 'Wczytaj grę';

  @override
  String get noSavedGamesMessage => 'Brak zapisanych gier';

  @override
  String get savedGameDefaultName => 'Zapisana gra';

  @override
  String savedGameSubtitle(Object when, Object turn) {
    return '$when • Tura: $turn';
  }

  @override
  String get helpGoalTitle => 'Cel';

  @override
  String helpGoalBody(Object board) {
    return 'Wypełnij planszę $board, wykonując ruchy na zmianę z SI. Ty jesteś czerwony, SI jest niebieska. Gracz z wyższym ŁĄCZNYM wynikiem wygrywa.';
  }

  @override
  String get helpTurnsTitle => 'Tury i umieszczanie';

  @override
  String get helpTurnsBody =>
      'Dotknij dowolnej pustej komórki, aby umieścić swój kolor. Po twoim ruchu SI umieszcza niebieski. Gracza rozpoczynającego można zmienić w Ustawieniach.';

  @override
  String get helpScoringTitle => 'Punktacja';

  @override
  String get helpScoringBase =>
      'Wynik podstawowy: liczba pól twojego koloru na planszy po zakończeniu gry.';

  @override
  String get helpScoringBonus =>
      'Premia: +50 punktów za każdy pełny wiersz lub kolumnę wypełnioną twoim kolorem.';

  @override
  String get helpScoringTotal => 'Wynik łączny: wynik podstawowy + premia.';

  @override
  String get helpScoringEarning =>
      'Zdobywanie punktów podczas gry (Czerwony): +1 za każde umieszczenie, +2 dodatkowe za narożnik, +2 za każde Niebieskie zmienione na Neutralne, +3 za każde Neutralne zmienione na Czerwone, +50 za każdy nowy pełny czerwony wiersz/kolumnę.';

  @override
  String get helpScoringCumulative =>
      'Twój łączny licznik trofeów tylko rośnie. Punkty są dodawane po każdej zakończonej grze na podstawie twojego łącznego wyniku Czerwonego. Działania przeciwnika nigdy nie zmniejszają twojego łącznego wyniku.';

  @override
  String get helpWinningTitle => 'Zwycięstwo';

  @override
  String get helpWinningBody =>
      'Gdy na planszy nie ma pustych pól, gra się kończy. Gracz z wyższym łącznym wynikiem wygrywa. Remisy są możliwe.';

  @override
  String get helpAiLevelTitle => 'Poziom SI';

  @override
  String get helpAiLevelBody =>
      'Wybierz trudność SI w Ustawieniach (1–7). Wyższe poziomy myślą dalej, ale zajmują więcej czasu.';

  @override
  String get helpHistoryProfileTitle => 'Historia i profil';

  @override
  String get helpHistoryProfileBody =>
      'Twoje zakończone gry są zapisywane w Historii ze wszystkimi szczegółami.';

  @override
  String get aiDifficultyTitle => 'Trudność SI';

  @override
  String get aiDifficultyTipBeginner =>
      'Biały — Początkujący: wykonuje losowe ruchy.';

  @override
  String get aiDifficultyTipEasy =>
      'Żółty — Łatwy: preferuje natychmiastowe zyski.';

  @override
  String get aiDifficultyTipNormal =>
      'Pomarańczowy — Normalny: zachłanny z podstawowym pozycjonowaniem.';

  @override
  String get aiDifficultyTipChallenging =>
      'Zielony — Wymagający: płytkie przeszukiwanie z pewnym wyprzedzeniem.';

  @override
  String get aiDifficultyTipHard =>
      'Niebieski — Trudny: głębsze przeszukiwanie z przycinaniem.';

  @override
  String get aiDifficultyTipExpert =>
      'Brązowy — Ekspert: zaawansowane przycinanie i cache.';

  @override
  String get aiDifficultyTipMaster =>
      'Czarny — Mistrz: najsilniejszy i najbardziej kalkulujący.';

  @override
  String get aiDifficultyTipSelect => 'Wybierz poziom pasa.';

  @override
  String get aiDifficultyDetailBeginner =>
      'Biały — Początkujący: losowe puste pola. Nieprzewidywalny, ale słaby.';

  @override
  String get aiDifficultyDetailEasy =>
      'Żółty — Łatwy: zachłannie wybiera maksymalny natychmiastowy zysk.';

  @override
  String get aiDifficultyDetailNormal =>
      'Pomarańczowy — Normalny: zachłanny z rozstrzyganiem w centrum, by preferować silniejsze pozycje.';

  @override
  String get aiDifficultyDetailChallenging =>
      'Zielony — Wymagający: płytkie przeszukiwanie minimax (głębokość 2), bez przycinania.';

  @override
  String get aiDifficultyDetailHard =>
      'Niebieski — Trudny: głębszy minimax z przycinaniem alfa–beta i porządkowaniem ruchów.';

  @override
  String get aiDifficultyDetailExpert =>
      'Brązowy — Ekspert: głębszy minimax z przycinaniem + tabela transpozycji.';

  @override
  String get aiDifficultyDetailMaster =>
      'Czarny — Mistrz: Monte Carlo Tree Search (~1500 symulacji w limicie czasu).';

  @override
  String get aiDifficultyDetailSelect =>
      'Wybierz trudność SI, aby zobaczyć szczegóły.';

  @override
  String get currentAiLevelLabel => 'Aktualny poziom SI';

  @override
  String aiLevelDisplay(Object belt, Object level) {
    return '$belt ($level)';
  }

  @override
  String get resultsTitle => 'Wyniki';

  @override
  String get timePlayedLabel => 'Czas gry';

  @override
  String get redTurnsLabel => 'Tury czerwone';

  @override
  String get blueTurnsLabel => 'Tury niebieskie';

  @override
  String get yellowTurnsLabel => 'Tury żółte';

  @override
  String get greenTurnsLabel => 'Tury zielone';

  @override
  String get playerTurnsLabel => 'Tury gracza';

  @override
  String get aiTurnsLabel => 'Tury SI';

  @override
  String playerTurnStatus(Object player) {
    return '$player player turn';
  }

  @override
  String get newBestScoreLabel => 'Nowy najlepszy wynik';

  @override
  String pointsBelowBestScore(Object points) {
    return '$points punktów poniżej najlepszego wyniku';
  }

  @override
  String youWinReachedScore(Object score) {
    return 'Wygrywasz i osiągnąłeś $score punktów';
  }

  @override
  String get redTerritoryControlled =>
      'Terytorium gracza czerwonego kontrolowane.';

  @override
  String get blueTerritoryControlled =>
      'Terytorium gracza niebieskiego kontrolowane.';

  @override
  String get neutralTerritoryControlled => 'Terytorium neutralne kontrolowane.';

  @override
  String get territoryBalanced => 'Terytorium zrównoważone.';

  @override
  String get performanceLost => 'Przegrałeś. Potrzebna strategia.';

  @override
  String get performanceBrilliantEndgame => 'Genialny finał';

  @override
  String get performanceGreatControl => 'Świetna kontrola';

  @override
  String get performanceRiskyEffective => 'Ryzykowne, ale skuteczne';

  @override
  String get performanceSolidStrategy => 'Solidna strategia';

  @override
  String get playAgainLabel => 'Zagraj ponownie';

  @override
  String get continueNextAiLevelLabel => 'Kontynuuj na następnym poziomie SI';

  @override
  String get playLowerAiLevelLabel => 'Graj na niższym poziomie SI';

  @override
  String get replaySameLevelLabel => 'Powtórz ten sam poziom';

  @override
  String get aiThinkingLabel => 'SI myśli...';

  @override
  String get simulatingGameLabel => 'Symulacja gry...';

  @override
  String get noTurnsYetMessage => 'Brak tur w tej grze';

  @override
  String turnLabel(Object turn) {
    return 'Tura $turn';
  }

  @override
  String get undoLastActionTooltip => 'Cofnij ostatnią akcję';

  @override
  String get historyTabGames => 'Gry';

  @override
  String get historyTabDailyActivity => 'Aktywność dzienna';

  @override
  String get noFinishedGamesYet => 'Brak zakończonych gier';

  @override
  String gamesCountLabel(Object count) {
    return 'Gry: $count';
  }

  @override
  String get winsLabel => 'Wygrane';

  @override
  String get lossesLabel => 'Przegrane';

  @override
  String get drawsLabel => 'Remisy';

  @override
  String get totalTimeLabel => 'Łączny czas';

  @override
  String get resultDraw => 'Remis';

  @override
  String get resultPlayerWins => 'Wygrana gracza';

  @override
  String get resultAiWins => 'Wygrana SI';

  @override
  String aiLabelWithName(Object name) {
    return 'SI: $name';
  }

  @override
  String winnerLabel(Object result) {
    return 'Zwycięzca: $result';
  }

  @override
  String get yourScoreLabel => 'Twój wynik';

  @override
  String get timeLabel => 'Czas';

  @override
  String get redBaseLabel => 'Czerwony bazowy';

  @override
  String get blueBaseLabel => 'Niebieski bazowy';

  @override
  String get totalBlueLabel => 'Suma N';

  @override
  String get turnsRedLabel => 'Tury C';

  @override
  String get turnsBlueLabel => 'Tury N';

  @override
  String get ageLabel => 'Wiek';

  @override
  String get nicknameLabel => 'Pseudonim';

  @override
  String get enterNicknameHint => 'Wpisz pseudonim';

  @override
  String get countryLabel => 'Kraj';

  @override
  String get beltsTitle => 'Pasy';

  @override
  String get achievementsTitle => 'Osiągnięcia';

  @override
  String get achievementFullRow => 'Pełny wiersz';

  @override
  String get achievementFullColumn => 'Pełna kolumna';

  @override
  String get achievementDiagonal => 'Przekątna';

  @override
  String get achievement100GamePoints => '100 punktów gry';

  @override
  String get achievement1000GamePoints => '1000 punktów gry';

  @override
  String get nicknameRequiredError => 'Pseudonim jest wymagany';

  @override
  String get nicknameMaxLengthError => 'Maksymalnie 32 znaki';

  @override
  String get nicknameInvalidCharsError =>
      'Użyj liter, cyfr, kropki, myślnika lub podkreślenia';

  @override
  String get nicknameUpdatedMessage => 'Pseudonim zaktualizowany';

  @override
  String get noBeltsEarnedYetMessage => 'Brak zdobytych pasów.';

  @override
  String get whoStartsFirstLabel => 'Kto zaczyna';

  @override
  String get whoStartsFirstTip =>
      'If no turns have been made, changes apply immediately; otherwise they take effect in the next game.';

  @override
  String get startingPlayerHuman => 'Człowiek (Czerwony)';

  @override
  String get startingPlayerAi => 'SI (Niebieski)';

  @override
  String get leaveDuelBarrierLabel => 'Opuść pojedynek';

  @override
  String get leaveDuelTitle => 'Opuść pojedynek';

  @override
  String get leaveDuelMessage =>
      'Opuścić tryb pojedynku i wrócić do menu głównego?\n\nPostęp nie zostanie zapisany.';

  @override
  String get leaveBarrierLabel => 'Wyjdź';

  @override
  String leaveModeTitle(Object mode) {
    return 'Opuść $mode';
  }

  @override
  String get leaveMultiModeMessage =>
      'Wrócić do menu głównego?\n\nPostęp nie zostanie zapisany.';

  @override
  String get colorRedLabel => 'CZERWONY';

  @override
  String get colorBlueLabel => 'NIEBIESKI';

  @override
  String get colorYellowLabel => 'ŻÓŁTY';

  @override
  String get colorGreenLabel => 'ZIELONY';

  @override
  String get redShortLabel => 'C';

  @override
  String get blueShortLabel => 'N';

  @override
  String get yellowShortLabel => 'Ż';

  @override
  String get greenShortLabel => 'Z';

  @override
  String get supportTheDevLabel => 'Wesprzyj twórcę';

  @override
  String get aiBeltWhite => 'Biały';

  @override
  String get aiBeltYellow => 'Żółty';

  @override
  String get aiBeltOrange => 'Pomarańczowy';

  @override
  String get aiBeltGreen => 'Zielony';

  @override
  String get aiBeltBlue => 'Niebieski';

  @override
  String get aiBeltBrown => 'Brązowy';

  @override
  String get aiBeltBlack => 'Czarny';

  @override
  String get scorePlace => '+1 pole';

  @override
  String get scoreCorner => '+2 narożnik';

  @override
  String scoreBlueToGrey(Object count) {
    return '+2 x$count niebieski→szary';
  }

  @override
  String scoreGreyToRed(Object count) {
    return '+3 x$count szary→czerwony';
  }

  @override
  String get scorePlaceShort => 'Umieść';

  @override
  String get scoreZeroBlow => '0 cios';

  @override
  String get scoreZeroGreyDrop => '0 szary spadek';

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
        'Afghanistan': 'Afganistan',
        'Albania': 'Albania',
        'Algeria': 'Algieria',
        'Andorra': 'Andora',
        'Angola': 'Angola',
        'Antigua_and_Barbuda': 'Antigua i Barbuda',
        'Argentina': 'Argentyna',
        'Armenia': 'Armenia',
        'Australia': 'Australia',
        'Austria': 'Austria',
        'Azerbaijan': 'Azerbejdżan',
        'Bahamas': 'Bahamy',
        'Bahrain': 'Bahrajn',
        'Bangladesh': 'Bangladesz',
        'Barbados': 'Barbados',
        'Belarus': 'Białoruś',
        'Belgium': 'Belgia',
        'Belize': 'Belize',
        'Benin': 'Benin',
        'Bhutan': 'Bhutan',
        'Bolivia': 'Boliwia',
        'Bosnia_and_Herzegovina': 'Bośnia i Hercegowina',
        'Botswana': 'Botswana',
        'Brazil': 'Brazylia',
        'Brunei': 'Brunei',
        'Bulgaria': 'Bułgaria',
        'Burkina_Faso': 'Burkina Faso',
        'Burundi': 'Burundi',
        'Cabo_Verde': 'Cabo Verde',
        'Cambodia': 'Kambodża',
        'Cameroon': 'Kamerun',
        'Canada': 'Kanada',
        'Central_African_Republic': 'Republika Środkowoafrykańska',
        'Chad': 'Czad',
        'Chile': 'Chile',
        'China': 'Chiny',
        'Colombia': 'Kolumbia',
        'Comoros': 'Komory',
        'Congo_Congo_Brazzaville': 'Kongo (Brazzaville)',
        'Costa_Rica': 'Kostaryka',
        'Croatia': 'Chorwacja',
        'Cuba': 'Kuba',
        'Cyprus': 'Cypr',
        'Czechia': 'Czechy',
        'Democratic_Republic_of_the_Congo': 'Demokratyczna Republika Konga',
        'Denmark': 'Dania',
        'Djibouti': 'Dżibuti',
        'Dominica': 'Dominika',
        'Dominican_Republic': 'Dominikana',
        'Ecuador': 'Ekwador',
        'Egypt': 'Egipt',
        'El_Salvador': 'Salwador',
        'Equatorial_Guinea': 'Gwinea Równikowa',
        'Eritrea': 'Erytrea',
        'Estonia': 'Estonia',
        'Eswatini': 'Eswatini',
        'Ethiopia': 'Etiopia',
        'Fiji': 'Fidżi',
        'Finland': 'Finlandia',
        'France': 'Francja',
        'Gabon': 'Gabon',
        'Gambia': 'Gambia',
        'Georgia': 'Gruzja',
        'Germany': 'Niemcy',
        'Ghana': 'Ghana',
        'Greece': 'Grecja',
        'Grenada': 'Grenada',
        'Guatemala': 'Gwatemala',
        'Guinea': 'Gwinea',
        'Guinea_Bissau': 'Gwinea Bissau',
        'Guyana': 'Gujana',
        'Haiti': 'Haiti',
        'Honduras': 'Honduras',
        'Hungary': 'Węgry',
        'Iceland': 'Islandia',
        'India': 'Indie',
        'Indonesia': 'Indonezja',
        'Iran': 'Iran',
        'Iraq': 'Irak',
        'Ireland': 'Irlandia',
        'Israel': 'Izrael',
        'Italy': 'Włochy',
        'Jamaica': 'Jamajka',
        'Japan': 'Japonia',
        'Jordan': 'Jordania',
        'Kazakhstan': 'Kazachstan',
        'Kenya': 'Kenia',
        'Kiribati': 'Kiribati',
        'Kuwait': 'Kuwejt',
        'Kyrgyzstan': 'Kirgistan',
        'Laos': 'Laos',
        'Latvia': 'Łotwa',
        'Lebanon': 'Liban',
        'Lesotho': 'Lesotho',
        'Liberia': 'Liberia',
        'Libya': 'Libia',
        'Liechtenstein': 'Liechtenstein',
        'Lithuania': 'Litwa',
        'Luxembourg': 'Luksemburg',
        'Madagascar': 'Madagaskar',
        'Malawi': 'Malawi',
        'Malaysia': 'Malezja',
        'Maldives': 'Malediwy',
        'Mali': 'Mali',
        'Malta': 'Malta',
        'Marshall_Islands': 'Wyspy Marshalla',
        'Mauritania': 'Mauretania',
        'Mauritius': 'Mauritius',
        'Mexico': 'Meksyk',
        'Micronesia': 'Mikronezja',
        'Moldova': 'Mołdawia',
        'Monaco': 'Monako',
        'Mongolia': 'Mongolia',
        'Montenegro': 'Czarnogóra',
        'Morocco': 'Maroko',
        'Mozambique': 'Mozambik',
        'Myanmar': 'Mjanma',
        'Namibia': 'Namibia',
        'Nauru': 'Nauru',
        'Nepal': 'Nepal',
        'Netherlands': 'Niderlandy',
        'New_Zealand': 'Nowa Zelandia',
        'Nicaragua': 'Nikaragua',
        'Niger': 'Niger',
        'Nigeria': 'Nigeria',
        'North_Korea': 'Korea Północna',
        'North_Macedonia': 'Macedonia Północna',
        'Norway': 'Norwegia',
        'Oman': 'Oman',
        'Pakistan': 'Pakistan',
        'Palau': 'Palau',
        'Panama': 'Panama',
        'Papua_New_Guinea': 'Papua-Nowa Gwinea',
        'Paraguay': 'Paragwaj',
        'Peru': 'Peru',
        'Philippines': 'Filipiny',
        'Poland': 'Polska',
        'Portugal': 'Portugalia',
        'Qatar': 'Katar',
        'Romania': 'Rumunia',
        'Russia': 'Rosja',
        'Rwanda': 'Rwanda',
        'Saint_Kitts_and_Nevis': 'Saint Kitts i Nevis',
        'Saint_Lucia': 'Saint Lucia',
        'Saint_Vincent_and_the_Grenadines': 'Saint Vincent i Grenadyny',
        'Samoa': 'Samoa',
        'San_Marino': 'San Marino',
        'Sao_Tome_and_Principe': 'Wyspy Świętego Tomasza i Książęca',
        'Saudi_Arabia': 'Arabia Saudyjska',
        'Senegal': 'Senegal',
        'Serbia': 'Serbia',
        'Seychelles': 'Seszele',
        'Sierra_Leone': 'Sierra Leone',
        'Singapore': 'Singapur',
        'Slovakia': 'Słowacja',
        'Slovenia': 'Słowenia',
        'Solomon_Islands': 'Wyspy Salomona',
        'Somalia': 'Somalia',
        'South_Africa': 'Republika Południowej Afryki',
        'South_Korea': 'Korea Południowa',
        'South_Sudan': 'Sudan Południowy',
        'Spain': 'Hiszpania',
        'Sri_Lanka': 'Sri Lanka',
        'Sudan': 'Sudan',
        'Suriname': 'Surinam',
        'Sweden': 'Szwecja',
        'Switzerland': 'Szwajcaria',
        'Syria': 'Syria',
        'Taiwan': 'Tajwan',
        'Tajikistan': 'Tadżykistan',
        'Tanzania': 'Tanzania',
        'Thailand': 'Tajlandia',
        'Timor_Leste': 'Timor Wschodni',
        'Togo': 'Togo',
        'Tonga': 'Tonga',
        'Trinidad_and_Tobago': 'Trynidad i Tobago',
        'Tunisia': 'Tunezja',
        'Turkey': 'Turcja',
        'Turkmenistan': 'Turkmenistan',
        'Tuvalu': 'Tuvalu',
        'Uganda': 'Uganda',
        'Ukraine': 'Ukraina',
        'United_Arab_Emirates': 'Zjednoczone Emiraty Arabskie',
        'United_Kingdom': 'Zjednoczone Królestwo',
        'United_States': 'Stany Zjednoczone',
        'Uruguay': 'Urugwaj',
        'Uzbekistan': 'Uzbekistan',
        'Vanuatu': 'Vanuatu',
        'Vatican_City': 'Watykan',
        'Venezuela': 'Wenezuela',
        'Vietnam': 'Wietnam',
        'Yemen': 'Jemen',
        'Zambia': 'Zambia',
        'Zimbabwe': 'Zimbabwe',
        'other': 'Wakanda',
      },
    );
    return '$_temp0';
  }

  @override
  String get deleteSaveTitle => 'Usunąć zapis?';

  @override
  String get deleteSaveMessage => 'Czy na pewno chcesz usunąć tę zapisaną grę?';

  @override
  String get failedToDeleteMessage => 'Nie udało się usunąć';

  @override
  String get webSaveGameNote =>
      'Uwaga web: twój zapis będzie przechowywany w lokalnej pamięci tej przeglądarki dla tej witryny. Nie synchronizuje się między urządzeniami ani w oknach prywatnych.';

  @override
  String get webLoadGameNote =>
      'Uwaga web: poniższa lista pochodzi z lokalnej pamięci tej przeglądarki dla tej witryny (nie jest współdzielona z innymi przeglądarkami ani oknami prywatnymi).';
}
