# TODO: Remove Menu2 Dependency & Custom Menu System

## Goal
Replace Garmin's `Menu2`/`Menu2InputDelegate` (requires API 3.0.0+) with a custom menu system compatible with Min API 1.2.0.

## Steps

### 1. Create reusable custom menu framework
- [x] `source/Views/CustomMenuView.mc` — generic menu view (title, items, selected highlight, footer hint)
- [x] `source/Delegates/CustomMenuDelegate.mc` — generic delegate (UP/DOWN nav, SELECT/TAP, BACK)

### 2. Replace Menu2 usage in views/delegates
- [x] `SimpleViewDelegate.mc` — Activity controls (Resume/Pause/Stop), Save/Discard, Discard confirmation
- [x] `WatchFaceMenuDelegate.mc` — Simple/Time view selection
- [x] `ProfileSettingsMenuDelegate.mc` — Profile options menu
- [x] `SelectProfileDelegate.mc` — Experience & Gender submenus
- [x] `SelectExperienceDelegate.mc` — Experience level
- [x] `SelectGenderDelegate.mc` — Gender
- [x] `SelectFeedbackDelegate.mc` — Feedback menu
- [x] `SelectHapticDelegate.mc` — Haptic settings
- [x] `SelectAudibleDelegate.mc` — Audible settings

### 3. Update manifest
- [x] `manifest.xml` — change `minApiLevel` from `2.3.0` to `1.2.0`

### 4. Verify
- [x] Confirm no Menu2 usage remains in codebase (only comments remain)
- [ ] Build with `monkeyc` to confirm API 1.2.0 compatibility (requires user's SDK/developer key)
