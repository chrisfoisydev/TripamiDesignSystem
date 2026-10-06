# 04 · Components

Widgets marked **`TPWidget`** are implemented in the Flutter package (`lib/src/components`). The rest are specified here and still need to be built; most map onto restyled Material widgets through `TripamiTheme`.

Each component lists its **anatomy**, the **tokens** it uses, its **states**, and a **Bonvoy reference** where the pattern originates, plus what Tripami changes.

---

## Actions

### Button · `TPButton.primary / .secondary / .tertiary / .destructive`, `TPGlassIconButton`
| Variant | Look | When |
|---|---|---|
| **Primary** | Ink pill, `action.primaryText`, `type.button`, height 52 (large) / 40 (small), horizontal padding 24 | The one main action on a screen: "Create trip", "Vote", "Add expense" |
| **Secondary** | Surface pill, 1pt `border.strong`, ink text | Equal alternative next to a primary: "Sign in" under "Get started" |
| **Tertiary** | Text + trailing `arrow.right`, `type.buttonSmall`, ink | Low-emphasis navigation: "See full itinerary →" |
| **Destructive** | Tertiary in `status.critical`; confirmation sheet holds an ink pill | "Leave trip", "Delete expense" |
| **On image** | Glass circle 40pt, white glyph | Back, share, save on hero photos |

States: default · pressed (scale .98, `primaryPressed`) · disabled (opacity .32, no shadow) · loading (label replaced by a 17pt spinner, width locked).
Never: accent-filled buttons, gradients, more than one primary per view, icons on both sides.
*Bonvoy ref:* black "Select Room", "Book Now", "Sign In" pills; "Join Marriott Bonvoy →" tertiary.

### Quick action · `TPQuickAction`
56pt `bg.surface` circle, `elevation.2`, 22pt `TPIcons` glyph in `text.primary`, `type.footnote` label 8pt below, max 2 lines. Used in a horizontally scrolling row of 4–6 on the Trip Home.
Tripami set: **Invite · Add plan · Split · Map · Chat · Photos**.
*Bonvoy ref:* stay hub Call / Add to Calendar / Get Directions / Share. *Change:* glyphs are ink, not accent, so the accent stays reserved for state.

### Floating pill · `TPFloatingPill`
Ink pill, height 44, `elevation.2`, centered 24pt above the tab bar. One per screen: "Map" / "List" toggle, "Jump to today".
*Bonvoy ref:* "Map" / "List" on results.

---

## Inputs

### Search pill
Height 56, `bg.raised`, `radius.pill`, `elevation.2`. Leading `magnifyingglass` in **Lagoon**, placeholder in `text.secondary`.
Filled state: two lines, destination in `type.body` and dates/travelers in `type.footnote`, with a trailing `pencil` to edit.
On a hero photo it floats over the image, overlapping the photo's top edge.
*Bonvoy ref:* "Where can we take you?" → Tripami placeholder **"Where's the group headed?"**

### Text field: underline · `TextField` via `TripamiTheme` input theme
Eyebrow label (`type.eyebrow`, `text.secondary`) → 8pt → value in `type.body` → 1pt `border.strong` underline (2pt `text.primary` when focused; `status.critical` + helper text on error). Clear button `xmark.circle.fill` in `text.tertiary` when there's a value.
User input is shown exactly as typed. Never uppercase it.
*Bonvoy ref:* Guest Information form.

### Text field: well
For chat composer, comments and notes: `bg.sunken`, `radius.sm`, 12/16 padding, `type.body`. Notes and journal entries use `type.diaryBody` (New York).

### Filter chip · `TPFilterChip`
Height 36, `radius.pill`, 1pt `border.strong`, `type.buttonSmall`, optional trailing `chevron.down`.
Selected: `accent.subtle` fill, `accent.default` border and text, leading `checkmark`. With a count, a 20pt ink circle holding white `type.caption` numerals sits on the leading edge.
*Bonvoy ref:* "Room Type", "Points", "Standard Rates" chips. *Change:* selection uses Lagoon, not grey.

### Segmented tabs: underline · `TPUnderlineTabs`
Text tabs in `type.callout`, `text.secondary`. Active tab is `text.primary` with a 2pt Lagoon underline matching the text width. A hairline runs under the whole row.
Tripami: **Upcoming · Planning · Past** (Trips), **Plan · Ideas · Booked** (Itinerary).
*Bonvoy ref:* Current / Past / Canceled.

