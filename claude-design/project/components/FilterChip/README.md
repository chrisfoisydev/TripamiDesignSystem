# FilterChip

Filter or day chip, 36px tall. Selected uses the orange accent: an `accent-subtle` fill with an `accent` border and text, plus a check. A count shows as an ink badge on the leading edge.

**Props:** `selected` (controlled) or `defaultSelected`, `count`, `dropdown` (adds a caret), `onClick`, `children` (the label).

**Motion:** the fill eases on the snappy spring, the check grows in, and the count badge bumps when its number changes. Pressed: scale 0.98. **Haptic:** selection tick (`select`). Try tapping them.
