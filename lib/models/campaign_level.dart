class CampaignLevel {
  final int index;
  final int boardSize;
  final int aiLevel;
  final bool bombsEnabled;

  const CampaignLevel({
    required this.index,
    required this.boardSize,
    required this.aiLevel,
    required this.bombsEnabled,
  });
}

const List<CampaignLevel> campaignLevels = [
  CampaignLevel(index: 1, boardSize: 7, aiLevel: 1, bombsEnabled: false),
  CampaignLevel(index: 2, boardSize: 7, aiLevel: 1, bombsEnabled: false),
  CampaignLevel(index: 3, boardSize: 7, aiLevel: 2, bombsEnabled: false),
  CampaignLevel(index: 4, boardSize: 7, aiLevel: 2, bombsEnabled: false),
  CampaignLevel(index: 5, boardSize: 7, aiLevel: 3, bombsEnabled: false),
  CampaignLevel(index: 6, boardSize: 7, aiLevel: 3, bombsEnabled: false),
  CampaignLevel(index: 7, boardSize: 7, aiLevel: 3, bombsEnabled: false),
  CampaignLevel(index: 8, boardSize: 7, aiLevel: 4, bombsEnabled: false),
  CampaignLevel(index: 9, boardSize: 8, aiLevel: 4, bombsEnabled: false),
  CampaignLevel(index: 10, boardSize: 8, aiLevel: 4, bombsEnabled: false),
  CampaignLevel(index: 11, boardSize: 8, aiLevel: 4, bombsEnabled: true),
  CampaignLevel(index: 12, boardSize: 8, aiLevel: 5, bombsEnabled: true),
  CampaignLevel(index: 13, boardSize: 8, aiLevel: 5, bombsEnabled: true),
  CampaignLevel(index: 14, boardSize: 8, aiLevel: 5, bombsEnabled: true),
  CampaignLevel(index: 15, boardSize: 8, aiLevel: 5, bombsEnabled: true),
  CampaignLevel(index: 16, boardSize: 8, aiLevel: 6, bombsEnabled: true),
  CampaignLevel(index: 17, boardSize: 8, aiLevel: 6, bombsEnabled: true),
  CampaignLevel(index: 18, boardSize: 8, aiLevel: 6, bombsEnabled: true),
  CampaignLevel(index: 19, boardSize: 9, aiLevel: 6, bombsEnabled: true),
  CampaignLevel(index: 20, boardSize: 9, aiLevel: 6, bombsEnabled: true),
  CampaignLevel(index: 21, boardSize: 9, aiLevel: 6, bombsEnabled: true),
  CampaignLevel(index: 22, boardSize: 9, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(index: 23, boardSize: 9, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(index: 24, boardSize: 9, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(index: 25, boardSize: 9, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(index: 26, boardSize: 9, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(index: 27, boardSize: 9, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(index: 28, boardSize: 9, aiLevel: 7, bombsEnabled: true),
  CampaignLevel(index: 29, boardSize: 9, aiLevel: 7, bombsEnabled: true),
];
