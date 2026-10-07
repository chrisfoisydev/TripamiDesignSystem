# ProgressBar

A 4px progress track: pill ends, `sunken` track, accent fill that eases to new values on the gentle spring (instant with reduced motion). Screen readers hear its label and percentage.

**Props:** `value` (0 to 1), `label`, `color` (default accent).

- Progress is a "now" state, so it takes the accent. Use ink only inside poll results.
- Flutter: `TPProgressBar`.