### Toggle, checkbox, radio · `Switch` / `Checkbox` / `Radio` via `TripamiTheme`
Platform controls (use `Switch.adaptive` for the iOS look). The toggle's on-state tint is **ink**, not green and not accent. Checkboxes are ink-filled rounded squares (`radius.xs`) with a white check.

### Date range picker
Full-screen sheet with a sticky ink header ("TRAVEL DATES" eyebrow + "Thu, 12 Jun → Tue, 17 Jun"). Selected endpoints are ink circles; the range between them is a `bg.sunken` band. Group availability overlay: under each date, small **member-color dots** for who marked themselves free.
*Bonvoy ref:* calendar. *Change:* availability dots are the social layer.

---

## Containers

### Trip cover card · `TPTripCoverCard`
4:5 photo, `radius.lg`, `elevation.1`. Bottom-left on scrim: trip name in **Newsreader `display`** (or `diaryHeading` in carousels), then `type.subhead` "12–17 Jun · Lisbon". Top-left: glass chip with status ("In 6 days", "Planning", "Now"). Bottom-right: avatar stack (max 4 + "+2").
*Bonvoy ref:* Recommended / Destinations cards. *Change:* serif trip name, faces of travelers.

### Content card · `TPCard`
`bg.surface`, `radius.md`, `elevation.1`, 16pt padding. Optional top media (16:9) with `radius.md` on top corners only. Title `type.title3`, metadata `type.subhead` `text.secondary`.
*Bonvoy ref:* room cards, dine & drink card.

### Row card (compact)
Horizontal: 88pt square thumbnail flush left (`radius.md` on left corners) + text block. Used for "Recently viewed", saved places and search results in tight lists.
*Bonvoy ref:* "Recently Viewed".

### List row · `TPListRow`
56pt min. Leading 22pt `TPIcons` glyph (optional) → 16pt → label `type.body` (+ optional `type.footnote` secondary line) → trailing value `type.callout` `text.secondary` or `chevron.right`. Hairline divider inset to the label.
*Bonvoy ref:* Preferences, Account lists.

### Section header · `TPSectionHeader.eyebrow / .titled`, `TPEyebrow`
- **Eyebrow:** `type.eyebrow` `text.secondary`, uppercase, then 12pt to content. Optional trailing "See all →" tertiary button.
- **Titled:** `type.title2` + optional `type.callout` subtitle. Used when a section is the main content of a hub screen.

### Trip strip · `TPTripStrip`
A three- or four-column fact row with hairline vertical dividers:
`ARRIVE` Thu 12 Jun / 15:00 · `LEAVE` Tue 17 Jun / 11:00 · `NIGHTS` 5 · `GOING` 6 (avatar stack).
Eyebrow labels, `type.body` values, `type.footnote` secondary. It sits directly under the hero sheet edge.
*Bonvoy ref:* the "We look forward to welcoming you." date strip.

### Sheet · `showTPSheet()`
`bg.surface`, `radius.sheet` top corners, 36×5 grabber (`border.strong`) 8pt from top, `elevation.3`, `overlay.dim` behind. Header: centered `type.title3` title with a trailing `xmark` (detents: medium, large). Primary action pinned at the bottom in a sticky action bar.
Uses: vote on an option, add expense, invite, item details, filters, confirmations.
*Bonvoy ref:* Room Details, Missing an upcoming stay?, Hotel Messages, Sign In.

### Sticky action bar · `TPStickyActionBar`
`bg.surface` with a top hairline, 16pt vertical padding, 24pt sides, plus safe area. Left: a fact in eyebrow + value (e.g. `YOUR SHARE` / **€214.50**). Right: primary pill.
*Bonvoy ref:* "FROM 40 USD / Night · Select Room".

### Empty state · `TPEmptyState`
A **dashed** (`border.strong`, 1.5pt, 6/6 dash) `radius.lg` container with 32pt padding. Inside, from the top: an optional 120pt grey-scale spot illustration with one Lagoon detail, a `type.title3` title, a one-line `type.callout` description, and a small primary pill.
*Bonvoy ref:* "Create your first wishlist". *Change:* copy invites the group ("Add a place and everyone can vote on it").

### Toast · `SnackBar` via `TripamiTheme`
Ink capsule-rectangle (`radius.md`), inverse text, 16pt above the tab bar, optional trailing "Undo" in `accent.default` (dark-mode value for contrast on ink) and an `xmark`. Auto-dismiss after 4s; 6s with Undo.
*Bonvoy ref:* "All set. Your reservation has been cancelled."

