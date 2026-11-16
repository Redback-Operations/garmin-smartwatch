# Complete Existing Feature Audit

Audit date: 7 August 2026  
Branch: `fix/complete-feature-audit`  
Test target: Garmin Connect IQ SDK 9.2.0, fēnix 7 simulator (firmware profile 5.2.0)  
Test activity: `TestingData/12974552018_ACTIVITY.fit`

## Executive summary

The app builds and launches successfully for the fēnix 7 target. Recording, the live timer, live cadence, live heart rate, live pace, the advanced graph, stop, save, and summary navigation all ran without a runtime exception.

The audit found correctness and navigation defects that make the current build unsuitable for relying on summary statistics without fixes. The most serious defects are the incorrect distance conversion in the summary, fabricated cadence samples when cadence is unavailable, and duplicate cadence sampling while the graph is open.

Status totals:

- Working: 7 feature groups
- Partially working: 11 feature groups
- Not working: 6 feature groups

## Build and runtime results

### Build

Status: **Partially working**

Command used:

```text
monkeyc -f monkey.jungle -d fenix7 -o bin/audit-fenix7.prg -y developer_key.der -w -l 1
```

Result: `BUILD SUCCESSFUL`

Compiler warnings:

- `fenix7x` is an invalid device ID in `manifest.xml`.
- The 54x54 launcher icon is scaled to the fēnix 7 required 40x40 size.
- `_cadenceAvgIndex` and `_cadenceAvgCount` are unused.
- `SPORT_RUNNING` and `SUB_SPORT_GENERIC` are deprecated.
- `GarminApp.mc` contains an unreachable statement.

### Runtime console

Status: **Partially working**

No unhandled runtime exception was recorded. Unexpected output included:

```text
[DEBUG] currentCadence is null - using test cadence 100
[CADENCE QUALITY] CQ = 30%
```

The log also showed two cadence-quality calculations per second after `AdvancedView` opened, confirming duplicate graph sampling. Selecting `Resume` while the session was already recording closed the menu but produced no state change.

The completed FIT-backed run recorded:

```text
[ACTIVITY] Duration: 184 seconds
[ACTIVITY] Heart Rate: 140 bpm
[CADENCE QUALITY] Final CQ frozen at 62% (Improving, High confidence)
[UI] Activity stopped
[UI] Activity saved
```

## Feature audit

| Feature | Status | Result |
|---|---|---|
| Application build and launch | Working | fēnix 7 debug build compiled and launched. |
| Main dashboard | Working | Dashboard opened and refreshed without a crash. |
| Recording start/stop | Working | Confirmation, start, stop, save, and final CQ flow ran. |
| Timer | Working | Timer incremented during recording and the stopped duration was captured. |
| Live cadence | Partially working | FIT cadence displayed, but missing cadence is internally replaced with 100 spm. |
| Cadence quality | Partially working | Score, confidence, and trend are produced, but fake and duplicate samples corrupt the result. |
| Cadence target/range | Partially working | Target can be changed and saved, but there is no upper or lower bound. |
| Heart rate | Partially working | Live HR displays, but summary “average” and “peak” both use only the final current HR value. |
| Live pace | Working | FIT speed was displayed as min/km. |
| Summary average pace | Not working | Distance is divided by 100,000 even though Garmin supplies metres, so average pace is incorrect or unavailable. |
| Live distance | Working | Main screen correctly divides elapsed metres by 1,000. |
| Summary distance | Not working | Summary divides elapsed metres by 100,000 and understates distance by 100x. |
| Advanced graph | Partially working | Graph opens and updates, but it records a second sample every second and treats above-target cadence as green. |
| Vibration toggle | Partially working | Toggle and confirmation view work, but the preference is not persisted. Physical vibration cannot be felt in the desktop simulator. |
| Cadence alert | Partially working | Popup/timer code exists for out-of-zone cadence, but graph mode only alerts below the target and ignores above-target cadence. |
| Pause/resume | Partially working | Pause/resume methods exist; the recording menu incorrectly includes a no-op Resume item while already recording. |
| Save activity | Working | The session saved and opened the summary. |
| Discard activity | Partially working | The implementation is present, but the complete discard confirmation path was not dynamically completed in the FIT run. |
| Settings navigation | Partially working | Cadence, graph, summary, and reset cards exist; profile and feedback settings are unreachable from the current route. |
| Summary preference | Not working | Selecting Summary only logs a message; it never opens the Yes/No preference view. |
| Reset settings | Not working | Reset writes different property keys and then saves the current values back, so most settings are not reset. |
| Profile settings | Not working | Profile view and pickers exist but have no route from the active settings carousel. |
| Haptic/audible levels | Not working | Menus are unreachable and their setters are commented out. |
| Workout summary | Partially working | Opens after Save and shows time/HR/QC, but distance/pace are wrong and cadence, steps, and temperature are placeholders. |

