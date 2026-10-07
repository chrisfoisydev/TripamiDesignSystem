# ReactionBar

Up to three user reactions as 28px pills, plus an add button. Your own reaction is tinted with the accent. Emoji are user content, which is the only place they appear.

**Props:** `reactions`: `[{emoji, count, mine?}]`, `onReact(reaction)` (without it, tapping toggles yours locally), `onAdd` (`false` hides the add button).

**Motion:** pressed pills scale to 0.94, a pill bumps when its count changes, and colors ease to "mine". **Haptic:** light tap (`join`) when you react; the add button is silent. Try tapping them.
