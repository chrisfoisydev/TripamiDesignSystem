# Backdrop

A background for the top of a screen that has no photo header, so it still feels like this trip and these people. It paints `size-backdrop` (280px) behind the content and fades into `canvas`.

- **`photo`**: the trip's cover photo, blurred and washed 35% toward the canvas. For screens inside a trip: Crew, Money, the Map list.
- **`braid`**: the crew's strands in their member colors, bundled, parting, crossing and parting again. They draw in once (600ms). For people moments: Crew, invites, joining.
- **`route`**: a faint dotted route between two pins, ending in the brand-orange dot. For screens with no trip yet: bringing in a trip, starting one, onboarding.

**Props:** `kind` (`'photo' | 'braid' | 'route'`), `image` (photo), `members` (braid, up to 6 strands), `height`, `children` (the screen content on top).

- One per screen, never with a `PlaceHeader`.
- Keep text on the faded part; the top of a braid is for the back button and avatars. Decorative: screen readers skip it.
- No other patterns: no gradient washes, blobs or illustration.
- Flutter: `TPBackdrop.photo / .braid / .route`.
