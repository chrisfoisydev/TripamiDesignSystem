# ConnectCard

Connect a service that brings plans in for you: "Find your plans in Gmail". A card with a 48px `sunken` icon disc, a `title3` title, a `subhead` message, an optional row of what it finds (icons in `text-secondary`), and the primary button full width.

**Props:** `icon`, `title`, `message`, `kinds` (icon names), `actionLabel`, `onConnect`, `loading`.

- It holds the screen's one primary action. List the other ways to do the same job under it with `ListRow`s.
- Never a navy or orange block: the card is a plain surface.
- Flutter: `TPConnectCard`.
