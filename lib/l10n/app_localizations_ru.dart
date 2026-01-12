// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String appTitle(Object size) {
    return 'Dual Clash';
  }

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get commonYes => 'Да';

  @override
  String get commonNo => 'Нет';

  @override
  String get deleteLabel => 'Удалить';

  @override
  String get playLabel => 'Играть';

  @override
  String get leaveLabel => 'Выйти';

  @override
  String get menuTitle => 'Меню';

  @override
  String get mainMenuBarrierLabel => 'Главное меню';

  @override
  String get mainMenuTooltip => 'Главное меню';

  @override
  String get gameMenuTitle => 'Игровое меню';

  @override
  String get returnToMainMenuLabel => 'Вернуться в главное меню';

  @override
  String get returnToMainMenuTitle => 'Вернуться в главное меню';

  @override
  String get returnToMainMenuMessage =>
      'Хотите вернуться в главное меню?\n\nПрогресс не будет сохранён.';

  @override
  String get restartGameLabel => 'Перезапустить/начать игру';

  @override
  String get restartGameTitle => 'Перезапустить игру';

  @override
  String get restartGameMessage =>
      'Перезапустить игру с нуля?\n\nТекущий прогресс будет потерян.';

  @override
  String get statisticsTitle => 'Статистика';

  @override
  String get helpTitle => 'Помощь';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get historyTitle => 'История';

  @override
  String get saveGameTitle => 'Сохранить игру';

  @override
  String get saveGameNameLabel => 'Название сохранения';

  @override
  String get saveGameNameHint => 'Введите название...';

  @override
  String get saveGameBarrierLabel => 'Сохранение игры';

  @override
  String get gameSavedMessage => 'Игра сохранена';

  @override
  String get simulateGameLabel => 'Симуляция игры';

  @override
  String get simulateGameHumanWinLabel => 'Симуляция игры (победа человека)';

  @override
  String get simulateGameAiWinLabel => 'Симуляция игры (победа ИИ)';

  @override
  String get simulateGameGreyWinLabel => 'Симуляция игры (победа серых)';

  @override
  String get removeAdsLabel => 'Убрать рекламу — 1€';

  @override
  String get restorePurchasesLabel => 'Восстановить покупки';

  @override
  String get menuGameShort => 'Игра';

  @override
  String get menuGameChallenge => 'Игра челлендж';

  @override
  String get menuDuelShort => 'Дуэль';

  @override
  String get menuDuelMode => 'Режим дуэли';

  @override
  String get menuLoadShort => 'Загрузить';

  @override
  String get menuLoadGame => 'Загрузить игру';

  @override
  String get menuCampaignShort => 'Camp.';

  @override
  String get menuCampaign => 'Campaign';

  @override
  String get menuHubShort => 'Хаб';

  @override
  String get menuPlayerHub => 'Хаб игрока';

  @override
  String get menuTripleShort => 'Тройной';

  @override
  String get menuTripleThreat => 'Тройная угроза';

  @override
  String get menuQuadShort => 'Четверной';

  @override
  String get menuQuadClash => 'Четверной бой';

  @override
  String get menuAlliance2v2 => 'Alliance 2vs2';

  @override
  String get playerHubBarrierLabel => 'Хаб игрока';

  @override
  String get modesBarrierLabel => 'Режимы';

  @override
  String get languageTitle => 'Язык';

  @override
  String get userProfileLabel => 'Профиль игрока';

  @override
  String get gameChallengeLabel => 'Игра вызов';

  @override
  String get gameChallengeComingSoon => 'Режим вызова скоро появится';

  @override
  String get loadGameBarrierLabel => 'Загрузка игры';

  @override
  String get noSavedGamesMessage => 'Нет сохранённых игр';

  @override
  String get savedGameDefaultName => 'Сохранённая игра';

  @override
  String savedGameSubtitle(Object when, Object turn) {
    return '$when • Ход: $turn';
  }

  @override
  String get helpGoalTitle => 'Цель';

  @override
  String helpGoalBody(Object board) {
    return 'Заполните поле $board, по очереди с ИИ. Вы — Красный, ИИ — Синий. Побеждает игрок с более высоким ОБЩИМ счётом.';
  }

  @override
  String get helpTurnsTitle => 'Ходы и размещение';

  @override
  String get helpTurnsBody =>
      'Нажмите на любую пустую клетку, чтобы поставить свой цвет. После вашего хода ИИ ставит синий. Кто ходит первым, можно изменить в настройках.';

  @override
  String get helpScoringTitle => 'Подсчёт очков';

  @override
  String get helpScoringBase =>
      'Базовый счёт: количество клеток вашего цвета на поле к концу игры.';

  @override
  String get helpScoringBonus =>
      'Бонус: +50 очков за каждый полностью заполненный вашим цветом ряд или столбец.';

  @override
  String get helpScoringTotal => 'Итоговый счёт: базовый счёт + бонус.';

  @override
  String get helpScoringEarning =>
      'Заработок очков во время игры (Красный): +1 за каждое размещение, +2 дополнительно за угол, +2 за каждую синюю клетку, ставшую нейтральной, +3 за каждую нейтральную, ставшую красной, +50 за каждый новый полный красный ряд/столбец.';

  @override
  String get helpScoringCumulative =>
      'Ваш общий счёт трофеев только увеличивается. Очки добавляются после каждой завершённой игры по вашему красному итогу. Действия соперника никогда не уменьшают ваш общий итог.';

  @override
  String get helpWinningTitle => 'Победа';

  @override
  String get helpWinningBody =>
      'Когда на поле не остаётся пустых клеток, игра заканчивается. Побеждает игрок с более высоким итоговым счётом. Возможна ничья.';

  @override
  String get helpAiLevelTitle => 'Уровень ИИ';

  @override
  String get helpAiLevelBody =>
      'Выберите сложность ИИ в настройках (1–7). Более высокие уровни думают дальше, но дольше.';

  @override
  String get helpHistoryProfileTitle => 'История и профиль';

  @override
  String get helpHistoryProfileBody =>
      'Ваши завершённые игры сохраняются в Истории со всеми деталями.';

  @override
  String get aiDifficultyTitle => 'Сложность ИИ';

  @override
  String get aiDifficultyTipBeginner =>
      'Белый — Новичок: делает случайные ходы.';

  @override
  String get aiDifficultyTipEasy =>
      'Жёлтый — Лёгкий: предпочитает мгновенную выгоду.';

  @override
  String get aiDifficultyTipNormal =>
      'Оранжевый — Нормальный: жадный с базовым позиционированием.';

  @override
  String get aiDifficultyTipChallenging =>
      'Зелёный — Сложный: неглубокий поиск с некоторым предвидением.';

  @override
  String get aiDifficultyTipHard =>
      'Синий — Тяжёлый: более глубокий поиск с отсечением.';

  @override
  String get aiDifficultyTipExpert =>
      'Коричневый — Эксперт: продвинутое отсечение и кэш.';

  @override
  String get aiDifficultyTipMaster =>
      'Чёрный — Мастер: самый сильный и расчётливый.';

  @override
  String get aiDifficultyTipSelect => 'Выберите уровень пояса.';

  @override
  String get aiDifficultyDetailBeginner =>
      'Белый — Новичок: случайные пустые клетки. Непредсказуем, но слаб.';

  @override
  String get aiDifficultyDetailEasy =>
      'Жёлтый — Лёгкий: жадные ходы, максимизирующие мгновенную выгоду.';

  @override
  String get aiDifficultyDetailNormal =>
      'Оранжевый — Нормальный: жадный, с приоритетом центра при равенстве.';

  @override
  String get aiDifficultyDetailChallenging =>
      'Зелёный — Сложный: неглубокий минимакс (глубина 2), без отсечения.';

  @override
  String get aiDifficultyDetailHard =>
      'Синий — Тяжёлый: более глубокий минимакс с альфа–бета отсечением и упорядочиванием ходов.';

  @override
  String get aiDifficultyDetailExpert =>
      'Коричневый — Эксперт: более глубокий минимакс с отсечением и таблицей транспозиций.';

  @override
  String get aiDifficultyDetailMaster =>
      'Чёрный — Мастер: Monte Carlo Tree Search (~1500 симуляций в лимит времени).';

  @override
  String get aiDifficultyDetailSelect =>
      'Выберите сложность ИИ, чтобы увидеть детали.';

  @override
  String get currentAiLevelLabel => 'Текущий уровень ИИ';

  @override
  String aiLevelDisplay(Object belt, Object level) {
    return '$belt ($level)';
  }

  @override
  String get resultsTitle => 'Результаты';

  @override
  String get timePlayedLabel => 'Время игры';

  @override
  String get redTurnsLabel => 'Ходы красных';

  @override
  String get blueTurnsLabel => 'Ходы синих';

  @override
  String get yellowTurnsLabel => 'Ходы жёлтых';

  @override
  String get greenTurnsLabel => 'Ходы зелёных';

  @override
  String get playerTurnsLabel => 'Ходы игрока';

  @override
  String get aiTurnsLabel => 'Ходы ИИ';

  @override
  String playerTurnStatus(Object player) {
    return '$player player turn';
  }

  @override
  String get newBestScoreLabel => 'Новый лучший результат';

  @override
  String pointsBelowBestScore(Object points) {
    return 'На $points очков меньше лучшего результата';
  }

  @override
  String youWinReachedScore(Object score) {
    return 'Вы победили и набрали $score очков';
  }

  @override
  String get redTerritoryControlled =>
      'Территория красного игрока под контролем.';

  @override
  String get blueTerritoryControlled =>
      'Территория синего игрока под контролем.';

  @override
  String get neutralTerritoryControlled =>
      'Нейтральная территория под контролем.';

  @override
  String get territoryBalanced => 'Территория сбалансирована.';

  @override
  String get performanceLost => 'Вы проиграли. Нужна стратегия.';

  @override
  String get performanceBrilliantEndgame => 'Блестящий эндшпиль';

  @override
  String get performanceGreatControl => 'Отличный контроль';

  @override
  String get performanceRiskyEffective => 'Рискованно, но эффективно';

  @override
  String get performanceSolidStrategy => 'Солидная стратегия';

  @override
  String get playAgainLabel => 'Играть снова';

  @override
  String get continueNextAiLevelLabel => 'Перейти к следующему уровню ИИ';

  @override
  String get playLowerAiLevelLabel => 'Играть на более низком уровне ИИ';

  @override
  String get replaySameLevelLabel => 'Повторить этот уровень';

  @override
  String get aiThinkingLabel => 'ИИ думает...';

  @override
  String get simulatingGameLabel => 'Симуляция игры...';

  @override
  String get noTurnsYetMessage => 'В этой игре ещё нет ходов';

  @override
  String turnLabel(Object turn) {
    return 'Ход $turn';
  }

  @override
  String get undoLastActionTooltip => 'Отменить последнее действие';

  @override
  String get historyTabGames => 'Игры';

  @override
  String get historyTabDailyActivity => 'Дневная активность';

  @override
  String get noFinishedGamesYet => 'Ещё нет завершённых игр';

  @override
  String gamesCountLabel(Object count) {
    return 'Игр: $count';
  }

  @override
  String get winsLabel => 'Победы';

  @override
  String get lossesLabel => 'Поражения';

  @override
  String get drawsLabel => 'Ничьи';

  @override
  String get totalTimeLabel => 'Общее время';

  @override
  String get resultDraw => 'Ничья';

  @override
  String get resultPlayerWins => 'Победа игрока';

  @override
  String get resultAiWins => 'Победа ИИ';

  @override
  String aiLabelWithName(Object name) {
    return 'ИИ: $name';
  }

  @override
  String winnerLabel(Object result) {
    return 'Победитель: $result';
  }

  @override
  String get yourScoreLabel => 'Ваш счёт';

  @override
  String get timeLabel => 'Время';

  @override
  String get redBaseLabel => 'Красная база';

  @override
  String get blueBaseLabel => 'Синяя база';

  @override
  String get totalBlueLabel => 'Итого синих';

  @override
  String get turnsRedLabel => 'Ходы К';

  @override
  String get turnsBlueLabel => 'Ходы С';

  @override
  String get ageLabel => 'Возраст';

  @override
  String get nicknameLabel => 'Ник';

  @override
  String get enterNicknameHint => 'Введите ник';

  @override
  String get countryLabel => 'Страна';

  @override
  String get beltsTitle => 'Пояса';

  @override
  String get achievementsTitle => 'Достижения';

  @override
  String get achievementFullRow => 'Полный ряд';

  @override
  String get achievementFullColumn => 'Полный столбец';

  @override
  String get achievementDiagonal => 'Диагональ';

  @override
  String get achievement100GamePoints => '100 очков игры';

  @override
  String get achievement1000GamePoints => '1000 очков игры';

  @override
  String get nicknameRequiredError => 'Ник обязателен';

  @override
  String get nicknameMaxLengthError => 'Максимум 32 символа';

  @override
  String get nicknameInvalidCharsError =>
      'Используйте буквы, цифры, точку, дефис или подчёркивание';

  @override
  String get nicknameUpdatedMessage => 'Ник обновлён';

  @override
  String get noBeltsEarnedYetMessage => 'Пояса ещё не заработаны.';

  @override
  String get whoStartsFirstLabel => 'Кто ходит первым';

  @override
  String get whoStartsFirstTip =>
      'If no turns have been made, changes apply immediately; otherwise they take effect in the next game.';

  @override
  String get startingPlayerHuman => 'Человек (Красный)';

  @override
  String get startingPlayerAi => 'ИИ (Синий)';

  @override
  String get leaveDuelBarrierLabel => 'Выйти из дуэли';

  @override
  String get leaveDuelTitle => 'Выйти из дуэли';

  @override
  String get leaveDuelMessage =>
      'Выйти из режима дуэли и вернуться в главное меню?\n\nПрогресс не будет сохранён.';

  @override
  String get leaveBarrierLabel => 'Выйти';

  @override
  String leaveModeTitle(Object mode) {
    return 'Выйти из режима $mode';
  }

  @override
  String get leaveMultiModeMessage =>
      'Вернуться в главное меню?\n\nПрогресс не будет сохранён.';

  @override
  String get colorRedLabel => 'КРАСНЫЙ';

  @override
  String get colorBlueLabel => 'СИНИЙ';

  @override
  String get colorYellowLabel => 'ЖЁЛТЫЙ';

  @override
  String get colorGreenLabel => 'ЗЕЛЁНЫЙ';

  @override
  String get redShortLabel => 'К';

  @override
  String get blueShortLabel => 'С';

  @override
  String get yellowShortLabel => 'Ж';

  @override
  String get greenShortLabel => 'З';

  @override
  String get supportTheDevLabel => 'Поддержать разработчика';

  @override
  String get aiBeltWhite => 'Белый';

  @override
  String get aiBeltYellow => 'Жёлтый';

  @override
  String get aiBeltOrange => 'Оранжевый';

  @override
  String get aiBeltGreen => 'Зелёный';

  @override
  String get aiBeltBlue => 'Синий';

  @override
  String get aiBeltBrown => 'Коричневый';

  @override
  String get aiBeltBlack => 'Чёрный';

  @override
  String get scorePlace => '+1 размещение';

  @override
  String get scoreCorner => '+2 угол';

  @override
  String scoreBlueToGrey(Object count) {
    return '+2 x$count синий→серый';
  }

  @override
  String scoreGreyToRed(Object count) {
    return '+3 x$count серый→красный';
  }

  @override
  String get scorePlaceShort => 'Ход';

  @override
  String get scoreZeroBlow => '0 ударов';

  @override
  String get scoreZeroGreyDrop => '0 серых падений';

  @override
  String durationSeconds(Object seconds) {
    return '$secondsс';
  }

  @override
  String durationMinutesSeconds(Object minutes, Object seconds) {
    return '$minutesм $secondsс';
  }

  @override
  String durationHoursMinutes(Object hours, Object minutes) {
    return '$hoursч $minutesм';
  }

  @override
  String countryName(String country) {
    String _temp0 = intl.Intl.selectLogic(
      country,
      {
        'Afghanistan': 'Афганистан',
        'Albania': 'Албания',
        'Algeria': 'Алжир',
        'Andorra': 'Андорра',
        'Angola': 'Ангола',
        'Antigua_and_Barbuda': 'Антигуа и Барбуда',
        'Argentina': 'Аргентина',
        'Armenia': 'Армения',
        'Australia': 'Австралия',
        'Austria': 'Австрия',
        'Azerbaijan': 'Азербайджан',
        'Bahamas': 'Багамы',
        'Bahrain': 'Бахрейн',
        'Bangladesh': 'Бангладеш',
        'Barbados': 'Барбадос',
        'Belarus': 'Беларусь',
        'Belgium': 'Бельгия',
        'Belize': 'Белиз',
        'Benin': 'Бенин',
        'Bhutan': 'Бутан',
        'Bolivia': 'Боливия',
        'Bosnia_and_Herzegovina': 'Босния и Герцеговина',
        'Botswana': 'Ботсвана',
        'Brazil': 'Бразилия',
        'Brunei': 'Бруней',
        'Bulgaria': 'Болгария',
        'Burkina_Faso': 'Буркина-Фасо',
        'Burundi': 'Бурунди',
        'Cabo_Verde': 'Кабо-Верде',
        'Cambodia': 'Камбоджа',
        'Cameroon': 'Камерун',
        'Canada': 'Канада',
        'Central_African_Republic': 'Центральноафриканская Республика',
        'Chad': 'Чад',
        'Chile': 'Чили',
        'China': 'Китай',
        'Colombia': 'Колумбия',
        'Comoros': 'Коморы',
        'Congo_Congo_Brazzaville': 'Конго (Браззавиль)',
        'Costa_Rica': 'Коста-Рика',
        'Croatia': 'Хорватия',
        'Cuba': 'Куба',
        'Cyprus': 'Кипр',
        'Czechia': 'Чехия',
        'Democratic_Republic_of_the_Congo': 'Демократическая Республика Конго',
        'Denmark': 'Дания',
        'Djibouti': 'Джибути',
        'Dominica': 'Доминика',
        'Dominican_Republic': 'Доминиканская Республика',
        'Ecuador': 'Эквадор',
        'Egypt': 'Египет',
        'El_Salvador': 'Сальвадор',
        'Equatorial_Guinea': 'Экваториальная Гвинея',
        'Eritrea': 'Эритрея',
        'Estonia': 'Эстония',
        'Eswatini': 'Эсватини',
        'Ethiopia': 'Эфиопия',
        'Fiji': 'Фиджи',
        'Finland': 'Финляндия',
        'France': 'Франция',
        'Gabon': 'Габон',
        'Gambia': 'Гамбия',
        'Georgia': 'Грузия',
        'Germany': 'Германия',
        'Ghana': 'Гана',
        'Greece': 'Греция',
        'Grenada': 'Гренада',
        'Guatemala': 'Гватемала',
        'Guinea': 'Гвинея',
        'Guinea_Bissau': 'Гвинея-Бисау',
        'Guyana': 'Гайана',
        'Haiti': 'Гаити',
        'Honduras': 'Гондурас',
        'Hungary': 'Венгрия',
        'Iceland': 'Исландия',
        'India': 'Индия',
        'Indonesia': 'Индонезия',
        'Iran': 'Иран',
        'Iraq': 'Ирак',
        'Ireland': 'Ирландия',
        'Israel': 'Израиль',
        'Italy': 'Италия',
        'Jamaica': 'Ямайка',
        'Japan': 'Япония',
        'Jordan': 'Иордания',
        'Kazakhstan': 'Казахстан',
        'Kenya': 'Кения',
        'Kiribati': 'Кирибати',
        'Kuwait': 'Кувейт',
        'Kyrgyzstan': 'Киргизия',
        'Laos': 'Лаос',
        'Latvia': 'Латвия',
        'Lebanon': 'Ливан',
        'Lesotho': 'Лесото',
        'Liberia': 'Либерия',
        'Libya': 'Ливия',
        'Liechtenstein': 'Лихтенштейн',
        'Lithuania': 'Литва',
        'Luxembourg': 'Люксембург',
        'Madagascar': 'Мадагаскар',
        'Malawi': 'Малави',
        'Malaysia': 'Малайзия',
        'Maldives': 'Мальдивы',
        'Mali': 'Мали',
        'Malta': 'Мальта',
        'Marshall_Islands': 'Маршалловы Острова',
        'Mauritania': 'Мавритания',
        'Mauritius': 'Маврикий',
        'Mexico': 'Мексика',
        'Micronesia': 'Микронезия',
        'Moldova': 'Молдова',
        'Monaco': 'Монако',
        'Mongolia': 'Монголия',
        'Montenegro': 'Черногория',
        'Morocco': 'Марокко',
        'Mozambique': 'Мозамбик',
        'Myanmar': 'Мьянма',
        'Namibia': 'Намибия',
        'Nauru': 'Науру',
        'Nepal': 'Непал',
        'Netherlands': 'Нидерланды',
        'New_Zealand': 'Новая Зеландия',
        'Nicaragua': 'Никарагуа',
        'Niger': 'Нигер',
        'Nigeria': 'Нигерия',
        'North_Korea': 'КНДР',
        'North_Macedonia': 'Северная Македония',
        'Norway': 'Норвегия',
        'Oman': 'Оман',
        'Pakistan': 'Пакистан',
        'Palau': 'Палау',
        'Panama': 'Панама',
        'Papua_New_Guinea': 'Папуа — Новая Гвинея',
        'Paraguay': 'Парагвай',
        'Peru': 'Перу',
        'Philippines': 'Филиппины',
        'Poland': 'Польша',
        'Portugal': 'Португалия',
        'Qatar': 'Катар',
        'Romania': 'Румыния',
        'Russia': 'Россия',
        'Rwanda': 'Руанда',
        'Saint_Kitts_and_Nevis': 'Сент-Китс и Невис',
        'Saint_Lucia': 'Сент-Люсия',
        'Saint_Vincent_and_the_Grenadines': 'Сент-Винсент и Гренадины',
        'Samoa': 'Самоа',
        'San_Marino': 'Сан-Марино',
        'Sao_Tome_and_Principe': 'Сан-Томе и Принсипи',
        'Saudi_Arabia': 'Саудовская Аравия',
        'Senegal': 'Сенегал',
        'Serbia': 'Сербия',
        'Seychelles': 'Сейшельские Острова',
        'Sierra_Leone': 'Сьерра-Леоне',
        'Singapore': 'Сингапур',
        'Slovakia': 'Словакия',
        'Slovenia': 'Словения',
        'Solomon_Islands': 'Соломоновы Острова',
        'Somalia': 'Сомали',
        'South_Africa': 'Южная Африка',
        'South_Korea': 'Республика Корея',
        'South_Sudan': 'Южный Судан',
        'Spain': 'Испания',
        'Sri_Lanka': 'Шри-Ланка',
        'Sudan': 'Судан',
        'Suriname': 'Суринам',
        'Sweden': 'Швеция',
        'Switzerland': 'Швейцария',
        'Syria': 'Сирия',
        'Taiwan': 'Тайвань',
        'Tajikistan': 'Таджикистан',
        'Tanzania': 'Танзания',
        'Thailand': 'Таиланд',
        'Timor_Leste': 'Восточный Тимор',
        'Togo': 'Того',
        'Tonga': 'Тонга',
        'Trinidad_and_Tobago': 'Тринидад и Тобаго',
        'Tunisia': 'Тунис',
        'Turkey': 'Турция',
        'Turkmenistan': 'Туркменистан',
        'Tuvalu': 'Тувалу',
        'Uganda': 'Уганда',
        'Ukraine': 'Украина',
        'United_Arab_Emirates': 'Объединённые Арабские Эмираты',
        'United_Kingdom': 'Великобритания',
        'United_States': 'США',
        'Uruguay': 'Уругвай',
        'Uzbekistan': 'Узбекистан',
        'Vanuatu': 'Вануату',
        'Vatican_City': 'Ватикан',
        'Venezuela': 'Венесуэла',
        'Vietnam': 'Вьетнам',
        'Yemen': 'Йемен',
        'Zambia': 'Замбия',
        'Zimbabwe': 'Зимбабве',
        'other': 'Ваканда',
      },
    );
    return '$_temp0';
  }

  @override
  String get deleteSaveTitle => 'Удалить сохранение?';

  @override
  String get deleteSaveMessage =>
      'Вы уверены, что хотите удалить это сохранение?';

  @override
  String get failedToDeleteMessage => 'Не удалось удалить';
}
