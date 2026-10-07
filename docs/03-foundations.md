# 03 · Foundations

Every value here exists in two places:
- [`tokens/tokens.json`](../tokens/tokens.json): W3C design-tokens format, the source of truth for design tools (Figma Tokens/Variables).
- The Flutter package in [`lib/`](../lib): `TPPalette`, `TPColors` (a `ThemeExtension`), `TPType`, `TPSpace`, `TPRadius`, `TPSize`, `TPElevation`, `TPMotion`, `TPIcons`, and `TripamiTheme` for `ThemeData`.

In Dart, read colors with `TPColors.of(context)` so light and dark resolve automatically.

---

## Color

**Light is the default theme.** The app opens in light whatever the phone is set to (`themeMode: TripamiTheme.defaultMode`). Dark is a choice the user makes in settings (Light · Dark · Match phone); it is fully specified below and passes the same contrast checks. Design and review in light first.

### Brand: from the logo
The logo is a navy wordmark with an orange dot on the "i". Those two colors are the brand, and the product UI uses them the way the logo does: navy carries everything, and orange is one small, deliberate point.

| Token | Value | Use |
|---|---|---|
| `color.brand.navy` | `#02203A` | Logo wordmark; also `text.primary` and the ink pill |
| `color.brand.orange` | `#FC6316` | The logo dot and brand moments (cover, splash, marketing). 3.0:1 on white, so **never** text or a meaningful UI mark: the UI uses `accent` instead |

### Neutrals: paper & navy ink
Warm paper with navy ink, like a notebook. The dark theme is a deep navy night rather than neutral black, so it stays on brand.

| Token | Light | Dark | Use |
|---|---|---|---|
| `color.bg.canvas` | `#FAFAF7` paper | `#0B1220` | Screen background |
| `color.bg.surface` | `#FFFFFF` | `#121A29` | Cards, sheets, sticky bars |
| `color.bg.sunken` | `#F2F1EC` | `#070C16` | Section bands, input wells, skeletons |
| `color.bg.raised` | `#FFFFFF` | `#1A2333` | Floating search, popovers |
| `color.border.hairline` | `#E6E4DE` | `#243045` | Row dividers, card outlines |
| `color.border.strong` | `#D6D3CB` | `#334058` | Outline buttons, chips, input underline |
| `color.text.primary` | `#02203A` navy | `#F2F1EC` | Titles, body |
| `color.text.secondary` | `#525D6E` | `#A7AFBD` | Metadata, eyebrows, captions |
| `color.text.tertiary` | `#66707F` | `#8C95A3` | Placeholders, disabled labels. Use on canvas/surface only, not on sunken |
| `color.text.onImage` | `#FFFFFF` | `#FFFFFF` | Text on photo scrims |
| `color.text.inverse` | `#FAFAF7` | `#02203A` | Text on ink pill |

Contrast (WCAG 2.1): primary 15.8:1, secondary 6.4:1 on canvas (5.9:1 on sunken), tertiary 5.0:1 on surface. All pass AA, which fixes a Bonvoy weak spot.

### Action: ink
| Token | Light | Dark |
|---|---|---|
| `color.action.primary` | `#02203A` | `#F2F1EC` |
| `color.action.primaryPressed` | `#12355A` | `#D9D8D2` |
| `color.action.primaryText` | `#FAFAF7` | `#02203A` |

In dark mode the ink pill inverts to a **paper pill**. It stays the highest-contrast object on screen, which matches Bonvoy's black pill on white.

### Accent: Tripami orange
The logo's orange, deepened just enough to pass AA as text on every light ground (5.3:1 on canvas, 4.9:1 on sunken, 5.0:1 on its own subtle tint). In dark mode it brightens to `#FF7A3D` (6.9:1 on surface).

| Token | Light | Dark | Use |
|---|---|---|---|
| `color.accent.default` | `#B8400F` | `#FF7A3D` | Active tab indicator, selected states, links, "now", your vote, deadlines, the needs-you dot |
| `color.accent.pressed` | `#9A3409` | `#FF9866` | Pressed links |
| `color.accent.subtle` | `#FFF1E8` | `#3A1D10` | Selected chip fill, today's row tint |
| `color.accent.onAccent` | `#FFFFFF` | `#02203A` | Text/glyph on accent (checkmarks only) |

**Rules:** the accent is never a primary-button fill, never a large background, and covers ≤ 5% of a screen.

