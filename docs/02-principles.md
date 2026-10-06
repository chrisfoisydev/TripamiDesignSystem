# 02 · Principles

> **Tripami = Marriott Bonvoy's editorial restraint + a modern social travel diary + Apple-level utility.**
> The product UI is calmer and more refined than Tripami's marketing.

These six principles settle design disagreements. When two options both look fine, pick the one that better serves the principle higher on the list.

---

### 1. Places and people bring the color
Chrome is paper, white and ink. Color comes from two sources only:
- **Places:** trip covers, activity photos, the group's own pictures.
- **People:** each traveler has a *member color* used for their avatar, their votes, their expenses and the things they added.

No decorative gradients, no colored section backgrounds, no illustrated mascots in product UI.

> *Test:* cover the photos and avatars on a screen. What's left should be almost monochrome.

### 2. The accent shows state. Ink shows action.
**Lagoon** (our single accent) marks *you, now, selected, live*: the active tab, your own vote, today in the itinerary, a selected date, a link. Primary actions are **ink pills**, as in Bonvoy. If everything is colored, nothing is.

> *Budget:* accent covers ≤ 5% of any screen's pixels.

### 3. Editorial hierarchy, set quietly
- Hierarchy through **size, case and space**, not weight or color.
- Large titles are **Regular**. We never use Bold in product UI; the heaviest weight is Semibold, and only for eyebrows and buttons.
- Small uppercase **eyebrows** introduce sections.
- A **serif (Newsreader)** is the *diary voice*. It's used for trip names, day headings and memories, which are moments that belong to the group, not the system. Never for controls.

### 4. Social presence without social noise
Tripami is collaborative, but it should feel like a well-kept shared notebook, not a group chat that never stops.
- People show up as **avatars and names inside the content** ("Maya added", "3 of 5 voted"), not as feeds of notifications.
- Activity is shown with a **small dot**, not red count badges. Red is only for errors and destructive actions.
- **Reactions are the only place emoji appear**, because they're user content. Icons always come from the `TPIcons` set (Phosphor).
- Mention names over counts: "Waiting on Jonah and Priya" beats "2 pending".

### 5. Apple-level utility under the editorial surface
Tripami is built in Flutter for iOS and Android, but the bar is Apple-quality utility on both.
- Platform page transitions (Cupertino on iOS, predictive back on Android), modal sheets with a grabber, haptics on key actions, platform maps.
- Text scales with the system setting (`MediaQuery.textScaler`). Layouts must hold at 200%.
- Motion collapses when the OS asks for reduced motion (`MediaQuery.disableAnimations`).
- Facts in one glance: the **trip strip** (Arrive · Leave · Nights · Travelers) shows up wherever a trip does.
- Every secondary task is a **sheet** with a grabber. The context stays visible behind it.
- One primary action per screen, sticky at the bottom when it matters.
- 44pt minimum hit targets. AA contrast for all text, including secondary text.

### 6. Calm is a feature
- One idea per section, one primary action per screen, one accent per screen.
- Motion explains rather than entertains: sheets rise, cards settle, votes count up. No confetti, no bouncing.
- Celebrations are restrained: a single Lagoon check and a short warm sentence ("Everyone's in.").
- Copy is short, warm and specific, written by *the friend who planned the trip*: second person, names over numbers, no exclamation marks in system copy.

---

## Product vs. marketing

Marketing can be loud: big color fields, playful type, motion, illustration, energetic copy. The product is where people *live with* their trip for weeks, so it turns everything down a notch.

| | Marketing (site, App Store, social) | Product UI |
|---|---|---|
| Color | Full brand palette, color fields, gradients allowed | Paper/ink chrome, Lagoon ≤ 5%, member colors for people only |
| Type | Expressive display sizes, tight tracking, mixed weights | Inter Regular/Medium/Semibold + Newsreader for diary moments only |
| Imagery | Staged lifestyle, collage, stickers | The group's real photos and places; consistent scrims and glass chips |
| Illustration | Characterful, full color | Grey-scale spot illustration with one accent touch, empty states only |
| Motion | Showy, looping | Purposeful, 120–480ms, respects Reduce Motion |
| Voice | Hype allowed ("Group trips, minus the group chat chaos!") | Calm, specific ("3 people still need to vote on dinner.") |
| Emoji | Yes | Only in user content and reactions |

---

## Voice samples

| Moment | Bonvoy | Tripami |
|---|---|---|
| Search prompt | "Where can we take you?" | "Where's the group headed?" |
| Upcoming stay | "We look forward to welcoming you." | "Lisbon in 6 days. Here's where things stand." |
| Confirmation | "You're All Set" | "Booked. Everyone can see it in the itinerary." |
| Empty list | "Ready to add hotels to this wishlist?" | "Nothing saved yet. Add a place and the group can vote on it." |
| Pending | (n/a) | "Waiting on Jonah and Priya." |
| Toast | "All set. Your reservation has been cancelled." | "Removed from Friday. Maya and Leo were notified." |
| Error | (n/a) | "Couldn't save the expense. Check your connection and try again." |

Next: [03 · Foundations](./03-foundations.md)
