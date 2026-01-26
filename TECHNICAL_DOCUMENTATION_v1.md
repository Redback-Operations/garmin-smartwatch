# Rebback ooperation Garmin App - Technical Documentation

## Table of Contents
0. [prequisites] (#prequisites)
0.5 [Build Process](#Build-Process)
1. [Architecture Overview](#architecture-overview)
2. [Core Components](#core-components)
3. [Data Flow](#data-flow)
4. [State Management](#state-management)
5. [Activity Recording System](#activity-recording-system)
6. [Cadence Quality Algorithm](#cadence-quality-algorithm)
7. [User Interface](#user-interface)
8. [Settings System](#settings-system)
9. [Features Reference](#features-reference)

---
## prequisites
- Garmin Connect IQ SDK 8.3.0+
- Visual Studio Code with Connect IQ extension
- Forerunner 165/165 Music device or simulator

## Build-Process
1. Clone repository
2. Configure project settings in `monkey.jungle`
3. Build for target device:
   ```bash
   monkeyc -o bin/app.prg -f monkey.jungle -y developer_key.der

## Architecture Overview

### Application Type
- **Type**: Garmin Watch App (not data field or widget)
- **Target Devices**: Forerunner 165, Forerunner 165 Music
- **SDK Version**: Minimum API Level 5.2.0
- **Architecture**: MVC (Model-View-Controller/Delegate pattern)

### High-Level Structure
```
GarminApp (Application Core)
    ├── Views
    │   ├── SimpleView (Main activity view)
    │   └── AdvancedView (Chart visualization)
    ├── Delegates (Input handlers)
    │   ├── SimpleViewDelegate (Main controls)
    │   ├── AdvancedViewDelegate (Chart controls)
    │   └── Settings Delegates (Configuration)
    ├── Managers
    │   ├── SensorManager (Cadence sensor)
    │   └── Logger (Memory tracking)
    └── Data Processing
        ├── Cadence Quality Calculator
        └── Activity Recording Session
```

---

## Core Components

### 1. GarminApp.mc
**Purpose**: Central application controller and data manager

**Key Responsibilities**:
- Activity session lifecycle management (start/pause/resume/stop/save/discard)
- Cadence data collection and storage
- Cadence quality score computation
- State machine management
- Timer management
- Integration with Garmin Activity Recording API

**Important Constants**:
```monkey-c
MAX_BARS = 280              // Maximum cadence samples to store
BASELINE_AVG_CADENCE = 160  // Minimum acceptable cadence
MAX_CADENCE = 190           // Maximum cadence for calculations
MIN_CQ_SAMPLES = 30         // Minimum samples for CQ calculation
DEBUG_MODE = true           // Enable debug logging
```

**State Variables**:
- `_sessionState`: Current session state (IDLE/RECORDING/PAUSED/STOPPED)
- `activitySession`: Garmin ActivityRecording session object
- `_cadenceHistory`: Circular buffer storing 280 cadence samples
- `_cadenceBarAvg`: Rolling average buffer for chart display
- `_cqHistory`: Last 10 CQ scores for trend analysis

---

## Data Flow

### 1. Cadence Data Collection Pipeline

```
Cadence Sensor
    ↓
Activity.getActivityInfo().currentCadence
    ↓
updateCadenceBarAvg() [Every 1 second]
    ↓
_cadenceBarAvg buffer (accumulates samples)
    ↓
When buffer full (chart duration samples)
    ↓
Calculate bar average
    ↓
updateCadenceHistory(average)
    ↓
_cadenceHistory circular buffer [280 samples]
    ↓
computeCadenceQualityScore()
    ↓
_cqHistory [Last 10 scores]
```

### 2. Timer System

**Global Timer** (`globalTimer`):
- Frequency: Every 1 second
- Callback: `updateCadenceBarAvg()`
- Runs: Always (from app start to stop)
- Purpose: Collect cadence data when recording

**View Refresh Timers**:
- SimpleView: Refresh every 1 second
- AdvancedView: Refresh every 1 second
- Purpose: Update UI elements

### 3. Data Averaging System

The app uses a two-tier averaging system:

**Tier 1: Bar Averaging**
```
Chart Duration = 6 seconds (ThirtyminChart default)
↓
Collect 6 cadence readings (1 per second)
↓
Calculate average of these 6 readings
↓
Store as single bar value
```

**Tier 2: Historical Storage**
```
280 bar values stored
↓
Each bar = average of 6 seconds
↓
Total history = 280 × 6 = 1680 seconds = 28 minutes
```

**Chart Duration Options**:
- FifteenminChart = 3 seconds per bar
- ThirtyminChart = 6 seconds per bar (default)
- OneHourChart = 13 seconds per bar
- TwoHourChart = 26 seconds per bar

---

## State Management

### Session State Machine

```
┌──────┐
│ IDLE │ ← Initial state, no session
└──┬───┘
   │ startRecording()
   ↓
┌───────────┐
│ RECORDING │ ← Activity running, timer active
└─┬───────┬─┘
  │       │
  │       │ pauseRecording()
  │       ↓
  │   ┌────────┐
  │   │ PAUSED │ ← Activity paused, timer stopped
  │   └───┬────┘
  │       │
  │       │ resumeRecording()
  │       ↓
  │   (back to RECORDING)
  │
  │ stopRecording()
  ↓
┌─────────┐
│ STOPPED │ ← Activity stopped, awaiting save/discard
└────┬────┘
     │
     │ saveSession() or discardSession()
     ↓
  (back to IDLE)
```

### State Transition Rules

**IDLE → RECORDING**:
- User presses START/STOP button
- Creates new ActivityRecording session
- Starts Garmin timer
- Resets all cadence data arrays
- Initializes timestamps

**RECORDING → PAUSED**:
- User selects "Pause" from menu
- Stops Garmin timer (timer pauses)
- Records pause timestamp
- Data collection stops

**PAUSED → RECORDING**:
- User selects "Resume" from menu
- Restarts Garmin timer
- Accumulates paused time
- Data collection resumes

**RECORDING/PAUSED → STOPPED**:
- User selects "Stop" from menu
- Stops Garmin timer
- Computes final CQ score
- Freezes all metrics
- Awaits save/discard decision

**STOPPED → IDLE**:
- User selects "Save": Saves to FIT file
- User selects "Discard": Deletes session
- Resets all data structures
- Ready for new session

---

## Activity Recording System

### Garmin ActivityRecording Integration

**Session Creation** (`startRecording()`):
```monkey-c
activitySession = ActivityRecording.createSession({
    :name => "Running",
    :sport => ActivityRecording.SPORT_RUNNING,
    :subSport => ActivityRecording.SUB_SPORT_GENERIC
});
activitySession.start();
```

**What This Does**:
- Creates official Garmin activity
- Starts timer (visible in UI)
- Records GPS, heart rate, cadence automatically
- Manages distance calculation
- Handles sensor data collection

**Pause/Resume** (`pauseRecording()` / `resumeRecording()`):
```monkey-c
// Pause
activitySession.stop();  // Pauses timer

// Resume
activitySession.start(); // Resumes timer
```

**Save** (`saveSession()`):
```monkey-c
activitySession.save();
```
- Writes FIT file to device
- Syncs to Garmin Connect
- Appears in activity history
- Includes all sensor data

**Discard** (`discardSession()`):
```monkey-c
activitySession.discard();
```
- Deletes session completely
- No FIT file created
- No sync to Garmin Connect

---

## Cadence Quality Algorithm

### Overview
The Cadence Quality (CQ) score is a composite metric (0-100%) evaluating running efficiency.

### Components

#### 1. Time in Zone Score (70% weight)

**Purpose**: Measures percentage of time spent in ideal cadence range

**Algorithm**:
```
idealMin = 120 spm (default)
idealMax = 150 spm (default)

inZoneCount = 0
validSamples = 0

for each sample in _cadenceHistory:
    if sample exists:
        validSamples++
        if sample >= idealMin AND sample <= idealMax:
            inZoneCount++

timeInZone = (inZoneCount / validSamples) × 100
```

**Example**:
- 200 valid samples
- 140 samples in zone (120-150)
- Score = (140/200) × 100 = 70%

#### 2. Smoothness Score (30% weight)

**Purpose**: Measures cadence consistency (less variation = better)

**Algorithm**:
```
totalDiff = 0
diffCount = 0

for i = 1 to MAX_BARS:
    prev = _cadenceHistory[i-1]
    curr = _cadenceHistory[i]
    if both exist:
        totalDiff += abs(curr - prev)
        diffCount++

avgDiff = totalDiff / diffCount
rawScore = 100 - (avgDiff × 10)
smoothness = clamp(rawScore, 0, 100)
```

**Interpretation**:
- avgDiff = 0-1: Very smooth (score ~90-100)
- avgDiff = 2-3: Normal (score ~70-80)
- avgDiff > 5: Erratic (score < 50)

#### 3. Final CQ Score

**Formula**:
```
CQ = (timeInZone × 0.7) + (smoothness × 0.3)
```

**Example Calculation**:
```
timeInZone = 75%
smoothness = 85%

CQ = (75 × 0.7) + (85 × 0.3)
   = 52.5 + 25.5
   = 78%
```

### CQ Confidence Level

**Purpose**: Indicates reliability of CQ score

**Factors**:
1. **Sample Count**: Need minimum 30 samples
2. **Missing Data Ratio**: Sensor dropout rate

**Algorithm**:
```
if samples < 30:
    confidence = "Low"
else:
    missingRatio = missingCount / (validCount + missingCount)
    if missingRatio > 0.2:
        confidence = "Low"
    else if missingRatio > 0.1:
        confidence = "Medium"
    else:
        confidence = "High"
```

### CQ Trend Analysis

**Purpose**: Shows if cadence quality is improving during run

**Algorithm**:
```
Uses last 10 CQ scores (_cqHistory)

if scores < 5:
    trend = "Stable"
else:
    delta = lastScore - firstScore
    if delta < -5:
        trend = "Declining"
    else if delta > 5:
        trend = "Improving"
    else:
        trend = "Stable"
```

### Ideal Cadence Calculator

**Purpose**: Calculate personalized ideal cadence based on user profile

**Formula** (gender-specific):

**Male**:
```
referenceCadence = (-1.268 × legLength) + (3.471 × speed) + 261.378
```

**Female**:
```
referenceCadence = (-1.190 × legLength) + (3.705 × speed) + 249.688
```

**Other**:
```
referenceCadence = (-1.251 × legLength) + (3.665 × speed) + 254.858
```

**Experience Adjustment**:
```
Beginner: multiplier = 1.06 (6% higher cadence)
Intermediate: multiplier = 1.04 (4% higher)
Advanced: multiplier = 1.02 (2% higher)

finalCadence = referenceCadence × multiplier
idealMin = finalCadence - 5
idealMax = finalCadence + 5
```

**Example**:
```
User: Male, 170cm height, 10 km/h speed, Intermediate

legLength = 170 × 0.53 = 90.1 cm
speed = 10 / 3.6 = 2.78 m/s

referenceCadence = (-1.268 × 90.1) + (3.471 × 2.78) + 261.378
                 = -114.25 + 9.65 + 261.378
                 = 156.78

adjusted = 156.78 × 1.04 = 163.05
final = round(163.05) = 163
clamped = max(160, min(163, 190)) = 163

idealMin = 163 - 5 = 158 spm
idealMax = 163 + 5 = 168 spm
```

---

## User Interface

### View Architecture

#### SimpleView.mc
**Purpose**: Main activity tracking screen

**Display Elements**:
1. **Timer**: HH:MM:SS format from Activity.getActivityInfo().timerTime
2. **Heart Rate**: BPM with heart icon (red)
3. **Cadence**: Current spm with cadence icon (green/red based on zone)
4. **Distance**: Kilometers with 2 decimals
5. **Cadence Zone**: Text showing if in/out of ideal range
6. **CQ Score**: Cadence Quality percentage
7. **State Indicator**: Visual recording state (REC/PAUSE/STOP)

**Layout** (from top to bottom):
```
[Timer: 00:00:00]              [REC ●]
    
    ❤️ [Heart Rate]      🏃 [Cadence]
    
        [Distance] km
    
    [Zone: In/Out (120-150)]
    
        CQ: [Score]%
```

**State Visual Indicators**:
- **IDLE**: "Press START/STOP to start" text
- **RECORDING**: Red dot + "REC" in top-right
- **PAUSED**: Yellow dot + "PAUSE" + flashing "PAUSED" text
- **STOPPED**: Green dot + "STOP" + "Activity Complete!" message

#### AdvancedView.mc
**Purpose**: Real-time cadence visualization chart

**Display Elements**:
1. **Timer**: Simplified format (H:MM) at top in yellow
2. **Heart Rate Circle**: Dark red circle on left with BPM
3. **Distance Circle**: Dark green circle on right with km
4. **Current Cadence**: Large centered text with spm
5. **Cadence Chart**: Histogram showing last 280 bars
6. **Chart Duration Label**: Shows time range (e.g., "Last 30 Minutes")

**Chart Visualization**:
```
Height of screen
    ↓
┌─────────────────────────┐
│     Time: 1:30          │
│                         │
│  ●HR    Cadence    Dist●│
│  150      170       2.5 │
│                         │
│  ┌───────────────────┐  │
│  │ ▂▃▅▇█▇▅▃▂▁▃▅▇█▇ │  │ ← Chart
│  │ ▁▂▃▅▇█▇▅▃▂▁▃▅▇█ │  │
│  └───────────────────┘  │
│   Last 30 Minutes       │
└─────────────────────────┘
```

**Color Coding**:
- **Green** (0x00bf63): Cadence in ideal zone
- **Blue** (0x0cc0df): Below zone but within 20 spm
- **Grey** (0x969696): More than 20 spm below zone
- **Orange** (0xff751f): Above zone but within 20 spm
- **Red** (0xFF0000): More than 20 spm above zone

**Chart Algorithm**:
```
For each bar in cadenceHistory:
    barHeight = (cadence / MAX_CADENCE_DISPLAY) × chartHeight
    x = barZoneLeft + (barIndex × barWidth)
    y = barZoneBottom - barHeight
    
    color = determineColor(cadence, idealMin, idealMax)
    drawRectangle(x, y, barWidth, barHeight, color)
```

### Navigation Flow

```
SimpleView (Main)
    ↓ Swipe UP / Press DOWN
AdvancedView (Chart)
    ↓ Swipe DOWN / Press UP
SimpleView (Main)
    ↓ Swipe LEFT / Press MENU
Settings Menu
    ├── Profile
    ├── Customization
    ├── Feedback
    └── Cadence Range
```

### Button Mapping (Forerunner 165)

**Physical Buttons**:
```
        [LIGHT/MENU]
              ↓
              Settings
              
    [UP] ←  WATCH  → [DOWN]
Settings     AdvancedView
              
        [START/STOP]
              ↓
         Main Control
              
          [BACK]
              ↓
     Exit (if idle)
```

**START/STOP Button Behavior**:
| Current State | Action | Result |
|---------------|--------|--------|
| IDLE | Press | Start activity |
| RECORDING | Press | Show menu: Resume/Pause/Stop |
| PAUSED | Press | Show menu: Resume/Stop |
| STOPPED | Press | Show menu: Save/Discard |

---

## Settings System

### Architecture

Settings use a hierarchical menu system with specialized delegates:

```
Settings Menu (SettingsMenuDelegate)
    ├── Profile (SelectProfileDelegate)
    │   ├── Height (ProfilePickerDelegate)
    │   ├── Speed (ProfilePickerDelegate)
    │   ├── Experience (SelectExperienceDelegate)
    │   └── Gender (SelectGenderDelegate)
    ├── Customization (SelectCustomizableDelegate)
    │   └── Chart Duration (SelectBarChartDelegate)
    ├── Feedback (SelectFeedbackDelegate)
    │   ├── Haptic (SelectHapticDelegate)
    │   └── Audible (SelectAudibleDelegate)
    └── Cadence Range
        ├── Min Cadence (Picker)
        └── Max Cadence (Picker)
```

### Profile Settings

#### Height Setting
**Purpose**: Calculate leg length for ideal cadence
**Range**: 100-250 cm
**Default**: 170 cm
**UI**: Number picker with " cm" label

**Implementation**:
```monkey-c
ProfilePickerFactory(100, 250, 1, {:label=>" cm"})
Callback: ProfilePickerDelegate(:prof_height)
Storage: app.setUserHeight(value)
```

#### Speed Setting
**Purpose**: Running pace for cadence calculation
**Range**: 3-30 km/h
**Default**: 10 km/h
**UI**: Number picker with " km/h" label

#### Experience Level
**Purpose**: Adjust ideal cadence by fitness level
**Options**:
- Beginner (1.06 multiplier)
- Intermediate (1.04 multiplier)
- Advanced (1.02 multiplier)
**Default**: Beginner
**UI**: Menu selection

**Rationale**: Less experienced runners typically benefit from slightly higher cadence to reduce impact forces.

#### Gender
**Purpose**: Gender-specific cadence formulas
**Options**: Male, Female, Other
**Default**: Male
**UI**: Menu selection

### Customization Settings

#### Chart Duration
**Purpose**: Set time range for cadence chart
**Options**:
- 15 Minutes (3 sec/bar)
- 30 Minutes (6 sec/bar) [Default]
- 1 Hour (13 sec/bar)
- 2 Hours (26 sec/bar)
**Effect**: Changes `_chartDuration` which affects bar averaging

### Feedback Settings

#### Haptic Feedback
**Purpose**: Vibration alerts for zone crossing
**Options**: On/Off
**Behavior**:
- Single pulse: Dropped below min cadence
- Double pulse: Exceeded max cadence

#### Audible Feedback
**Purpose**: Audio alerts for zone crossing
**Options**: On/Off
**Behavior**: Beep patterns for zone events

### Cadence Range Settings

**Purpose**: Manually override ideal cadence zone

**Min Cadence**:
- Range: 100-180 spm
- Default: 120 spm
- UI: Number picker

**Max Cadence**:
- Range: 120-200 spm
- Default: 150 spm
- UI: Number picker

**Use Case**: Advanced users who want custom zones based on training goals.

---

## Features Reference

### 1. Activity Session Management

**Feature**: Full lifecycle control of running activities

**Components**:
- Start: Begin new activity with Garmin session
- Pause: Temporarily stop timer and data collection
- Resume: Continue paused activity
- Stop: End activity (awaiting save/discard)
- Save: Write to FIT file and sync to Garmin Connect
- Discard: Delete activity without saving

**User Flow**:
```
Press START/STOP
    ↓
Activity starts (timer runs)
    ↓
Press START/STOP → Select "Pause"
    ↓
Activity paused (timer stops)
    ↓
Press START/STOP → Select "Resume"
    ↓
Activity resumes (timer continues)
    ↓
Press START/STOP → Select "Stop"
    ↓
Activity stopped (timer frozen)
    ↓
Select "Save" or "Discard"
    ↓
Return to IDLE (ready for new activity)
```

### 2. Real-Time Cadence Monitoring

**Feature**: Live cadence tracking with visual feedback

**Data Source**: Activity.getActivityInfo().currentCadence
**Update Frequency**: Every 1 second
**Storage**: Circular buffer (280 samples = ~28 mins at default)

**Visual Feedback**:
- **SimpleView**: Large cadence number with zone text
- **AdvancedView**: Color-coded histogram chart
- **Zone Indicator**: "In Zone" or "Out of Zone" text

### 3. Cadence Quality Scoring

**Feature**: Composite metric evaluating running efficiency

**Algorithm**: Weighted combination of:
- Time in Zone (70%): Percentage in ideal range
- Smoothness (30%): Consistency of cadence

**Output**:
- CQ Score: 0-100%
- Confidence: Low/Medium/High
- Trend: Improving/Stable/Declining

**Update**: Real-time during recording, frozen when stopped

### 4. Personalized Ideal Cadence

**Feature**: Calculate optimal cadence based on user profile

**Inputs**:
- Height (cm)
- Speed (km/h)
- Experience Level
- Gender

**Output**:
- Ideal Min Cadence (spm)
- Ideal Max Cadence (spm)

**Formula**: Gender-specific biomechanical equation with experience adjustment

### 5. Historical Data Visualization

**Feature**: Real-time cadence chart showing last 28 minutes

**Chart Type**: Histogram (bar chart)
**Data Points**: 280 bars (each = average of 6 seconds)
**Color Coding**: 5-color gradient based on zone proximity
**Update**: Real-time (every second when recording)

**Chart Duration Modes**:
- 15 min: Higher resolution (3 sec/bar)
- 30 min: Default (6 sec/bar)
- 1 hour: Lower resolution (13 sec/bar)
- 2 hours: Lowest resolution (26 sec/bar)

### 6. Multi-Sensor Integration

**Feature**: Display all relevant running metrics

**Sensors**:
- **Cadence**: Steps per minute from cadence pod or wrist sensor
- **Heart Rate**: BPM from optical HR or chest strap
- **GPS**: Distance and speed
- **Timer**: Elapsed time (pauses with activity)

**Display**:
- SimpleView: All metrics in text format
- AdvancedView: Heart rate and distance in circles

### 7. Zone-Based Haptic Alerts

**Feature**: Vibration feedback when leaving ideal zone

**Triggers**:
- Single pulse: Cadence drops below min
- Double pulse: Cadence exceeds max

**Implementation**:
- Tracks zone state (-1/0/1)
- Only triggers on state change
- Second pulse delayed 240ms

### 8. Session Persistence

**Feature**: Save activities to Garmin ecosystem

**Save Format**: FIT file (Flexible and Interoperable Transfer)
**Storage Location**: Device internal storage
**Sync**: Automatic to Garmin Connect when synced
**Data Included**:
- Timer duration (excluding paused time)
- GPS track
- Heart rate
- Cadence samples
- Distance
- Speed/pace
- Custom CQ score (if supported)

### 9. Memory Management

**Feature**: Track and log memory usage

**Implementation**: Logger.mc module
**Frequency**: 
- On startup
- On shutdown
- Every ~60 seconds during runtime

**Output**: System.println with stats
**Format**: `[MEMORY] Tag: used/total bytes (X% used)`

### 10. Debug Logging

**Feature**: Comprehensive logging for development

**Enabled**: `DEBUG_MODE = true`
**Categories**:
- [INFO]: App lifecycle events
- [DEBUG]: Button presses, state changes
- [UI]: User interactions
- [CADENCE]: Cadence samples
- [CADENCE QUALITY]: CQ calculations
- [MEMORY]: Memory statistics

**Toggle**: Set `DEBUG_MODE = false` for production

---

## Data Structures

### Circular Buffers

**_cadenceHistory**:
```
Type: Array<Float?>[280]
Purpose: Store last 280 cadence bar averages
Access: Circular (wraps at 280)
Index: _cadenceIndex (0-279)
Count: _cadenceCount (0-280)
```

**_cadenceBarAvg**:
```
Type: Array<Float?>[_chartDuration]
Purpose: Temporary buffer for bar averaging
Access: Circular (wraps at chart duration)
Index: _cadenceAvgIndex
Count: _cadenceAvgCount
```

**_cqHistory**:
```
Type: Array<Number>[10]
Purpose: Store last 10 CQ scores for trend
Access: Array (removes oldest when > 10)
```

### Session Metadata

```monkey-c
_sessionStartTime: Number     // System.getTimer() at start
_sessionPausedTime: Number    // Total ms spent paused
_lastPauseTime: Number?       // When current pause began
_finalCQ: Number?             // Frozen CQ score when stopped
_finalCQConfidence: String?   // Frozen confidence
_finalCQTrend: String?        // Frozen trend
```

---

## Performance Considerations

### Timer Efficiency
- **Global timer**: 1 second interval (low overhead)
- **View timers**: Only run when view is visible
- **Data collection**: O(1) operations (circular buffer)

### Memory Usage
- **Cadence history**: 280 × 4 bytes = 1120 bytes
- **Bar average**: 6 × 4 bytes = 24 bytes (default)
- **CQ history**: 10 × 4 bytes = 40 bytes
- **Total data**: ~1200 bytes (negligible on modern watches)

### CPU Usage
- **Cadence update**: O(n) where n = chart duration (typically 6)
- **CQ calculation**: O(280) = O(1) for fixed size
- **Chart rendering**: O(280) bars drawn per frame

### Battery Impact
- **GPS**: Major drain (handled by Garmin OS)
- **Sensors**: Minimal (optical HR, cadence)
- **Screen refresh**: 1 Hz (low power)
- **Recommendation**: Use with GPS activities (already optimized)

---

## Future Enhancement Ideas

### Visualization Enhancements

#### 1. **Current Cadence Marker** ⭐
**Priority**: High  
**Complexity**: Low  
**Effort**: 1-2 hours  

**Description**: Add a horizontal line or marker showing current real-time cadence on the chart

**Implementation**:
```monkey-c
// In drawChart() after drawing bars:
if (info != null && info.currentCadence != null) {
    var currentCadence = info.currentCadence;
    var currentY = barZoneBottom - ((currentCadence / MAX_CADENCE_DISPLAY) * chartHeight);
    
    // Draw yellow horizontal line
    dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
    dc.drawLine(chartLeft, currentY, chartRight, currentY);
    
    // Optional: Draw small arrow or label
    dc.fillCircle(chartRight + 5, currentY, 3); // Dot at end
}
```

**Benefits**:
- Instant visual reference for current performance
- Easy to see if cadence is trending up or down relative to history
- Helps runners maintain target cadence by comparing to past bars

**User Experience**: 
- Glanceable feedback during run
- No need to look at number - just see if line is in green zone

---

#### 2. **Smooth Bars (Moving Average)** ⭐
**Priority**: Medium  
**Complexity**: Medium  
**Effort**: 3-4 hours  

**Description**: Apply exponential moving average (EMA) or simple moving average to reduce visual "jumpiness" from sensor noise

**Implementation Options**:

**Option A: Simple Moving Average (SMA)**
```monkey-c
// Average last N bars for smoother display
private var _smoothedHistory as Array<Float> = new [MAX_BARS];

function smoothBars(windowSize as Number) as Void {
    for (var i = 0; i < _cadenceCount; i++) {
        var sum = 0.0;
        var count = 0;
        
        // Average surrounding bars
        for (var j = -windowSize; j <= windowSize; j++) {
            var idx = (i + j + MAX_BARS) % MAX_BARS;
            if (_cadenceHistory[idx] != null) {
                sum += _cadenceHistory[idx];
                count++;
            }
        }
        
        _smoothedHistory[i] = (count > 0) ? (sum / count) : 0;
    }
}
```

**Option B: Exponential Moving Average (EMA)** (Recommended)
```monkey-c
// Weighted average favoring recent data
private var _emaHistory as Array<Float> = new [MAX_BARS];
private const SMOOTHING_FACTOR = 0.3; // α (0-1), lower = smoother

function updateEMA(newValue as Float, index as Number) as Void {
    if (index == 0 || _emaHistory[index-1] == null) {
        _emaHistory[index] = newValue;
    } else {
        _emaHistory[index] = SMOOTHING_FACTOR * newValue + 
                             (1 - SMOOTHING_FACTOR) * _emaHistory[index-1];
    }
}
```

**Configurable Settings**:
```
Smoothing: Off / Low (α=0.5) / Medium (α=0.3) / High (α=0.1)
```

**Benefits**:
- Cleaner visual representation
- Reduces noise from sensor fluctuations
- Easier to spot genuine trends vs. random variation
- More professional appearance

**Tradeoffs**:
- Slightly delayed response to actual changes
- May hide brief cadence spikes/drops
- Recommendation: Make it toggleable

---

#### 3. **Fade Old Bars** ⭐
**Priority**: Low  
**Complexity**: Low  
**Effort**: 1-2 hours  

**Description**: Apply opacity/alpha gradient to bars based on age - recent bars full opacity, older bars gradually fade

**Implementation**:
```monkey-c
// Calculate fade based on bar age
for (var i = 0; i < numBars; i++) {
    var index = (startIndex + i) % MAX_BARS;
    var cadence = cadenceHistory[index];
    
    // Calculate age factor (0.0 = oldest, 1.0 = newest)
    var ageFactor = i / numBars.toFloat();
    
    // Map to opacity (50% fade for oldest → 100% for newest)
    var minOpacity = 0.5;  // Don't fade below 50%
    var opacity = minOpacity + (ageFactor * (1.0 - minOpacity));
    
    // Get base color
    var baseColor = getColorForCadence(cadence);
    
    // Apply opacity (note: not all Garmin devices support alpha)
    // Fallback: lighten color instead
    dc.setColor(applyFade(baseColor, opacity), Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(x, y, barWidth, barHeight);
}

function applyFade(color as Number, opacity as Float) as Number {
    // Blend color with background (black) based on opacity
    // For devices without alpha channel support
    var r = ((color >> 16) & 0xFF) * opacity;
    var g = ((color >> 8) & 0xFF) * opacity;
    var b = (color & 0xFF) * opacity;
    
    return ((r.toNumber() << 16) | (g.toNumber() << 8) | b.toNumber());
}
```

**Benefits**:
- Emphasizes recent data (what matters now, i think anyways)
- Creates visual depth/perspective
- Easier to focus on current performance
- More aesthetically pleasing

**Configuration**:
```
Fade: Off / Subtle (70-100%) / Medium (50-100%) / Strong (30-100%)
```

---

#### 4. **Zone Boundary Lines**
**Priority**: Medium  
**Complexity**: Low  
**Effort**: 30 minutes  

**Description**: Draw horizontal lines at idealMinCadence and idealMaxCadence for immediate visual reference

**Implementation**:
```monkey-c
// Draw zone boundaries
var minY = barZoneBottom - ((idealMinCadence / MAX_CADENCE_DISPLAY) * chartHeight);
var maxY = barZoneBottom - ((idealMaxCadence / MAX_CADENCE_DISPLAY) * chartHeight);

// Green dashed lines for zone boundaries
dc.setColor(0x00bf63, Graphics.COLOR_TRANSPARENT); // Green
dc.drawLine(chartLeft, minY, chartRight, minY);
dc.drawLine(chartLeft, maxY, chartRight, maxY);

// Optional: Fill zone area with semi-transparent green
// (if device supports)
dc.setColor(0x00bf63, 0x20); // Green with alpha
dc.fillRectangle(chartLeft, maxY, chartWidth, minY - maxY);
```

**Benefits**:
- Clear visual target zone
- No need to remember numbers while running
- Instant feedback if bars cross boundaries
- Reduces cognitive load

---

### Chart Optimization & Performance

#### 5. **Reduce Redraw Cost (Battery Optimization)** ⭐⭐⭐
**Priority**: High  
**Complexity**: Medium  
**Effort**: 4-6 hours  

**Description**: Implement intelligent redraw strategies to minimize unnecessary screen updates

**Strategy 1: Dirty Region Tracking**
```monkey-c
private var _lastDrawnCadence = 0;
private var _lastDrawnBarCount = 0;
private var _lastDrawnZone = [0, 0]; // [min, max]

function needsRedraw() as Boolean {
    var currentCadence = getCurrentCadence();
    
    // Redraw if:
    // 1. New bar added (every ~6 seconds)
    if (_cadenceCount != _lastDrawnBarCount) { return true; }
    
    // 2. Current cadence changed significantly (>2 spm)
    if (Math.abs(currentCadence - _lastDrawnCadence) > 2) { return true; }
    
    // 3. Zone settings changed
    if (_idealMinCadence != _lastDrawnZone[0] || 
        _idealMaxCadence != _lastDrawnZone[1]) { return true; }
    
    return false;
}

function onUpdate(dc as Dc) as Void {
    if (needsRedraw()) {
        View.onUpdate(dc);
        drawElements(dc);
        
        // Update tracking
        _lastDrawnCadence = getCurrentCadence();
        _lastDrawnBarCount = _cadenceCount;
        _lastDrawnZone = [_idealMinCadence, _idealMaxCadence];
    }
}
```

**Strategy 2: Partial Chart Updates**
```monkey-c
// Only redraw new bars, not entire chart
private var _lastRenderedBarIndex = 0;

function drawNewBarsOnly(dc as Dc) as Void {
    // Calculate how many new bars since last draw
    var newBars = _cadenceIndex - _lastRenderedBarIndex;
    
    if (newBars <= 0) { return; } // No new data
    
    // Set clip region to only new bar area
    var newBarX = chartLeft + (_lastRenderedBarIndex * barWidth);
    var clipWidth = newBars * barWidth;
    
    dc.setClip(newBarX, chartTop, clipWidth, chartHeight);
    
    // Draw only new bars
    for (var i = _lastRenderedBarIndex; i < _cadenceIndex; i++) {
        drawSingleBar(dc, i);
    }
    
    dc.clearClip();
    _lastRenderedBarIndex = _cadenceIndex;
}
```

**Strategy 3: Adaptive Refresh Rate**
```monkey-c
private var _refreshRate = 1000; // Default 1 Hz

function updateRefreshRate() as Void {
    if (_sessionState == PAUSED) {
        _refreshRate = 5000; // 0.2 Hz when paused
    } else if (_sessionState == STOPPED) {
        _refreshRate = 10000; // 0.1 Hz when stopped
    } else {
        _refreshRate = 1000; // 1 Hz when recording
    }
    
    // Restart timer with new rate
    if (_simulationTimer != null) {
        _simulationTimer.stop();
        _simulationTimer.start(method(:refreshScreen), _refreshRate, true);
    }
}
```

**Expected Impact**:
- **10-20% battery improvement** during long activities
- **30-40% reduction** in unnecessary screen updates
- **Smoother performance** on lower-end devices

---

#### 6. **Chart Rendering Optimization**
**Priority**: High  
**Complexity**: Medium  
**Effort**: 3-4 hours  

**Description**: Optimize the chart drawing loop using cached calculations and efficient rendering

**Optimization 1: Pre-calculate Bar Positions**
```monkey-c
private var _barPositions as Array<Array> = new [MAX_BARS];

function precalculateBarPositions() as Void {
    var barWidth = (barZoneWidth / MAX_BARS).toNumber();
    
    for (var i = 0; i < MAX_BARS; i++) {
        var x = barZoneLeft + i * barWidth;
        _barPositions[i] = [x, barWidth]; // Store x and width
    }
}

// In drawChart():
for (var i = 0; i < numBars; i++) {
    var x = _barPositions[i][0];
    var barWidth = _barPositions[i][1];
    // ... rest of drawing
}
```

**Optimization 2: Color Lookup Table**
```monkey-c
private var _colorCache as Dictionary = {};

function getColorCached(cadence as Number) as Number {
    var key = cadence.toNumber(); // Round to integer
    
    if (_colorCache.hasKey(key)) {
        return _colorCache[key];
    }
    
    var color = calculateColor(cadence);
    _colorCache.put(key, color);
    return color;
}
```

**Optimization 3: Batch Drawing Operations**
```monkey-c
// Group bars by color to reduce setColor() calls
var colorGroups = {};

for (var i = 0; i < numBars; i++) {
    var color = getColor(cadence);
    if (!colorGroups.hasKey(color)) {
        colorGroups[color] = [];
    }
    colorGroups[color].add(barData);
}

// Draw all bars of same color together
foreach (var color in colorGroups.keys()) {
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    foreach (var bar in colorGroups[color]) {
        dc.fillRectangle(bar.x, bar.y, bar.width, bar.height);
    }
}
```

**Impact**: **50-70% reduction** in chart draw time

---

### Advanced Chart Features

#### 7. **Auto-Adjust Averaging Based on Zone Width**
**Priority**: Low  
**Complexity**: Medium  
**Effort**: 2-3 hours  

**Description**: Automatically adjust chart duration (samples per bar) based on cadence zone range

**Logic**:
```monkey-c
function calculateOptimalChartDuration() as Number {
    var zoneRange = _idealMaxCadence - _idealMinCadence;
    
    // Narrow zone → Higher resolution
    if (zoneRange <= 5) {
        return 3; // 3 sec/bar (high detail for precision)
    }
    // Normal zone → Default resolution
    else if (zoneRange <= 15) {
        return 6; // 6 sec/bar (balanced)
    }
    // Wide zone → Lower resolution (smoother)
    else if (zoneRange <= 30) {
        return 13; // 13 sec/bar (reduce noise)
    }
    // Very wide zone → Overview mode
    else {
        return 26; // 26 sec/bar (big picture)
    }
}

// Call when zone changes:
function onZoneChanged() as Void {
    _chartDuration = calculateOptimalChartDuration();
    resizeAveragingBuffer(_chartDuration);
}
```

**Benefits**:
- Optimal granularity for any zone width
- Narrow zones (e.g., 148-152) get fine detail
- Wide zones (e.g., 120-160) get smoothed data
- Automatic - no user configuration needed

**Example**:
- Zone 98-99 (range=1): 3 sec/bar → 280 bars = 14 min history
- Zone 140-155 (range=15): 6 sec/bar → 280 bars = 28 min history
- Zone 100-150 (range=50): 26 sec/bar → 280 bars = 121 min history

---

#### 8. **Statistical Overlays**
**Priority**: Medium  
**Complexity**: Medium  
**Effort**: 3-4 hours  

**Description**: Display statistical information on chart (mean, median, trend line)

**Implementation**:
```monkey-c
function calculateStats() as Dictionary {
    var sum = 0.0;
    var count = 0;
    var sortedData = [];
    
    for (var i = 0; i < _cadenceCount; i++) {
        if (_cadenceHistory[i] != null) {
            sum += _cadenceHistory[i];
            count++;
            sortedData.add(_cadenceHistory[i]);
        }
    }
    
    var mean = count > 0 ? sum / count : 0;
    
    // Calculate median
    sortedData = sortData(sortedData);
    var median = sortedData[count / 2];
    
    // Calculate standard deviation
    var variance = 0.0;
    for (var i = 0; i < count; i++) {
        variance += Math.pow(_cadenceHistory[i] - mean, 2);
    }
    var stdDev = Math.sqrt(variance / count);
    
    return {
        :mean => mean,
        :median => median,
        :stdDev => stdDev
    };
}

// Draw mean line on chart
var stats = calculateStats();
var meanY = barZoneBottom - ((stats[:mean] / MAX_CADENCE_DISPLAY) * chartHeight);
dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
dc.drawLine(chartLeft, meanY, chartRight, meanY); // Dashed line

// Draw std dev band
var stdDevTop = meanY - (stats[:stdDev] / MAX_CADENCE_DISPLAY) * chartHeight;
var stdDevBottom = meanY + (stats[:stdDev] / MAX_CADENCE_DISPLAY) * chartHeight;
dc.setColor(0xFFFFFF, 0x40); // Semi-transparent white
dc.fillRectangle(chartLeft, stdDevTop, chartWidth, stdDevBottom - stdDevTop);
```

**Display**:
```
┌──────────────────┐
│    ▄▄▄  ▄▄       │
│  ▄████████  ▄    │ ← Std dev band (±5 spm)
├──────────────────┤ ← Mean line (148 spm)
│ ████████████     │
└──────────────────┘

Text overlay: "Avg: 148±5 spm"
```

---

### User Experience Enhancements

#### 9. **Configurable Refresh Rate**
**Priority**: Medium  
**Complexity**: Low  
**Effort**: 1-2 hours  

**Description**: User setting for screen update frequency to balance responsiveness vs. battery

**Settings Options**:
```
Display Refresh Rate:
[ ] Battery Saver (0.5 Hz - every 2 sec)
[✓] Balanced (1 Hz - every 1 sec) [DEFAULT]
[ ] Performance (2 Hz - twice per sec)
```

**Implementation**:
```monkey-c
enum RefreshRate {
    BATTERY_SAVER = 2000,  // 0.5 Hz
    BALANCED = 1000,       // 1 Hz
    PERFORMANCE = 500      // 2 Hz
}

private var _refreshRate = RefreshRate.BALANCED;

function setRefreshRate(rate as RefreshRate) as Void {
    _refreshRate = rate;
    if (_simulationTimer != null) {
        _simulationTimer.stop();
        _simulationTimer.start(method(:refreshScreen), rate, true);
    }
}
```

**Benefits**:
- Ultra-runners can extend battery life
- Interval trainers get higher responsiveness
- User control over performance/battery tradeoff

---

#### 10. **Smart Alerts (Context-Aware)**
**Priority**: Medium  
**Complexity**: High  
**Effort**: 4-5 hours  

**Description**: Intelligent haptic feedback that considers context

**Features**:
```monkey-c
// Don't alert during warm-up period
private const WARMUP_DURATION = 300000; // 5 minutes

// Gradient alert intensity
function triggerCadenceAlert(cadence as Number) as Void {
    var elapsed = System.getTimer() - _sessionStartTime;
    
    // Suppress during warm-up
    if (elapsed < WARMUP_DURATION) { return; }
    
    var deviation = 0;
    if (cadence < _idealMinCadence) {
        deviation = _idealMinCadence - cadence;
    } else if (cadence > _idealMaxCadence) {
        deviation = cadence - _idealMaxCadence;
    }
    
    // Intensity based on deviation
    if (deviation > 10) {
        tripleVibration(); // Urgent
    } else if (deviation > 5) {
        doubleVibration(); // Warning
    } else if (deviation > 0) {
        singleVibration(); // Gentle reminder
    }
}

// Consider terrain (if GPS elevation available)
function adjustZoneForTerrain() as Void {
    var grade = calculateGrade(); // From GPS
    
    if (grade > 5) { // Uphill > 5%
        _adjustedMin = _idealMinCadence - 5;
        _adjustedMax = _idealMaxCadence - 5;
    } else if (grade < -5) { // Downhill > 5%
        _adjustedMin = _idealMinCadence + 5;
        _adjustedMax = _idealMaxCadence + 5;
    }
}
```

---

### Data & Analytics

#### 11. **Export to CSV**
**Priority**: Low  
**Complexity**: Medium  
**Effort**: 3-4 hours  

**Description**: Generate CSV file for external analysis

**Format**:
```csv
Timestamp,Cadence,Zone,HeartRate,Distance,CQ_Score
00:00:06,145,Below,152,0.02,--
00:00:12,148,In,155,0.05,--
00:00:18,151,In,158,0.08,67
...
```

**Implementation**:
```monkey-c
function exportToCSV() as String {
    var csv = "Timestamp,Cadence,Zone,HeartRate,Distance,CQ_Score\n";
    
    for (var i = 0; i < _cadenceCount; i++) {
        var time = formatTime(i * _chartDuration);
        var cadence = _cadenceHistory[i];
        var zone = getZoneLabel(cadence);
        
        csv += time + "," + cadence + "," + zone + "," + 
               getHR(i) + "," + getDist(i) + "," + getCQ(i) + "\n";
    }
    
    return csv;
}
```

**Note**: Garmin devices have limited file I/O. May need to:
- Store in string and copy via Garmin Connect IQ
- Or upload to companion app via Bluetooth

---

### Performance Metrics

#### 12. **Dynamic Memory Management**
**Priority**: Medium  
**Complexity**: High  
**Effort**: 5-6 hours  

**Description**: Adapt buffer sizes based on available memory

**Implementation**:
```monkey-c
function initializeWithMemoryCheck() as Void {
    var stats = System.getSystemStats();
    var freeMemory = stats.freeMemory;
    var totalMemory = stats.totalMemory;
    var usagePercent = (totalMemory - freeMemory) / totalMemory.toFloat();
    
    // Conservative if low memory
    if (freeMemory < 50000 || usagePercent > 0.75) {
        MAX_BARS = 140; // 14 min @ 6 sec/bar
        System.println("[MEMORY] Low memory mode: 140 bars");
    } 
    // Aggressive if plenty of memory
    else if (freeMemory > 200000) {
        MAX_BARS = 560; // 56 min @ 6 sec/bar
        System.println("[MEMORY] Extended mode: 560 bars");
    }
    // Standard
    else {
        MAX_BARS = 280; // 28 min @ 6 sec/bar
    }
    
    _cadenceHistory = new [MAX_BARS];
}
```

**Benefits**:
- Prevents out-of-memory crashes
- Better device compatibility
- Graceful degradation on constrained devices

---

## Implementation Priority Matrix

### 🔴 High Priority ? Maybe
1. **Current Cadence Marker** 
2. **Battery Optimization** 
3. **Chart Rendering Optimization** 

### 🟡 Medium Priority 
4. **Smooth Bars** 
5. **Zone Boundary Lines** 
6. **Configurable Refresh Rate** 
7. **Statistical Overlays** 
8. **Smart Alerts** 

### 🟢 Low Priority 
9. **Fade Old Bars** 
10. **Auto-Adjust Chart Duration** 
11. **CSV Export** 
12. **Dynamic Memory** 

---

## Technical Debt & Code Quality & other ramblign thoughts

### Refactoring Needed
- [ ] Extract chart rendering to `ChartRenderer.mc` class
- [ ] Create `CircularBuffer.mc` reusable class
- [ ] Consolidate color constants into `Colors.mc`
- [ ] Add input validation layer for all settings
- [ ] Document all public methods with JSDoc-style comments

### Testing & Quality
- [ ] Add unit tests for CQ algorithm
- [ ] Add integration tests for state machine
- [ ] Profile memory usage during 2+ hour activities
- [ ] Benchmark chart rendering on FR165 vs FR165 Music
- [ ] Test sensor disconnection recovery

### Performance Profiling Targets
- [ ] Chart draw time: <50ms per frame
- [ ] Memory usage: <5% of total device memory
- [ ] Battery drain: <5% per hour (GPS active)

---

## Debugging Guide

### Common Issues

**Issue**: Timer not pausing
**Cause**: ActivityRecording session not properly controlled
**Solution**: Check `activitySession.stop()` is called on pause

**Issue**: Cadence data not collecting
**Cause**: State not RECORDING or sensor not connected
**Solution**: Verify `_sessionState == RECORDING` and sensor paired

**Issue**: CQ always shows "--"
**Cause**: Less than MIN_CQ_SAMPLES (30) collected
**Solution**: Wait 30 seconds after starting, check sensor connection

**Issue**: Chart not updating
**Cause**: View timer not running or data not flowing
**Solution**: Check `_simulationTimer` started in `onShow()`

### Debug Checklist

1. ✓ `DEBUG_MODE = true` in GarminApp.mc
2. ✓ Watch console for `[INFO]`, `[DEBUG]`, `[CADENCE]` messages
3. ✓ Verify state transitions match expected flow
4. ✓ Check `_cadenceCount` increments when recording
5. ✓ Confirm `activitySession != null` when active
6. ✓ Validate sensor pairing in Garmin Connect app

---

## Version History

**Current Version**: 1.0 (January 2026)

**Changes from Original**:
- ✓ Fixed: Uncommented critical recording check (line 270)
- ✓ Added: Full state machine (IDLE/RECORDING/PAUSED/STOPPED)
- ✓ Added: Pause/Resume functionality
- ✓ Added: Save/Discard workflow
- ✓ Added: Garmin ActivityRecording integration
- ✓ Added: Menu system for activity control
- ✓ Fixed: Timer now properly pauses/resumes
- ✓ Added: Visual state indicators
- ✓ Added: Comprehensive documentation

**Known Limitations**:
- No persistent storage of CQ history
- No lap/split functionality
- No custom alert thresholds
- No data export capability
- Haptic feedback placeholder (device-dependent)

---

## Glossary

**CQ**: Cadence Quality - composite score measuring running efficiency
**FIT File**: Flexible and Interoperable Transfer - Garmin's activity file format
**SPM**: Steps Per Minute - cadence measurement unit
**Circular Buffer**: Fixed-size buffer that wraps when full
**Activity Session**: Garmin's ActivityRecording instance managing timer/sensors
**State Machine**: System that transitions between defined states based on events
**Delegate Pattern**: Separation of input handling from view logic
**MVC**: Model-View-Controller architecture pattern

---

## Credits

**Application**: Garmin Cadence Monitoring App for Forerunner 165
**Platform**: Garmin Connect IQ SDK 8.3.0
**Language**: Monkey C
**Target API**: 5.2.0+
**Documentation Version**: 1.0
**Last Updated**: January 2026
** S
## Special Mentions
**Dom
**Chum
**jack
**Kyle
**Jin


---