### Member colors: the social layer
Eight hues, assigned to travelers in join order (the trip creator gets `lagoon`). None sits near the brand orange, so a person's color is never mistaken for the accent. They're the *only* saturated UI colors besides the accent, and they always mean **"this belongs to this person."**

| Join order | Token | Hex | White text contrast |
|---|---|---|---|
| 1 (trip creator) | `color.member.lagoon` | `#0B6B61` | 6.4:1 |
| 2 | `color.member.plum` | `#7F4FAE` | 5.8:1 |
| 3 | `color.member.fern` | `#3F7D4E` | 4.9:1 |
| 4 | `color.member.iris` | `#5160C9` | 5.4:1 |
| 5 | `color.member.olive` | `#66692B` | 5.8:1 |
| 6 | `color.member.rose` | `#B2466E` | 5.3:1 |
| 7 | `color.member.sky` | `#2F73A8` | 5.1:1 |
| 8 | `color.member.slate` | `#4F5D75` | 6.6:1 |

**The join order is chosen for color blindness.** We simulated protanopia, deuteranopia and tritanopia and picked the order that keeps the first *k* colors furthest apart for every trip size. The worst pair stays at ΔE ≥ 3.7 for trips of up to six (in plain hue order it dropped to 2.0). With seven or eight travelers some pairs converge for some readers, so **color is never the only cue**: avatars carry initials, braid knots show faces, and every plan names who's in it. `TPMemberColor.forJoinIndex(i)` applies the order.

Each member color also has a **strand** value for the braid: the same hex in light mode, and a lighter version in dark mode (lagoon `#0F9083`, sky `#3683C0`, iris `#6C79D1`, plum `#966EBD`, rose `#BF5D81`, fern `#468B56`, olive `#7F8235`, slate `#6E809D`), each ≥ 4.5:1 on dark canvas. Avatar fills keep the base color in both themes.

Used for: avatar fill (white initials) when there's no photo, a 2pt avatar ring when there is one, a voter's dot on a poll, the payer marker on an expense, the "added by" mark on an itinerary item, and a cursor/presence dot. **Never** for buttons, backgrounds, or text longer than a name. Groups larger than 8 cycle the palette and are told apart by initials.

### Semantic
| Token | Light | Dark | Use |
|---|---|---|---|
| `color.status.positive` | `#2E7D4F` | `#6FCF97` | Settled up, confirmed |
| `color.status.caution` | `#7A5A00` | `#E8C054` | Unpaid, deadline soon |
| `color.status.critical` | `#B3133F` | `#FF6B8A` | Errors and destructive actions only. Shifted toward crimson so it never reads as the orange accent |

### Tints and shades
Fourteen ramps of 11 steps each, from **50** (lightest) to **950** (darkest), generated in OKLCH from Tripami's own colors: `neutral` (paper to ink), `navy`, `orange`, `red`, `green`, `amber`, and one for each member color. In Flutter: `TPRamps.orange[100]`; on the web: `var(--orange-100)`.

**Grade is luminance.** Unlike most palettes, where "500" means something different in every hue, a Tripami grade fixes the color's luminance. So the contrast between two colors depends only on the gap between their grades, whatever the hues. You never need a contrast checker:

| Grade gap | Contrast | Safe for |
|---|---|---|
| ≥ 400 | ≥ 3:1 | Large text (≥ 18pt, or 14pt bold), icons, borders that carry meaning |
| ≥ 500 | ≥ 4.5:1 | All text (WCAG AA) |
| ≥ 650 | ≥ 7:1 | WCAG AAA |

White is grade 0 and black 1000, so **white text works on any step from 500**, and **950 text works on any step to 450**. It holds across ramps too: `orange-100` behind `navy-700` text is a 600 gap, so ≥ 4.5:1. The tests check every pair of the 154 colors.

How they're made (`tool/ramps/generate.py`):
- Each step's luminance comes from its grade, the same in every ramp.
- Hue and chroma come from **anchors**, the colors Tripami already uses: the accent and brand orange anchor `orange`; canvas, borders and the dark surfaces anchor `neutral`; each member color and its strand anchor its ramp. Between anchors, hue and chroma are interpolated in OKLCH, so steps look evenly spaced to the eye.
- Light steps fade toward white and dark steps toward black without going muddy. Colors are pulled into sRGB by lowering chroma, never by shifting hue.
- To change a ramp, edit its anchors and rerun the script, which also writes `tp_ramps.dart` and `tokens.json`. It refuses to write a palette that breaks the contrast rules.