---

## Social components (new, not in Bonvoy)

### Avatar · `TPAvatar`, `TPMember`
Sizes 24 / 32 / 40 / 56 / 88 (`TPAvatarSize`). Below 32pt only the first initial is shown. A photo has a 2pt member-color ring with a 2pt `bg.surface` gap. Without a photo it's a member-color fill with white initials (`type.caption` at 24/32, `type.subhead` Medium at 40+).
Presence: a 10pt dot at the bottom-right in `status.positive` for online/at the trip. Nothing shown when away.

### Avatar stack · `TPAvatarStack`
Overlap −8pt, 2pt `bg.surface` stroke between avatars, max 4 shown, then a "+N" circle in `bg.sunken` with `text.secondary`. Tapping it opens the Travelers sheet.

### Attribution line · `TPAttribution`
`[24pt avatar] Maya added · 2h` in `type.footnote` `text.secondary`, with the name in `text.primary`. It appears on itinerary items, saved places, expenses and photos. This is the main way presence shows up.

### Poll / vote card · `TPPollCard`
Content card with:
1. Eyebrow: `DINNER · FRI 13 JUN`, plus a deadline chip if any ("Closes 18:00" in `status.caution`).
2. Question in `type.title3`: "Where should we eat on Friday?"
3. Options as rows: 56pt thumbnail, name, `type.footnote` details, and on the right the **voter avatars (24pt)** + count in tabular figures. A 3pt bar under each option shows its share: `border.hairline` track, `text.primary` fill, and **Lagoon** fill for the option *you* voted for.
4. Footer: "Waiting on Jonah and Priya" + primary small pill "Vote" (or "Change vote").
Closed state: winner row gets a `checkmark.circle.fill` in Lagoon and the label "Decided". Other rows go to `text.secondary`.

### Itinerary item · `TPItineraryItem`
Timeline layout: 56pt time column (`type.subhead` tabular, `text.secondary`) | 1pt `border.hairline` rail with an 8pt node | content: title `type.body` Medium, place + duration `type.footnote`, attribution line, reaction row.
- Now/next item: node and time in **Lagoon**, row tinted `accent.subtle`.
- Booked: trailing `checkmark.seal` in `text.secondary` + confirmation code in tabular footnote.
- Idea (not yet booked): dashed node, title in `text.secondary`.

### Expense row · `TPExpenseRow`
Leading 40pt category circle (`bg.sunken`, `TPIcons` glyph), title `type.body`, "Paid by Maya · split 6 ways" `type.footnote` with Maya's member dot, trailing amount `type.body` tabular, and below it your share in `type.footnote` (`status.caution` if you owe, `status.positive` if you're owed).
Balance summary uses Bonvoy's **Summary of charges** layout: eyebrow, rows, hairline, **Total** row in `type.title3`.

### Reaction bar · `TPReactionBar`
Up to 3 user emoji reactions as 28pt `bg.sunken` pills holding emoji + count (`type.caption`); your reaction gets an `accent.subtle` fill + `accent.default` border. A trailing `face.smiling` + glyph button adds one.

### Comment
Avatar 32 → name `type.subhead` Medium + time `type.footnote` → text `type.callout`. Threads are indented 40pt. Mentions are `text.primary` Medium, never colored.

### Activity dot · `TPActivityDot`
8pt dot. `accent.default` = new since your last visit. `status.critical` = you were mentioned or something needs your action. No numeric badges except on the Chat tab (max "9+").

---

## Navigation

### Tab bar · `TPTabBar`
5 tabs: **Trips · Plan · Chat · Memories · You**. `bg.surface` with a top hairline, 24pt `TPIcons` (outline, filled when active), `type.caption` labels. The active item is `text.primary` with a 2pt Lagoon indicator **on the top edge** of the bar, 32pt wide. Inactive items use `text.tertiary`.
*Bonvoy ref:* the same top-edge indicator in copper.

### Navigation bar
Large-title behavior (`SliverAppBar.large` or `CupertinoSliverNavigationBar`): `type.title1` large title collapses to `type.body` Medium inline. Back is `arrow.left` (Bonvoy-style) rather than a chevron + label, because it reads more editorial. On hero screens the nav bar is transparent with glass circle buttons until the hero scrolls away.
