# dual_clash

Dual Clash is a turn-based board game built with Flutter. The project mixes
gameplay logic in `lib/logic` with UI state management in `lib/ui`, and it
supports multiple form factors (desktop, web, mobile).

## UI Architecture Overview

The main gameplay screen is implemented in `lib/ui/pages/game_page.dart`. It
coordinates:

- **Game state & scoring** via `GameController` (`lib/logic/game_controller.dart`)
- **Board rendering** via `BoardWidget` (`lib/ui/widgets/board_widget.dart`)
- **Dialogs** for results and difficulty (`lib/ui/dialogs`)
- **Reusable UI widgets** for score rows, AI level badges, and support links

### GamePage Layout Components

`GamePage` now focuses on orchestration and state, while layout details are
split into focused widgets:

- `GamePageScoreRow` (`lib/ui/widgets/game_page_score_row.dart`)  
  Renders the menu button, points, and player counts for mobile/desktop.
- `GamePageAiLevelRow` (`lib/ui/widgets/game_page_ai_level_row.dart`)  
  Displays the current AI belt level beneath the board.
- `SupportLinksBar` (`lib/ui/widgets/support_links_bar.dart`)  
  Fallback bottom bar when ads are disabled or unavailable.
- `HoverScaleBox` (`lib/ui/widgets/hover_scale_box.dart`)  
  Safe hover scale helper that preserves layout sizing.

Layout sizing is centralized in `GameLayoutMetrics`
(`lib/ui/widgets/game_layout_metrics.dart`) so Game Challenge and Duel mode
share the same board/score sizing rules.

### Dialogs

Dialogs have been extracted into `lib/ui/dialogs` for reuse:

- `showAnimatedResultsDialog` in `results_dialog.dart`
- `showAiDifficultyDialog` in `ai_difficulty_dialog.dart`

Dialogs now share responsive sizing rules: phone dialogs are fullscreen with a
top offset, while tablet/desktop dialogs render at 80% width/height.

## Testing

Widget tests live under `test/`. Key coverage includes:

- `test/game_page_layout_test.dart` — desktop layout and support links
- `test/widget_test.dart` — main menu animations and menu interactions

Run the test suite with:

```sh
flutter test
```

## Getting Started

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