| Ramp | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 | 950 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `neutral` | `#EFEEE9` | `#E0DDD6` | `#C0BFBC` | `#A2A5A7` | `#868D95` | `#6D7784` | `#576272` | `#424E63` | `#2E3B52` | `#1C2536` | `#101726` |
| `navy` | `#E6EFF9` | `#D2DFED` | `#AFC1D6` | `#91A6C0` | `#768EAB` | `#5D7898` | `#466385` | `#305073` | `#1A3C60` | `#062643` | `#02182D` |
| `orange` | `#FFEADE` | `#FFD5C1` | `#FFAB87` | `#FF8048` | `#EF5C15` | `#CD4B11` | `#AC3B0D` | `#89310D` | `#622A11` | `#3A1D10` | `#261209` |
| `red` | `#FFE8EB` | `#FFD2D8` | `#FFA7B4` | `#FF7A93` | `#EC5877` | `#D33E5E` | `#BB2046` | `#9C0B35` | `#780527` | `#4F0418` | `#35040E` |
| `green` | `#CFF7DD` | `#AFEBC5` | `#76D29B` | `#5BB681` | `#479C6A` | `#348455` | `#256E44` | `#1A5935` | `#114327` | `#092B18` | `#061B0E` |
| `amber` | `#FFECBE` | `#F7DB93` | `#E2BB50` | `#C69F3C` | `#AB8729` | `#937117` | `#7C5C02` | `#644900` | `#4C3700` | `#312300` | `#201601` |
| `lagoon` | `#D7F4EF` | `#BCE6DF` | `#8DCBC1` | `#62B2A7` | `#349B8F` | `#0D8478` | `#0B6D63` | `#02584F` | `#00423C` | `#022A26` | `#021B18` |
| `sky` | `#DFF0FF` | `#C2E1FE` | `#96C4ED` | `#70AADC` | `#4D91CA` | `#327BB3` | `#276596` | `#1B517A` | `#123D5E` | `#0A273D` | `#061928` |
| `iris` | `#E9EDFF` | `#D4DCFF` | `#B0BDF8` | `#93A0E9` | `#7986D9` | `#606ECD` | `#4A58BB` | `#3A4699` | `#2B3476` | `#1A214E` | `#101534` |
| `plum` | `#F4EAFF` | `#E8D7FC` | `#CEB5EA` | `#B797D8` | `#A17CC7` | `#8D63B7` | `#7A4BA7` | `#633B89` | `#4B2B69` | `#301B45` | `#1F112E` |
| `rose` | `#FFE8EF` | `#FFD2DF` | `#F0ADC2` | `#DD8DA8` | `#CB6F90` | `#BA5379` | `#A23E63` | `#842F4F` | `#66223C` | `#431526` | `#2C0D18` |
| `fern` | `#DFF3E2` | `#C7E5CC` | `#9FCAA6` | `#7CB185` | `#5B9A68` | `#428351` | `#346D42` | `#275733` | `#1C4225` | `#102A17` | `#0A1B0E` |
| `olive` | `#EEF0D9` | `#DDE0C0` | `#BFC394` | `#A5A86E` | `#8D904B` | `#777A32` | `#626528` | `#4E511D` | `#3B3D14` | `#25270B` | `#181906` |
| `slate` | `#E8EEF8` | `#D5DEEC` | `#B4C0D4` | `#96A5BD` | `#7C8DA8` | `#667792` | `#53627B` | `#424E63` | `#313B4B` | `#1F2531` | `#13181F` |

**Tone roles.** Don't pick steps by hand for common jobs. `TPTone.of(context, TPRamps.green)` gives theme-aware roles whose pairings are safe by construction:

| Role | Light | Dark | Use |
|---|---|---|---|
| `subtle` | 50 | 950 | Tinted background: a banner, a "you're owed" row, a member's highlight |
| `muted` | 100 | 900 | Hover, pressed or selected tinted background |
| `border` | 200 | 800 | Decorative outline on a tinted area |
| `text` | 700 | 200 | Tinted text and icons on `subtle`, `muted`, canvas or surface (≥ 7:1 on `subtle`) |
| `solid` | 600 | 400 | Filled badge or strong banner |
| `solidPressed` | 700 | 300 | Pressed fill |
| `onSolid` | white | 950 | Text and icons on `solid` |

