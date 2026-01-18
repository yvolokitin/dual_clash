# Campaign Modes and Selection

This document defines the final campaign order, default selection behavior, persistence keys, and per‑campaign gameplay mode configuration for Dual Clash.

## Campaign Order (Fixed)
Campaigns are always presented in this exact order on the Campaign screen:
1) Buddha (Easy)
2) Ganesha (Medium)
3) Shiva (Hard)

The order never changes, regardless of progress.

## Default Selection and Remembered Campaign
- On fresh install or when no previous selection exists, the Campaign screen auto‑selects Buddha.
- When the player switches campaigns, the selection is immediately persisted.
- On next open (including after app restarts), the last active campaign is auto‑selected.
- Legacy key migration: if a legacy key exists, it will be read once and re‑saved under the new key.

### Keys
- New: `activeCampaignId` → values: `buddha`, `ganesha`, `shiva`.
- Legacy (read‑only fallback): `campaign_last_played` → migrated to `activeCampaignId` when seen.

## Persistence Keys (Campaign Progress & Achievements)
- Per‑campaign progress map (level status: locked/available/passed/failed):
  - `campaign_progress_<campaignId>`
- Per‑campaign results history (list of played results by level):
  - `campaign_results_<campaignId>`
- Per‑campaign best result cache (best per level):
  - `campaign_best_results_<campaignId>`
- Per‑campaign highest completed level (monotonic):
  - `campaign_highest_completed_<campaignId>` → integer level index (1..29)
- Campaign achievements (unlocked once on completion of level 29):
  - `campaign_achievements` → map of `{ 'ACH_BUDDHA': true, 'ACH_GANESHA': true, 'ACH_SHIVA': true }`

Notes:
- “Highest completed” is updated after wins and during progress load to ensure consistency.
- Achievements are idempotent – unlocking sets the corresponding flag once.

## Per‑Campaign Gameplay Modes (Fixed per campaign)
Global board size is fixed per campaign level at 7×7. Each campaign has 29 levels.

- Buddha (Easy)
  - InfectionResolutionMode: `neutralIntermediary` (gray enabled)
  - InfectionAdjacencyMode: `orthogonal4` (no diagonals)
  - Bombs: disabled (calm control, safety buffer)

- Ganesha (Medium)
  - InfectionResolutionMode: `neutralIntermediary` (gray enabled)
  - InfectionAdjacencyMode: `orthogonalPlusDiagonal8` (diagonals enabled)
  - Bombs: limited, per‑level flag from campaign level definitions

- Shiva (Hard)
  - InfectionResolutionMode: `directTransfer` (no gray intermediary)
  - InfectionAdjacencyMode: `orthogonalPlusDiagonal8` (diagonals enabled)
  - Bombs: always enabled (core mechanic)

## Validation Checklist
- On a fresh install, Campaign screen opens with Buddha selected.
- After starting or switching to Ganesha, reopening Campaign screen auto‑selects Ganesha.
- After app restart, the last active campaign is restored correctly.
- Campaign order is always Buddha → Ganesha → Shiva.
- Gameplay rules match campaign difficulty expectations.
- Completing level 29 unlocks the corresponding campaign achievement and it persists across sessions.
