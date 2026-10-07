# OverlapSheet

The `canvas` surface that rises `size-sheet-overlap` (24px) over a `PlaceHeader`, with `radius-sheet` (28px) top corners, so the photo shows behind its corners. Put the rest of the screen inside it: tabs, the day strip, the stay row, the Now card.

**Props:** `children`.

- Only directly under a `PlaceHeader` (which leaves room for it with `sheetBelow`).
- Flutter: `TPOverlapSheet`.