**Where the semantic colors sit.** The semantic tokens stay exactly as they are; they're anchors on the ramps. Their grades let you check any pairing with the gap rule: `accent` (565) on `canvas` (15) is a 550 gap, so ≥ 4.5:1.

| Token | Light grade | Dark grade |
|---|---|---|
| `canvas` | 15 | 965 |
| `surface` | 0 | 942 |
| `sunken` | 41 | 980 |
| `hairline` | 79 | 852 |
| `border-strong` | 133 | 772 |
| `text-primary` | 924 | 41 |
| `text-secondary` | 625 | 261 |
| `text-tertiary` | 531 | 365 |
| `accent` | 565 | 314 |
| `accent-subtle` | 33 | 901 |
| `brand-orange` | 365 | — |
| `positive` | 533 | 212 |
| `caution` | 611 | 182 |
| `critical` | 632 | 330 |

**Rules**
- **Semantic tokens first.** Use `TPColors` for everything they cover (text, surfaces, the accent, status). Ramps are for what they don't: tinted banners, illustration, charts, a member's highlight row, empty-state art.
- **The accent rules still apply to `orange`:** orange steps mark state or brand moments only, never a button fill, at most about 5% of a screen.
- **Member ramps mean "this person"**: tint a row or card with its member's `subtle` to show whose it is. Never use them as decoration.
- **`red`, `green` and `amber` keep their status meanings.** Always pair them with a word or icon.
- **Dark mode flips the grade:** a light-mode role at grade *g* uses about *1000 − g* in dark. `TPTone` does this for you.

### Imagery overlays
| Token | Value | Use |
|---|---|---|
| `color.overlay.scrim` | `linear-gradient(180deg, rgba(2,16,30,0) 40%, rgba(2,16,30,.62) 100%)` | Text on photos (always bottom-aligned) |
| `color.overlay.glass` | `rgba(2,32,58,.48)` + `blur(16px)` | Chips and icon buttons on photos |
| `color.overlay.dim` | `rgba(2,32,58,.36)` | Behind sheets |

---

## Typography

Three open-licensed (OFL) variable families, bundled in the package so iOS and Android render identically:

- **Bricolage Grotesque** (display): trip names and day headings, set at 800 and 700 to echo the heavy, warm letterforms of the wordmark. It's a close match chosen for the brand, not the logo's own typeface, so never use it to re-typeset the logo. It has optical sizes from 12 to 96pt.
- **Inter** (UI): every control, label, number and body text. It's a neo-grotesk close to SF Pro, with true tabular figures and an optical-size axis.
- **Newsreader** (diary voice): journal text and pull quotes in Memories. *Never* on buttons, tabs, inputs or eyebrows. It's an editorial serif with optical sizes from 6 to 72pt, so display settings tighten and text settings open up.

Why not SF Pro and New York? Apple's license restricts them to Apple platforms, so a Flutter app shipping to Android can't bundle them. `TPType` sets the `wght` and `opsz` variation axes explicitly, because Flutter doesn't map `FontWeight` onto variable axes on every platform.

### Scale (logical pixels; scales with `MediaQuery.textScaler`)

| Token (`TPType.*`) | Family | Size / Line | Weight | Tracking | `TextTheme` slot | Use |
|---|---|---|---|---|---|---|
| `type.display` | Bricolage Grotesque | 34 / 38 | ExtraBold 800 | −0.7 | displaySmall | Trip name on hero, Memories title |
| `type.title1` | Inter | 28 / 34 | Regular | −0.4 | headlineLarge | Screen large titles ("Trips") |
| `type.diaryHeading` | Bricolage Grotesque | 24 / 30 | Bold 700 | −0.3 | headlineMedium | Day headings ("Friday, 13 June") |
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
- Weights: Regular, Medium, Semibold for UI. Bold and ExtraBold exist only in the display face (`display`, `diaryHeading`).
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

## Braid metrics
| Token | Value | Use |
|---|---|---|
| `braid.strand` | 3pt | Person strand; your strand is +1.5pt |
| `braid.ribbonMax` | 12pt | Widest group ribbon (3pt + 0.6pt per person) |
| `braid.gap` / `braid.bundleGap` | 4pt / 12pt | Inside a bundle / between bundles |
| `braid.gutter` | ≥ 88pt | Strand gutter beside the cards |
| `braid.turn` | 48pt | Height of the curve into each plan |
| `braid.maxStrands` | 6 | Most strands on screen on big trips |
| `braid.twoSidedMinWidth` | 600pt | Width at which other groups move to a right-hand gutter |

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
| `elevation.1` | `0 1px 2px rgba(2,32,58,.04), 0 6px 20px rgba(2,32,58,.06)` | Cards |
| `elevation.2` | `0 2px 6px rgba(2,32,58,.05), 0 12px 32px rgba(2,32,58,.10)` | Floating search, quick-action circles, sticky bars, floating "Map" pill |
| `elevation.3` | `0 −8px 40px rgba(2,32,58,.14)` | Sheets |

