# 05 · Using the design system in the Tripami app

The design system is a Flutter package (`tripami_design_system`). The app depends on it, wraps itself in `TripamiTheme`, and builds screens from `TP*` widgets and tokens instead of raw colors, font sizes and Material defaults.

---

## 1. Add the package

The package lives in this repo. Pin it to a tag, or until there is one, to the branch:

```yaml
# Tripami app: pubspec.yaml
dependencies:
  tripami_design_system:
    git:
      url: https://github.com/chrisfoisydev/TripamiDesignSystem.git
      ref: claude/bold-davinci-hg35mz   # switch to a tag (e.g. v0.3.0) once this is merged
```

Then run `flutter pub get`. The fonts (Bricolage Grotesque, Inter, Newsreader) and the Phosphor icons come with the package, so the app doesn't declare them.

**Private repo:** whatever runs `flutter pub get` needs read access to this repo:
- Locally, your normal GitHub login over HTTPS or SSH works (`url: git@github.com:chrisfoisydev/TripamiDesignSystem.git`).
- In CI, add a deploy key or token.
- In a Claude Code cloud session, add the repo to the session (see step 4).

Requires Flutter ≥ 3.32 and Dart ≥ 3.8.

## 2. Turn it on

```dart
import 'package:tripami_design_system/tripami_design_system.dart';

MaterialApp(
  theme: TripamiTheme.light(),
  darkTheme: TripamiTheme.dark(),
  // themeMode defaults to system: dark mode follows the phone.
  home: const TripsScreen(),
);
```

`TripamiTheme` restyles standard Material widgets, so existing `FilledButton`, `TextField`, `Switch`, `SnackBar` and `showModalBottomSheet` calls look right straight away.

## 3. Build with it

| Instead of | Use |
|---|---|
| `Colors.*`, `Color(0x…)` | `TPColors.of(context).textPrimary`, `.accent`, `.surface`… |
| `TextStyle(fontSize: …)` | `TPType.title1`, `TPType.body`, `TPType.display`… (`.tabular` for numbers) |
| Magic numbers for padding and radius | `TPSpace.s4`, `TPSpace.screen`, `TPRadius.md`, `TPSize.hitTarget` |
| `Icons.*` | `TPIcons.*` (outline), `TPIconsFill.*` (active or toggled) |
| `Duration(milliseconds: …)`, `Curves.*` | `TPMotion.quick`, `TPMotion.ease`, `TPMotion.gentleCurve`; `TPMotion.reduced(context)` |
| `HapticFeedback.*` | `TPHaptics.select()`, `.join()`, `.reorder()`, `.success()` |
| Hand-built components | `TPButton`, `TPTripCoverCard`, `TPBraidDay`, `TPPollCard`, `TPExpenseRow`… (list in the README) |

A traveler is a `TPMember` with a `TPMemberColor`. Assign colors in join order with `TPMemberColor.forJoinIndex(i)`; the trip creator gets `lagoon`.

The Plan view is `TPBraidDay`: map your itinerary into `TPBraidMoment`s (a time plus the plans starting then) and `TPBraidEvent`s (who's in each plan). It handles the scaling rules, layout, copy and motion.

## 4. Set up Claude Code in the app repo

Claude Code reads a `CLAUDE.md` at the repo root at the start of every session, including sessions you start from the Claude mobile app. Put the design-system rules there so every change Claude makes stays on-system.

1. **Paste this into the app repo's `CLAUDE.md`** (create it if it doesn't exist):

   ```markdown
   ## Design system

   This app uses the Tripami design system: the `tripami_design_system` Flutter package
   (github.com/chrisfoisydev/TripamiDesignSystem). Its README and docs/ are the reference; the
   visual reference is the Claude Design system at https://claude.ai/artifact/RfRNGEUDTXnSNNXjGYTbpa.

   - Wrap the app in `TripamiTheme.light()` / `.dark()`. Never hard-code colors, font sizes,
     spacing, radii, durations or curves: use `TPColors.of(context)`, `TPType`, `TPSpace`,
     `TPRadius`, `TPSize`, `TPMotion`.
   - Use `TP*` widgets before building new ones. If a screen needs something the system doesn't
     have, build it from tokens and flag it as a candidate for the design system.
   - Icons: `TPIcons` (outline) and `TPIconsFill` (active/toggled only). No Material `Icons`, no emoji as icons.
   - Primary actions are ink pills (`TPButton.primary`), one per screen. The orange `accent` marks
     state (you / now / selected / needs you), never a button fill, at most 5% of a screen.
   - Members are `TPMember` with `TPMemberColor.forJoinIndex(i)`. Member colors identify people only.
   - Type: `TPType.display` / `diaryHeading` (Bricolage Grotesque) for trip names and day headings
     only; Inter for all UI; Newsreader for journal text only. No bold UI text.
   - Copy: plain, warm, short, names over numbers ("Waiting on Jonah and Priya"). Sentence case.
     No exclamation marks in system copy.
   - Plan view: `TPBraidDay`. Motion: calm by default (`TPMotion.ease`, `gentle`); the `playful`
     spring only for people moments, at most once per screen; always respect `TPMotion.reduced`.
   - Every text pairing must pass WCAG AA in light and dark.
   ```

2. **Give the session access to the design-system repo.** When you start a session on the app repo, ask Claude to "add chrisfoisydev/TripamiDesignSystem to this session". Claude can then read the package source and docs and resolve the git dependency during `flutter pub get`.

3. **Use it from the mobile app.** In a session on the app repo, ask for work in product terms, for example:
   - "Adopt the Tripami design system: add the package, wrap the app in TripamiTheme, and replace hard-coded colors and text styles with tokens. Start with the Trips tab."
   - "Rebuild the Plan screen with TPBraidDay using our itinerary model."
   - "Add the needs-you dot to the Chat tab and the success check when everyone has voted."

   Claude will follow the `CLAUDE.md` rules, run `flutter analyze` and tests, and push to a branch for you to review.

## 5. Keep the two in step

- **Changing the system:** make the change here, both in the Flutter package and in the Claude Design source in `claude-design/`, then tag a release. In the app, bump `ref` and run `flutter pub upgrade tripami_design_system`.
- **Something new built in the app:** if a screen needs a pattern twice, promote it into the package rather than copying it.
- **Designing first:** mock screens in Claude Design using the Tripami design system, then hand the link to the app session to build with the same components.
