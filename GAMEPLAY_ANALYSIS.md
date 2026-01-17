Gameplay Analysis: Current Mechanics

This document describes the current gameplay behavior of Dual Clash as implemented in the codebase at the time of writing. It focuses on how moves interact with neighboring cells, the lifecycle of grey (neutral) cells, player/AI limitations related to neutrals, and how scoring treats grey cells. This is a descriptive baseline only; it does not propose changes.

1) How a move affects neighboring cells

A move is a placement of the current player’s color onto an empty cell.
- Preconditions
  - The target cell must be within bounds and empty.
  - Only orthogonal adjacency is considered (up, down, left, right). Diagonals are not considered.
- On placement (RulesEngine.place)
  - Place the attacker’s color into the chosen empty cell.
  - For each orthogonal neighbor:
    - If the neighbor is an opponent color (i.e., not the attacker, not neutral, not empty) and not a bomb or wall, it becomes Neutral (grey).
    - If the neighbor is Neutral (grey), it becomes the attacker’s color.
    - Bomb and wall cells are ignored by this conversion logic (they neither convert nor are converted).
- Notes
  - Only the four orthogonal neighbors are processed.
  - Conversions happen immediately in the resulting board state for that move.

2) How and when grey cells appear

Grey cells are the Neutral state in the code (CellState.neutral) and appear during normal placements:
- Appearance triggers
  - When a player places a piece orthogonally adjacent to an opponent’s colored cell (not neutral/empty/bomb/wall), that neighbor is converted to Neutral (grey).
- Persistence and movement
  - Grey cells persist on the board until they are either:
    - Converted back into a player color by a subsequent placement adjacent to them, or
    - Removed via a “grey drop” action (see below), or
    - Emptied by an explosion (“blow”) effect.
  - Gravity after explosions moves non-empty pieces downward within each column. Grey cells, if present during a gravity step, fall like regular colored cells. Falling does not change a cell’s color.
- What does not create greys
  - Explosions/blows do not create grey cells; they set affected cells to empty.

Grey drop (removal of all greys)
- Trigger and flow
  - If a neutral (grey) cell exists, the user can tap a grey cell to select it and preview all grey cells. Tapping the same selected grey again triggers a “grey drop”.
  - In normal mode (vs AI), only the human Red turn can initiate this; in Duel mode, the current player’s turn may initiate it.
  - The AI (Blue) can also decide to perform a grey drop on its turn.
- What happens during a grey drop
  - An earthquake-like shake animation plays, then all neutral cells are animated to “fall out.”
  - After the animation, all neutral cells are removed from the board (set to empty) in one step.
  - No other cells are moved or changed by the grey drop itself (beyond the animation visuals for neutrals).
  - The action consumes the turn (current switches to the opponent after completion).
  - No score is awarded for performing a grey drop.

3) How grey cells are converted into player colors

Grey (neutral) cells are converted back to a player color only by adjacency during a placement:
- When a player places a piece, any orthogonal grey neighbor becomes that player’s color.
- Grey drop does not convert grey cells; it removes all greys (sets them to empty) without awarding points.
- Explosions remove greys if they are in the affected set (they become empty).

4) Limitations this creates for players and AI

Action and turn constraints
- Turn ownership
  - Normal (vs AI): Only Red is controlled by the human; Blue is controlled by AI. Actions are processed only when it is that side’s turn.
  - Duel (human vs human or multi): Only the current player’s color may act.
- Input gating / animation states
  - During explosions, falling, shaking (grey-drop quake), or while AI is thinking, user actions are ignored. This prevents mid-animation state changes.
- Placement restrictions
  - You can only place on empty cells (cannot place on greys or any other occupied cell).
  - Only orthogonal neighbors are affected by placement; diagonals are unaffected.
- Blow (explosion) restrictions (context)
  - A player may blow up their own color only on their turn (in vs AI, Red can blow Red on Red’s turn).
  - Blowing empties the blown cell and its orthogonally adjacent non-empty cells; it does not score points.
