# PollCard

A group decision. Each option shows who voted (faces) and a 3px share bar: ink for others, Lagoon for the option you picked or the winner. The footer names who hasn't voted yet.

**Props:** `eyebrow` ("Dinner · Fri 13 Jun"), `question`, `options`: `[{id, title, detail?, image?, voters}]`, `myVoteId`, `waitingOn` (first names), `deadline`, `decidedId` (closes the poll), `onVote` (`false` hides the button).

- Names beat counts: "Waiting on Jonah and Priya."
- Closed: the winner gets a filled Lagoon check and the other options dim.
