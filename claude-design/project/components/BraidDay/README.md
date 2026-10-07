# BraidDay

The day as a braid: one strand per traveler running down the left, bundling into the plans people share and parting when they split. Plain-language markers ("All 5 together", "Splits into 3", "Back together") and event cards sit beside it.

**Props:** `members` (`{id, name, color}`), `youId`, `moments` (`[{time, events: [{id, title, start, end, place, participantIds, loose?, now?}]}]`), `groups` (`[{id, name, color, memberIds}]`, for big trips), `maxVisibleEvents` (default 3), `width` (optional; otherwise measured).

**How it scales**
- **2–8 travelers:** one strand per person, in their member color (`strand-*`).
- **9–20:** you, plus the people you share plans with, plus a neutral "Everyone else" ribbon whose width follows headcount.
- **21+:** you, plus one ribbon per group (yours first, then by size, 3–12px wide). If there are too many groups, the rest fold into "+N more groups". Never more than 6 strands on screen.
- **Color means one thing per view:** people *or* groups, never both.
- **More than 3 plans at once:** yours first, then by size, then "Show N more".
- **Phones:** strands on the left only. **600px and wider:** groups you're not with when the group splits move to a right-hand gutter.

**Details**
- Your strand is 1.5px wider and drawn on top.
- A loose plan ("No plans, just vibes") has dotted strands and a dashed card.
- A plan you're in with part of the group gets an `accent` outline; plans with everyone don't.
- The plan happening now gets `accent-subtle`.
- Avatars where a bundle meets its card, plus names on the card, mean color is never the only cue.

**Motion**
- On open, strands draw top to bottom in one 600ms sweep, and each card rises as the line reaches it.
- When plans change, strands glide to their new bundles on the gentle spring, so you can see who moved.
- When someone joins a plan, its avatars pop.
- Press Replay to see the draw-in again. Reduced motion shows the day fully drawn.
