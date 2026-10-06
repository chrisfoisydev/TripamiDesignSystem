# 03 · Foundations

Every value here exists in two places:
- [`tokens/tokens.json`](../tokens/tokens.json): W3C design-tokens format, the source of truth for design tools (Figma Tokens/Variables).
- The Flutter package in [`lib/`](../lib): `TPPalette`, `TPColors` (a `ThemeExtension`), `TPType`, `TPSpace`, `TPRadius`, `TPSize`, `TPElevation`, `TPMotion`, `TPIcons`, and `TripamiTheme` for `ThemeData`.

In Dart, read colors with `TPColors.of(context)` so light and dark resolve automatically.

---

## Color

### Neutrals: paper & ink
A warm, slightly yellow-biased neutral ramp. It's softer than Bonvoy's pure white, which makes it feel like a notebook and keeps photos warm.

| Token | Light | Dark | Use |
|---|---|---|---|
| `color.bg.canvas` | `#FAFAF7` paper | `#0E0F11` | Screen background |
| `color.bg.surface` | `#FFFFFF` | `#17181B` | Cards, sheets, sticky bars |
| `color.bg.sunken` | `#F2F1EC` | `#0A0B0C` | Section bands, input wells, skeletons |
| `color.bg.raised` | `#FFFFFF` | `#1F2024` | Floating search, popovers |
| `color.border.hairline` | `#E6E4DE` | `#2A2B30` | Row dividers, card outlines |
| `color.border.strong` | `#D6D3CB` | `#3A3B41` | Outline buttons, chips, input underline |
| `color.text.primary` | `#16171B` ink | `#F2F1EC` | Titles, body |
| `color.text.secondary` | `#5C5E66` | `#A6A7AD` | Metadata, eyebrows, captions |
| `color.text.tertiary` | `#6F7178` | `#8A8C93` | Placeholders, disabled labels. Use on canvas/surface only, not on sunken |
| `color.text.onImage` | `#FFFFFF` | `#FFFFFF` | Text on photo scrims |
| `color.text.inverse` | `#FAFAF7` | `#16171B` | Text on ink pill |

Contrast (WCAG 2.1): primary 17.1:1, secondary 6.2:1 on canvas (5.7:1 on sunken), tertiary 4.9:1 on surface. All pass AA, which fixes a Bonvoy weak spot.

### Action: ink
| Token | Light | Dark |
|---|---|---|
| `color.action.primary` | `#16171B` | `#F2F1EC` |
| `color.action.primaryPressed` | `#2C2D33` | `#D9D8D2` |
| `color.action.primaryText` | `#FAFAF7` | `#16171B` |

In dark mode the ink pill inverts to a **paper pill**. It stays the highest-contrast object on screen, which matches Bonvoy's black pill on white.

### Accent: Lagoon
A deep sea-glass teal. It's calm, it reads as travel and water, it's clearly distinct from Bonvoy's copper, and it holds AA on both white and ink.

| Token | Light | Dark | Use |
|---|---|---|---|
| `color.accent.default` | `#0B6B61` | `#5CC4B4` | Active tab indicator, selected states, links, "today", your vote |
| `color.accent.pressed` | `#08564E` | `#7DD3C5` | Pressed links |
| `color.accent.subtle` | `#E3F1EE` | `#12302C` | Selected chip fill, today's row tint |
| `color.accent.onAccent` | `#FFFFFF` | `#0E0F11` | Text/glyph on accent (checkmarks only) |

**Rules:** the accent is never a primary-button fill, never a large background, and covers ≤ 5% of a screen.

### Member colors: the social layer
Eight hues, assigned to travelers in join order (the trip creator gets `clay`). They're the *only* saturated UI colors besides the accent, and they always mean **"this belongs to this person."**

| Token | Hex | White text contrast |
|---|---|---|
| `color.member.clay` | `#B4553A` | 4.9:1 |
| `color.member.marigold` | `#9A6410` | 5.0:1 |
| `color.member.fern` | `#3F7D4E` | 4.9:1 |
| `color.member.sky` | `#2F73A8` | 5.1:1 |
| `color.member.iris` | `#5160C9` | 5.4:1 |
| `color.member.plum` | `#7F4FAE` | 5.8:1 |
| `color.member.rose` | `#B2466E` | 5.3:1 |
| `color.member.olive` | `#66692B` | 5.8:1 |

Used for: avatar fill (white initials) when there's no photo, a 2pt avatar ring when there is one, a voter's dot on a poll, the payer marker on an expense, the "added by" mark on an itinerary item, and a cursor/presence dot. **Never** for buttons, backgrounds, or text longer than a name. Groups larger than 8 cycle the palette and are told apart by initials.

### Semantic
| Token | Light | Dark | Use |
|---|---|---|---|
| `color.status.positive` | `#2E7D4F` | `#6FCF97` | Settled up, confirmed |
| `color.status.caution` | `#94600F` | `#F2B84B` | Unpaid, deadline soon |
| `color.status.critical` | `#B42318` | `#F97066` | Errors, destructive actions, @mention dot |