In dark mode shadows are replaced by surface lightness (`bg.surface` → `bg.raised`) plus a hairline border. `TPElevation.of(brightness)` returns the right list.

---

## Iconography
- **Phosphor Icons** (MIT), bundled in the package and exposed as a curated set: `TPIcons.*` (regular, the default) and `TPIconsFill.*` (filled). Phosphor's regular weight has the same calm, even stroke as SF Symbols, and it ships a matching fill for every glyph.
- Sizes: 22pt for leading icons in list rows, nav bars and quick actions; 18pt for chevrons and inline status; 24pt in the tab bar.
- Outline by default; the **filled** variant marks the active tab or a toggled state (saved heart, your vote).
- Icon color follows the text color it sits next to; the accent only on active/selected.
- No emoji as icons. Emoji appear only as user reactions.
- To add an icon, add its codepoint to `lib/src/foundations/tp_icons.dart` in both classes. The curated list keeps the vocabulary small.

Core set: `house` · `suitcase` (Trips) · `calendarBlank` (Plan) · `chatsCircle` (Chat) · `notebook` (Memories) · `userCircle` (You) · `mapTrifold` · `mapPin` · `userPlus` (invite) · `receipt` (split) · `images` · `camera` · `heart` · `export` · `dotsThree` · `caretRight` · `x` · `arrowLeft` · `arrowRight` · `magnifyingGlass` · `pencilSimple` · `checkCircle` · `sealCheck` (booked) · `smiley` (react) · `forkKnife` · `bell` · `airplane` · `bed` · `ticket` · `wallet` · `clock`.

---

## Imagery
- Trip covers: one photo per trip, chosen by the group, shown 4:5 on cards and full-bleed 3:4 on the trip hero.
- Text on photos: white, bottom-left, 24pt inset, always on `overlay.scrim`.
- Metadata on photos: **glass chips** (`overlay.glass`, `radius.sm`, `type.footnote`, white).
- Never put a colored block over a photo; let the photo carry the emotion.
- Fallback when there's no photo: a `bg.sunken` card with the destination name in `display`. No stock illustration.

---

## Motion

**Calm by default, playful when people come together.** About 90% of motion is quiet and quick. The other 10% is a short list of people moments that get a small bounce. The braid sets the style: things weave, gather and part, and never fly in from off-screen.

**Principles**
1. **Fast to respond, gentle to settle.** Touches react within 120ms. Things settle on soft springs, not hard stops.
2. **Bounce is earned.** Only people moments use `playful` (about 5% overshoot), at most one per screen. Chrome, navigation and text never bounce.
3. **Movement follows the metaphor.** Strands reroute, avatars gather into bundles, cards rise 8pt. Nothing crosses the whole screen.
4. **The orange dot is the playful signature.**

| Token (`TPMotion.*`) | Value | Use |
|---|---|---|
| `instant` / `quick` / `standard` / `slow` | 120 / 200 / 320 / 480ms | Press, fades, sheets, tallies |
| `ease` | `cubic-bezier(0.2, 0, 0, 1)` | Every everyday transition |
| `exit` | `cubic-bezier(0.4, 0, 1, 1)` | Dismissals |
| `gentle` (+ `gentleCurve`, 430ms) | response 0.42s, damping 0.86, no overshoot | Sheets, cards settling, braid rerouting |
| `snappy` (+ `snappyCurve`, 250ms) | response 0.28s, damping 0.9 | Chips, tab indicators, toggles |
| `playful` (+ `playfulCurve`, 500ms) | response 0.45s, damping 0.7, ~4.7% overshoot | People moments only |
| `stagger` | 30ms per item, max 6 | Groups entering together |

On the web, the same springs are CSS `linear()` easings (`--tp-spring-gentle`, `--tp-spring-snappy`, `--tp-spring-playful`), sampled from the same physics.

