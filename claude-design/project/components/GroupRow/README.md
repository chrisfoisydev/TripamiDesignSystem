# GroupRow

A row about a group of people: their faces (24px, up to three and "+N") in a fixed 72px slot so titles line up, what they're doing, who, and an optional time. "Vatican Museums · You and Sandra · until 12:30".

**Props:** `members`, `title`, `detail` (defaults to their first names: "Shannon and Christy"), `value`, `onClick`, `divider`.

- Use it for "Right now" on Crew, and wherever plans are listed by who.
- Flutter: `TPGroupRow` (faces move above the words at large text).
