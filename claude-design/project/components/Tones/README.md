# Tones

Ready-made roles for any ramp, so nobody picks steps by hand. Flutter: `TPTone.of(context, TPRamps.green)`. Each pairing is contrast-safe by construction, and dark mode flips the grade.

| Role | Light | Dark | Use |
|---|---|---|---|
| `subtle` | 50 | 950 | Tinted background |
| `muted` | 100 | 900 | Hover, pressed or selected tint |
| `border` | 200 | 800 | Decorative outline on a tint |
| `text` | 700 | 200 | Tinted text and icons (≥ 7:1 on subtle) |
| `solid` | 600 | 400 | Filled badge or strong banner |
| `solidPressed` | 700 | 300 | Pressed fill |
| `onSolid` | white | 950 | Text on solid |

Examples: a green "Settled with Maya" banner, a navy info note, an amber "You owe" row, and a member's highlighted row in their own color.
