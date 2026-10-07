# NowCard

What you're doing right now: the heart of a trip day. An accent dot and "NOW · UNTIL 12:30", the plan and place, a `ProgressBar` with start, time left and end, then who you're with ("With Sandra", or "Just you"). Time left reads "Starts in 20 min" before and "Over by 15 min" after.

**Props:** `title`, `place`, `start` and `end` ("HH:MM"), `companions` (everyone on the plan except you), `now` ("HH:MM" to pin the clock; leave it out and the card follows the real time, updating every 30 seconds), `onClick`.

- The accent marks the state only. The card stays a plain surface: never fill it navy or orange.
- One Now card per screen, under the day strip.
- Flutter: `TPNowCard`.
