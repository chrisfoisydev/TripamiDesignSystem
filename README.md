# Tripami Design System

> **Marriott Bonvoy's editorial restraint + a modern social travel diary + Apple-level utility.**
> The product UI is calmer and more refined than Tripami's marketing.

Tripami's logo, components, colors and type, in two forms:

- **Claude Design:** the [Tripami design system artifact](https://claude.ai/artifact/RfRNGEUDTXnSNNXjGYTbpa). This is what Claude's design and slide tools build from. Its source is in [`claude-design/`](claude-design).
- **Flutter / Dart:** the `tripami_design_system` package in [`lib/`](lib), with `TripamiTheme`, tokens and `TP*` widgets.

Both hold the same tokens, and components match by name and props. The Claude Design set also includes `Icon`, `TextField`, `Toggle` and `Toast`; in Flutter those come from `TPIcons` and the standard widgets that `TripamiTheme` restyles.

## Logo

![Tripami](brand/tripami-wordmark.webp)

Two versions, as supplied, both on transparent grounds with the orange `#FC6316` dot:
- [`brand/tripami-wordmark.webp`](brand/tripami-wordmark.webp): navy `#02203A` letters, for light grounds.
- [`brand/tripami-wordmark-reversed.webp`](brand/tripami-wordmark-reversed.webp): white letters, for dark grounds and dark photos.

## Using it in the Tripami app

See **[Using the design system in the app](docs/05-using-in-the-app.md)**: how to add the package, set the theme, and set up Claude Code in the app's repo so it builds with the system.

## Docs

1. **[Bonvoy study](docs/01-bonvoy-study.md):** about 45 Marriott Bonvoy iOS screens studied on Mobbin, and what Tripami takes from them.
2. **[Principles](docs/02-principles.md):** six rules, the product-vs-marketing split, and voice.
3. **[Foundations](docs/03-foundations.md):** color, type, spacing, shape, elevation, icons, imagery, motion.
4. **[Components](docs/04-components.md):** anatomy, tokens and states for every component.
5. **[Using it in the app](docs/05-using-in-the-app.md):** adding the package, the theme, and setting up Claude Code in the app repo.

## The system in one minute

- **Color:** paper `canvas` (`#FAFAF7`), white `surface` and navy `text-primary` (`#02203A`, the logo's wordmark color). Navy ink and one accent, Tripami orange, both from the logo: `#FC6316` for the logo and brand moments, `#B8400F` (text-safe) for state in the UI. Eight `member-*` colors identify travelers.
- **Tints and shades:** 14 ramps (50–950) built in OKLCH from those colors (`TPRamps.orange[100]`). A step's grade fixes its luminance, so contrast follows from the grade gap alone: a gap of 500 or more is always ≥ 4.5:1, in any pair of hues. `TPTone` gives theme-aware roles (subtle, text, solid…) that are safe by construction.
- **Type:** Bricolage Grotesque, set heavy to echo the wordmark, for trip names and day headings. Inter for UI (Regular titles, uppercase eyebrows). Newsreader for journal text.
- **Shape:** pills to act, rounded cards to open, circles for people and tools, sheets for side tasks, dashed boxes for what the group hasn't filled yet.
- **The braid:** the day drawn as one strand per traveler, bundling when people are together and parting when they split. It scales to 50+ by turning strands into group ribbons.
- **Motion:** calm by default (`TPMotion.ease`, `gentle`), playful only when people come together (`playful` spring, at most once per screen): the braid drawing in, avatars popping when someone joins, the orange dot, a single success check. Every component has press feedback and haptics built in (`TPHaptics`: select, join, reorder, success, warning). Everything respects reduced motion.
- **Icons:** a curated Phosphor set, regular by default and fill for active states.
- **Contrast:** every allowed text pairing passes WCAG AA in light and dark, enforced by `test/contrast_test.dart`.

## MCP server

`mcp/` is an MCP server that lets Claude, Cursor and other agents query the system: tokens, tints and shades, components with their Flutter APIs, guidelines, contrast checks, and a reviewer that lints UI code against the rules. Claude Code connects to it automatically in this repo through `.mcp.json`. See [mcp/README.md](mcp/README.md) to use it from the app repo or host it.

## Claude Design

The artifact is a Claude Design System. Use it by naming it when you ask Claude for a design, slides or a prototype ("use the Tripami design system"), or by pasting its link. Claude reads its `README.md`, `tokens.json` and component cards and builds with them.

To change it, ask Claude in a session with this repo to edit the files in `claude-design/project/` and re-publish them to the same artifact URL. The asset ids for the uploaded icons and placeholder photos are in `claude-design/asset-ids.txt`. Font files aren't duplicated there: they're published from `lib/fonts/`.

The artifact is private until you share it from its Share menu.

## Flutter

```yaml
dependencies:
  tripami_design_system:
    git:
      url: https://github.com/chrisfoisydev/TripamiDesignSystem.git
```

```dart
import 'package:tripami_design_system/tripami_design_system.dart';

MaterialApp(theme: TripamiTheme.light(), darkTheme: TripamiTheme.dark());

final c = TPColors.of(context);
Text('Lisbon with the crew', style: TPType.display.copyWith(color: c.textPrimary));
TPButton.primary(label: 'Create trip', onPressed: createTrip);
Icon(TPIcons.mapPin);
```

| | |
|---|---|
| `foundations/tp_palette.dart` | Raw colors and `TPMemberColor` |
| `foundations/tp_ramp.dart`, `tp_ramps.dart` | `TPRamp`, `TPTone` and the generated `TPRamps` (from `tool/ramps/generate.py`) |
| `foundations/tp_colors.dart` | `TPColors` `ThemeExtension`, light and dark |
| `foundations/tp_type.dart` | `TPType` scale (Bricolage Grotesque + Inter + Newsreader) and `.tabular` |
| `foundations/tp_layout.dart` | `TPSpace`, `TPRadius`, `TPSize`, `TPElevation`, `TPMotion` |
| `foundations/tp_icons.dart` | `TPIcons` / `TPIconsFill` (Phosphor) |
| `theme/tp_theme.dart` | `TripamiTheme.light()` / `.dark()`, which restyles standard Material widgets |
| `components/` | `TPButton`, `TPGlassIconButton`, `TPQuickAction`, `TPFloatingPill`, `TPFilterChip`, `TPUnderlineTabs`, `TPEyebrow`, `TPSectionHeader`, `TPCard`, `TPGlassChip`, `TPTripCoverCard`, `TPTripStrip`, `TPListRow`, `TPSectionBand`, `TPStickyActionBar`, `showTPSheet`, `TPEmptyState`, `TPTabBar`, `TPAvatar`, `TPAvatarStack`, `TPAttribution`, `TPActivityDot`, `TPReactionBar`, `TPPollCard`, `TPItineraryItem`, `TPExpenseRow`, `TPBraidDay`, `TPBraidEventCard`, `TPBraidMarker`, `TPToggle`, `TPPressable`, `TPBump`, `TPPop`, `TPRise`, `TPCountUp`, `TPSuccessCheck`, `TPBrandDot`, `TPHaptics` |

Fonts are bundled in `lib/fonts/`: Bricolage Grotesque, Inter and Newsreader (SIL OFL) and Phosphor Icons (MIT), with their licenses. Requires Flutter ≥ 3.32.

```sh
flutter analyze
flutter test      # WCAG AA contrast for every allowed pairing, plus unit tests
```

`tokens/tokens.json` holds the same values in W3C design-token format for other tools.