## Screen audit

| Screen | Status | Result |
|---|---|---|
| `SimpleView` | Working | Live dashboard opened and refreshed. |
| `StartConfirmView` | Partially working | Yes works; No is drawn below the 260px fēnix 7 display and is invisible. |
| `AdvancedView` | Partially working | Opens and renders metrics/graph; sampling and high-zone colour are incorrect. |
| `CadenceAlertView` | Partially working | Draws and auto-dismisses; high cadence is not handled in graph mode. |
| `VibrationView` | Working | ON/OFF confirmation renders and auto-closes. |
| `SettingsView` | Working | Landing card renders and opens cadence settings. |
| `CadenceSettingsMenuView` | Working | Card renders and opens target selection. |
| `CadenceTargetView` | Partially working | Value changes and persists, but is unbounded. |
| `BarChartSettingsMenuView` | Working | Card renders and opens duration selection. |
| `BarChartSelectView` | Partially working | 15m/30m/1h/2h options cycle, but changing the option clears live cadence history. |
| `SummarySettingsMenuView` | Not working | Tap/select is a no-op. |
| `SummaryPromptView` | Not working | Implemented but unreachable from Summary settings. |
| `ResetSettingsView` | Not working | UI flow exists, but the reset operation does not reset the actual stored settings. |
| `ProfileSettingsMenuView` | Not working | Implemented but unreachable. |
| `SummaryView` | Partially working | Opens after Save; several values are wrong or placeholders. |
| `TimeView` | Not working | Implemented but has no route from the current application. |

## Button and menu audit

| Context/control | Status | Result |
|---|---|---|
| Main Start/Select | Working | Opens recording confirmation or activity controls. |
| Main Down/swipe | Working | Opens the advanced graph. |
| Main Up single press | Working | Waits for a possible double press by design. |
| Main Up double press | Partially working | Toggles vibration, but the value is not persisted. |
| Main Up long press/Menu | Partially working | Opens settings; several settings routes are incomplete. |
| Main Back while active | Working | Blocks exit and tells the user to finish/discard. |
| Main Back while idle | Not working | Replaces the main view with another main view, preventing normal app exit. |
| Start confirmation Yes | Working | Starts recording. |
| Start confirmation No | Not working | Selection exists but is outside the visible fēnix 7 screen. |
| Recording menu Resume | Not working | Shown while already recording; selecting it is a no-op. |
| Recording menu Pause | Partially working | Code changes to paused state, but it was not completed end-to-end in the FIT run. |
| Recording menu Stop | Working | Stops recording and opens Save/Discard. |
| Paused menu Resume | Partially working | Code restarts the recording session. |
| Paused menu Stop | Partially working | Code stops the paused session. |
| Save | Working | Saves and opens/skips summary based on preference. |
| Discard | Partially working | Discards and opens confirmation; full runtime path not completed. |
| Summary Select/Back | Working | Resets session and returns to main. |
| Summary swipe/other key | Not working | Returns to main without resetting the stopped session. |
| Summary setting Select | Not working | Does not toggle or open the preference prompt. |
| Reset Yes | Not working | Reports success but leaves most active/stored settings unchanged. |
| Reset No/Back | Working | Cancels the reset UI. |

## Confirmed bugs and reproduction steps

### BUG-01: Missing cadence creates fake 100 spm samples

Severity: High

Steps:

1. Launch the app without activity/sensor cadence data.
2. Start a recording.
3. Wait at least 30 seconds.
4. Stop and save the activity.

Expected: Missing cadence is recorded as missing and CQ remains unavailable or low confidence.

Actual: The app inserts 100 spm every second, calculates a CQ score, and reports high confidence.

