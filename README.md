# Arrow Words

Arrow Words is a Flutter implementation of an arrowword-style crossword puzzle. The app includes bundled demo puzzles and support for importing JSON puzzles on device.

## Running the app

```
flutter pub get
flutter run
```

The app uses Riverpod for state management and go_router for navigation. Settings and puzzle progress are stored with `shared_preferences`.

## Importing puzzles

1. Launch the app and open the **Import JSON** action from the home screen.
2. Paste a puzzle JSON string (matching the schema below) and confirm.
3. The puzzle will appear in the home list and can be resumed like bundled puzzles.

Progress auto-saves after each move and can be resumed from the home screen.

## Puzzle JSON schema

```jsonc
{
  "schemaVersion": 1,
  "id": "unique_puzzle_id",
  "title": "Puzzle Title",
  "author": "Author",
  "width": 9,
  "height": 9,
  "cells": [
    { "type": "CLUE", "arrow": "E", "text": "Desert ship" },
    { "type": "LETTER", "solution": "C" },
    { "type": "BLOCK" }
  ]
}
```

- `type` can be `CLUE`, `LETTER`, or `BLOCK`.
- For `CLUE`, `arrow` is one of `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, or `NW` and `text` holds the clue string.
- `LETTER` cells include an uppercase `solution` character. Optional `given: true` can pre-fill a cell.
- The `cells` array is row-major with length `width * height`.

Sample puzzles live in `assets/puzzles/` and cover both 7×7 and 9×9 grids.

## Testing

Run unit, widget, and golden tests:

```
flutter test
```

The test suite covers puzzle parsing, validation, widget interactions, and baseline golden rendering (light/dark).
