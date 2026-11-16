# TODO - Fix Pause Mode Behaviour (branch: fix/pause_mode)

## Task
When an activity is paused, live runtime behaviour should completely stop:
- Cadence graph stops updating
- Cadence processing pauses
- No vibration alerts
- Resume continues correctly

## Steps
- [x] Create branch `fix/pause_mode`
- [x] Analyze pause flow (SimpleViewDelegate, GarminApp session state)
- [x] Identify root cause: runtime loops in SimpleView & AdvancedView run regardless of pause state
- [x] Edit `source/Views/SimpleView.mc` - gate refreshScreen() on isRecording()
- [x] Edit `source/Views/AdvancedView.mc` - gate refreshScreen() on isRecording()
- [x] Verify changes compile / review diff (monkeyc SDK not on PATH; manual review done)
- [x] Commit changes on `fix/pause_mode` branch (commit b23079d)
