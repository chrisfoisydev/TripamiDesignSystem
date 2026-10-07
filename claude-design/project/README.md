Tripami is a collaborative group-travel app. Its product UI pairs a hotel concierge's editorial restraint with a shared travel diary and Apple-level utility. The product is calmer than the marketing: when in doubt, take something away.

## Six rules, in priority order

1. **Places and people bring the color.** Chrome is `canvas`, `surface` and `text-primary` ink. Color comes from trip photos and the eight `member-*` colors. Cover the photos and avatars on any layout: what's left should be almost monochrome.
2. **The accent shows state; ink shows action.** `accent` (Tripami orange) marks *you, now, selected, live*: the active tab, a selected chip, your vote, the current itinerary item, links. It covers at most 5% of a layout and is never a button fill. Primary actions are `action-primary` ink pills.
3. **One loud voice, everything else quiet.** The display face (`display`, `diary-heading`) is set heavy, like the wordmark, and is the only type above weight 600. Everything else gets hierarchy from size, case and space: large titles (`title1`) are Regular, and the heaviest UI weight is 600, for `eyebrow` only. Uppercase is only for `eyebrow` labels, never for user content.
4. **Social presence without noise.** People appear as avatars and first names inside content ("Waiting on Jonah and Priya"), not as notification feeds. Show activity with an `ActivityDot` (navy for new, orange for needs-you), not a count badge. Emoji appear only as user reactions.
5. **Utility you don't notice.** Every secondary task is a sheet with a grabber. One primary action per view. Touch targets are at least `size-hit-target`. Every text pairing passes WCAG AA in both themes.
6. **Calm is a feature.** Motion explains, it doesn't decorate: 120–480ms on `cubic-bezier(0.2, 0, 0, 1)`, and it collapses under reduced motion. Celebrate with a single `accent` check and one warm sentence. No confetti.

## Content

- **Voice:** the friend who planned the trip. Second person, short, specific, warm. No exclamation marks in system copy.
- **Names over numbers:** "Waiting on Jonah and Priya", not "2 pending". "Maya added" on everything a person contributed.
- **Sentence case** for buttons and titles: "Create trip", "Needs your vote". Verb first on buttons.
- **Examples:** "Where's the group headed?" · "Lisbon in 6 days. Here's where things stand." · "Booked. Everyone can see it in the plan." · "Nothing saved yet. Add a place and the group can vote on it." · "Couldn't save the expense. Check your connection and try again."
- **Numbers:** money, times and counts use tabular figures (`font-variant-numeric: tabular-nums`). Dates are written "Thu 12 Jun", ranges "12–17 Jun", times in 24h ("20:30").

## Logo

- The `Logos` group holds two versions, both with the `brand-orange` dot: `tripami-wordmark.webp` (`brand-navy` letters) for light grounds and `tripami-wordmark-reversed.webp` (white letters) for dark grounds and dark photos. Choose by the ground behind it.
- Use the files as supplied: never redraw, recolor, outline, stretch or re-typeset them, and never detach the dot.
- Keep clear space of at least the dot's diameter around it.
- The product UI borrows the logo's logic: navy carries everything, and orange is one small, deliberate point.

## Color

**Light is the default theme.** Tripami opens in light (paper canvas, navy ink) whatever the device is set to; dark is a user choice in settings, fully specified and contrast-checked. Design and review in light first, then check dark.

