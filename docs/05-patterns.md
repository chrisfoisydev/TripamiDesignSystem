# 05 · Screen patterns

Trips, Trip Home, Plan and the vote sheet are built in [`example/lib/screens.dart`](../example/lib/screens.dart). Screenshots are in [`example/test/goldens`](../example/test/goldens).

Wireframe-level specs for Tripami's core screens, built only from the components in [04](./04-components.md). Each one notes the Bonvoy screen it learns from and what it changes.

---

## Trips (tab: Trips)
*Learns from:* [Bonvoy Trips list](https://mobbin.com/screens/ddbde250-8103-404f-a0ea-2385e66c2ea8) + [Recommended carousel](https://mobbin.com/screens/5140363e-6f79-4b7a-9668-ee6c8f050536)

```
Trips                                   (+)      ← title1, Regular; + = new trip
Upcoming   Planning   Past                        ← underline tabs, Lagoon on active
───────────────────────────────────────────
┌─────────────────────────────┐
│ [In 6 days]                 │  ← glass chip
│                             │
│        (trip photo 4:5)     │
│                             │
│ Lisbon with                 │  ← Newsreader display, white on scrim
│ the crew                    │
│ 12–17 Jun · Lisbon   ◐◐◐◐+2 │  ← subhead + avatar stack
└─────────────────────────────┘
NEEDS YOU                                         ← eyebrow
 ◉ Vote on Friday dinner · Lisbon          ›      ← list row with red activity dot
 ◉ Settle €42.10 with Maya · Lisbon        ›
```
- One full-width cover card per upcoming trip; stack vertically, 24pt apart.
- "Needs you" collects cross-trip actions as plain rows, so no notification feed is needed.
- Empty: dashed container, "Plan your first trip with friends", pill "Start a trip".

## Trip Home (the hub)
*Learns from:* [Bonvoy stay hub](https://mobbin.com/screens/03279ce4-db8f-4a5f-b3b8-ce4a28ae09c2) + [Hero home](https://mobbin.com/screens/95f05a78-a272-4964-9117-329afc667c7a)

```
(←)                                   (↑) (···)   ← glass circles over photo
        full-bleed cover photo 3:4
Lisbon with the crew                              ← Newsreader display
[◉ 6 days to go]  [⌖ Alfama, Lisbon]               ← glass chips (⌖ = TPIcons.mapPin)
╭───────────────────────────────────────────╮      ← surface sheet edge, radius.sheet
│ ARRIVE        │ LEAVE         │ NIGHTS │ GOING  │  ← trip strip
│ Thu 12 Jun    │ Tue 17 Jun    │ 5      │ ◐◐◐+3  │
│ 15:00         │ 11:00         │        │        │
│                                                 │
│ (Invite) (Add plan) (Split) (Map) (Chat) (Photos)│  ← quick actions, scrolls
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ← 8pt sunken band
Needs your vote                                   ← title2
[Poll card: Where should we eat on Friday?]
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
Up next                          Full itinerary →
[Itinerary item: 15:00 Check in · Casa do Largo]
[Itinerary item: 20:30 Dinner · Taberna da Rua]
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
Money                                    Details →
 You owe Maya                          €42.10     ← summary rows
 Trip total so far                    €1,284.00
```
- The hub is the only screen that uses sunken bands; everywhere else sections are separated by space.
- Section order adapts to trip phase: **Planning** (votes, ideas, dates) → **Upcoming** (up next, bookings, money) → **During** (today, map, photos) → **After** (memories, settle up).

## Plan / Itinerary
*Learns from:* [Bonvoy room selection](https://mobbin.com/screens/85e0c34b-aa71-4cc4-a0c4-195d23cad9b4) (sticky context header + filter chips) and [Review reservation](https://mobbin.com/screens/741c5687-7714-40f4-8c1f-e2690fb37bde) (clean stacked facts)

```
Plan                                      (+)
Plan   Ideas   Booked                              ← underline tabs
[Thu 12] [Fri 13] [Sat 14] [Sun 15] [Mon 16]       ← date chips, selected = Lagoon subtle
Friday, 13 June                                    ← Newsreader diaryHeading
Day 2 · 4 plans · Sunny 24°                        ← subhead secondary
09:30 ●─ Pastéis at Manteigaria                     
         Chiado · 30 min                             
         ◐ Leo added · 👍 3  ❤️ 2                    ← attribution + reactions (user content)
12:00 ●─ Tram 28 to Graça           [Now]          ← Lagoon node, accent.subtle row
         ...
20:30 ◌─ Dinner (voting)                           ← dashed node = undecided
         3 options · Closes 18:00     Vote →
```
- Undecided items link straight to their poll sheet.
- Drag-to-reorder (`ReorderableListView`) uses `HapticFeedback.mediumImpact()` and the `TPMotion.gentle` spring.

## Decide together (poll sheet)
*Learns from:* [Room Details sheet](https://mobbin.com/screens/4bdc6f06-33d4-4128-ab5a-8601c32ea551) + [Filter flow](https://mobbin.com/flows/44f66b12-8b51-4908-a1c8-2f459976c8b4) ("Show 36 Results" sticky pill)

- Large-detent sheet. Eyebrow `DINNER · FRI 13 JUN`, question in `title3`.
- Options as photo row cards; tap to select (Lagoon ring + `checkmark.circle.fill`).
- Sticky action bar: left `4 OF 6 VOTED` / "Waiting on Jonah and Priya"; right ink pill "Vote".
- After voting: bars animate to their share over `slow`; your bar is Lagoon. Toast: "Voted. We'll let you know when it closes."

## Split (expenses)
*Learns from:* [Summary of charges](https://mobbin.com/screens/3ba91323-9304-4e51-92ce-bf40a2fefaf0) + [Guest info form](https://mobbin.com/screens/fd7fbfaa-6206-421a-850c-6e4a3074c751)

- Header: eyebrow `YOUR BALANCE`, `display`-size tabular number in Inter (not serif; money is utility), caption "You owe Maya €42.10 · Leo owes you €18.00".
- Expense list grouped by day with eyebrow date headers.
- Add expense sheet: underline fields (`AMOUNT`, `WHAT FOR`, `PAID BY` with avatar picker, `SPLIT` with member chips), sticky bar `YOUR SHARE €35.75` + pill "Add expense".
- Settle up: summary-of-charges table + ink pill "Mark as settled". The success state is a single Lagoon check: "Settled with Maya."

## Memories (diary)
*Learns from:* [Destinations to explore](https://mobbin.com/screens/fa52c1ae-449e-4455-b4a7-0053e6f4d70d) (editorial photo cards) + Bonvoy's restraint, pushed further toward print

- The most editorial screen in the product. Newsreader for day titles and journal text, generous 40pt section spacing, photos in a mix of full-bleed and 2-up grids with 4pt gutters.
- Each day: `diaryHeading` "Saturday in Sintra", a `diaryBody` entry (any traveler can write; attribution line above), then photos.
- Pull quotes from the group's notes in Newsreader Italic 22/30 (`TPType.diaryQuote`), `text.primary`, with a 2pt left rule in the author's member color. This is the only place a member color appears as a line.
- Still no colored backgrounds; the photos do the work.

## Invite
*Learns from:* [Missing an upcoming stay? sheet](https://mobbin.com/screens/922b1a0a-5f5b-4105-8e00-b7f3eb1c314b)

- Medium sheet: title "Invite to Lisbon with the crew", trip link in a well with a copy button, ink pill "Share invite link", then a "GOING" eyebrow list of avatars + names + role ("Organizer").
- Pending invites show as dashed-outline avatars with "Invited · 2d".

## Onboarding & sign-in
*Learns from:* [Onboarding](https://mobbin.com/screens/7ece582b-7992-47f7-a814-32a3f566e2b8) + [Sign in sheet](https://mobbin.com/screens/c507eaa8-9fcd-4f2f-8935-d9e34cdf21a0)

- Three cards maximum. Each has a circular photo crop (as in Bonvoy), a `title1` headline in Regular, one sentence, and page dots. Primary "Get started" + secondary "I have an invite".
- Arriving from an invite link skips onboarding entirely: the trip cover appears with "Maya invited you to Lisbon with the crew" and a pill "Join trip".
- This is where marketing energy is *allowed* to leak in slightly (bigger photos, warmer copy), and only here.

## Confirmation moments
*Learns from:* [You're All Set](https://mobbin.com/screens/dcd11968-b4fc-447f-a5fd-c33167b7d2be)

- Centered 40pt Lagoon `checkmark`, `title1` headline ("Everyone's in."), one line of `callout`, a row card summarizing the thing, and an ink pill "Done".
- Light success haptic. No confetti.
