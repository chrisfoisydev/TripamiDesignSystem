# 06 · Accessibility

Tripami is used on the move: in sunlight, one-handed, by people of every age and ability, often in a second language. Accessibility is part of every component, not an extra mode.

**What's automatic.** Use the `TP*` components and `TripamiTheme` and you get everything below. Tests check every component against it (`test/a11y_test.dart`, `test/a11y_settings_test.dart`).

---

## Platform settings we honor

| Setting | What Tripami does | How |
|---|---|---|
| **VoiceOver / TalkBack** | Every control has a role, a label and its state (selected, toggled, "needs you", "including you", vote counts) | `Semantics` in each component |
| **Larger Text** (Dynamic Type, font size) | Layouts reflow up to 310% (iOS's largest accessibility size): side-by-side rows stack, nothing truncates important content | `TPA11y.largeText(context)` |
| **Bold Text** | Every style steps up about two weights | `MaterialApp(builder: TripamiTheme.builder)` |
| **Increase Contrast** / high-contrast text | Text and the accent reach 7:1 (AAA), meaningful borders 3:1 | `highContrastTheme: TripamiTheme.highContrastLight()`, `highContrastDarkTheme: …Dark()` |
| **Reduce Motion** | Movement becomes 120ms fades or none; presses don't scale; the braid appears drawn | `TPMotion.reduced(context)` |
| **Keyboard** (iPad, Android, web) | Tab reaches every control, a 2pt focus ring shows where you are, Enter or Space activates | `TPPressable` |
| **Color blindness** | Member colors are assigned in the order that keeps them most distinct; color is never the only cue | `TPMemberColor.forJoinIndex` |
| **Vibration off** | All haptics stop | `TPHaptics.enabled = false` |

Wire it up once:

```dart
MaterialApp(
  theme: TripamiTheme.light(),
  darkTheme: TripamiTheme.dark(),
  highContrastTheme: TripamiTheme.highContrastLight(),
  highContrastDarkTheme: TripamiTheme.highContrastDark(),
  themeMode: TripamiTheme.defaultMode,
  builder: TripamiTheme.builder,
  home: …,
);
```

---

## Rules

### Touch
- **Tap areas are at least 48×48** (`TPA11y.minTapTarget`), even when the visual is smaller: 36pt chips, 28pt reaction pills and 40pt glass buttons all have a 48pt area around them. Use `TPPressable(expandTapTarget: true)` for your own small controls.
- Keep 8pt between separate tap areas.

### Text
- **Never fix a height around text.** Use a minimum (`BoxConstraints(minHeight: …)`) so it can grow.
- **At large text, stack; don't squeeze.** Put amounts under titles, voters under options, and the action under the fact. Check with `TPA11y.largeText(context)`.
- **Truncate only what has another route to full text** (a chip label, a cover title that opens the trip). Never truncate amounts, names in "Waiting on…", or errors.
- **Tab bar labels cap at 130%**, as iOS does, so five tabs still fit. That's the only text we cap.

### Color and contrast
- **Body text is 4.5:1 or more** in light and dark, and **7:1 in high contrast**. Large text, icons and meaningful borders are 3:1. The grade rule makes this easy: two colors 500 grades apart always pass (see Tints and shades).
- **Never use color alone.** Status pairs with a word ("You owe", "Settled") or an icon. A member's color pairs with initials, a face or a name. The accent pairs with a check, an underline or a word.
- **`brand-orange` is never text or a meaningful mark** (3.0:1).

### Screen readers
- **Label by meaning, not appearance:** "Chat, needs you", not "Chat, orange dot". "👍 3, including you", not "👍 3".
- **Group things that belong together.** A poll option reads as one item: "Taberna da Rua, Petiscos · Bairro Alto, 3 votes, your vote".
- **Decoration stays silent:** braid strands, the brand dot, dividers.
- **Images of trips need a description;** avatars read the person's name.

### Motion and haptics
- Respect Reduce Motion everywhere (see Motion in [03 · Foundations](./03-foundations.md)). Nothing flashes more than three times a second.
- Haptics always come with a visible change, never alone.

### Keyboard
- Every custom tappable goes through `TPPressable`, which gives focus, the ring and Enter/Space activation. A bare `GestureDetector` is invisible to keyboards and switch control.
- Focus order follows reading order. Don't reorder focus with `FocusTraversalOrder` unless the visual order is misleading.

---

## Color blindness and member colors

Eight mid-tone hues can't all stay distinct for every reader. We simulated protanopia, deuteranopia and tritanopia (Machado et al. 2009) and ordered the colors so the first *k* travelers are as far apart as possible.

| Trip size | Worst pair (ΔE) in the old order | Worst pair now |
|---|---|---|
| 2 | 6.5 | 11.7 |
| 3 | 2.7 | 5.3 |
| 4 | 2.0 | 4.8 |
| 5 | 2.0 | 4.3 |
| 6 | 2.0 | 3.7 |
| 7–8 | 1.4 | 1.4 (some pairs converge) |

ΔE under about 2 looks the same; above about 3.5 most people can tell the colors apart. Beyond six travelers, the redundant cues (initials, faces, names on every plan) carry identity.

---

## Testing a screen

1. **Catalog:** open the component in the catalog (`widgetbook/`) and step through the Theme, Text scale and Phone settings panels; the Accessibility checker flags problems as you go.
2. **Automated:** add the component to `test/support/gallery.dart`. The sweep checks tap targets, labels and contrast in four themes, and layout at 200% and 310% text.
3. **VoiceOver / TalkBack:** swipe through the screen once. Every stop should make sense read aloud, in order.
4. **Largest text size:** nothing overlaps, cuts off mid-word, or hides an action.
5. **Bold Text and Increase Contrast** on together: still on-brand, still readable.
6. **Keyboard:** Tab through it on an iPad or simulator; every action is reachable and visibly focused.
7. **Grayscale** (Settings › Accessibility › Color Filters): every state is still understandable.

Next: [07 · Imagery](./07-imagery.md)
