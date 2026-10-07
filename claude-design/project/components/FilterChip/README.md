# FilterChip

Filter or day chip, 36px tall. Selected uses the orange accent: an `accent-subtle` fill with an `accent` border and text, plus a check. A count shows as an ink badge on the leading edge.

**Width:** the chip hugs its label, which stays on one line ("Wed 18", never "Wed" over "18"). In a row of chips, scroll the row sideways rather than squeezing chips; only a chip wider than the screen (very large text) ellipsizes.

**Props:** `selected` (controlled) or `defaultSelected`, `count`, `dropdown` (adds a caret), `onClick`, `children` (the label).

**Motion:** the fill eases on the snappy spring, the check grows in, and the count badge bumps when its number changes. Pressed: scale 0.98. **Haptic:** selection tick (`select`). Try tapping them.