- Grey drop limitations
  - Grey drop is only available if at least one grey cell is present.
  - It removes all greys at once, awards 0 points, and consumes the turn.
  - In normal (vs AI) mode, only Red can trigger it on Red’s turn; AI Blue may choose it on Blue’s turn.
- Board effects
  - Grey cells block placement because they are non-empty. They must be converted by adjacency or removed via grey drop/blow before a piece can occupy those squares.

AI behavior related to greys
- The AI evaluates actions among: placement, blow, and grey drop.
- If neutrals exist, the AI may choose grey drop; otherwise it chooses among its other options.
- For placements, the AI simulates immediate board outcomes and typically prefers moves that increase its own colored-cell count (varies by AI level/strategy).
- AI follows the same conversion rules: enemies adjacent to its placement become grey; adjacent greys become Blue.

5) How scoring currently works with grey cells

Per-move points (tracked from the Red player’s perspective)
- When Red places a piece
  - +1 for placing a piece.
  - +2 additional if the placed piece is in a corner.
  - +2 for each Blue→Grey conversion caused by this placement (orthogonal neighbors only).
  - +3 for each Grey→Red conversion caused by this placement.
- When Blue places a piece
  - The per-move points are applied as negatives to Red’s current-move tally:
    - −2 for each Red→Grey conversion caused by Blue’s placement.
    - −3 for each Grey→Blue conversion caused by Blue’s placement.
  - Blue’s own placement/corner bonuses are not subtracted from Red.
- Grey drop
  - Awards 0 points to whoever performs it.
- Blow (explosion)
  - Awards 0 points.

Base counts and end-of-game bonuses
- Base score used for results is simply the count of colored cells for each side.
  - Grey (neutral) cells do not count toward any player’s base score.
- At game end, line bonuses are awarded:
  - +50 to Red for each full row or column consisting entirely of Red cells.
  - +50 to Blue for each full row or column consisting entirely of Blue cells.
  - Rows/columns containing any grey cells (or mixed colors) prevent that line from awarding a bonus.
- Grey cells therefore indirectly affect end scoring by blocking full-color lines until they are converted or removed.

Step-by-step examples (concise)
- Placement next to enemies
  1) Red places on an empty cell.
  2) Each orthogonal Blue neighbor becomes Grey.
  3) Each orthogonal Grey neighbor becomes Red.
  4) Score updates: +1 place, +2 corner if applicable, +2 per Blue→Grey, +3 per Grey→Red.
- Placement next to greys
  1) Red places on an empty cell adjacent to Grey.
  2) The Grey neighbor(s) become Red.
  3) Score updates: +1 place, +2 corner if applicable, +3 per Grey→Red.
- Grey drop
  1) Player selects a Grey cell (preview shows all greys), then confirms by tapping again.
  2) Board shakes (quake), all Greys are animated as falling out, then removed.
  3) No points are awarded; turn passes to the opponent.
- Blow affecting greys
  1) Player selects their own colored piece and triggers a blow.
  2) The piece and orthogonal neighbors (including any greys) become empty.
  3) No points are awarded.

Current Design Limitations
- Greys block placement yet hold no intrinsic score value, creating positions where optimal play may be to remove them (grey drop) even though it yields 0 points and consumes a full turn.
- Only orthogonal neighbors are affected by placements; diagonals never interact, potentially limiting tactical depth around diagonals.
- Grey drop is an all-or-nothing action: it removes every grey on the board at once; there is no selective removal.
- Scoring is asymmetric in per-move accounting (tracked from Red’s perspective), which may complicate interpreting intermediate move values in Duel mode.
- Grey cells can hinder end-of-game line bonuses until actively converted or dropped, which can stall line formation without providing countervailing score benefits.
- Actions are blocked during animations and AI thinking; this can delay or constrain rapid move inputs in fast play.
