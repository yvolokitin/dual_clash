// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String appTitle(Object size) {
    return 'Dual Clash';
  }

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonYes => 'Oui';

  @override
  String get commonNo => 'Non';

  @override
  String get deleteLabel => 'Supprimer';

  @override
  String get playLabel => 'Jouer';

  @override
  String get leaveLabel => 'Quitter';

  @override
  String get menuTitle => 'Menu';

  @override
  String get mainMenuBarrierLabel => 'Menu principal';

  @override
  String get mainMenuTooltip => 'Menu principal';

  @override
  String get gameMenuTitle => 'Menu du jeu';

  @override
  String get returnToMainMenuLabel => 'Retour au menu principal';

  @override
  String get returnToMainMenuTitle => 'Retour au menu principal';

  @override
  String get returnToMainMenuMessage =>
      'Voulez-vous revenir au menu principal ?\n\nLa progression ne sera pas enregistrée.';

  @override
  String get restartGameLabel => 'Redémarrer/Démarrer la partie';

  @override
  String get restartGameTitle => 'Redémarrer la partie';

  @override
  String get restartGameMessage =>
      'Recommencer la partie depuis le début ?\n\nLa progression actuelle sera perdue.';

  @override
  String get statisticsTitle => 'Statistiques';

  @override
  String get helpTitle => 'Aide';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get profileTitle => 'Profil';

  @override
  String get historyTitle => 'Historique';

  @override
  String get saveGameTitle => 'Sauvegarder la partie';

  @override
  String get saveGameNameLabel => 'Nom pour cette sauvegarde';

  @override
  String get saveGameNameHint => 'Entrez un nom...';

  @override
  String get saveGameBarrierLabel => 'Sauvegarder la partie';

  @override
  String get gameSavedMessage => 'Partie sauvegardée';

  @override
  String get simulateGameLabel => 'Simuler la partie';

  @override
  String get simulateGameHumanWinLabel =>
      'Simuler la partie (victoire humaine)';

  @override
  String get simulateGameAiWinLabel => 'Simuler la partie (victoire IA)';

  @override
  String get simulateGameGreyWinLabel => 'Simuler la partie (victoire gris)';

  @override
  String get removeAdsLabel => 'Supprimer les pubs — 1€';

  @override
  String get restorePurchasesLabel => 'Restaurer les achats';

  @override
  String get menuGameShort => 'Jeu';

  @override
  String get menuGameChallenge => 'Défi du jeu';

  @override
  String get menuDuelShort => 'Duel';

  @override
  String get menuDuelMode => 'Mode duel';

  @override
  String get menuLoadShort => 'Charger';

  @override
  String get menuLoadGame => 'Charger une partie';

  @override
  String get menuCampaignShort => 'Camp.';

  @override
  String get menuCampaign => 'Campaign';

  @override
  String get buddhaCampaignTitle => 'Campagne Bouddha';

  @override
  String get buddhaCampaignDescription =>
      'La Campagne Bouddha est un voyage de calme, de contrôle et de clarté stratégique. Chaque niveau vous met au défi de lire le plateau, d\'agir avec précision et de gagner par l\'équilibre plutôt que par la force.';

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
  String get menuPlayerHub => 'Hub joueur';

  @override
  String get menuTripleShort => 'Triple';

  @override
  String get menuTripleThreat => 'Triple menace';

  @override
  String get menuQuadShort => 'Quad';

  @override
  String get menuQuadClash => 'Affrontement quadruple';

  @override
  String get menuAlliance2v2 => 'Alliance 2vs2';

  @override
  String get menuAlliance2v2Short => 'Alliance';

  @override
  String get playerHubBarrierLabel => 'Hub joueur';

  @override
  String get modesBarrierLabel => 'Modes';

  @override
  String get languageTitle => 'Langue';

  @override
  String get userProfileLabel => 'Profil utilisateur';

  @override
  String get gameChallengeLabel => 'Défi du jeu';

  @override
  String get gameChallengeComingSoon => 'Le mode défi arrive bientôt';

  @override
  String get loadGameBarrierLabel => 'Charger la partie';

  @override
  String get noSavedGamesMessage => 'Aucune partie sauvegardée';

  @override
  String get savedGameDefaultName => 'Partie sauvegardée';

  @override
  String savedGameSubtitle(Object when, Object turn) {
    return '$when • Tour : $turn';
  }

  @override
  String get helpGoalTitle => 'Objectif';

  @override
  String helpGoalBody(Object board) {
    return 'Remplissez le plateau $board en alternant avec l’IA. Vous êtes Rouge, l’IA est Bleue. Le joueur avec le score TOTAL le plus élevé gagne.';
  }

  @override
  String get helpTurnsTitle => 'Tours et placement';

  @override
  String get helpTurnsBody =>
      'Touchez une case vide pour placer votre couleur. Après votre coup, l’IA place du bleu. Le joueur qui commence peut être changé dans les Paramètres.';

  @override
  String get helpScoringTitle => 'Score';

  @override
  String get helpScoringBase =>
      'Score de base : nombre de cases de votre couleur sur le plateau à la fin.';

  @override
  String get helpScoringBonus =>
      'Bonus : +50 points pour chaque ligne ou colonne complète de votre couleur.';

  @override
  String get helpScoringTotal => 'Score total : base + bonus.';

  @override
  String get helpScoringEarning =>
      'Points gagnés pendant la partie (Rouge) : +1 par placement, +2 en plus si placé dans un coin, +2 pour chaque Bleu devenu Neutre, +3 pour chaque Neutre devenu Rouge, +50 pour chaque nouvelle ligne/colonne rouge complète.';

  @override
  String get helpScoringCumulative =>
      'Votre compteur de trophées ne fait qu’augmenter. Les points sont ajoutés après chaque partie terminée selon votre total Rouge. Les actions de l’adversaire ne réduisent jamais votre total cumulé.';

  @override
  String get helpWinningTitle => 'Victoire';

  @override
  String get helpWinningBody =>
      'Quand il n’y a plus de cases vides, la partie se termine. Le joueur avec le score total le plus élevé gagne. Les égalités sont possibles.';

  @override
  String get helpAiLevelTitle => 'Niveau de l’IA';

  @override
  String get helpAiLevelBody =>
      'Choisissez la difficulté de l’IA dans Paramètres (1–7). Les niveaux plus élevés anticipent davantage mais prennent plus de temps.';

  @override
  String get helpHistoryProfileTitle => 'Historique et profil';

  @override
  String get helpHistoryProfileBody =>
      'Vos parties terminées sont enregistrées dans l’historique avec tous les détails.';

  @override
  String get aiDifficultyTitle => 'Difficulté de l’IA';

  @override
  String get aiDifficultyTipBeginner =>
      'Blanc — Débutant : fait des coups aléatoires.';

  @override
  String get aiDifficultyTipEasy =>
      'Jaune — Facile : privilégie les gains immédiats.';

  @override
  String get aiDifficultyTipNormal =>
      'Orange — Normal : gourmand avec un positionnement basique.';

  @override
  String get aiDifficultyTipChallenging =>
      'Vert — Difficile : recherche superficielle avec un peu de prévoyance.';

  @override
  String get aiDifficultyTipHard =>
      'Bleu — Très difficile : recherche plus profonde avec élagage.';

  @override
  String get aiDifficultyTipExpert =>
      'Marron — Expert : élagage avancé et cache.';

  @override
  String get aiDifficultyTipMaster =>
      'Noir — Maître : le plus fort et le plus calculateur.';

  @override
  String get aiDifficultyTipSelect => 'Sélectionnez un niveau de ceinture.';

  @override
  String get aiDifficultyDetailBeginner =>
      'Blanc — Débutant : cases vides aléatoires. Imprévisible mais faible.';

  @override
  String get aiDifficultyDetailEasy =>
      'Jaune — Facile : coups gourmands qui maximisent le gain immédiat.';

  @override
  String get aiDifficultyDetailNormal =>
      'Orange — Normal : gourmand avec départage au centre pour privilégier de meilleures positions.';

  @override
  String get aiDifficultyDetailChallenging =>
      'Vert — Difficile : minimax superficiel (profondeur 2), sans élagage.';

  @override
  String get aiDifficultyDetailHard =>
      'Bleu — Très difficile : minimax plus profond avec élagage alpha-bêta et ordre des coups.';

  @override
  String get aiDifficultyDetailExpert =>
      'Marron — Expert : minimax plus profond avec élagage + table de transposition.';

  @override
  String get aiDifficultyDetailMaster =>
      'Noir — Maître : Monte Carlo Tree Search (~1500 simulations dans la limite de temps).';

  @override
  String get aiDifficultyDetailSelect =>
      'Sélectionnez la difficulté de l’IA pour voir les détails.';

  @override
  String get currentAiLevelLabel => 'Niveau actuel de l’IA';

  @override
  String aiLevelDisplay(Object belt, Object level) {
    return '$belt ($level)';
  }

  @override
  String get resultsTitle => 'Résultats';

  @override
  String get timePlayedLabel => 'Temps de jeu';

  @override
  String get redTurnsLabel => 'Tours rouges';

  @override
  String get blueTurnsLabel => 'Tours bleus';

  @override
  String get yellowTurnsLabel => 'Tours jaunes';

  @override
  String get greenTurnsLabel => 'Tours verts';

  @override
  String get playerTurnsLabel => 'Tours du joueur';

  @override
  String get aiTurnsLabel => 'Tours de l’IA';

  @override
  String playerTurnStatus(Object player) {
    return '$player player turn';
  }

  @override
  String get newBestScoreLabel => 'Nouveau meilleur score';

  @override
  String pointsBelowBestScore(Object points) {
    return '$points points sous le meilleur score';
  }

  @override
  String youWinReachedScore(Object score) {
    return 'Vous avez gagné et atteint $score points';
  }

  @override
  String get redTerritoryControlled => 'Territoire du joueur rouge contrôlé.';

  @override
  String get blueTerritoryControlled => 'Territoire du joueur bleu contrôlé.';

  @override
  String get neutralTerritoryControlled => 'Territoire neutre contrôlé.';

  @override
  String get territoryBalanced => 'Territoire équilibré.';

  @override
  String get performanceLost => 'Vous avez perdu. Stratégie requise.';

  @override
  String get performanceBrilliantEndgame => 'Fin de partie brillante';

  @override
  String get performanceGreatControl => 'Excellent contrôle';

  @override
  String get performanceRiskyEffective => 'Risqué, mais efficace';

  @override
  String get performanceSolidStrategy => 'Stratégie solide';

  @override
  String get playAgainLabel => 'Rejouer';

  @override
  String get continueNextAiLevelLabel => 'Continuer au niveau d’IA suivant';

  @override
  String get playLowerAiLevelLabel => 'Jouer un niveau d’IA inférieur';

  @override
  String get replaySameLevelLabel => 'Rejouer le même niveau';

  @override
  String get aiThinkingLabel => 'L’IA réfléchit...';

  @override
  String get simulatingGameLabel => 'Simulation en cours...';

  @override
  String get noTurnsYetMessage => 'Aucun tour pour cette partie';

  @override
  String turnLabel(Object turn) {
    return 'Tour $turn';
  }

  @override
  String get undoLastActionTooltip => 'Annuler la dernière action';

  @override
  String get historyTabGames => 'Parties';

  @override
  String get historyTabDailyActivity => 'Activité quotidienne';

  @override
  String get noFinishedGamesYet => 'Aucune partie terminée';

  @override
  String gamesCountLabel(Object count) {
    return 'Parties : $count';
  }

  @override
  String get winsLabel => 'Victoires';

  @override
  String get lossesLabel => 'Défaites';

  @override
  String get drawsLabel => 'Matchs nuls';

  @override
  String get totalTimeLabel => 'Temps total';

  @override
  String get resultDraw => 'Match nul';

  @override
  String get resultPlayerWins => 'Le joueur gagne';

  @override
  String get resultAiWins => 'L’IA gagne';

  @override
  String aiLabelWithName(Object name) {
    return 'IA : $name';
  }

  @override
  String winnerLabel(Object result) {
    return 'Gagnant : $result';
  }

  @override
  String get yourScoreLabel => 'Votre score';

  @override
  String get timeLabel => 'Temps';

  @override
  String get redBaseLabel => 'Base rouge';

  @override
  String get blueBaseLabel => 'Base bleue';

  @override
  String get totalBlueLabel => 'Total bleu';

  @override
  String get turnsRedLabel => 'Tours R';

  @override
  String get turnsBlueLabel => 'Tours B';

  @override
  String get ageLabel => 'Âge';

  @override
  String get nicknameLabel => 'Pseudo';

  @override
  String get enterNicknameHint => 'Entrez un pseudo';

  @override
  String get countryLabel => 'Pays';

  @override
  String get beltsTitle => 'Ceintures';

  @override
  String get achievementsTitle => 'Succès';

  @override
  String get achievementFullRow => 'Ligne complète';

  @override
  String get achievementFullColumn => 'Colonne complète';

  @override
  String get achievementDiagonal => 'Diagonale';

  @override
  String get achievement100GamePoints => '100 points de jeu';

  @override
  String get achievement1000GamePoints => '1000 points de jeu';

  @override
  String get nicknameRequiredError => 'Le pseudo est requis';

  @override
  String get nicknameMaxLengthError => 'Maximum 32 caractères';

  @override
  String get nicknameInvalidCharsError =>
      'Utilisez lettres, chiffres, point, tiret ou underscore';

  @override
  String get nicknameUpdatedMessage => 'Pseudo mis à jour';

  @override
  String get noBeltsEarnedYetMessage =>
      'Aucune ceinture gagnée pour le moment.';

  @override
  String get whoStartsFirstLabel => 'Qui commence';

  @override
  String get whoStartsFirstTip =>
      'If no turns have been made, changes apply immediately; otherwise they take effect in the next game.';

  @override
  String get startingPlayerHuman => 'Humain (Rouge)';

  @override
  String get startingPlayerAi => 'IA (Bleu)';

  @override
  String get leaveDuelBarrierLabel => 'Quitter le duel';

  @override
  String get leaveDuelTitle => 'Quitter le duel';

  @override
  String get leaveDuelMessage =>
      'Quitter le mode duel et revenir au menu principal ?\n\nLa progression ne sera pas enregistrée.';

  @override
  String get leaveBarrierLabel => 'Quitter';

  @override
  String leaveModeTitle(Object mode) {
    return 'Quitter $mode';
  }

  @override
  String get leaveMultiModeMessage =>
      'Revenir au menu principal ?\n\nLa progression ne sera pas enregistrée.';

  @override
  String get colorRedLabel => 'ROUGE';

  @override
  String get colorBlueLabel => 'BLEU';

  @override
  String get colorYellowLabel => 'JAUNE';

  @override
  String get colorGreenLabel => 'VERT';

  @override
  String get redShortLabel => 'R';

  @override
  String get blueShortLabel => 'B';

  @override
  String get yellowShortLabel => 'J';

  @override
  String get greenShortLabel => 'V';

  @override
  String get supportTheDevLabel => 'Soutenir le développeur';

  @override
  String get aiBeltWhite => 'Blanc';

  @override
  String get aiBeltYellow => 'Jaune';

  @override
  String get aiBeltOrange => 'Orange';

  @override
  String get aiBeltGreen => 'Vert';

  @override
  String get aiBeltBlue => 'Bleu';

  @override
  String get aiBeltBrown => 'Marron';

  @override
  String get aiBeltBlack => 'Noir';

  @override
  String get scorePlace => '+1 placement';

  @override
  String get scoreCorner => '+2 coin';

  @override
  String scoreBlueToGrey(Object count) {
    return '+2 x$count bleu→gris';
  }

  @override
  String scoreGreyToRed(Object count) {
    return '+3 x$count gris→rouge';
  }

  @override
  String get scorePlaceShort => 'Placer';

  @override
  String get scoreZeroBlow => '0 coup';

  @override
  String get scoreZeroGreyDrop => '0 chute grise';

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
        'Albania': 'Albanie',
        'Algeria': 'Algérie',
        'Andorra': 'Andorre',
        'Angola': 'Angola',
        'Antigua_and_Barbuda': 'Antigua-et-Barbuda',
        'Argentina': 'Argentine',
        'Armenia': 'Arménie',
        'Australia': 'Australie',
        'Austria': 'Autriche',
        'Azerbaijan': 'Azerbaïdjan',
        'Bahamas': 'Bahamas',
        'Bahrain': 'Bahreïn',
        'Bangladesh': 'Bangladesh',
        'Barbados': 'Barbade',
        'Belarus': 'Biélorussie',
        'Belgium': 'Belgique',
        'Belize': 'Belize',
        'Benin': 'Bénin',
        'Bhutan': 'Bhoutan',
        'Bolivia': 'Bolivie',
        'Bosnia_and_Herzegovina': 'Bosnie-Herzégovine',
        'Botswana': 'Botswana',
        'Brazil': 'Brésil',
        'Brunei': 'Brunei',
        'Bulgaria': 'Bulgarie',
        'Burkina_Faso': 'Burkina Faso',
        'Burundi': 'Burundi',
        'Cabo_Verde': 'Cabo Verde',
        'Cambodia': 'Cambodge',
        'Cameroon': 'Cameroun',
        'Canada': 'Canada',
        'Central_African_Republic': 'République centrafricaine',
        'Chad': 'Tchad',
        'Chile': 'Chili',
        'China': 'Chine',
        'Colombia': 'Colombie',
        'Comoros': 'Comores',
        'Congo_Congo_Brazzaville': 'Congo (Brazzaville)',
        'Costa_Rica': 'Costa Rica',
        'Croatia': 'Croatie',
        'Cuba': 'Cuba',
        'Cyprus': 'Chypre',
        'Czechia': 'Tchéquie',
        'Democratic_Republic_of_the_Congo': 'République démocratique du Congo',
        'Denmark': 'Danemark',
        'Djibouti': 'Djibouti',
        'Dominica': 'Dominique',
        'Dominican_Republic': 'République dominicaine',
        'Ecuador': 'Équateur',
        'Egypt': 'Égypte',
        'El_Salvador': 'Salvador',
        'Equatorial_Guinea': 'Guinée équatoriale',
        'Eritrea': 'Érythrée',
        'Estonia': 'Estonie',
        'Eswatini': 'Eswatini',
        'Ethiopia': 'Éthiopie',
        'Fiji': 'Fidji',
        'Finland': 'Finlande',
        'France': 'France',
        'Gabon': 'Gabon',
        'Gambia': 'Gambie',
        'Georgia': 'Géorgie',
        'Germany': 'Allemagne',
        'Ghana': 'Ghana',
        'Greece': 'Grèce',
        'Grenada': 'Grenade',
        'Guatemala': 'Guatemala',
        'Guinea': 'Guinée',
        'Guinea_Bissau': 'Guinée-Bissau',
        'Guyana': 'Guyana',
        'Haiti': 'Haïti',
        'Honduras': 'Honduras',
        'Hungary': 'Hongrie',
        'Iceland': 'Islande',
        'India': 'Inde',
        'Indonesia': 'Indonésie',
        'Iran': 'Iran',
        'Iraq': 'Irak',
        'Ireland': 'Irlande',
        'Israel': 'Israël',
        'Italy': 'Italie',
        'Jamaica': 'Jamaïque',
        'Japan': 'Japon',
        'Jordan': 'Jordanie',
        'Kazakhstan': 'Kazakhstan',
        'Kenya': 'Kenya',
        'Kiribati': 'Kiribati',
        'Kuwait': 'Koweït',
        'Kyrgyzstan': 'Kirghizistan',
        'Laos': 'Laos',
        'Latvia': 'Lettonie',
        'Lebanon': 'Liban',
        'Lesotho': 'Lesotho',
        'Liberia': 'Liberia',
        'Libya': 'Libye',
        'Liechtenstein': 'Liechtenstein',
        'Lithuania': 'Lituanie',
        'Luxembourg': 'Luxembourg',
        'Madagascar': 'Madagascar',
        'Malawi': 'Malawi',
        'Malaysia': 'Malaisie',
        'Maldives': 'Maldives',
        'Mali': 'Mali',
        'Malta': 'Malte',
        'Marshall_Islands': 'Îles Marshall',
        'Mauritania': 'Mauritanie',
        'Mauritius': 'Maurice',
        'Mexico': 'Mexique',
        'Micronesia': 'Micronésie',
        'Moldova': 'Moldavie',
        'Monaco': 'Monaco',
        'Mongolia': 'Mongolie',
        'Montenegro': 'Monténégro',
        'Morocco': 'Maroc',
        'Mozambique': 'Mozambique',
        'Myanmar': 'Myanmar',
        'Namibia': 'Namibie',
        'Nauru': 'Nauru',
        'Nepal': 'Népal',
        'Netherlands': 'Pays-Bas',
        'New_Zealand': 'Nouvelle-Zélande',
        'Nicaragua': 'Nicaragua',
        'Niger': 'Niger',
        'Nigeria': 'Nigeria',
        'North_Korea': 'Corée du Nord',
        'North_Macedonia': 'Macédoine du Nord',
        'Norway': 'Norvège',
        'Oman': 'Oman',
        'Pakistan': 'Pakistan',
        'Palau': 'Palaos',
        'Panama': 'Panama',
        'Papua_New_Guinea': 'Papouasie-Nouvelle-Guinée',
        'Paraguay': 'Paraguay',
        'Peru': 'Pérou',
        'Philippines': 'Philippines',
        'Poland': 'Pologne',
        'Portugal': 'Portugal',
        'Qatar': 'Qatar',
        'Romania': 'Roumanie',
        'Russia': 'Russie',
        'Rwanda': 'Rwanda',
        'Saint_Kitts_and_Nevis': 'Saint-Kitts-et-Nevis',
        'Saint_Lucia': 'Sainte-Lucie',
        'Saint_Vincent_and_the_Grenadines': 'Saint-Vincent-et-les-Grenadines',
        'Samoa': 'Samoa',
        'San_Marino': 'Saint-Marin',
        'Sao_Tome_and_Principe': 'Sao Tomé-et-Principe',
        'Saudi_Arabia': 'Arabie saoudite',
        'Senegal': 'Sénégal',
        'Serbia': 'Serbie',
        'Seychelles': 'Seychelles',
        'Sierra_Leone': 'Sierra Leone',
        'Singapore': 'Singapour',
        'Slovakia': 'Slovaquie',
        'Slovenia': 'Slovénie',
        'Solomon_Islands': 'Îles Salomon',
        'Somalia': 'Somalie',
        'South_Africa': 'Afrique du Sud',
        'South_Korea': 'Corée du Sud',
        'South_Sudan': 'Soudan du Sud',
        'Spain': 'Espagne',
        'Sri_Lanka': 'Sri Lanka',
        'Sudan': 'Soudan',
        'Suriname': 'Suriname',
        'Sweden': 'Suède',
        'Switzerland': 'Suisse',
        'Syria': 'Syrie',
        'Taiwan': 'Taïwan',
        'Tajikistan': 'Tadjikistan',
        'Tanzania': 'Tanzanie',
        'Thailand': 'Thaïlande',
        'Timor_Leste': 'Timor oriental',
        'Togo': 'Togo',
        'Tonga': 'Tonga',
        'Trinidad_and_Tobago': 'Trinité-et-Tobago',
        'Tunisia': 'Tunisie',
        'Turkey': 'Turquie',
        'Turkmenistan': 'Turkménistan',
        'Tuvalu': 'Tuvalu',
        'Uganda': 'Ouganda',
        'Ukraine': 'Ukraine',
        'United_Arab_Emirates': 'Émirats arabes unis',
        'United_Kingdom': 'Royaume-Uni',
        'United_States': 'États-Unis',
        'Uruguay': 'Uruguay',
        'Uzbekistan': 'Ouzbékistan',
        'Vanuatu': 'Vanuatu',
        'Vatican_City': 'Cité du Vatican',
        'Venezuela': 'Venezuela',
        'Vietnam': 'Viêt Nam',
        'Yemen': 'Yémen',
        'Zambia': 'Zambie',
        'Zimbabwe': 'Zimbabwe',
        'other': 'Wakanda',
      },
    );
    return '$_temp0';
  }

  @override
  String get deleteSaveTitle => 'Supprimer la sauvegarde ?';

  @override
  String get deleteSaveMessage =>
      'Voulez-vous vraiment supprimer cette partie sauvegardée ?';

  @override
  String get failedToDeleteMessage => 'Échec de la suppression';

  @override
  String get webSaveGameNote =>
      'Note Web : votre sauvegarde sera stockée dans le stockage local de ce navigateur pour ce site. Elle ne se synchronise pas entre appareils ni en navigation privée.';

  @override
  String get webLoadGameNote =>
      'Note Web : la liste ci-dessous provient du stockage local de ce navigateur pour ce site (non partagé avec d’autres navigateurs ni les fenêtres privées).';
}