### BUG-02: Summary distance and average pace use the wrong unit conversion

Severity: High

Steps:

1. Load or record an activity with a known non-zero distance.
2. Stop and save the activity.
3. Compare live distance with Summary distance and average pace.

Expected: Metres are divided by 1,000 to obtain kilometres.

Actual: Summary code divides metres by 100,000, understating distance by 100x and corrupting average pace.

### BUG-03: Advanced graph double-counts cadence and miscolours high cadence

Severity: High

Steps:

1. Start a recording with cadence data.
2. Open the advanced graph.
3. Compare cadence-history growth before and after opening the graph.
4. Feed cadence above the configured maximum.

Expected: One sample per second; below range red, in range green, above range visibly out of zone.

Actual: Both the global timer and `AdvancedView` add samples. Values above maximum are coloured green.

### BUG-04: Start confirmation No option is off-screen

Severity: Medium

Steps:

1. Launch on fēnix 7 (260x260).
2. Press Start/Select.

Expected: Yes and No are both visible.

Actual: No is drawn at y=280 and is outside the display.

### BUG-05: Summary preference cannot be changed

Severity: Medium

Steps:

1. Open Settings.
2. Navigate to Summary.
3. Press Select/tap.

Expected: Open the Yes/No summary preference and persist the selection.

Actual: The delegate only logs a message and returns.

### BUG-06: Reset Settings does not reset the active stored values

Severity: High

Steps:

1. Change cadence target, chart duration, profile, and summary preference.
2. Open Reset Settings and choose Yes.
3. Reopen the settings or restart the app.

Expected: All settings return to documented defaults.

Actual: Reset uses unrelated property names, then saves the current values back. Only the target is forced to 140.

### BUG-07: Vibration preference is lost after restart

Severity: Medium

Steps:

1. Double-press Up to turn vibration off.
2. Close and relaunch the app.

Expected: Vibration remains off.

Actual: Vibration returns to the default because it is never written or read from storage.

### BUG-08: Some Summary dismissal paths do not reset the session

Severity: High

Steps:

1. Record, stop, and save an activity.
2. On Summary, dismiss using swipe or Up/Down/Menu instead of Select/Back.
3. Press Start on the main screen.

Expected: A new recording confirmation opens.

Actual: The app remains in `STOPPED`, so it reopens Save/Discard for the old session.

### BUG-09: Main Back cannot exit while idle

Severity: Medium

Steps:

1. Launch the app and remain idle.
2. Press Back.

Expected: Exit the watch app using the platform’s normal back behaviour.

Actual: The delegate switches to a new copy of the main view and consumes Back.

### BUG-10: Recording menu exposes a no-op Resume action

Severity: Low

Steps:

1. Start recording.
2. Press Start to open Activity controls.
3. Select Resume.

Expected: Resume is absent while already recording.

Actual: Resume is shown and closes the menu without changing state.

### BUG-11: Summary HR values are not averages or peaks

Severity: Medium

Steps:

1. Record an activity with changing heart rate.
2. Stop and save.
3. Compare the summary average/peak values with the recorded activity.

Expected: Average and peak are calculated across the session.

Actual: Both values are assigned from `currentHeartRate` at stop time.

### BUG-12: Several settings/features are unreachable or placeholders

Severity: Medium

Steps:

1. Open Settings.
2. Navigate through every available card and menu.

Expected: Profile, summary preference, haptic/audible feedback, and all implemented screens are reachable and functional.

Actual: Profile, feedback, `SummaryPromptView`, and `TimeView` have no active route. Haptic/audible setters are commented out. Summary cadence, steps, and temperature are placeholders.

### BUG-13: Manifest contains an invalid target

Severity: Medium

Steps:

1. Build with SDK 9.2.0.
2. Observe compiler output or target `fenix7x` directly.

Expected: Every product ID in the manifest is valid.

Actual: The compiler warns that `fenix7x` is invalid.

## Limitations and recommended physical-watch checks

- Desktop simulation cannot confirm the strength or perception of physical vibration.
- GPS and optical HR accuracy require a physical watch/outdoor session.
- Pause/resume and discard should receive one final physical-watch pass because the FIT audit run completed the stop/save route.
- Verify all supported devices after correcting the invalid manifest product and responsive layout issue.
