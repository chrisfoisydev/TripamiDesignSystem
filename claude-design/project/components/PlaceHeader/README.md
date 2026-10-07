# PlaceHeader

Full-bleed photo header for a day or a place ("Rome", "Today · Day 5 of 14"). The photo fills the width under a two-part scrim: `scrim-top` behind the glass controls, clear through the middle, `scrim-end` under the title. Controls sit top (`leading`: back; `trailing`: on-image `AvatarStack`, options as `GlassIconButton`). Text sits bottom-left: eyebrow, title in `display`, subtitle, and a license credit when one is needed.

**Props:** `title`, `image` (a real photo URL), `imageLabel` (what the photo shows, for screen readers), `eyebrow`, `subtitle`, `credit` ("Photo: Gareth Williams, CC BY 2.0"), `leading`, `trailing`, `minHeight` (default `size-place-header`, 340px; it grows with large text), `sheetBelow` (default true: leaves room for an `OverlapSheet`).

- **Real photos only:** the group's own, or a licensed photo of the place. Never an illustration or AI image. No photo or a failed load falls back to brand navy.
- **Crop for the zones:** sky or quiet texture behind the controls (top 30%), the landmark in the middle, an even tone under the title (bottom 40%).
- One per screen, at the top. Put the rest of the screen in an `OverlapSheet`.
- Flutter: `TPPlaceHeader`. Full rules: docs/07-imagery.md in the repo.
