// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String appTitle(Object size) {
    return 'Dual Clash';
  }

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonYes => 'Sí';

  @override
  String get commonNo => 'No';

  @override
  String get deleteLabel => 'Eliminar';

  @override
  String get playLabel => 'Jugar';

  @override
  String get leaveLabel => 'Salir';

  @override
  String get menuTitle => 'Menú';

  @override
  String get mainMenuBarrierLabel => 'Menú principal';

  @override
  String get mainMenuTooltip => 'Menú principal';

  @override
  String get gameMenuTitle => 'Menú del juego';

  @override
  String get returnToMainMenuLabel => 'Volver al menú principal';

  @override
  String get returnToMainMenuTitle => 'Volver al menú principal';

  @override
  String get returnToMainMenuMessage =>
      '¿Quieres volver al menú principal?\n\nEl progreso no se guardará.';

  @override
  String get restartGameLabel => 'Reiniciar/Empezar el juego';

  @override
  String get restartGameTitle => 'Reiniciar juego';

  @override
  String get restartGameMessage =>
      '¿Reiniciar el juego desde cero?\n\nSe perderá el progreso actual.';

  @override
  String get adminModeEnableTitle => 'Activar modo admin';

  @override
  String get adminModeEnableMessage =>
      '¿Activar el modo admin en este dispositivo?\n\nSe mostrarán las opciones de simulación.';

  @override
  String get statisticsTitle => 'Estadísticas';

  @override
  String get helpTitle => 'Ayuda';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsMusicLabel => 'Música';
  @override
  String get settingsSoundsLabel => 'Sonidos';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get historyTitle => 'Historial';

  @override
  String get saveGameTitle => 'Guardar partida';

  @override
  String get saveGameNameLabel => 'Nombre de este guardado';

  @override
  String get saveGameNameHint => 'Introduce un nombre...';

  @override
  String get saveGameBarrierLabel => 'Guardar partida';

  @override
  String get gameSavedMessage => 'Partida guardada';

  @override
  String get simulateGameLabel => 'Simular partida';

  @override
  String get simulateGameHumanWinLabel => 'Simular partida (gana el humano)';

  @override
  String get simulateGameAiWinLabel => 'Simular partida (gana la IA)';

  @override
  String get simulateGameGreyWinLabel => 'Simular partida (gana gris)';

  @override
  String get removeAdsLabel => 'Eliminar anuncios — 1€';

  @override
  String get restorePurchasesLabel => 'Restaurar compras';

  @override
  String get menuGameShort => 'Juego';

  @override
  String get menuGameChallenge => 'Juego desafío';

  @override
  String get menuDuelShort => 'Duelo';

  @override
  String get menuDuelMode => 'Modo duelo';

  @override
  String get menuLoadShort => 'Cargar';

  @override
  String get menuLoadGame => 'Cargar partida';

  @override
  String get menuCampaignShort => 'Camp.';

  @override
  String get menuCampaign => 'Campaign';

  @override
  String get buddhaCampaignTitle => 'Campaña Buda';

  @override
  String get buddhaCampaignDescription =>
      'La Campaña Buda es un viaje de calma, control y claridad estratégica. Cada nivel te desafía a leer el tablero, actuar con precisión y ganar mediante el equilibrio en lugar de la fuerza.';

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
  String get menuPlayerHub => 'Hub de jugador';

  @override
  String get menuTripleShort => 'Triple';

  @override
  String get menuTripleThreat => 'Triple amenaza';

  @override
  String get menuQuadShort => 'Cuádruple';

  @override
  String get menuQuadClash => 'Choque cuádruple';

  @override
  String get menuAlliance2v2 => 'Alliance 2vs2';

  @override
  String get menuAlliance2v2Short => 'Alianza';

  @override
  String get playerHubBarrierLabel => 'Hub de jugador';

  @override
  String get modesBarrierLabel => 'Modos';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get userProfileLabel => 'Perfil de usuario';

  @override
  String get gameChallengeLabel => 'Juego desafío';

  @override
  String get gameChallengeComingSoon =>
      'El modo desafío estará disponible pronto';

  @override
  String get loadGameBarrierLabel => 'Cargar partida';

  @override
  String get noSavedGamesMessage => 'No hay partidas guardadas';

  @override
  String get savedGameDefaultName => 'Partida guardada';

  @override
  String savedGameSubtitle(Object when, Object turn) {
    return '$when • Turno: $turn';
  }

  @override
  String get helpGoalTitle => 'Objetivo';

  @override
  String helpGoalBody(Object board) {
    return 'Rellena el tablero $board por turnos con la IA. Tú eres Rojo, la IA es Azul. Gana el jugador con la mayor puntuación TOTAL.';
  }

  @override
  String get helpTurnsTitle => 'Turnos y colocación';

  @override
  String get helpTurnsBody =>
      'Toca cualquier celda vacía para colocar tu color. Después de tu movimiento, la IA coloca azul. El jugador inicial se puede cambiar en Ajustes.';

  @override
  String get helpScoringTitle => 'Puntuación';

  @override
  String get helpScoringBase =>
      'Puntuación base: número de celdas de tu color en el tablero cuando termina la partida.';

  @override
  String get helpScoringBonus =>
      'Bono: +50 puntos por cada fila o columna completa de tu color.';

  @override
  String get helpScoringTotal => 'Puntuación total: Base + Bono.';

  @override
  String get helpScoringEarning =>
      'Ganancia de puntos durante la partida (Rojo): +1 por cada colocación, +2 extra si está en una esquina, +2 por cada azul convertido en neutral, +3 por cada neutral convertido en rojo, +50 por cada nueva fila/columna roja completa.';

  @override
  String get helpScoringCumulative =>
      'Tu contador de trofeos solo aumenta. Los puntos se suman tras cada partida según tu total rojo. Las acciones del rival nunca reducen tu total acumulado.';

  @override
  String get helpWinningTitle => 'Victoria';

  @override
  String get helpWinningBody =>
      'Cuando no quedan celdas vacías, la partida termina. Gana el jugador con mayor puntuación total. Puede haber empates.';

  @override
  String get helpAiLevelTitle => 'Nivel de IA';

  @override
  String get helpAiLevelBody =>
      'Elige la dificultad de la IA en Ajustes (1–7). Los niveles más altos piensan más, pero tardan más.';

  @override
  String get helpHistoryProfileTitle => 'Historial y perfil';

  @override
  String get helpHistoryProfileBody =>
      'Tus partidas terminadas se guardan en Historial con todos los detalles.';

  @override
  String get aiDifficultyTitle => 'Dificultad de IA';

  @override
  String get aiDifficultyTipBeginner =>
      'Blanco — Principiante: hace movimientos aleatorios.';

  @override
  String get aiDifficultyTipEasy =>
      'Amarillo — Fácil: prefiere ganancias inmediatas.';

  @override
  String get aiDifficultyTipNormal =>
      'Naranja — Normal: voraz con posicionamiento básico.';

  @override
  String get aiDifficultyTipChallenging =>
      'Verde — Desafiante: búsqueda superficial con algo de previsión.';

  @override
  String get aiDifficultyTipHard =>
      'Azul — Difícil: búsqueda más profunda con poda.';

  @override
  String get aiDifficultyTipExpert =>
      'Marrón — Experto: poda avanzada y caché.';

  @override
  String get aiDifficultyTipMaster =>
      'Negro — Maestro: el más fuerte y calculador.';

  @override
  String get aiDifficultyTipSelect => 'Selecciona un nivel de cinturón.';

  @override
  String get aiDifficultyDetailBeginner =>
      'Blanco — Principiante: celdas vacías aleatorias. Impredecible pero débil.';

  @override
  String get aiDifficultyDetailEasy =>
      'Amarillo — Fácil: movimientos voraces que maximizan la ganancia inmediata.';

  @override
  String get aiDifficultyDetailNormal =>
      'Naranja — Normal: voraz con desempate al centro para preferir posiciones fuertes.';

  @override
  String get aiDifficultyDetailChallenging =>
      'Verde — Desafiante: minimax superficial (profundidad 2), sin poda.';

  @override
  String get aiDifficultyDetailHard =>
      'Azul — Difícil: minimax más profundo con poda alfa–beta y ordenación de movimientos.';

  @override
  String get aiDifficultyDetailExpert =>
      'Marrón — Experto: minimax más profundo con poda y tabla de transposiciones.';

  @override
  String get aiDifficultyDetailMaster =>
      'Negro — Maestro: Monte Carlo Tree Search (~1500 simulaciones en el límite de tiempo).';

  @override
  String get aiDifficultyDetailSelect =>
      'Selecciona dificultad de IA para ver detalles.';

  @override
  String get currentAiLevelLabel => 'Nivel actual de IA';

  @override
  String aiLevelDisplay(Object belt, Object level) {
    return '$belt ($level)';
  }

  @override
  String get resultsTitle => 'Resultados';

  @override
  String get timePlayedLabel => 'Tiempo jugado';

  @override
  String get redTurnsLabel => 'Turnos rojos';

  @override
  String get blueTurnsLabel => 'Turnos azules';

  @override
  String get yellowTurnsLabel => 'Turnos amarillos';

  @override
  String get greenTurnsLabel => 'Turnos verdes';

  @override
  String get playerTurnsLabel => 'Turnos del jugador';

  @override
  String get aiTurnsLabel => 'Turnos de la IA';

  @override
  String playerTurnStatus(Object player) {
    return '$player player turn';
  }

  @override
  String get newBestScoreLabel => 'Nuevo mejor resultado';

  @override
  String pointsBelowBestScore(Object points) {
    return '$points puntos por debajo del mejor resultado';
  }

  @override
  String youWinReachedScore(Object score) {
    return 'Has ganado y alcanzado $score puntos';
  }

  @override
  String get redTerritoryControlled =>
      'Territorio del jugador rojo controlado.';

  @override
  String get blueTerritoryControlled =>
      'Territorio del jugador azul controlado.';

  @override
  String get neutralTerritoryControlled => 'Territorio neutral controlado.';

  @override
  String get territoryBalanced => 'Territorio equilibrado.';

  @override
  String get performanceLost => 'Has perdido. Se requiere estrategia.';

  @override
  String get performanceBrilliantEndgame => 'Final brillante';

  @override
  String get performanceGreatControl => 'Gran control';

  @override
  String get performanceRiskyEffective => 'Arriesgado, pero efectivo';

  @override
  String get performanceSolidStrategy => 'Estrategia sólida';

  @override
  String get playAgainLabel => 'Jugar de nuevo';

  @override
  String get continueNextAiLevelLabel => 'Continuar al siguiente nivel de IA';

  @override
  String get playLowerAiLevelLabel => 'Jugar con nivel de IA más bajo';

  @override
  String get replaySameLevelLabel => 'Repetir el mismo nivel';

  @override
  String get aiThinkingLabel => 'La IA está pensando...';

  @override
  String get simulatingGameLabel => 'Simulando partida...';

  @override
  String get noTurnsYetMessage => 'Aún no hay turnos en esta partida';

  @override
  String turnLabel(Object turn) {
    return 'Turno $turn';
  }

  @override
  String get undoLastActionTooltip => 'Deshacer la última acción';

  @override
  String get historyTabGames => 'Partidas';

  @override
  String get historyTabDailyActivity => 'Actividad diaria';

  @override
  String get noFinishedGamesYet => 'Aún no hay partidas finalizadas';

  @override
  String gamesCountLabel(Object count) {
    return 'Partidas: $count';
  }

  @override
  String get winsLabel => 'Victorias';

  @override
  String get lossesLabel => 'Derrotas';

  @override
  String get drawsLabel => 'Empates';

  @override
  String get totalTimeLabel => 'Tiempo total';

  @override
  String get resultDraw => 'Empate';

  @override
  String get resultPlayerWins => 'Gana el jugador';

  @override
  String get resultAiWins => 'Gana la IA';

  @override
  String aiLabelWithName(Object name) {
    return 'IA: $name';
  }

  @override
  String winnerLabel(Object result) {
    return 'Ganador: $result';
  }

  @override
  String get yourScoreLabel => 'Tu puntuación';

  @override
  String get timeLabel => 'Tiempo';

  @override
  String get redBaseLabel => 'Base roja';

  @override
  String get blueBaseLabel => 'Base azul';

  @override
  String get totalBlueLabel => 'Total azul';

  @override
  String get turnsRedLabel => 'Turnos R';

  @override
  String get turnsBlueLabel => 'Turnos A';

  @override
  String get ageLabel => 'Edad';

  @override
  String get nicknameLabel => 'Apodo';

  @override
  String get enterNicknameHint => 'Introduce apodo';

  @override
  String get countryLabel => 'País';

  @override
  String get beltsTitle => 'Cinturones';

  @override
  String get achievementsTitle => 'Logros';

  @override
  String get achievementFullRow => 'Fila completa';

  @override
  String get achievementFullColumn => 'Columna completa';

  @override
  String get achievementDiagonal => 'Diagonal';

  @override
  String get achievement100GamePoints => '100 puntos de juego';

  @override
  String get achievement1000GamePoints => '1000 puntos de juego';

  @override
  String get nicknameRequiredError => 'El apodo es obligatorio';

  @override
  String get nicknameMaxLengthError => 'Máximo 32 caracteres';

  @override
  String get nicknameInvalidCharsError =>
      'Usa letras, números, punto, guion o guion bajo';

  @override
  String get nicknameUpdatedMessage => 'Apodo actualizado';

  @override
  String get noBeltsEarnedYetMessage => 'Aún no has ganado cinturones.';

  @override
  String get whoStartsFirstLabel => 'Quién empieza';

  @override
  String get whoStartsFirstTip =>
      'If no turns have been made, changes apply immediately; otherwise they take effect in the next game.';

  @override
  String get startingPlayerHuman => 'Humano (Rojo)';

  @override
  String get startingPlayerAi => 'IA (Azul)';

  @override
  String get leaveDuelBarrierLabel => 'Salir del duelo';

  @override
  String get leaveDuelTitle => 'Salir del duelo';

  @override
  String get leaveDuelMessage =>
      '¿Salir del modo duelo y volver al menú principal?\n\nEl progreso no se guardará.';

  @override
  String get leaveBarrierLabel => 'Salir';

  @override
  String leaveModeTitle(Object mode) {
    return 'Salir de $mode';
  }

  @override
  String get leaveMultiModeMessage =>
      '¿Volver al menú principal?\n\nEl progreso no se guardará.';

  @override
  String get colorRedLabel => 'ROJO';

  @override
  String get colorBlueLabel => 'AZUL';

  @override
  String get colorYellowLabel => 'AMARILLO';

  @override
  String get colorGreenLabel => 'VERDE';

  @override
  String get redShortLabel => 'R';

  @override
  String get blueShortLabel => 'A';

  @override
  String get yellowShortLabel => 'Am';

  @override
  String get greenShortLabel => 'V';

  @override
  String get supportTheDevLabel => 'Apoya al desarrollador';

  @override
  String get aiBeltWhite => 'Blanco';

  @override
  String get aiBeltYellow => 'Amarillo';

  @override
  String get aiBeltOrange => 'Naranja';

  @override
  String get aiBeltGreen => 'Verde';

  @override
  String get aiBeltBlue => 'Azul';

  @override
  String get aiBeltBrown => 'Marrón';

  @override
  String get aiBeltBlack => 'Negro';

  @override
  String get scorePlace => '+1 colocación';

  @override
  String get scoreCorner => '+2 esquina';

  @override
  String scoreBlueToGrey(Object count) {
    return '+2 x$count azul→gris';
  }

  @override
  String scoreGreyToRed(Object count) {
    return '+3 x$count gris→rojo';
  }

  @override
  String get scorePlaceShort => 'Colocar';

  @override
  String get scoreZeroBlow => '0 golpes';

  @override
  String get scoreZeroGreyDrop => '0 caída gris';

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
        'Wakanda': 'Wakanda',
        'Afghanistan': 'Afganistán',
        'Albania': 'Albania',
        'Algeria': 'Argelia',
        'Andorra': 'Andorra',
        'Angola': 'Angola',
        'Antigua_and_Barbuda': 'Antigua y Barbuda',
        'Argentina': 'Argentina',
        'Armenia': 'Armenia',
        'Australia': 'Australia',
        'Austria': 'Austria',
        'Azerbaijan': 'Azerbaiyán',
        'Bahamas': 'Bahamas',
        'Bahrain': 'Baréin',
        'Bangladesh': 'Bangladesh',
        'Barbados': 'Barbados',
        'Belarus': 'Bielorrusia',
        'Belgium': 'Bélgica',
        'Belize': 'Belice',
        'Benin': 'Benín',
        'Bhutan': 'Bután',
        'Bolivia': 'Bolivia',
        'Bosnia_and_Herzegovina': 'Bosnia y Herzegovina',
        'Botswana': 'Botsuana',
        'Brazil': 'Brasil',
        'Brunei': 'Brunéi',
        'Bulgaria': 'Bulgaria',
        'Burkina_Faso': 'Burkina Faso',
        'Burundi': 'Burundi',
        'Cabo_Verde': 'Cabo Verde',
        'Cambodia': 'Camboya',
        'Cameroon': 'Camerún',
        'Canada': 'Canadá',
        'Central_African_Republic': 'República Centroafricana',
        'Chad': 'Chad',
        'Chile': 'Chile',
        'China': 'China',
        'Colombia': 'Colombia',
        'Comoros': 'Comoras',
        'Congo_Congo_Brazzaville': 'Congo (Brazzaville)',
        'Costa_Rica': 'Costa Rica',
        'Croatia': 'Croacia',
        'Cuba': 'Cuba',
        'Cyprus': 'Chipre',
        'Czechia': 'Chequia',
        'Democratic_Republic_of_the_Congo': 'República Democrática del Congo',
        'Denmark': 'Dinamarca',
        'Djibouti': 'Yibuti',
        'Dominica': 'Dominica',
        'Dominican_Republic': 'República Dominicana',
        'Ecuador': 'Ecuador',
        'Egypt': 'Egipto',
        'El_Salvador': 'El Salvador',
        'Equatorial_Guinea': 'Guinea Ecuatorial',
        'Eritrea': 'Eritrea',
        'Estonia': 'Estonia',
        'Eswatini': 'Esuatini',
        'Ethiopia': 'Etiopía',
        'Fiji': 'Fiyi',
        'Finland': 'Finlandia',
        'France': 'Francia',
        'Gabon': 'Gabón',
        'Gambia': 'Gambia',
        'Georgia': 'Georgia',
        'Germany': 'Alemania',
        'Ghana': 'Ghana',
        'Greece': 'Grecia',
        'Grenada': 'Granada',
        'Guatemala': 'Guatemala',
        'Guinea': 'Guinea',
        'Guinea_Bissau': 'Guinea-Bisáu',
        'Guyana': 'Guyana',
        'Haiti': 'Haití',
        'Honduras': 'Honduras',
        'Hungary': 'Hungría',
        'Iceland': 'Islandia',
        'India': 'India',
        'Indonesia': 'Indonesia',
        'Iran': 'Irán',
        'Iraq': 'Irak',
        'Ireland': 'Irlanda',
        'Israel': 'Israel',
        'Italy': 'Italia',
        'Jamaica': 'Jamaica',
        'Japan': 'Japón',
        'Jordan': 'Jordania',
        'Kazakhstan': 'Kazajistán',
        'Kenya': 'Kenia',
        'Kiribati': 'Kiribati',
        'Kuwait': 'Kuwait',
        'Kyrgyzstan': 'Kirguistán',
        'Laos': 'Laos',
        'Latvia': 'Letonia',
        'Lebanon': 'Líbano',
        'Lesotho': 'Lesoto',
        'Liberia': 'Liberia',
        'Libya': 'Libia',
        'Liechtenstein': 'Liechtenstein',
        'Lithuania': 'Lituania',
        'Luxembourg': 'Luxemburgo',
        'Madagascar': 'Madagascar',
        'Malawi': 'Malawi',
        'Malaysia': 'Malasia',
        'Maldives': 'Maldivas',
        'Mali': 'Malí',
        'Malta': 'Malta',
        'Marshall_Islands': 'Islas Marshall',
        'Mauritania': 'Mauritania',
        'Mauritius': 'Mauricio',
        'Mexico': 'México',
        'Micronesia': 'Micronesia',
        'Moldova': 'Moldavia',
        'Monaco': 'Mónaco',
        'Mongolia': 'Mongolia',
        'Montenegro': 'Montenegro',
        'Morocco': 'Marruecos',
        'Mozambique': 'Mozambique',
        'Myanmar': 'Myanmar',
        'Namibia': 'Namibia',
        'Nauru': 'Nauru',
        'Nepal': 'Nepal',
        'Netherlands': 'Países Bajos',
        'New_Zealand': 'Nueva Zelanda',
        'Nicaragua': 'Nicaragua',
        'Niger': 'Níger',
        'Nigeria': 'Nigeria',
        'North_Korea': 'Corea del Norte',
        'North_Macedonia': 'Macedonia del Norte',
        'Norway': 'Noruega',
        'Oman': 'Omán',
        'Pakistan': 'Pakistán',
        'Palau': 'Palaos',
        'Panama': 'Panamá',
        'Papua_New_Guinea': 'Papúa Nueva Guinea',
        'Paraguay': 'Paraguay',
        'Peru': 'Perú',
        'Philippines': 'Filipinas',
        'Poland': 'Polonia',
        'Portugal': 'Portugal',
        'Qatar': 'Catar',
        'Romania': 'Rumanía',
        'Russia': 'Rusia',
        'Rwanda': 'Ruanda',
        'Saint_Kitts_and_Nevis': 'San Cristóbal y Nieves',
        'Saint_Lucia': 'Santa Lucía',
        'Saint_Vincent_and_the_Grenadines': 'San Vicente y las Granadinas',
        'Samoa': 'Samoa',
        'San_Marino': 'San Marino',
        'Sao_Tome_and_Principe': 'Santo Tomé y Príncipe',
        'Saudi_Arabia': 'Arabia Saudita',
        'Senegal': 'Senegal',
        'Serbia': 'Serbia',
        'Seychelles': 'Seychelles',
        'Sierra_Leone': 'Sierra Leona',
        'Singapore': 'Singapur',
        'Slovakia': 'Eslovaquia',
        'Slovenia': 'Eslovenia',
        'Solomon_Islands': 'Islas Salomón',
        'Somalia': 'Somalia',
        'South_Africa': 'Sudáfrica',
        'South_Korea': 'Corea del Sur',
        'South_Sudan': 'Sudán del Sur',
        'Spain': 'España',
        'Sri_Lanka': 'Sri Lanka',
        'Sudan': 'Sudán',
        'Suriname': 'Surinam',
        'Sweden': 'Suecia',
        'Switzerland': 'Suiza',
        'Syria': 'Siria',
        'Taiwan': 'Taiwán',
        'Tajikistan': 'Tayikistán',
        'Tanzania': 'Tanzania',
        'Thailand': 'Tailandia',
        'Timor_Leste': 'Timor Oriental',
        'Togo': 'Togo',
        'Tonga': 'Tonga',
        'Trinidad_and_Tobago': 'Trinidad y Tobago',
        'Tunisia': 'Túnez',
        'Turkey': 'Turquía',
        'Turkmenistan': 'Turkmenistán',
        'Tuvalu': 'Tuvalu',
        'Uganda': 'Uganda',
        'Ukraine': 'Ucrania',
        'United_Arab_Emirates': 'Emiratos Árabes Unidos',
        'United_Kingdom': 'Reino Unido',
        'United_States': 'Estados Unidos',
        'Uruguay': 'Uruguay',
        'Uzbekistan': 'Uzbekistán',
        'Vanuatu': 'Vanuatu',
        'Vatican_City': 'Ciudad del Vaticano',
        'Venezuela': 'Venezuela',
        'Vietnam': 'Vietnam',
        'Yemen': 'Yemen',
        'Zambia': 'Zambia',
        'Zimbabwe': 'Zimbabue',
        'other': 'Wakanda',
      },
    );
    return '$_temp0';
  }

  @override
  String get deleteSaveTitle => '¿Eliminar guardado?';

  @override
  String get deleteSaveMessage =>
      '¿Seguro que quieres eliminar esta partida guardada?';

  @override
  String get failedToDeleteMessage => 'No se pudo eliminar';

  @override
  String get webSaveGameNote =>
      'Nota web: tu guardado se almacenará en el almacenamiento local de este navegador para este sitio. No se sincroniza entre dispositivos ni en ventanas privadas.';

  @override
  String get webLoadGameNote =>
      'Nota web: la lista de abajo proviene del almacenamiento local de este navegador para este sitio (no se comparte entre otros navegadores ni ventanas privadas).';
}