- The brand is two colors from the logo: `brand-navy` (#02203A) and `brand-orange` (#FC6316). `brand-orange` is 3.0:1 on white, so it appears only in the logo, the cover and brand moments. In the UI, orange is `accent`, the same hue deepened to pass AA.

- Screens sit on `canvas` (warm paper). Cards, sheets, sticky bars and the tab bar sit on `surface`. Use `sunken` for section bands on hub screens, input wells and the "+N" avatar.
- Text: `text-primary` for titles and body; `text-secondary` for metadata, eyebrows and captions (AA on every ground); `text-tertiary` for placeholders on `canvas` or `surface` only.
- Divide with `hairline`. Outline controls with `border-strong`.
- **Primary action:** `action-primary` fill with `action-primary-text`. In dark mode it inverts to a paper pill, so it stays the highest-contrast object.
- **Accent:** use `accent` for state, `accent-subtle` for selected fills (with `accent` text on top), and `on-accent` for a glyph on an accent fill.
- **Members:** each traveler gets a `member-*` color in join order. The trip creator is `member-lagoon`. None of the member hues sits near the orange, so a person is never mistaken for the accent. Use them for avatar fills (white initials pass AA), avatar rings, vote and payer dots, and pull-quote rules. Never use them for buttons, backgrounds or text longer than a name.
- **Status:** `positive` (settled, confirmed), `caution` (you owe), `critical` (errors and destructive actions only; crimson, so it never reads as the accent). Always pair status color with a word.
- **On photos:** put text bottom-left in `text-on-image` over the scrim (transparent at 40% to `scrim-end`). Put metadata in glass chips (`glass` with a 16px backdrop blur). Never place a colored block over a photo.


### Tints and shades

- **14 ramps, 50–950**, built in OKLCH from Tripami's own colors: `neutral` (paper to ink), `navy`, `orange`, `red`, `green`, `amber`, and one per member color. Tokens `orange-100`, `navy-700`…; see the **Tints & shades** card.
- **Grade is luminance**, the same in every ramp, so contrast follows from the grade gap alone, in any pair of hues: **≥ 400 → 3:1** (large text, icons), **≥ 500 → 4.5:1** (all text), **≥ 650 → 7:1**. White text passes on every step from 500.
- **Use semantic tokens first.** Ramps are for what they don't cover: tinted banners, a member's highlight row, charts, illustration. For tinted UI use the **Tones** roles: `subtle` 50/950, `muted` 100/900, `border` 200/800, `text` 700/200, `solid` 600/400 with white/950 on it (light/dark).
- `orange` keeps the accent rules (state and brand only, never a button fill). `red`, `green` and `amber` keep their status meanings. A member's ramp means "this person".

## Type

- **Bricolage Grotesque** (`--font-display`) is the display voice, chosen to echo the wordmark's heavy, warm letterforms: `display` (800) for trip names and `diary-heading` (700) for day headings. Use it only at those two styles, at most once or twice per view, and never for UI text. It is a close match, not the logo's own typeface: never use it to re-typeset the logo.
- **Inter** (`--font-ui`) for everything functional: controls, labels, numbers, body.
- **Newsreader** (`--font-diary`) is the diary voice for long-form reading: `diary-body` for journal entries and `diary-quote` (italic) for pull quotes. Never use it on buttons, tabs, inputs or eyebrows. Money is utility and is always Inter.
- Scale: `display` 34/38 · `title1` 28/34 · `diary-heading` 24/30 · `title2` 22/28 · `title3` 18/24 · `body` 17/24 · `callout` 15/20 · `subhead` 14/19 · `footnote` 13/18 · `eyebrow` 12/16 caps · `caption` 11/13.
- All three families are variable fonts with an optical-size axis. Keep `font-optical-sizing: auto` so display sizes tighten and small text opens up.

## The braid

The Plan view draws the day as a braid (`BraidDay`): one strand per traveler, bundling into shared plans and parting when the group splits.
- Strands use `strand-*` (the member colors, lightened in dark mode). Color means people *or* groups in a view, never both.
- Use `braid-*` tokens for widths, gaps and the 48px turn. Your strand is 1.5px wider and on top.
- Scale by changing what a strand is: a person up to 8 travelers; you plus close people plus "Everyone else" up to 20; groups beyond that, at most 6 strands.
- Write markers and labels in plain language: "All 5 together", "Splits into 3", "Back together", "You + Sandra".
- Phones keep strands on the left. From 600px, groups you're not with move to a right-hand gutter.

## Space, shape, depth

- **Spacing:** 4px grid. The screen side margin is `space-6` (24px). Eyebrow to content is `space-3`; section title to content is `space-5`; related sections are `space-8` apart and unrelated ones `space-10`.
- **Each shape has one meaning:** a **pill** (`radius-pill`) is something you act on, a **rounded rectangle** (`radius-md` cards, `radius-lg` trip covers) is something you open, a **circle** is a person or a tool, a **sheet** (`radius-sheet` top corners) is a task on top of where you are, and a **dashed rounded rectangle** is a space the group hasn't filled yet.
- **Depth:** cards use `elevation-1`, floating controls `elevation-2`, sheets `elevation-3`. In dark mode, depth comes from surface lightness and a hairline.
- **Focus:** a solid 2px `text-primary` outline, offset 2px. It reads at 3:1 or better on every surface in both themes.

## Motion

- **Calm by default, playful when people come together.** Everyday transitions use `cubic-bezier(0.2, 0, 0, 1)` or `--tp-spring-gentle` (no overshoot): 120ms presses, 200ms fades, 320ms entrances (`Rise`), 480ms tallies (`CountUp`). Chips and tab indicators move on `--tp-spring-snappy`.
- **Bounce only for people moments**, on `--tp-spring-playful` (about 5% overshoot), and at most once per screen: someone joining a plan (`Pop`), a needs-you dot arriving, vote bars, the brand dot (`BrandDot`) at launch.
- **The braid** draws top to bottom in one 600ms sweep when a day opens, with cards rising as the line reaches them. When plans change, strands glide to their new bundles.
- **Confirmation** is one `accent` check drawing itself (`SuccessCheck`) and one warm sentence. Never confetti.
- **Never:** looping or idle animation, bouncing text or navigation, anything over about 600ms, or movement across the whole screen.
- **Every component moves on its own:** presses scale (0.98 buttons and chips, 0.96 small round controls, 0.94 reaction pills, 0.99 cards) and spring back; changed counts bump; chip checks grow in; a new face pops into an avatar stack; the last vote draws the check. A state already true when the screen opens shows at rest.
- **Reduced motion:** everything becomes a 120ms fade or appears at rest, and presses don't scale.

## Haptics

- **A haptic answers your own touch, or confirms the group finished something.** Other people's changes never buzz. One per gesture at most.
- `select` (tick): changing tab, chip, toggle or option. `join` (light): primary buttons, voting, reacting. `reorder` (medium): dragging plans. `success` (firm, then light): "Everyone's in", with `SuccessCheck`. `warning` (heavy): something refused.
- Silent: secondary, tertiary and destructive buttons, the current tab, sheets, toasts, scrolling, navigation.
- Components already play theirs (see the **Haptics** card). On the web, `Tripami.haptic(kind)` vibrates where the browser allows; in Flutter, `TPHaptics`.

## Iconography

- Use Phosphor Icons, **regular** weight, as the default (the `Icons` asset group, or `Tripami.Icon` with `name`). Use the **fill** variant only for the active tab or a toggled state (saved heart, your vote).
- Sizes: 22px for leading icons in rows, nav bars and quick actions; 18px for chevrons and inline status; 24px in the tab bar.
- Icons take the color of the text beside them. Use `accent` only when active or selected.
- The SVG files in the asset group are single-ink `brand-navy`, for light grounds. In code, use `Tripami.Icon`, which draws in `currentColor` and follows `text-primary` in both themes.
- No emoji as icons.

## Imagery

- Trip covers are the group's own photos: 4:5 on cards, full-bleed on a hero. Without a photo, use a `sunken` card with the trip name in `display`; never stock illustration.
- The `Placeholders` asset group holds generated stand-in photos for previews only. Don't ship them.

## Platform

The product ships in Flutter for iOS and Android (`tripami_design_system` package: `TripamiTheme`, `TPColors`, `TPType`, `TPIcons` and `TP*` widgets with the same names and props as the components here). These web components mirror the Flutter widgets one to one.
