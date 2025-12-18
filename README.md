
# Two Touch 9x9 Game (Flutter)

Portrait UI inspired by Block Blast. Red player is human (top HUD), Blue is computer (bottom HUD). Grid is exactly 9×9, centered with 5% left/right margins. Only orthogonal adjacency counts. First touch turns opponent cell neutral; second *independent* touch (i.e., a neutral cell now has two attacker neighbors) captures that cell to the attacker color.

## Run
```
flutter pub get
flutter run
```

## Structure
- `lib/main.dart` — app bootstrap
- `lib/ui/pages/game_page.dart` — main screen
- `lib/ui/widgets/board_widget.dart` — grid 9×9
- `lib/ui/widgets/cell_widget.dart` — tile rendering
- `lib/logic/game_controller.dart` — turn flow & state
- `lib/logic/rules_engine.dart` — capture rules
- `lib/logic/ai.dart` — simple heuristic AI (Blue)
- `lib/models/cell_state.dart` — enum
- `lib/core/colors.dart` — palette
- `lib/core/constants.dart` — constants

## Notes
- No third-party packages required.
- Optional persistence can be added via `shared_preferences` or local file.
