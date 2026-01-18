# Adjacency Modes

This document defines the supported Infection Adjacency Modes and how they interact with the already‑centralized adjacency provider. It also clarifies defaults, composition with infection resolution, and what remains explicitly out of scope.


## Supported Modes

Adjacency is the rule that determines which neighboring cells are considered “affected” by a placement. The single source of truth is the centralized provider in `lib/logic/adjacency.dart`.

```dart
enum InfectionAdjacencyMode {
  // 4-way orthogonal neighbors: up, down, left, right.
  orthogonal4,

  // 8-way neighbors: orthogonal plus diagonals.
  orthogonalPlusDiagonal8,
}
```

- Default (dev/global): `InfectionAdjacencyMode.orthogonal4`
- Dev toggle (internal): `Adjacency.mode = InfectionAdjacencyMode.orthogonalPlusDiagonal8;`
  - No UI/settings wiring is added in this step; this is intended for developer validation only.


## Exact Neighbor Sets

All coordinates below are relative to the placed cell at (r, c). Out‑of‑bounds neighbors are discarded.

- orthogonal4
  - Up:    (r-1, c)
  - Down:  (r+1, c)
  - Left:  (r, c-1)
  - Right: (r, c+1)

- orthogonalPlusDiagonal8
  - All orthogonal neighbors listed above, plus diagonals:
    - (r-1, c-1)
    - (r-1, c+1)
    - (r+1, c-1)
    - (r+1, c+1)

Implementation reference: `Adjacency.neighborsOf(r, c)` and `Adjacency.neighborsOfMode(r, c, mode)` in `lib/logic/adjacency.dart`.


## Where This Is Used

- Placement and conversions: via the centralized resolution in
  - `lib/logic/infection_resolution.dart` (2‑player)
  - `lib/logic/infection_resolution_multi.dart` (multi‑player)
  These modules call `Adjacency.neighborsOf(...)` to enumerate affected neighbors.

- Rules engines that perform placements:
  - `lib/logic/rules_engine.dart`
  - `lib/logic/multi_rules_engine.dart`
  Both delegate infection side‑effects to the centralized infection resolution modules, which use the adjacency provider.

- AI move simulation/evaluation:
  - AI simulates placements through `RulesEngine.place(...)`, so it indirectly uses the adjacency provider.

- UI previews/highlights (if any depend on simulated placements) also benefit implicitly through `RulesEngine.place(...)`.


## What Does NOT Change

- Explosion/blow adjacency and bomb blast shapes remain strictly cross‑shaped (orthogonal only) as currently implemented.
  - `RulesEngine.blowAffected(...)` continues to use 4‑way neighbors for the immediate cross effect.
  - `RulesEngine.bombBlastAffected(...)` continues to extend in 4 straight directions until a wall.
- Bomb activation conditions that rely on orthogonal checks remain unchanged in this step.
- No scoring rules are changed.
- No UI toggles or settings were added.

This ensures that enabling diagonal adjacency affects only infection (placement‑driven neighbor effects), not explosions or other systems.


## Default Behavior Confirmation

- With `Adjacency.mode == InfectionAdjacencyMode.orthogonal4` (default):
  - Gameplay is identical to the current baseline documented in `GAMEPLAY_ANALYSIS.md`.

- With `Adjacency.mode == InfectionAdjacencyMode.orthogonalPlusDiagonal8` (dev toggle only):
  - Diagonal neighbors are included in infection processing for placements (conversions apply to 8 neighbors).


## Conceptual Examples: Diagonals × Resolution Modes

Let X be the attacker placing at (r, c). Let O be the opponent. Let N be Neutral (gray). Bombs and walls are ignored for infection.

1) neutralIntermediary (Enemies → Neutral, Neutral → Attacker)
- If any diagonal neighbor contains O, that diagonal O becomes N.
- If any diagonal neighbor contains N, that diagonal N becomes X.
- Orthogonal neighbors behave as before; diagonals are simply added to the affected set.

2) directTransfer (Enemies → Attacker directly; no Neutral generated)
- If any diagonal neighbor contains O, that diagonal O becomes X directly.
- No Neutral tiles are ever created; gray‑specific actions remain disabled.

In both cases, bombs/walls are not converted and do not participate in infection transitions.


## Why Adjacency and Resolution Must Remain Independent

- Orthogonality: Adjacency defines “who is affected,” while resolution defines “how they change.” These concerns compose without special cases.
- Flexibility: We can add new adjacency graphs (e.g., map‑specific links) without touching transition semantics; likewise, we can add new transition styles without changing neighborhood enumeration.
- Consistency: A single adjacency provider guarantees that logic, AI, and UI previews agree on the same affected set.
- Backwards compatibility: Keeping default `orthogonal4` preserves existing gameplay; enabling `orthogonalPlusDiagonal8` is an opt‑in dev toggle.


## Developer Toggle

To validate diagonal adjacency during development:

```dart
import 'package:dual_clash/logic/adjacency.dart';

void main() {
  // Temporary dev toggle for testing; default is orthogonal4.
  Adjacency.mode = InfectionAdjacencyMode.orthogonalPlusDiagonal8;
  // ... run app
}
```

Do not ship this toggle enabled by default unless the product decision is made. No user‑facing settings are included in this change.
