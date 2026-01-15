// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String appTitle(Object size) {
    return 'Dual Clash';
  }

  @override
  String get commonClose => 'Закрити';

  @override
  String get commonCancel => 'Скасувати';

  @override
  String get commonSave => 'Зберегти';

  @override
  String get commonConfirm => 'Підтвердити';

  @override
  String get commonYes => 'Так';

  @override
  String get commonNo => 'Ні';

  @override
  String get deleteLabel => 'Видалити';

  @override
  String get playLabel => 'Грати';

  @override
  String get leaveLabel => 'Вийти';

  @override
  String get menuTitle => 'Меню';

  @override
  String get mainMenuBarrierLabel => 'Головне меню';

  @override
  String get mainMenuTooltip => 'Головне меню';

  @override
  String get gameMenuTitle => 'Ігрове меню';

  @override
  String get returnToMainMenuLabel => 'Повернутися до головного меню';

  @override
  String get returnToMainMenuTitle => 'Повернутися до головного меню';

  @override
  String get returnToMainMenuMessage =>
      'Повернутися до головного меню?\n\nПрогрес не буде збережено.';

  @override
  String get restartGameLabel => 'Перезапустити/почати гру';

  @override
  String get restartGameTitle => 'Перезапустити гру';

  @override
  String get restartGameMessage =>
      'Перезапустити гру з нуля?\n\nПоточний прогрес буде втрачено.';

  @override
  String get adminModeEnableTitle => 'Увімкнути режим адміністратора';

  @override
  String get adminModeEnableMessage =>
      'Увімкнути режим адміністратора на цьому пристрої?\n\nЗ\'являться пункти симуляції.';

  @override
  String get statisticsTitle => 'Статистика';

  @override
  String get helpTitle => 'Допомога';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsMusicLabel => 'Музика';

  @override
  String get settingsSoundsLabel => 'Звуки';

  @override
  String get profileTitle => 'Профіль';

  @override
  String get historyTitle => 'Історія';

  @override
  String get saveGameTitle => 'Зберегти гру';

  @override
  String get saveGameNameLabel => 'Назва збереження';

  @override
  String get saveGameNameHint => 'Введіть назву...';

  @override
  String get saveGameBarrierLabel => 'Збереження гри';

  @override
  String get gameSavedMessage => 'Гру збережено';

  @override
  String get simulateGameLabel => 'Симуляція гри';

  @override
  String get simulateGameHumanWinLabel => 'Симуляція гри (перемога людини)';

  @override
  String get simulateGameAiWinLabel => 'Симуляція гри (перемога ШІ)';

  @override
  String get simulateGameGreyWinLabel => 'Симуляція гри (перемога сірих)';

  @override
  String get removeAdsLabel => 'Прибрати рекламу — 1€';

  @override
  String get restorePurchasesLabel => 'Відновити покупки';

  @override
  String get menuGameShort => 'Гра';

  @override
  String get menuGameChallenge => 'Ігровий виклик';

  @override
  String get menuDuelShort => 'Дуель';

  @override
  String get menuDuelMode => 'Режим дуелі';

  @override
  String get menuLoadShort => 'Завантажити';

  @override
  String get menuLoadGame => 'Завантажити гру';

  @override
  String get menuCampaignShort => 'Camp.';

  @override
  String get menuCampaign => 'Campaign';

  @override
  String get buddhaCampaignTitle => 'Кампанія Будди';

  @override
  String get buddhaCampaignDescription =>
      'Кампанія Будди — це шлях спокою, контролю та стратегічної ясності. Кожен рівень кидає виклик: читати поле, діяти з точністю та перемагати завдяки балансу, а не силі.';

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
  String get menuHubShort => 'Хаб';

  @override
  String get menuPlayerHub => 'Хаб гравця';

  @override
  String get menuTripleShort => 'Трійна';

  @override
  String get menuTripleThreat => 'Потрійна загроза';

  @override
  String get menuQuadShort => 'Квад';

  @override
  String get menuQuadClash => 'Квадро-сутичка';

  @override
  String get menuAlliance2v2 => 'Alliance 2vs2';

  @override
  String get menuAlliance2v2Short => 'Альянс';

  @override
  String get playerHubBarrierLabel => 'Хаб гравця';

  @override
  String get modesBarrierLabel => 'Режими';

  @override
  String get languageTitle => 'Мова';

  @override
  String get userProfileLabel => 'Профіль користувача';

  @override
  String get gameChallengeLabel => 'Ігровий виклик';

  @override
  String get gameChallengeComingSoon => 'Ігровий виклик скоро з\'явиться';

  @override
  String get loadGameBarrierLabel => 'Завантаження гри';

  @override
  String get noSavedGamesMessage => 'Немає збережених ігор';

  @override
  String get savedGameDefaultName => 'Збережена гра';

  @override
  String savedGameSubtitle(Object when, Object turn) {
    return '$when • Хід: $turn';
  }

  @override
  String get helpGoalTitle => 'Мета';

  @override
  String helpGoalBody(Object board) {
    return 'Заповніть поле $board, ходячи по черзі з ШІ. Ви — Червоний, ШІ — Синій. Перемагає гравець із більшим ЗАГАЛЬНИМ рахунком.';
  }

  @override
  String get helpTurnsTitle => 'Ходи та розміщення';

  @override
  String get helpTurnsBody =>
      'Торкніться будь-якої порожньої клітинки, щоб поставити свій колір. Після вашого ходу ШІ ставить синій. Початкового гравця можна змінити в Налаштуваннях.';

  @override
  String get helpScoringTitle => 'Нарахування очок';

  @override
  String get helpScoringBase =>
      'Базові очки: кількість клітинок вашого кольору на полі, коли гра закінчується.';

  @override
  String get helpScoringBonus =>
      'Бонус: +50 очок за кожен повний рядок або стовпчик, заповнений вашим кольором.';

  @override
  String get helpScoringTotal => 'Загальний рахунок: базові очки + бонус.';

  @override
  String get helpScoringEarning =>
      'Нарахування очок під час гри (Червоний): +1 за кожне розміщення, +2 додатково за кут, +2 за кожну синю, що стала нейтральною, +3 за кожну нейтральну, що стала червоною, +50 за кожен новий повний червоний рядок/стовпчик.';

  @override
  String get helpScoringCumulative =>
      'Ваш сумарний лічильник трофеїв лише зростає. Очки додаються після кожної завершеної гри на основі вашого червоного загального рахунку. Дії суперника ніколи не зменшують ваш сумарний результат.';

  @override
  String get helpWinningTitle => 'Перемога';

  @override
  String get helpWinningBody =>
      'Коли на полі не залишиться порожніх клітинок, гра закінчується. Перемагає гравець із більшим загальним рахунком. Можлива нічия.';

  @override
  String get helpAiLevelTitle => 'Рівень ШІ';

  @override
  String get helpAiLevelBody =>
      'Виберіть складність ШІ в Налаштуваннях (1–7). Вищі рівні думають наперед, але роблять ходи довше.';

  @override
  String get helpHistoryProfileTitle => 'Історія та профіль';

  @override
  String get helpHistoryProfileBody =>
      'Ваші завершені ігри зберігаються в Історії з усіма деталями.';

  @override
  String get aiDifficultyTitle => 'Складність ШІ';

  @override
  String get aiDifficultyTipBeginner =>
      'Білий — Початківець: робить випадкові ходи.';

  @override
  String get aiDifficultyTipEasy =>
      'Жовтий — Легкий: віддає перевагу миттєвим виграшам.';

  @override
  String get aiDifficultyTipNormal =>
      'Помаранчевий — Нормальний: жадібний із базовим позиціюванням.';

  @override
  String get aiDifficultyTipChallenging =>
      'Зелений — Складний: поверхневий пошук із передбаченням.';

  @override
  String get aiDifficultyTipHard =>
      'Синій — Важкий: глибший пошук із відсіканням.';

  @override
  String get aiDifficultyTipExpert =>
      'Коричневий — Експерт: просунуте відсікання та кешування.';

  @override
  String get aiDifficultyTipMaster =>
      'Чорний — Майстер: найсильніший і найрозважливіший.';

  @override
  String get aiDifficultyTipSelect => 'Оберіть рівень поясу.';

  @override
  String get aiDifficultyDetailBeginner =>
      'Білий — Початківець: випадкові порожні клітинки. Непередбачуваний, але слабкий.';

  @override
  String get aiDifficultyDetailEasy =>
      'Жовтий — Легкий: жадібно обирає ходи, що максимізують миттєву вигоду.';

  @override
  String get aiDifficultyDetailNormal =>
      'Помаранчевий — Нормальний: жадібний з перевагою центру для кращих позицій.';

  @override
  String get aiDifficultyDetailChallenging =>
      'Зелений — Складний: поверхневий мінімакс (глибина 2) без відсікання.';

  @override
  String get aiDifficultyDetailHard =>
      'Синій — Важкий: глибший мінімакс із альфа–бета відсіканням та впорядкуванням ходів.';

  @override
  String get aiDifficultyDetailExpert =>
      'Коричневий — Експерт: глибший мінімакс із відсіканням + таблицею транспозицій.';

  @override
  String get aiDifficultyDetailMaster =>
      'Чорний — Майстер: пошук дерева Монте-Карло (~1500 симуляцій в межах ліміту часу).';

  @override
  String get aiDifficultyDetailSelect =>
      'Оберіть складність ШІ, щоб побачити деталі.';

  @override
  String get currentAiLevelLabel => 'Поточний рівень ШІ';

  @override
  String aiLevelDisplay(Object belt, Object level) {
    return '$belt ($level)';
  }

  @override
  String get resultsTitle => 'Результати';

  @override
  String get timePlayedLabel => 'Час гри';

  @override
  String get redTurnsLabel => 'Червоні ходи';

  @override
  String get blueTurnsLabel => 'Сині ходи';

  @override
  String get yellowTurnsLabel => 'Жовті ходи';

  @override
  String get greenTurnsLabel => 'Зелені ходи';

  @override
  String get playerTurnsLabel => 'Ходи гравця';

  @override
  String get aiTurnsLabel => 'Ходи ШІ';

  @override
  String playerTurnStatus(Object player) {
    return '$player player turn';
  }

  @override
  String get newBestScoreLabel => 'Новий найкращий рахунок';

  @override
  String pointsBelowBestScore(Object points) {
    return '$points очок до найкращого';
  }

  @override
  String youWinReachedScore(Object score) {
    return 'Ви виграли та набрали $score очок';
  }

  @override
  String get redTerritoryControlled => 'Контроль території Червоного гравця.';

  @override
  String get blueTerritoryControlled => 'Контроль території Синього гравця.';

  @override
  String get neutralTerritoryControlled => 'Контроль нейтральної території.';

  @override
  String get territoryBalanced => 'Території збалансовані.';

  @override
  String get performanceLost => 'Ви програли. Потрібна стратегія.';

  @override
  String get performanceBrilliantEndgame => 'Блискучий ендшпіль';

  @override
  String get performanceGreatControl => 'Чудовий контроль';

  @override
  String get performanceRiskyEffective => 'Ризиковано, але ефективно';

  @override
  String get performanceSolidStrategy => 'Надійна стратегія';

  @override
  String get playAgainLabel => 'Грати знову';

  @override
  String get continueNextAiLevelLabel => 'Продовжити на наступному рівні ШІ';

  @override
  String get playLowerAiLevelLabel => 'Грати на нижчому рівні ШІ';

  @override
  String get replaySameLevelLabel => 'Переграти той самий рівень';

  @override
  String get aiThinkingLabel => 'ШІ думає...';

  @override
  String get simulatingGameLabel => 'Симуляція гри...';

  @override
  String get noTurnsYetMessage => 'Ще немає ходів для цієї гри';

  @override
  String turnLabel(Object turn) {
    return 'Хід $turn';
  }

  @override
  String get undoLastActionTooltip => 'Скасувати останню дію';

  @override
  String get historyTabGames => 'Ігри';

  @override
  String get historyTabDailyActivity => 'Щоденна активність';

  @override
  String get noFinishedGamesYet => 'Ще немає завершених ігор';

  @override
  String gamesCountLabel(Object count) {
    return 'Ігор: $count';
  }

  @override
  String get winsLabel => 'Перемоги';

  @override
  String get lossesLabel => 'Поразки';

  @override
  String get drawsLabel => 'Нічиї';

  @override
  String get totalTimeLabel => 'Загальний час';

  @override
  String get resultDraw => 'Нічия';

  @override
  String get resultPlayerWins => 'Перемога гравця';

  @override
  String get resultAiWins => 'Перемога ШІ';

  @override
  String aiLabelWithName(Object name) {
    return 'ШІ: $name';
  }

  @override
  String winnerLabel(Object result) {
    return 'Переможець: $result';
  }

  @override
  String get yourScoreLabel => 'Ваш рахунок';

  @override
  String get timeLabel => 'Час';

  @override
  String get redBaseLabel => 'Червона база';

  @override
  String get blueBaseLabel => 'Синя база';

  @override
  String get totalBlueLabel => 'Всього С';

  @override
  String get turnsRedLabel => 'Ходи Ч';

  @override
  String get turnsBlueLabel => 'Ходи С';

  @override
  String get ageLabel => 'Вік';

  @override
  String get nicknameLabel => 'Нікнейм';

  @override
  String get enterNicknameHint => 'Введіть нікнейм';

  @override
  String get countryLabel => 'Країна';

  @override
  String get beltsTitle => 'Пояси';

  @override
  String get achievementsTitle => 'Досягнення';

  @override
  String get achievementFullRow => 'Повний рядок';

  @override
  String get achievementFullColumn => 'Повний стовпчик';

  @override
  String get achievementDiagonal => 'Діагональ';

  @override
  String get achievement100GamePoints => '100 очок гри';

  @override
  String get achievement1000GamePoints => '1000 очок гри';

  @override
  String get nicknameRequiredError => 'Потрібен нікнейм';

  @override
  String get nicknameMaxLengthError => 'Максимум 32 символи';

  @override
  String get nicknameInvalidCharsError =>
      'Використовуйте літери, цифри, крапку, дефіс або підкреслення';

  @override
  String get nicknameUpdatedMessage => 'Нікнейм оновлено';

  @override
  String get noBeltsEarnedYetMessage => 'Ще немає здобутих поясів.';

  @override
  String get whoStartsFirstLabel => 'Хто починає';

  @override
  String get whoStartsFirstTip =>
      'If no turns have been made, changes apply immediately; otherwise they take effect in the next game.';

  @override
  String get startingPlayerHuman => 'Людина (Червоний)';

  @override
  String get startingPlayerAi => 'ШІ (Синій)';

  @override
  String get leaveDuelBarrierLabel => 'Вийти з дуелі';

  @override
  String get leaveDuelTitle => 'Вийти з дуелі';

  @override
  String get leaveDuelMessage =>
      'Вийти з режиму дуелі і повернутися до головного меню?\n\nПрогрес не буде збережено.';

  @override
  String get leaveBarrierLabel => 'Вийти';

  @override
  String leaveModeTitle(Object mode) {
    return 'Вийти з $mode';
  }

  @override
  String get leaveMultiModeMessage =>
      'Повернутися до головного меню?\n\nПрогрес не буде збережено.';

  @override
  String get colorRedLabel => 'ЧЕРВОНИЙ';

  @override
  String get colorBlueLabel => 'СИНІЙ';

  @override
  String get colorYellowLabel => 'ЖОВТИЙ';

  @override
  String get colorGreenLabel => 'ЗЕЛЕНИЙ';

  @override
  String get redShortLabel => 'Ч';

  @override
  String get blueShortLabel => 'С';

  @override
  String get yellowShortLabel => 'Ж';

  @override
  String get greenShortLabel => 'З';

  @override
  String get supportTheDevLabel => 'Підтримати розробника';

  @override
  String get aiBeltWhite => 'Білий';

  @override
  String get aiBeltYellow => 'Жовтий';

  @override
  String get aiBeltOrange => 'Помаранчевий';

  @override
  String get aiBeltGreen => 'Зелений';

  @override
  String get aiBeltBlue => 'Синій';

  @override
  String get aiBeltBrown => 'Коричневий';

  @override
  String get aiBeltBlack => 'Чорний';

  @override
  String get scorePlace => '+1 розміщення';

  @override
  String get scoreCorner => '+2 кут';

  @override
  String scoreBlueToGrey(Object count) {
    return '+2 x$count синій→сірий';
  }

  @override
  String scoreGreyToRed(Object count) {
    return '+3 x$count сірий→червоний';
  }

  @override
  String get scorePlaceShort => 'Розміщення';

  @override
  String get scoreZeroBlow => '0 ударів';

  @override
  String get scoreZeroGreyDrop => '0 сірих падінь';

  @override
  String durationSeconds(Object seconds) {
    return '$secondsс';
  }

  @override
  String durationMinutesSeconds(Object minutes, Object seconds) {
    return '$minutesхв $secondsс';
  }

  @override
  String durationHoursMinutes(Object hours, Object minutes) {
    return '$hoursгод $minutesхв';
  }

  @override
  String countryName(String country) {
    String _temp0 = intl.Intl.selectLogic(
      country,
      {
        'Afghanistan': 'Афганістан',
        'Albania': 'Албанія',
        'Algeria': 'Алжир',
        'Andorra': 'Андорра',
        'Angola': 'Ангола',
        'Antigua_and_Barbuda': 'Антигуа і Барбуда',
        'Argentina': 'Аргентина',
        'Armenia': 'Вірменія',
        'Australia': 'Австралія',
        'Austria': 'Австрія',
        'Azerbaijan': 'Азербайджан',
        'Bahamas': 'Багами',
        'Bahrain': 'Бахрейн',
        'Bangladesh': 'Бангладеш',
        'Barbados': 'Барбадос',
        'Belarus': 'Білорусь',
        'Belgium': 'Бельгія',
        'Belize': 'Беліз',
        'Benin': 'Бенін',
        'Bhutan': 'Бутан',
        'Bolivia': 'Болівія',
        'Bosnia_and_Herzegovina': 'Боснія і Герцеговина',
        'Botswana': 'Ботсвана',
        'Brazil': 'Бразилія',
        'Brunei': 'Бруней',
        'Bulgaria': 'Болгарія',
        'Burkina_Faso': 'Буркіна-Фасо',
        'Burundi': 'Бурунді',
        'Cabo_Verde': 'Кабо-Верде',
        'Cambodia': 'Камбоджа',
        'Cameroon': 'Камерун',
        'Canada': 'Канада',
        'Central_African_Republic': 'Центральноафриканська Республіка',
        'Chad': 'Чад',
        'Chile': 'Чилі',
        'China': 'Китай',
        'Colombia': 'Колумбія',
        'Comoros': 'Комори',
        'Congo_Congo_Brazzaville': 'Конго (Браззавіль)',
        'Costa_Rica': 'Коста-Рика',
        'Croatia': 'Хорватія',
        'Cuba': 'Куба',
        'Cyprus': 'Кіпр',
        'Czechia': 'Чехія',
        'Democratic_Republic_of_the_Congo': 'Демократична Республіка Конго',
        'Denmark': 'Данія',
        'Djibouti': 'Джибуті',
        'Dominica': 'Домініка',
        'Dominican_Republic': 'Домініканська Республіка',
        'Ecuador': 'Еквадор',
        'Egypt': 'Єгипет',
        'El_Salvador': 'Сальвадор',
        'Equatorial_Guinea': 'Екваторіальна Гвінея',
        'Eritrea': 'Еритрея',
        'Estonia': 'Естонія',
        'Eswatini': 'Есватіні',
        'Ethiopia': 'Ефіопія',
        'Fiji': 'Фіджі',
        'Finland': 'Фінляндія',
        'France': 'Франція',
        'Gabon': 'Габон',
        'Gambia': 'Гамбія',
        'Georgia': 'Грузія',
        'Germany': 'Німеччина',
        'Ghana': 'Гана',
        'Greece': 'Греція',
        'Grenada': 'Гренада',
        'Guatemala': 'Гватемала',
        'Guinea': 'Гвінея',
        'Guinea_Bissau': 'Гвінея-Бісау',
        'Guyana': 'Гаяна',
        'Haiti': 'Гаїті',
        'Honduras': 'Гондурас',
        'Hungary': 'Угорщина',
        'Iceland': 'Ісландія',
        'India': 'Індія',
        'Indonesia': 'Індонезія',
        'Iran': 'Іран',
        'Iraq': 'Ірак',
        'Ireland': 'Ірландія',
        'Israel': 'Ізраїль',
        'Italy': 'Італія',
        'Jamaica': 'Ямайка',
        'Japan': 'Японія',
        'Jordan': 'Йорданія',
        'Kazakhstan': 'Казахстан',
        'Kenya': 'Кенія',
        'Kiribati': 'Кирибаті',
        'Kuwait': 'Кувейт',
        'Kyrgyzstan': 'Киргизстан',
        'Laos': 'Лаос',
        'Latvia': 'Латвія',
        'Lebanon': 'Ліван',
        'Lesotho': 'Лесото',
        'Liberia': 'Ліберія',
        'Libya': 'Лівія',
        'Liechtenstein': 'Ліхтенштейн',
        'Lithuania': 'Литва',
        'Luxembourg': 'Люксембург',
        'Madagascar': 'Мадагаскар',
        'Malawi': 'Малаві',
        'Malaysia': 'Малайзія',
        'Maldives': 'Мальдіви',
        'Mali': 'Малі',
        'Malta': 'Мальта',
        'Marshall_Islands': 'Маршаллові Острови',
        'Mauritania': 'Мавританія',
        'Mauritius': 'Маврикій',
        'Mexico': 'Мексика',
        'Micronesia': 'Мікронезія',
        'Moldova': 'Молдова',
        'Monaco': 'Монако',
        'Mongolia': 'Монголія',
        'Montenegro': 'Чорногорія',
        'Morocco': 'Марокко',
        'Mozambique': 'Мозамбік',
        'Myanmar': 'М\'янма',
        'Namibia': 'Намібія',
        'Nauru': 'Науру',
        'Nepal': 'Непал',
        'Netherlands': 'Нідерланди',
        'New_Zealand': 'Нова Зеландія',
        'Nicaragua': 'Нікарагуа',
        'Niger': 'Нігер',
        'Nigeria': 'Нігерія',
        'North_Korea': 'Північна Корея',
        'North_Macedonia': 'Північна Македонія',
        'Norway': 'Норвегія',
        'Oman': 'Оман',
        'Pakistan': 'Пакистан',
        'Palau': 'Палау',
        'Panama': 'Панама',
        'Papua_New_Guinea': 'Папуа — Нова Гвінея',
        'Paraguay': 'Парагвай',
        'Peru': 'Перу',
        'Philippines': 'Філіппіни',
        'Poland': 'Польща',
        'Portugal': 'Португалія',
        'Qatar': 'Катар',
        'Romania': 'Румунія',
        'Russia': 'Росія',
        'Rwanda': 'Руанда',
        'Saint_Kitts_and_Nevis': 'Сент-Кітс і Невіс',
        'Saint_Lucia': 'Сент-Люсія',
        'Saint_Vincent_and_the_Grenadines': 'Сент-Вінсент і Гренадини',
        'Samoa': 'Самоа',
        'San_Marino': 'Сан-Марино',
        'Sao_Tome_and_Principe': 'Сан-Томе і Принсіпі',
        'Saudi_Arabia': 'Саудівська Аравія',
        'Senegal': 'Сенегал',
        'Serbia': 'Сербія',
        'Seychelles': 'Сейшельські Острови',
        'Sierra_Leone': 'Сьєрра-Леоне',
        'Singapore': 'Сінгапур',
        'Slovakia': 'Словаччина',
        'Slovenia': 'Словенія',
        'Solomon_Islands': 'Соломонові Острови',
        'Somalia': 'Сомалі',
        'South_Africa': 'Південна Африка',
        'South_Korea': 'Південна Корея',
        'South_Sudan': 'Південний Судан',
        'Spain': 'Іспанія',
        'Sri_Lanka': 'Шрі-Ланка',
        'Sudan': 'Судан',
        'Suriname': 'Суринам',
        'Sweden': 'Швеція',
        'Switzerland': 'Швейцарія',
        'Syria': 'Сирія',
        'Taiwan': 'Тайвань',
        'Tajikistan': 'Таджикистан',
        'Tanzania': 'Танзанія',
        'Thailand': 'Таїланд',
        'Timor_Leste': 'Східний Тимор',
        'Togo': 'Того',
        'Tonga': 'Тонга',
        'Trinidad_and_Tobago': 'Тринідад і Тобаго',
        'Tunisia': 'Туніс',
        'Turkey': 'Туреччина',
        'Turkmenistan': 'Туркменістан',
        'Tuvalu': 'Тувалу',
        'Uganda': 'Уганда',
        'Ukraine': 'Україна',
        'United_Arab_Emirates': 'Об\'єднані Арабські Емірати',
        'United_Kingdom': 'Велика Британія',
        'United_States': 'Сполучені Штати',
        'Uruguay': 'Уругвай',
        'Uzbekistan': 'Узбекистан',
        'Vanuatu': 'Вануату',
        'Vatican_City': 'Ватикан',
        'Venezuela': 'Венесуела',
        'Vietnam': 'В\'єтнам',
        'Yemen': 'Ємен',
        'Zambia': 'Замбія',
        'Zimbabwe': 'Зімбабве',
        'other': 'Ваканда',
      },
    );
    return '$_temp0';
  }

  @override
  String get deleteSaveTitle => 'Видалити збереження?';

  @override
  String get deleteSaveMessage =>
      'Ви впевнені, що хочете видалити це збереження гри?';

  @override
  String get failedToDeleteMessage => 'Не вдалося видалити';

  @override
  String get webSaveGameNote =>
      'Веб‑примітка: ваше збереження буде зберігатися в локальному сховищі цього браузера для цього сайту. Воно не синхронізується між пристроями і не зберігається в приватних вікнах.';

  @override
  String get webLoadGameNote =>
      'Веб‑примітка: наведений нижче список береться з локального сховища цього браузера для цього сайту (не спільний з іншими браузерами чи приватними вікнами).';
}
