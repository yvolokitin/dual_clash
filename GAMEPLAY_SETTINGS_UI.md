# Gameplay Settings UI Integration

This document describes the user-facing Settings integration for gameplay modes and the associated UI/HUD gating rules. It builds on the configuration axes defined in GAMEPLAY_MODES_DESIGN.md and the centralized providers implemented earlier.


## Final Setting Names and Option Labels

1) Infection Resolution
- Options:
  - Two-Step (Gray Cells)
  - Direct Capture
- Tooltip:
  "Controls whether opponent cells are captured instantly or first converted to neutral (gray)."

2) Adjacency Rules
- Options:
  - Sides Only (4 directions)
  - Sides + Diagonals (8 directions)
- Tooltip:
  "Defines which neighboring cells can be affected during capture."


## Configuration Architecture

- Central config object: GameRulesConfig
  - resolutionMode: InfectionResolutionMode
    - neutralIntermediary (default)
    - directTransfer
  - adjacencyMode: InfectionAdjacencyMode
    - orthogonal4 (default)
    - orthogonalPlusDiagonal8

- Persistence: Stored in SharedPreferences by GameController with keys
  - resolutionMode: 'neutral' | 'direct'
  - adjacencyMode: 'orthogonal4' | 'orthogonalPlusDiagonal8'

- Consumers:
  - RulesEngine / MultiRulesEngine via InfectionResolution + Adjacency
  - AI simulations via RulesEngine.place (indirect)
  - UI/HUD gating via GameRulesConfig.current


## UI Wiring

- Settings dialog (lib/ui/pages/settings_page.dart):
  - Two new sections added with the labels and tooltips above.
  - Local state mirrors GameRulesConfig.current and saves through:
    - GameController.setResolutionMode(InfectionResolutionMode)
    - GameController.setAdjacencyMode(InfectionAdjacencyMode)
  - Defaults reflect legacy behavior on first run:
    - Two-Step (Gray Cells)
    - Sides Only (4 directions)


## HUD / UI Gating Rules

When Infection Resolution = Direct Capture:
- Gray cells must not appear in score/HUD elements.
- Gray-related labels or counters are hidden.
- Gray-drop interactions remain disabled (already gated in logic).

Implementation references:
- GamePage (lib/ui/pages/game_page.dart):
  - GamePageScoreRow.showNeutral is set to (resolutionMode == neutralIntermediary).
- DuelPage (lib/ui/pages/duel_page.dart):
  - Score row conditionally shows neutral count/icon only when neutralIntermediary.
  - Leader highlighting calculations exclude neutrals when directTransfer is active.
- ResultsCard (lib/ui/widgets/results_card.dart):
  - Neutral tile is only included when neutralIntermediary.
  - Challenge winner logic that previously considered neutrals is unchanged for neutralIntermediary, and neutrals are omitted from tiles when directTransfer.


## Defaults Confirmation

- Defaults preserve legacy gameplay exactly:
  - Infection Resolution: neutralIntermediary
  - Adjacency Rules: orthogonal4
- Gameplay, scoring, AI heuristics, and bomb/explosion behavior remain unchanged by default.


## Notes

- No rebalancing of scoring or AI heuristics has been made.
- No changes to bomb or explosion adjacency (still orthogonal cross).
- These settings are independent, matching the design contract: adjacency choice does not imply gray usage, and resolution choice does not change the adjacency graph.
