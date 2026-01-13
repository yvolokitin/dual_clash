import 'campaign_level.dart';

class CampaignMetadata {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final bool isUnlocked;
  final int totalLevels;
  final List<CampaignLevel> levels;

  const CampaignMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.isUnlocked,
    required this.totalLevels,
    required this.levels,
  });
}
