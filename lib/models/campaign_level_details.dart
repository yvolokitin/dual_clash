class CampaignLevelDetails {
  final String title;
  final String description;
  final String hint;

  const CampaignLevelDetails({
    required this.title,
    required this.description,
    required this.hint,
  });
}

const Map<int, CampaignLevelDetails> buddhaCampaignLevelDetails = {
  1: CampaignLevelDetails(
    title: 'First Breath',
    description:
        'Your journey begins. Make your first move and feel the balance of the board.',
    hint: 'Start with calm expansion and secure the center.',
  ),
  2: CampaignLevelDetails(
    title: 'Still Mind',
    description:
        'Patience reveals opportunities. The simplest move can be the strongest.',
    hint: 'Wait for clean openings before you commit.',
  ),
  3: CampaignLevelDetails(
    title: 'Center Focus',
    description: 'Control the center early to shape the game in your favor.',
    hint: 'Anchor your presence around the middle tiles.',
  ),
  4: CampaignLevelDetails(
    title: 'Silent Expansion',
    description:
        'Grow your presence quietly without exposing yourself too soon.',
    hint: 'Spread steadily without overextending.',
  ),
  5: CampaignLevelDetails(
    title: 'Balanced Steps',
    description: 'Every move matters. Think one step ahead.',
    hint: 'Trade safely and keep your options open.',
  ),
  6: CampaignLevelDetails(
    title: 'Pressure Appears',
    description: 'The opponent gains ground. Find stability under pressure.',
    hint: 'Stabilize your borders before pushing forward.',
  ),
  7: CampaignLevelDetails(
    title: 'Calm Under Threat',
    description: 'Maintain control even when space is limited.',
    hint: 'Protect key tiles when space tightens.',
  ),
  8: CampaignLevelDetails(
    title: 'Narrow Paths',
    description: 'The board tightens. Choose your direction carefully.',
    hint: 'Commit to one strong lane of control.',
  ),
  9: CampaignLevelDetails(
    title: 'Measured Risk',
    description: 'Risk can be powerful—when it is calculated.',
    hint: 'Take only the risks that swing the center.',
  ),
  10: CampaignLevelDetails(
    title: 'Turning Point',
    description: 'One precise move can change everything.',
    hint: 'Look for the single move that shifts momentum.',
  ),
  11: CampaignLevelDetails(
    title: 'Quiet Dominance',
    description: 'Win through position, not aggression.',
    hint: 'Hold space instead of chasing battles.',
  ),
  12: CampaignLevelDetails(
    title: 'Lines of Influence',
    description: 'Placement matters more than numbers.',
    hint: 'Shape the board with strong positioning.',
  ),
  13: CampaignLevelDetails(
    title: 'Space Awareness',
    description: 'Learn to value empty space as much as occupied tiles.',
    hint: 'Leave space that supports future swings.',
  ),
  14: CampaignLevelDetails(
    title: 'Inner Balance',
    description: 'Balance attack and defense with clarity.',
    hint: 'Alternate pressure and protection evenly.',
  ),
  15: CampaignLevelDetails(
    title: 'The Bomb Lesson',
    description: 'Destruction is a tool, not the goal.',
    hint: 'Use bombs to reset control, not to chase.',
  ),
  16: CampaignLevelDetails(
    title: 'After the Impact',
    description: 'Think beyond the explosion and plan what follows.',
    hint: 'Plan your follow-up before detonating.',
  ),
  17: CampaignLevelDetails(
    title: 'Controlled Chaos',
    description: 'Chaos can be shaped with a clear mind.',
    hint: 'Stabilize quickly after a chaotic turn.',
  ),
  18: CampaignLevelDetails(
    title: 'Reading Intentions',
    description: 'Anticipate your opponent instead of reacting blindly.',
    hint: 'Predict the next strike and block it early.',
  ),
  19: CampaignLevelDetails(
    title: 'Defensive Wisdom',
    description: 'A strong defense can be the best offense.',
    hint: 'Build a wall before you push out.',
  ),
  20: CampaignLevelDetails(
    title: 'One Chance',
    description: 'There is no room for error here. Precision is key.',
    hint: 'Choose moves that guarantee safe gains.',
  ),
  21: CampaignLevelDetails(
    title: 'Endgame Calm',
    description: 'When the board is full, every tile counts.',
    hint: 'Prioritize stable control in the final turns.',
  ),
  22: CampaignLevelDetails(
    title: 'No Rush',
    description: 'Haste clouds judgment. Stay composed.',
    hint: 'Slow down and secure your core tiles.',
  ),
  23: CampaignLevelDetails(
    title: 'Fragile Advantage',
    description: 'An advantage is powerful only if protected.',
    hint: 'Protect your lead before expanding.',
  ),
  24: CampaignLevelDetails(
    title: 'Final Balance',
    description: 'Hold control when everything is on the edge.',
    hint: 'Guard the balance line and avoid swings.',
  ),
  25: CampaignLevelDetails(
    title: 'Almost There',
    description: 'The goal is close—but focus remains essential.',
    hint: 'Close out the board with steady control.',
  ),
  26: CampaignLevelDetails(
    title: 'Clear Mind',
    description: 'Remove distractions. Only the right move remains.',
    hint: 'Simplify the board and claim safe tiles.',
  ),
  27: CampaignLevelDetails(
    title: 'Last Patterns',
    description: 'Apply everything you have learned so far.',
    hint: 'Combine defense and timing in one plan.',
  ),
  28: CampaignLevelDetails(
    title: 'Path of Control',
    description: 'The board yields to those who see the whole picture.',
    hint: 'Focus on long chains of influence.',
  ),
  29: CampaignLevelDetails(
    title: 'Enlightenment',
    description: 'True victory comes from complete understanding.',
    hint: 'Stay balanced and secure the final edge.',
  ),
};

CampaignLevelDetails campaignLevelDetailsFor({
  required String? campaignId,
  required int levelIndex,
}) {
  if (campaignId == 'buddha') {
    return buddhaCampaignLevelDetails[levelIndex] ??
        CampaignLevelDetails(
          title: 'Level $levelIndex',
          description: 'Maintain control and outmaneuver the opponent.',
          hint: 'Hold key tiles and expand with purpose.',
        );
  }
  return CampaignLevelDetails(
    title: 'Level $levelIndex',
    description: 'Maintain control and outmaneuver the opponent.',
    hint: 'Hold key tiles and expand with purpose.',
  );
}
