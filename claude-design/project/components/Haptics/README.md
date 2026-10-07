# Haptics

Every Tripami component plays its own haptic; this is the map. A haptic answers **your own touch**, or confirms that **the group finished something**. Other people's changes arriving never buzz; they get motion only. One haptic per gesture at most.

| Kind | Feels like | Used for |
|---|---|---|
| `select` | Selection tick | Changing tab, chip, segment, toggle or option; the Map/List pill |
| `join` | Light tap | Primary buttons, voting, reacting, joining a plan |
| `reorder` | Medium tap | Picking up and dropping a plan while dragging |
| `success` | Firm tap, then a light one 90ms later | "Everyone's in", "Back together", "Settled" (with `SuccessCheck`) |
| `warning` | Heavy tap | Something refused: an invalid field, a delete that can't happen |

**Silent:** secondary, tertiary and destructive buttons, the tab you're already on, opening sheets, toasts, scrolling and navigation.

**Press feedback** goes with every tap: 0.98 for buttons, chips and rows, 0.96 for small round controls, 0.94 for reaction pills and glass buttons, 0.99 for cards. Down is 120ms on the standard ease; release springs back on `--tp-spring-snappy`. Reduced motion keeps the haptics and drops the scale.

**In code:** Flutter `TPHaptics.select()` … `.warning()`, `TPPressable(haptic: TPHaptic.select)` for custom controls, and `TPHaptics.enabled = false` for an in-app "Vibration" setting. Web prototypes: `Tripami.haptic('select')` uses the Vibration API where the browser has it (Android Chrome) and is silent elsewhere; every component marks its haptic with a `data-haptic` attribute.