**Signature moments (the playful 10%)**
| Moment | Motion | Widget |
|---|---|---|
| Launch | The orange dot drops onto the "i" with one bounce | `TPBrandDot` (needs a wordmark without its dot) |
| Needs-you dot arrives | Pops 0 → 1.05 → 1 | `TPActivityDot(urgent: true)` |
| Opening a day | Strands draw top to bottom in one 600ms sweep; cards rise as the line reaches them | `TPBraidDay` |
| Plans change | Strands glide to their new bundles on `gentle` | `TPBraidDay` |
| Someone joins a plan | The plan's avatars pop; your strand swings in; light haptic | `TPBraidDay` + `TPHaptics.join()` |
| Voting | Share bars spring to their new size | `TPPollCard` |
| Everyone's in / Back together / Settled | One accent check draws itself; success haptic; no confetti | `TPSuccessCheck` |

**Everyday motion (the calm 90%)**
- **Sheets:** rise on `gentle`, with the dim fading in over 200ms.
- **Navigation:** platform page transitions.
- **Presses** (`TPPressable`): settle to a smaller scale in 120ms and spring back on `snappy` when released. Use 0.98 for buttons and rows, 0.96 (or 0.94) for small round controls, and 0.99 for cards, so big surfaces barely move.
- **Tab indicators and chips:** move on `snappy`. The new tab's filled icon scales in from 0.8, and a chip's check grows in.
- **Changing numbers and badges** (`TPBump`): a 320ms bump to 1.12 and back, for reaction counts, "+N" and chip counts.
- **List rows and cards:** enter with `TPRise`, staggered. Plans revealed by "Show more" rise the same way.
- **Numbers:** money and counts tick with `TPCountUp` over 480ms, in tabular figures.
- **Hero photos:** only the slightest scale on scroll (about 1.02).

### Haptics

A haptic answers **your own touch**, or confirms that **the group finished something**. Other people's changes arriving from the server never buzz; they get motion only. Each gesture gets at most one haptic.

| `TPHaptics.*` | Feels like | Used for |
|---|---|---|
| `select()` | Selection tick | Changing tab, chip, segment, toggle or option; the Map/List pill |
| `join()` | Light tap | Primary buttons, voting, reacting, joining a plan |
| `reorder()` | Medium tap | Picking up and dropping a plan while dragging |
| `success()` | Firm tap, then a light one 90ms later | "Everyone's in", "Back together", "Settled" (with `TPSuccessCheck`) |
| `warning()` | Heavy tap | Something refused: an invalid field, a delete that can't happen |

Silent: secondary, tertiary and destructive buttons (the confirm in the sheet carries the weight), tapping the tab you're already on, opening sheets, toasts, scrolling and navigation.

`TPHaptics.enabled = false` turns them all off, so an in-app "Vibration" setting is one line. The phone's own system haptics setting still applies.

### What each component does

| Component | Motion | Haptic |
|---|---|---|
| `TPButton` | Press 0.98 | Primary: `join` |
| `TPGlassIconButton` · `TPQuickAction` | Press 0.94 / 0.96 | None |
| `TPFloatingPill` | Press 0.96 | `select` |
| `TPCard(onTap)` · `TPTripCoverCard` · braid plan cards | Press 0.99 / 0.98 / 0.99 | None |
| `TPTabBar` · `TPUnderlineTabs` | Indicator on `snappy`; filled icon scales in | `select` on change |
| `TPFilterChip` | Fill on `snappy`; check grows in; count bumps | `select` |
| `TPToggle` | Platform switch | `select` |
| `TPReactionBar` | Press 0.94; count bumps; colors ease to "mine" | `join` (add-reaction is silent) |
| `TPAvatarStack` | A new face pops on `playful`; the others glide over; "+N" bumps | None |
| `TPActivityDot(urgent)` | Pops on `playful` | None |
| `TPPollCard` | Bars spring; counts tick; a new voter pops; the last vote draws the check; the winner's check pops | `success` on the last vote, only if it happens on screen |
| `TPBraidDay` | Draw-in, reroute, knot pop, Show-more rise | None (a join is the button's `join`) |

A state that was already true when the screen opened (a finished poll, for example) shows at rest, with no animation and no haptic.

**Never:** confetti, looping or idle animation, bouncing text or navigation, anything longer than about 600ms, or parallax beyond that hint on hero photos.

**Reduced motion** (`TPMotion.reduced(context)`): movement becomes 120ms fades, the braid appears fully drawn, the dot appears without bouncing, and numbers show their final value, presses don't scale and bumps are skipped. Haptics stay.

Next: [04 · Components](./04-components.md)