### Imagery overlays
| Token | Value | Use |
|---|---|---|
| `color.overlay.scrim` | `linear-gradient(180deg, rgba(14,15,17,0) 40%, rgba(14,15,17,.62) 100%)` | Text on photos (always bottom-aligned) |
| `color.overlay.glass` | `rgba(22,23,27,.48)` + `blur(16px)` | Chips and icon buttons on photos |
| `color.overlay.dim` | `rgba(14,15,17,.36)` | Behind sheets |

---

## Typography

Two open-licensed (OFL) variable families, bundled in the package so iOS and Android render identically:

- **Inter** (UI): every control, label, number and body text. It's a neo-grotesk close to SF Pro, with true tabular figures and an optical-size axis.
- **Newsreader** (diary voice): trip names, day headings in the itinerary, memories/journal text and pull quotes. *Never* on buttons, tabs, inputs or eyebrows. It's an editorial serif with optical sizes from 6 to 72pt, so display settings tighten and text settings open up.

Why not SF Pro and New York? Apple's license restricts them to Apple platforms, so a Flutter app shipping to Android can't bundle them. `TPType` sets the `wght` and `opsz` variation axes explicitly, because Flutter doesn't map `FontWeight` onto variable axes on every platform.

### Scale (logical pixels; scales with `MediaQuery.textScaler`)

| Token (`TPType.*`) | Family | Size / Line | Weight | Tracking | `TextTheme` slot | Use |
|---|---|---|---|---|---|---|
| `type.display` | Newsreader | 34 / 40 | Regular | −0.4 | displaySmall | Trip name on hero, Memories title |
| `type.title1` | Inter | 28 / 34 | Regular | −0.4 | headlineLarge | Screen large titles ("Trips") |
| `type.diaryHeading` | Newsreader | 24 / 30 | Regular | −0.2 | headlineMedium | Day headings ("Friday, 13 June") |
| `type.title2` | Inter | 22 / 28 | Medium | −0.2 | headlineSmall | Section titles ("Needs your vote") |
| `type.title3` | Inter | 18 / 24 | Medium | −0.1 | titleLarge | Card titles, sheet titles |
| `type.body` | Inter | 17 / 24 | Regular | −0.2 | bodyLarge | Body, row labels |
| `type.diaryBody` | Newsreader | 17 / 26 | Regular | 0 | — | Journal entries, notes |
| `type.callout` | Inter | 15 / 20 | Regular | −0.1 | bodyMedium | Secondary row text, descriptions |
| `type.subhead` | Inter | 14 / 19 | Regular | −0.1 | — | Metadata ("Jun 12–17 · 6 travelers") |
| `type.footnote` | Inter | 13 / 18 | Regular | 0 | bodySmall | Helper text, timestamps |
| `type.eyebrow` | Inter | 12 / 16 | Semibold | +0.96 (8%) UPPERCASE | — | Section eyebrows, form labels |
| `type.caption` | Inter | 11 / 13 | Medium | +0.1 | labelSmall | Tab bar labels, chip counts |
| `type.button` | Inter | 17 / 22 | Medium | −0.2 | labelLarge | Pill buttons (large) |
| `type.buttonSmall` | Inter | 15 / 20 | Medium | −0.1 | labelMedium | Pill buttons (small), chips |
| `type.numeral` | `.tabular` extension | inherits | Regular/Medium | 0 | — | Money, times, counts |

**Rules**
- Weights: Regular, Medium, Semibold. No Bold or Heavy in product UI.
- Uppercase is only for eyebrows and form labels, never for user content (fixes a Bonvoy weak spot).
- All times, prices and counts use tabular figures so columns align.
- Line length for diary text is ≤ 34em; long content goes in a reading view.
- `TPType.diaryQuote` (Newsreader Italic 22/30) is for pull quotes in Memories only.

---

## Spacing & layout

4pt base grid.

| Token | pt | Typical use |
|---|---|---|
| `space.1` | 4 | Icon-to-label inside chips |
| `space.2` | 8 | Stacked metadata lines, avatar overlap (−8) |
| `space.3` | 12 | Gap between chips, between carousel cards |
| `space.4` | 16 | Card inner padding, row vertical padding |
| `space.5` | 20 | Gap between title and content in a section |
| `space.6` | 24 | **Screen side margin** (same as Bonvoy) |
| `space.8` | 32 | Between related sections |
| `space.10` | 40 | Between unrelated sections |
| `space.12` | 48 | Above a large title, hero bottom padding |
| `space.16` | 64 | Empty-state top padding |

