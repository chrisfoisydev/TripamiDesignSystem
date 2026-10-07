# 07 · Imagery

Photos give Tripami its color: the chrome stays neutral, and the place and the people bring the feeling (see [01 · Bonvoy study](./01-bonvoy-study.md)). That only works if the photos are real, well cropped, and treated the same way everywhere.

---

## Real photos only

- **Use real photographs of the actual place:** the group's own pictures first, then licensed photos of the destination.
- **Never use illustrations, AI images or generated stand-ins in product, or in designs meant to show the product.** A fake skyline reads as a placeholder and makes the whole screen look unfinished.
- **No photo yet? Use the fallback, not a drawing.** `TPPlaceHeader` falls back to brand navy with white text. `TPTripCoverCard` falls back to `sunken` with the name in ink. A photo that fails to load falls back the same way.

### Where photos come from, in order
1. **The group's own photos.** A trip cover the group chose, or a photo someone posted from that place.
2. **A licensed photo of the place**, from a source that states its license:
   - Wikimedia Commons, Unsplash, Pexels.
   - Prefer CC0 / public domain or the Unsplash and Pexels licenses, which need no credit.
   - CC BY and CC BY-SA need a visible credit (below).
   - Never use a photo with no stated license, or one marked "non-commercial" or "no derivatives".
3. **Nothing yet:** the fallback above.

### Credits
- When a license asks for credit, pass it to the component: `TPPlaceHeader(credit: 'Photo: Gareth Williams, CC BY 2.0')`. The credit shows as a small caption under the subtitle.
- Keep a record next to the files: file, what it shows, photographer, license and source link. The catalog's `widgetbook/assets/CREDITS.md` is the model.

---

## Cropping

Photo headers are full width and at least `size.placeHeader` (340pt) tall. Text and controls sit in fixed zones, so crop each photo to fit them:

| Zone | Where | What sits there | What the photo needs |
|---|---|---|---|
| Controls | Top 30% | Back button, travelers, options (glass) | Sky or quiet texture: no faces or landmarks behind the buttons |
| Subject | Middle | Nothing | The landmark or scene that says where you are |
| Title | Bottom 40% | Eyebrow, title, subtitle, credit | Even tone: water, street, foliage. The `scrim` darkens it |
| Sheet | Bottom 24pt | The `TPOverlapSheet` corners | Anything: it's covered |

- **Center the subject horizontally.** On wider screens the photo crops at the sides.
- **Never put a face or a landmark under the title.**
- **Never flip, tint or add a color block over a photo.** The scrims are the only overlays.

---

## Overlays

| Token | Value | Use |
|---|---|---|
| `scrim` | transparent at 40% → `rgba(2,16,30,.62)` at 100% | Under text at the bottom of any photo |
| `scrim-top` | `rgba(2,16,30,.28)` at 0% → transparent at 30% | Under glass controls at the top of a photo header |
| `TPColors.headerScrim` | both at once: `scrim-top`, clear 30–45%, `scrim` foot | Photo headers (`TPPlaceHeader`) |
| `glass` | `rgba(2,32,58,.48)` + blur | Buttons and chips on photos |

- Text on photos is white (`text-on-image`), bottom-left, with a 24pt inset.
- Controls on photos are glass: `TPGlassIconButton`, `TPGlassChip`, and `TPAvatarStack(onImage: true)`.

---

## The photo header pattern

A day or a place opens on a full-bleed photo with the rest of the screen in a sheet that rises over it.

```dart
ListView(children: [
  TPPlaceHeader(
    title: 'Rome',
    eyebrow: 'Today · Day 5 of 14',
    subtitle: 'Wednesday 18 November · Italy with Friends',
    image: const AssetImage('assets/places/rome.jpg'),
    imageLabel: "The Tiber leading to St Peter's dome",
    leading: TPGlassIconButton(icon: TPIcons.arrowLeft, onPressed: back, semanticLabel: 'Back to trips'),
    trailing: [TPAvatarStack(crew, onImage: true), TPGlassIconButton(icon: TPIcons.dotsThree, onPressed: menu, semanticLabel: 'Trip options')],
  ),
  TPOverlapSheet(child: Column(children: [tabs, dayStrip, stay, nowCard, next])),
])
```

- **The sheet rises `size.sheetOverlap` (24pt)** over the photo, with `radius.sheet` (28pt) top corners. The header leaves room for it, so the title is never covered.
- **The header grows with text size** instead of clipping (tested at 310%).
- **One photo header per screen**, at the top. Further down, use cards with thumbnails.

---

## Accessibility

- **Describe what the photo shows** in `imageLabel`, written for someone who can't see it: "The Tiber and Ponte Sant'Angelo leading to St Peter's dome", not "Rome photo".
- **The title is the screen's heading**, so screen readers can jump to it.
- **Text on photos must stay readable on bright photos:** check light skies and white buildings at the largest text size. If the scrim isn't enough, choose another crop.

Next: back to [README](../README.md)
