# Campaign Difficulty & Design

This document defines the unified campaign structure and core gameplay rules for Dual Clash campaigns. All campaigns are standardized to a 7×7 board and differentiated by fixed rule presets, level pacing, and bomb philosophy.

## Summary

- Board size: 7×7 only
- No dynamic board size changes inside campaigns
- No diagonal infection in any campaign
- Each campaign has a fixed ruleset across all its levels
- Each campaign has 29 levels (1–29)
- Completing level 29 unlocks a unique campaign achievement (once per campaign)

## Campaign Overview

| Campaign | Theme                                   | Difficulty | Rules (fixed)                                                                                          | Bomb Philosophy                                                | Achievement ID |
|---------|-----------------------------------------|------------|--------------------------------------------------------------------------------------------------------|---------------------------------------------------------------|----------------|
| Buddha  | Calm control, balance, clarity          | Easy       | Resolution: neutralIntermediary (gray ON); Adjacency: orthogonal4; Direct capture: not allowed        | Levels 1–10: disabled; 11–20: available (optional); 21–29: allowed, never required | ACH_BUDDHA     |
| Ganesha | Obstacles, clever paths, foresight      | Medium     | Resolution: neutralIntermediary (gray ON); Adjacency: orthogonal4; Direct capture: not allowed        | Available but limited throughout; often required to unlock paths | ACH_GANESHA    |
| Shiva   | Aggression, chaos, decisive strikes     | Hard       | Resolution: directTransfer (no gray); Adjacency: orthogonal4; Gray mechanics completely disabled      | Core mechanic; high availability; AI places and detonates      | ACH_SHIVA      |

Notes:
- “Direct capture” being disallowed means gray intermediaries are used (neutralIntermediary). When directTransfer is active (Shiva), gray mechanics are fully disabled.
- Adjacency is 4‑way (no diagonals) in all campaigns.

## Global Rules (apply to all campaigns)

- Board size is fixed at 7×7 across all campaign levels.
- Difficulty progression should come from puzzle setups, constraints, and AI pressure — not board size.
- No diagonals for infection or adjacency.
- Each campaign unlocks exactly one achievement on completion of level 29.

## Level Counts and Structure

- 29 levels per campaign: indices 1 through 29.
- The shared level list uses 7×7 layouts only. Former 8×8/9×9 layouts have been retired or normalized.

## Bomb Usage Philosophy (per campaign)

- Buddha
  - 1–10: bombs disabled.
  - 11–20: bombs available in select levels; optional tool for reset/control.
  - 21–29: bombs allowed but never required to win.
  - Design: teach careful reading, buffer with gray, reward patience.

- Ganesha
  - Bombs are available but limited; often required to open paths or bypass walls/obstacles.
  - Design: introduce walls, asymmetric setups, encourage 2–3 moves foresight and “aha!” solutions.

- Shiva
  - Bombs are core: plentiful and used by AI with high pressure.
  - Design: fast tempo, punishing mistakes, direct ownership transfers, minimal margin for error.

## Achievement Unlock Rules

- Three achievements are registered and persisted via SharedPreferences under a single key:
  - ACH_BUDDHA — unlocked on winning level 29 of Buddha campaign.
  - ACH_GANESHA — unlocked on winning level 29 of Ganesha campaign.
  - ACH_SHIVA — unlocked on winning level 29 of Shiva campaign.
- Unlock is idempotent — achievements are stored as booleans and won’t re‑unlock twice.

## Implementation Notes

- Rule presets are applied when a campaign level starts (GamePage) and restored upon exit, ensuring:
  - Buddha/Ganesha: neutralIntermediary + orthogonal4
  - Shiva: directTransfer + orthogonal4
- Campaign levels are standardized to boardSize: 7. Any legacy fixed states that were 8×8/9×9 are omitted or replaced by default 7×7 starts.
- The level flow persists progress and best results and allows retry/continue to next level.
