# Gameplay Modes Design

This document defines a future‑proof gameplay configuration architecture for Dual Clash that separates WHAT rules exist from HOW they are implemented. It introduces two independent axes of configuration:

- Axis 1: Infection Resolution Mode — how cell ownership changes are resolved.
- Axis 2: Infection Adjacency Mode — which neighboring cells are affected by a placement.

The goal is a clean contract that logic, UI, and AI can rely on, while keeping these axes independent and reusable.

Note: This document describes configuration and contracts only. It does not propose UI, balance changes, or modify scoring rules at this time.


## Guiding Principles
- Decouple “what the rule is” from “how we compute it.”
- Model both axes as explicit configuration enums passed to rules/AI/UX layers.
- Treat gray (neutral) states as an optional resolution mechanism, not a fundamental board element.
- Treat adjacency as a reusable graph neighborhood rule, not hardcoded in conversion logic.
- Maintain backwards compatibility: the current shipped behavior equals a specific combination of the two axes.


## Axis 1: Infection Resolution Mode
Controls how ownership transitions are resolved when placing on an empty cell.

Proposed enum:
```dart
enum InfectionResolutionMode {
  // Ownership change resolves via a neutral (gray) intermediate state.
  // Enemies → Neutral; Neutral → Attacker. Gray-specific UI/scoring enabled.
  neutralIntermediary,

  // Ownership transfers directly. Enemies → Attacker. No gray states at all.
  // Gray-specific UI/scoring disabled.
  directTransfer,
}
```

What Axis 1 controls
- The state transition function applied to all “affected neighbors” during placement.
  - neutralIntermediary: Opponent colored neighbors become `neutral`; neutral neighbors become `attacker`.
  - directTransfer: Opponent colored neighbors become `attacker` directly; no `neutral` states are generated.
- Availability of gray‑specific actions and hooks:
  - Gray drop action: available only in `neutralIntermediary` mode.
  - Gray‑related scoring labels/hooks: applicable only in `neutralIntermediary` mode (see Scoring notes below).

What Axis 1 must NOT control
- Which neighbors are considered affected (that is Axis 2).
- The existence and behavior of bombs, walls, gravity, or blow/explosion rules.
- End‑of‑game line bonuses, base score definitions, or board size/shape.
- UI layout/animations or AI search depth/heuristics (only their access to the configured transition function).

Interaction with Axis 2
- Axis 2 provides the set of affected neighbors; Axis 1 defines how each affected neighbor changes state.
- Both axes must compose without special cases. For example, using diagonal adjacency with `neutralIntermediary` simply expands which cells can turn gray or be claimed, but does not alter the transition semantics.

Notes and ties to current baseline (from GAMEPLAY_ANALYSIS.md)
- Current behavior matches `neutralIntermediary` with orthogonal adjacency (see Axis 2):
  - Enemies→gray, gray→attacker; bombs/walls ignored for conversion.
  - Gray drop exists and awards 0 points; gray cells block placement and can be removed or converted.
- Design limitation referenced: gray drop is all‑or‑nothing and costs a turn; that limitation remains a separate feature decision and is not governed by this axis.
- Explicit clarification: gray cells are a resolution mechanism, not fundamental tiles. In `directTransfer`, gray states are disabled and should not appear.

Scoring notes (no changes proposed now)
- Per the baseline, gray‑related per‑move scoring (+2 enemy→gray, +3 gray→attacker) only applies in `neutralIntermediary` mode. In `directTransfer`, those specific hooks are inert. End‑of‑game line bonuses and base colored‑cell counts are unaffected by Axis 1 directly.


## Axis 2: Infection Adjacency Mode
Controls which neighbors of the placed cell are considered “affected” by the infection rule.

Proposed enum:
```dart
enum InfectionAdjacencyMode {
  // 4-way orthogonal neighbors: up, down, left, right.
  orthogonal4,

  // 8-way neighbors: orthogonal plus diagonals.
  orthogonalPlusDiagonal8,
}
```

What Axis 2 controls
- The neighborhood definition (graph edges) used to enumerate affected cells given a placement coordinate.
- The adjacency provider abstraction that logic/AI/UX use for previews, conversions, blow previews (where applicable), and heuristics.

What Axis 2 must NOT control
- The state transition semantics of affected neighbors (that is Axis 1).
- The presence of gray states, gray drop, or any gray‑specific scoring.
- Rules for bombs, walls, gravity, or end‑of‑game scoring. Those continue to be independent systems.

Interaction with Axis 1
- Axis 2 provides a reusable neighbor iterator or precomputed graph; Axis 1 applies the chosen transition to that set.
- Adjacency independence: enabling diagonal adjacency does not imply any change to whether gray exists. Both modes of Axis 1 must work with either adjacency definition.

Notes and ties to current baseline (from GAMEPLAY_ANALYSIS.md)
- Current implementation processes only 4 orthogonal neighbors. That corresponds to `orthogonal4`.
- A cited limitation was that diagonals never interact, potentially limiting tactical depth. Axis 2 addresses this by making adjacency configurable without touching transition semantics.
- Adjacency must be a reusable graph rule: do not hardcode orthogonal checks in transition logic; instead, dependency‑inject a neighbor provider (or use a configured strategy) so UI/AI share the same adjacency.


