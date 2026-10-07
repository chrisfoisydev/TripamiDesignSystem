# Avatar

A traveler. Without a photo it shows their `member-*` color with white initials (one initial below 32px). With a photo it shows a 2px member-color ring. A presence dot appears only when they're active. Sizes: 24 · 32 · 40 · 56 · 88.

**Props:** `member` (`{name, color, photo?, online?}`), `size`, `presence`, `invited`.

**Invited:** someone asked to join who hasn't yet. A dashed `border-strong` ring around initials in `text-secondary`, no fill: the system's dashed shape for "not filled yet". Screen readers hear "Sarah Johnson, invited". Flutter: `TPAvatar(invited: true)`.
