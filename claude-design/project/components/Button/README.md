# Button

Pill button. **Primary** is the ink pill and appears at most once per view. **Secondary** is an outline pill for an equal alternative. **Tertiary** is text with an arrow, for low-emphasis navigation. **Destructive** is critical-red text; confirm the action in a sheet.

**Props:** `variant` (`primary` · `secondary` · `tertiary` · `destructive`), `small` (40px instead of 52px), `expand` (full width), `loading`, `disabled`, `onClick`, `children` (the label).

- Sentence case, verb first: "Create trip", "Add expense", "Vote".
- Never fill a button with `accent`. Never use more than one primary per view, and never put icons on both sides.
- Pressed: scale 0.98 and `action-primary-pressed`. Disabled: 32% opacity.