## Truth Table: Valid Combinations and Effects
All combinations of Axis 1 × Axis 2 are valid. Below, “affected neighbors” is determined solely by Axis 2; “state transition” by Axis 1.

| InfectionResolutionMode | InfectionAdjacencyMode       | Affected neighbors          | Result of placing on empty cell                                                                 | Gray actions & scoring |
|---|---|---|---|---|
| neutralIntermediary     | orthogonal4                   | 4-way (up, down, left, right) | Opponent colors → gray; gray → attacker; bombs/walls ignored. Matches current baseline.         | Gray drop enabled; gray scoring hooks apply |
| neutralIntermediary     | orthogonalPlusDiagonal8       | 8-way (orthogonal + diagonal)| Same as left, but includes diagonals in the affected set. More greys/claims possible via diagonals. | Gray drop enabled; gray scoring hooks apply |
| directTransfer          | orthogonal4                   | 4-way (up, down, left, right) | Opponent colors → attacker directly; no gray generated; bombs/walls ignored.                    | Gray actions disabled; gray scoring hooks inert |
| directTransfer          | orthogonalPlusDiagonal8       | 8-way (orthogonal + diagonal)| Opponent colors → attacker directly over 8 neighbors; no gray generated.                        | Gray actions disabled; gray scoring hooks inert |

Clarifications
- “Gray” is purely a resolution mechanism. In directTransfer, gray cells must neither be generated nor referenced by UI/AI; if legacy content with gray appears, migration/validation should sanitize it for that mode.
- Adjacency rules apply equally to infection attempts against enemies and conversions of existing neutrals under `neutralIntermediary`.
- Bombs/walls exclusions remain; explosions and gravity behavior are orthogonal to both axes.


## Independence and Composition Guarantees
- Axis 1 and Axis 2 are orthogonal and must compose without special‑case branching across the codebase.
- The same adjacency provider is used by logic, AI, and UI previews. The same resolution mode’s transition is applied wherever a placement would resolve ownership.
- Mode combinations must be serializable in saves/replays and injectable in simulations/AI playouts.


## Why These Axes Must Remain Independent
- Testability and combinatorial coverage: Independent axes allow unit tests to validate each behavior in isolation and in combination.
- Reuse across systems: UI highlights, AI evaluations, and rules engine all benefit from a singular adjacency abstraction and a singular resolution transition function, each configured independently.
- Balancing and expansion: We can tune adjacency (e.g., add custom graphs or map layouts) without touching resolution semantics, and vice versa (e.g., add probabilistic or staged resolutions) without breaking adjacency.
- Backwards compatibility: The current game equals a single combination (neutralIntermediary × orthogonal4). Independence lets us add new modes without rewriting existing ones.
- Clarity of scoring/UI gating: Gray‑specific UI and scoring activate only under the neutralIntermediary mode, avoiding scattered if‑checks and accidental coupling to adjacency.


## Compatibility With Current Implementation
- Current baseline (per GAMEPLAY_ANALYSIS.md) maps to:
  - InfectionResolutionMode.neutralIntermediary
  - InfectionAdjacencyMode.orthogonal4
- Referenced limitations that this design addresses structurally:
  - “Only orthogonal neighbors are affected” — handled by Axis 2.
  - “Greys block placement and can stall line formation” — a property of the neutralIntermediary mode; switching to directTransfer opts out of gray entirely.
  - “Gray drop is all‑or‑nothing and costs a turn” — remains a separate design decision; Axis 1 simply gates whether the action exists.
  - “Scoring is asymmetric per‑move” — no change now; the gray‑related scoring hooks are tied to neutralIntermediary and inert under directTransfer.


## Implementation Notes (non‑binding, no code changes proposed here)
- Inject a `GameRulesConfig` object throughout logic/UI/AI with:
  - `InfectionResolutionMode resolutionMode`
  - `InfectionAdjacencyMode adjacencyMode`
- Provide a shared adjacency provider `Iterable<(int,int)> neighborsOf(r,c)` bound to `adjacencyMode`.
- Provide a single ownership resolution function bound to `resolutionMode` that consumes the neighbor set and applies transitions.
- Gate gray‑specific actions (e.g., gray drop) and HUD affordances on `resolutionMode == neutralIntermediary` only.
- Keep bombs/walls, gravity, blow rules unchanged and independent of these modes.
- Ensure saves/replays record both mode values for deterministic playback.


## Non‑Goals and Out‑of‑Scope
- No new UI designs or changes specified here.
- No balance changes or parameter tuning.
- No modifications to scoring rules; only the applicability of gray‑related hooks is clarified by configuration.


## Terminology
- “Gray” and “Neutral” are synonymous in this document and refer to the same temporary state used only by the `neutralIntermediary` resolution mode.
- “Affected neighbors” are those returned by the adjacency provider selected by Axis 2.
