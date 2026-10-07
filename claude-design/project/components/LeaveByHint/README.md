# LeaveByHint

When to leave for the next plan, as one line under it with a clock icon. Three states:

- **Calm** (more than 30 minutes before): "Leave by 12:55 · 5 min walk from the Vatican", `text-secondary`.
- **Soon** (inside 30 minutes): "Leave in 8 min · …", accent, semibold.
- **Due** (time to go, or later): "Leave now · …", then "Leave now · 4 min behind", `caution` with a warning icon. Turning due plays the warning haptic once, never on first show.

**Props:** `leaveBy` ("HH:MM"), `travel` ("5 min walk from the Vatican"), `now` ("HH:MM" to pin; leave it out to follow the real time), `soonWindow` (minutes, default 30).

- Changes are announced politely to screen readers.
- Flutter: `TPLeaveByHint`.
