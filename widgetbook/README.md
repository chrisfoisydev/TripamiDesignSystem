# Tripami catalog (Widgetbook)

Every Tripami component and foundation, live, built with [Widgetbook](https://docs.widgetbook.io).

- **Hosted:** https://claude.ai/artifact/5cTgxzo2e5qdQdfe9wNMZp (private until you share it)
- **Foundations:** colors, tints and shades (with a contrast picker), tone roles, typography, space and shape, icons, motion and a haptics playground.
- **Components:** each with knobs for its props, plus live demos for the ones that move: votes coming in, someone joining, reacting, the braid drawing in, at 5 and at 50 travelers.

## Panels

Use the panel on the right:

| Addon | What it checks |
|---|---|
| Theme | Light, Dark, High contrast light, High contrast dark |
| Text scale | 100% to 310% (iOS's largest accessibility size) |
| Phone settings | Bold Text, Reduce Motion, Vibration |
| Viewport | iPhone 13, iPhone SE, iPad Air, Galaxy S20 |
| Semantics | What VoiceOver and TalkBack will read |
| Accessibility checker | Flags small tap targets, missing labels and low contrast as you browse |
| Inspector | Pick a widget to see its size and position |

## Run it

```bash
cd widgetbook
flutter run                 # on a phone (feel the haptics, try VoiceOver)
flutter run -d chrome       # in a browser
flutter run -d macos        # as a desktop app
flutter test                # opens every page and fails on any error
```

Haptics only play on a real phone; browsers and simulators don't vibrate.

## Add a component

Add a use case to `lib/components.dart` (or `lib/foundations.dart`). Use realistic Tripami content from `lib/sample_data.dart`, knobs for the props people will want to try, and a `_Live` wrapper when the component reacts to taps. `flutter test` then checks the new page too.

## Update the hosted copy

```bash
cd widgetbook && flutter build web --release --no-web-resources-cdn
```

Then publish `build/web` with `boot.js` (Flutter's loader without the service worker, which artifacts don't allow). Leave out `*.symbols`, the `skwasm`/`wimp` runtimes, `AssetManifest.bin` and the `.frag` shaders; Flutter on the web doesn't need them. Asking Claude to "republish the Tripami catalog" does all of this.
