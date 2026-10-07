# PollCard

A group decision. Each option shows who voted (faces) and a 3px share bar: navy ink for others, `accent` orange for the option you picked or the winner. The footer names who hasn't voted yet.

**Props:** `eyebrow` ("Dinner · Fri 13 Jun"), `question`, `options`: `[{id, title, detail?, image?, voters}]`, `myVoteId`, `waitingOn` (first names), `deadline`, `decidedId` (closes the poll), `onVote` (`false` hides the button).

- Names beat counts: "Waiting on Jonah and Priya."
- Closed: the winner gets a filled `accent` check and the other options dim.

**Motion:** share bars spring to their size, counts tick, and a new voter's face pops in. When the last person votes while the card is on screen, a check draws itself beside "Everyone has voted." with a success haptic, and a winner decided on screen pops its check. A poll that was already finished when the screen opened shows all of this at rest. Try the buttons below the card.
