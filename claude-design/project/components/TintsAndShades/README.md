# TintsAndShades

Fourteen ramps of 11 steps, 50 (lightest) to 950 (darkest), built in OKLCH from Tripami's own colors. Tokens: `orange-100`, `navy-700`… (`var(--orange-100)`); Flutter: `TPRamps.orange[100]`.

**Grade is luminance.** Every ramp puts the same luminance at the same grade, so contrast depends only on the gap between two grades, in any pair of hues:

- Gap **≥ 400** → ≥ 3:1: large text, icons, meaningful borders.
- Gap **≥ 500** → ≥ 4.5:1: all text (AA). White text works on every step from 500.
- Gap **≥ 650** → ≥ 7:1: AAA.

**Use semantic tokens first** (`canvas`, `text-*`, `accent`, `positive`…). Reach for ramps only where they don't fit: tinted banners, a member's highlight row, charts, illustration, empty-state art. `orange` keeps the accent rules (state and brand only, never a button fill). `red`, `green` and `amber` keep their status meanings. Member ramps mean "this person".

Try the checker under the swatches: pick any text and background step and it shows the grade gap and the real contrast.
