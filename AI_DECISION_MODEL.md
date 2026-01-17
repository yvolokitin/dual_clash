# AI Decision Model

This document describes the improved, mode‑aware AI decision model for Dual Clash. It separates action generation from evaluation and explicitly reasons about the three gameplay inputs:

- InfectionResolutionMode
  - neutralIntermediary (gray exists)
  - directTransfer (no gray)
- InfectionAdjacencyMode
  - orthogonal4
  - orthogonalPlusDiagonal8
- Bomb mechanics
  - Placement, Ownership, Detonation (owner‑only)

The goal is improved AI quality: different strategies per mode while preserving correctness.


## Action Set (per AI turn)

On every AI turn, the model considers the following actions when they are legal:
- Placement (place a blue tile on an empty cell)
- Bomb placement (if bombs are enabled and available)
- Bomb detonation (owned bombs only and only when activatable)
- Gray drop (ONLY if resolution = neutralIntermediary and at least one gray exists)

Legality is enforced by GameController (cooldowns, ownership, turn gating, etc.).


## Separation of Concerns

- Move generation: UI/controller determines which action types are available (e.g., which cells are empty, bomb targets, detonatable bombs). This logic already exists in GameController and RulesEngine.
- Evaluation: AiDecisionModel assigns a numeric value to each candidate action. Selection logic compares scores and chooses the best (subject to difficulty level behavior).

All evaluation relies on centralized providers:
- Adjacency: via `adjacency.dart` (no hardcoded 4 or 8 neighbors in AI)
- Infection resolution: via `RulesEngine.place(...)` → `InfectionResolution.applyUsingDefaults(...)`


## Implementation

- File: `lib/logic/ai_decision_model.dart`
- Public API:
  - `evaluatePlacement(board, r, c, attacker, {bombs}) -> double`
    - Simulates the placement using `RulesEngine.place` (which composes adjacency + resolution) and scores it.
    - Base score: board‑control swing (Blue vs Red). If evaluating Red, sign is flipped for symmetry.
    - Resolution impact:
      - `neutralIntermediary`: neutrals are valued as tactical buffers (mild positive for Blue; negative for Red when evaluating symmetry).
      - `directTransfer`: amplifies immediate gain to encourage aggression.
    - Adjacency impact:
      - `orthogonalPlusDiagonal8`: extra weight for local change density; favors multi‑capture.
    - Bomb risk: penalty for placing adjacent (orthogonally) to enemy bombs.
  - `bestPlacement(board, attacker, {bombs}) -> ({r,c,score})?`
    - Scans empty cells and returns the best evaluated cell (ties broken randomly).
  - `evaluateBombPlacement(board, r, c, owner) -> double`
    - Estimates value of planting a bomb by counting enemies vs self in the blast cross, adds centrality and density nudges. Biases slightly higher when adjacency is 8‑way (more clustering, bigger swings likely).

GameController integrates these scores into `_scheduleAi()` and composes them with existing blow/grey/bomb gating and higher‑level strategies.


## Mode‑Aware Evaluation (Heuristics)

### A) InfectionResolutionMode impact
- neutralIntermediary
  - Gray cells are tactical buffers; the model rewards creating gray clusters and converting gray to the attacker on placement.
  - Gray drop is available; its consideration remains in the controller (0 points but can improve position by clearing blockers).
- directTransfer
  - No gray exists; gray heuristics are disabled.
  - Placements favor immediate territory gain; evaluator slightly boosts aggression.

### B) InfectionAdjacencyMode impact
- orthogonal4
  - Central control and lines are more valuable; evaluator includes a mild centrality bonus.
- orthogonalPlusDiagonal8
  - Multi‑capture potential increases; evaluator boosts local change density.
  - Bomb placement becomes more appealing in dense areas; evaluator adds a small density bonus and extra nudge for multiple hits.


## Bomb‑Aware Reasoning

- Bomb placement is a first‑class action: evaluated with enemies‑vs‑self blast accounting and positional bonuses.
- Detonation: only bombs owned by the AI are considered; selection still uses existing swing and win‑rate tie‑breaks in controller.
- Avoidance: placement scoring penalizes placing next to enemy bombs (orthogonal neighbors), reducing risky moves.
- Independence: infection adjacency does not change blast shape; evaluator respects the fixed cross blast.


## Examples of Good vs Bad Moves

Legend: X = attacker (Blue for AI), O = opponent (Red), N = Neutral, • = empty, B = Bomb

1) neutralIntermediary × orthogonal4
- Good: Place X adjacent to multiple O, turning them into N and possibly converting nearby N to X. Creates gray buffers and gains space.
- Bad: Place X far from any interaction, creating few changes and no buffers.

2) neutralIntermediary × orthogonalPlusDiagonal8
- Good: Place X where orthogonal and diagonal neighbors include O and N, maximizing simultaneous conversions (O→N and N→X). Consider bombs in dense clusters.
- Bad: Place X on the rim with no neighbors affected; wastes the diagonal potential.

3) directTransfer × orthogonal4
- Good: Place X to directly flip several orthogonal O to X; aggressive gain is preferred.
- Bad: Moves that only add a single X without capturing neighbors, especially when central captures are available.

4) directTransfer × orthogonalPlusDiagonal8
- Good: Place X in high‑density spots where many orthogonal+diagonal O flip directly to X; consider bomb placement to threaten large swings.
- Bad: Moves that ignore diagonal captures and fail to leverage the expanded adjacency.


## Validation Checklist

- AI plays noticeably more aggressively in directTransfer (higher immediate gain weight).
- AI uses bombs proactively (bomb placement evaluated positively when it hits multiple enemies), not only reactively.
- AI avoids illegal actions (enemy bomb detonation, gray actions in direct mode are gated externally by controller).
- Behavior differs across the 4 mode combinations due to evaluation terms (gray valuation, density bonuses).
- No regressions in default mode (neutralIntermediary × orthogonal4); rules and scoring formulas unchanged.


## Why Keep Evaluation Centralized and Mode‑Aware

- Consistency: All placements are simulated via RulesEngine + InfectionResolution; no neighbor hardcoding in AI.
- Composability: Adjacency and resolution remain independent; AI composes them naturally through simulation.
- Extensibility: New heuristics or modes can be added in AiDecisionModel without touching UI or the rules engines.