**Layout rules**
- Side margin is **24pt**. Full-bleed only for hero photos and section bands.
- Carousels: cards are `screen width − 2×24 − 32` wide so **32pt of the next card peeks**, with a 12pt gap and snapping.
- Sections: eyebrow → 12pt → content. A large section title → 20pt → content.
- Section separation: on content screens use **space**. On hub screens (Trip Home) use an **8pt sunken band**, as Bonvoy's stay hub does.
- Rows: 56pt minimum height for single-line, 72pt for two-line; hairline dividers inset 24pt (or to text start when there's a leading icon).
- Hit targets: ≥ 44×44pt.

---

## Shape

| Token | pt | Use |
|---|---|---|
| `radius.xs` | 6 | Thumbnails in rows, small image chips |
| `radius.sm` | 10 | Glass chips on photos, input wells, tooltips |
| `radius.md` | 16 | Cards, list containers |
| `radius.lg` | 24 | Hero feature cards, trip cover cards |
| `radius.sheet` | 28 | Sheet top corners |
| `radius.pill` | 999 | Buttons, search, chips, floating buttons |
| `radius.circle` | 50% | Avatars, quick actions, date selection |

Use continuous (superellipse) corners like iOS: `RoundedSuperellipseBorder` and `ClipRSuperellipse` (Flutter 3.32+).

Shape vocabulary (one meaning each):
- **Pill:** you can act on it (button, chip, search).
- **Rounded rectangle:** a thing you can open (card).
- **Circle:** a person or a tool (avatar, quick action).
- **Sheet:** a task on top of where you are.
- **Dashed rounded rectangle:** a space the group hasn't filled yet.

---

## Elevation

Shadows are soft, wide and low-opacity, warm-tinted with ink rather than pure black.

| Token | Value (light) | Use |
|---|---|---|
| `elevation.0` | none, 1px hairline border | Flat lists, rows on canvas |
| `elevation.1` | `0 1px 2px rgba(22,23,27,.04), 0 6px 20px rgba(22,23,27,.06)` | Cards |
| `elevation.2` | `0 2px 6px rgba(22,23,27,.05), 0 12px 32px rgba(22,23,27,.10)` | Floating search, quick-action circles, sticky bars, floating "Map" pill |
| `elevation.3` | `0 −8px 40px rgba(22,23,27,.14)` | Sheets |

In dark mode shadows are replaced by surface lightness (`bg.surface` → `bg.raised`) plus a hairline border. `TPElevation.of(brightness)` returns the right list.

---

## Iconography
- **Phosphor Icons** (MIT), bundled in the package and exposed as a curated set: `TPIcons.*` (regular, the default) and `TPIconsFill.*` (filled). Phosphor's regular weight has the same calm, even stroke as SF Symbols, and it ships a matching fill for every glyph.
- Sizes: 22pt for leading icons in list rows, nav bars and quick actions; 18pt for chevrons and inline status; 24pt in the tab bar.
- Outline by default; the **filled** variant marks the active tab or a toggled state (saved heart, your vote).
- Icon color follows the text color it sits next to; Lagoon only on active/selected.
- No emoji as icons. Emoji appear only as user reactions.
- To add an icon, add its codepoint to `lib/src/foundations/tp_icons.dart` in both classes. The curated list keeps the vocabulary small.

Core set: `house` · `suitcase` (Trips) · `calendarBlank` (Plan) · `chatsCircle` (Chat) · `notebook` (Memories) · `userCircle` (You) · `mapTrifold` · `mapPin` · `userPlus` (invite) · `receipt` (split) · `images` · `camera` · `heart` · `export` · `dotsThree` · `caretRight` · `x` · `arrowLeft` · `arrowRight` · `magnifyingGlass` · `pencilSimple` · `checkCircle` · `sealCheck` (booked) · `smiley` (react) · `forkKnife` · `bell` · `airplane` · `bed` · `ticket` · `wallet` · `clock`.

---

## Imagery
- Trip covers: one photo per trip, chosen by the group, shown 4:5 on cards and full-bleed 3:4 on the trip hero.
- Text on photos: white, bottom-left, 24pt inset, always on `overlay.scrim`.
- Metadata on photos: **glass chips** (`overlay.glass`, `radius.sm`, `type.footnote`, white).
- Never put a colored block over a photo; let the photo carry the emotion.
- Fallback when there's no photo: a `bg.sunken` card with the destination name in Newsreader at `display` size. No stock illustration.

---

## Motion

| Token | Value | Use |
|---|---|---|
| `motion.duration.instant` | 120ms | Press states, toggles |
| `motion.duration.quick` | 200ms | Chips, tab switches, fades |
| `motion.duration.standard` | 320ms | Sheets, card expand |
| `motion.duration.slow` | 480ms | Hero transitions, vote tallies |
| `motion.easing.standard` | `cubic-bezier(0.2, 0, 0, 1)` | Most transitions |
| `motion.easing.exit` | `cubic-bezier(0.4, 0, 1, 1)` | Dismissals |
| `motion.spring.gentle` | `TPMotion.gentle`: `SpringDescription(mass: 1, stiffness: 224, damping: 25.7)` (≈ 0.42s response, 0.86 damping) | Sheets, cards settling |

- Press feedback: scale to 0.98 + `primaryPressed`, with `HapticFeedback.lightImpact()` on primary actions and `selectionClick()` on tab changes.
- Votes and totals count up over `slow`. When `MediaQuery.disableAnimationsOf(context)` is true they snap.
- No looping or decorative animation in product UI.

Next: [04 · Components](./04-components.md)
