# TabBar

Bottom navigation with five tabs: Trips · Plan · Chat · Memories · You. Icons are outline, filled when active. The active tab gets a 2px `accent` indicator on the top edge. Activity shows as a dot, never a number.

**Props:** `items`: `[{label, icon, activity?: 'new' | 'urgent'}]`, `value`.

**Motion:** the indicator moves on the snappy spring and the new tab's filled icon scales in from 0.8. **Haptic:** selection tick when the tab changes; tapping the current tab is silent.
