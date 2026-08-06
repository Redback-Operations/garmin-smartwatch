# garmin-smartwatch

This project is a **custom Garmin Connect IQ watch app** designed for the **Garmin Forerunner 165**, focused on **cadence-based running feedback**.

The app allows runners to define a **target cadence zone** and receive:

- Real-time visual feedback  
- Haptic alerts when cadence falls outside the target zone  
- Live run metrics including cadence, heart rate, distance, and time  

The goal is to support **cadence awareness and consistency during runs** without overwhelming the runner with complex data.

---

## ✨ Core Features

### 🏃‍♂️ Target Cadence
- User-defined **target cadence value**
- The app automatically creates a ±5spm tolerance zone around this value
- Clear **in-zone / out-of-zone** visual feedback via cadence graph colour coding:
    - 🔴 Red = below target
    - 🟢 Green = within range

### 🔔 Real-Time Alerts
- Visual popup when cadence crosses zone boundaries, displaying:
    - Elapsed timer
    - Yellow warning triangle
    - "Increase Cadence" or "Decrease Cadence" message
    - Vibration ON/OFF status
    - Auto-dismisses after 3 seconds
- Haptic alerts when cadence drops below the target zone
- Single vibration for low cadence

### 📊 Live Run Metrics
- Cadence  
- Heart rate  
- Distance  
- Elapsed time
- Pace (min/km)

### ⏺️ Activity Recording Flow
- From the main screen, tap the screen to be prompted to start a recording
- Press START to begin recording, or BACK to cancel
- Tap the screen again during a recording to open the recording menu (Resume / Pause / Stop)
- Selecting Stop prompts you to save the activity (yes/no)
- Selecting Yes takes you to the summary screen

### 📋 Summary Screen
- Displayed after saving a completed activity, showing:
    - Time
    - Pace
    - Distance
    - Average cadence
    - Cadence Quality

### 🔕 Vibration Toggle
- Double tap the UP button on the main screen to quickly toggle haptic alerts on or off
- Full-screen feedback confirms the new state:
    - 🟢 Green = vibration ON
    - 🔴 Red = vibration OFF
- Pending vibrations are cancelled immediately when disabled

---

### ⚙️ Settings Menu
- Accessible by holding the UP button from the main screen. Scroll between the following screens using UP/DOWN:

### 🎯 Set Cadence Target
- Set your target cadence value in spm (steps per minute)
- Use UP/DOWN to adjust the value by ±1
- Press START to confirm

### 📊 Change Bar Chart Length
- Set the duration of the cadence bar chart displayed during a run
- Options: 15 min, 30 min, 1 hour, 2 hours
- Use UP/DOWN to cycle through options
- Press START to confirm

### 👁️ Summary View ON/OFF
- Toggle the post-run summary screen on or off

---
## 🧠 Experimental Feature: Cadence Quality (CQ)

This project includes an **experimental metric** called **Cadence Quality (CQ)**, designed to provide a **higher-level assessment of cadence consistency** over the course of a run.

Unlike instantaneous cadence alerts, Cadence Quality evaluates cadence **over time**, capturing not just whether the runner hits the target zone, but **how consistently and smoothly** they do so.

> **Cadence Quality is a pilot research-style metric**, not a clinical or prescriptive measure.

---

## 📐 How Cadence Quality Works

Cadence Quality is a **composite score (0–100)** derived from two components:

### 1️⃣ Time-in-Zone
- The proportion of recent cadence samples that fall within the configured cadence range
- Rewards sustained adherence to the target cadence

### 2️⃣ Cadence Smoothness
- Measures how stable cadence is between consecutive samples
- Large fluctuations reduce the smoothness score

### 🧮 Weighting Formula

```text
Cadence Quality = (Time-in-Zone × 70%) + (Cadence Smoothness × 30%)
`````
This weighting reflects research priorities where consistency matters more than momentary precision.

---

## ⏱️ Warm-Up Window
To reduce early-run noise:

- CQ is withheld during the initial warm-up period
- A minimum data window (~30 seconds) must be collected before CQ is computed
- During this phase, the UI displays:

```text
CQ: --
`````
This prevents misleading early scores caused by sensor stabilization and pacing adjustments.

---

## ❄️ Frozen Final Score
- CQ is computed live during cadence monitoring
- When monitoring stops, the final CQ score is frozen
- This produces one evaluative score for the completed session

This mirrors how higher-level performance metrics are treated in research and commercial running analytics.

## 🧩 UI Integration (Easter Egg)
Cadence Quality is intentionally designed as a secondary, low-salience metric:
- Visible during cadence monitoring
- Hidden during warm-up
- Displays final frozen score after monitoring ends

This positions CQ as an advanced insight for curious or research-oriented users, without distracting from core cadence feedback.

## 🧪 Debugging & Diagnostics (Team Update Integration)
Significant development time was spent on debugging, validation, and traceability of the CQ metric.

### What Was Added / Refined
- Implemented Cadence Quality (CQ) as a new metric alongside live cadence
- Built a debug + diagnostic flow so CQ behaviour is visible and traceable in the terminal:
    - Warm-up phase
    - Live CQ values
    - Final frozen summary
- Added a warm-up phase to prevent early noisy calculations
- Implemented final CQ freezing when cadence monitoring stops
- Added CQ confidence levels:
    - High
    - Medium
    - Low
    Based on cadence data completeness
- Added a CQ trend indicator:
    - Improving
    - Stable
    - Declining
    Using a rolling window of recent CQ values
- Refactored start/stop logic so:
    - Cadence monitoring is explicit
    - Nothing runs in the background unintentionally
- Ensured everything remains within Watch App constraints:
    - No activity recording
    - No FIT file generation

    ### Memory & Timing Validation

Validating the **runtime stability, timer accuracy, and application lifecycle behaviour** of the cadence monitoring system. 
---

### Timer Accuracy (1-Second Tick Validation)

Cadence sampling is driven by a repeating timer configured to execute at a strict **1-second interval**, ensuring predictable data collection and UI updates.

//monkeyc
globalTimer = new Timer.Timer();
globalTimer.start(method(:updateCadenceBarAvg), 1000, true);

Evidence:
Simulator terminal logs showing repeated [TIMER] Tick messages at 1-second intervals.

### Memory Stress Testing (200+ Timer Cycles)

The application was stress tested across 200+ timer cycles while cadence monitoring remained active. Memory diagnostics were periodically logged during runtime to detect leaks or heap growth.

Observed results:

-Stable memory usage (~5–6% of available heap)
-No monotonic increase in memory consumption
-No crashes or garbage collection pressure

This confirms that timer callbacks, cadence buffers, and Cadence Quality computations do not introduce memory leaks.

Evidence:
Simulator logs displaying consistent [MEMORY] Runtime values after extended execution.

###Application Lifecycle Validation (Startup, Pause, Shutdown)

Correct lifecycle handling was validated to ensure safe resource management and prevent unintended background execution.

-Timer initialised during application startup
-Activity safely paused via user interaction
-Timer explicitly stopped and released during application shutdown

Simulator logs confirmed clean startup, correct pause behaviour, and graceful shutdown with no residual timer activity.

Evidence:
Logs showing pause events followed by clean application termination.

## 🎯 Why Cadence Quality Matters

Cadence Quality measures **how consistently and smoothly** a runner maintains cadence within an ideal range — not just how fast they step.

This is important because:

- Consistent cadence is linked to **running efficiency**
- Smooth cadence transitions reduce **impact stress**
- Variability in cadence has been associated with **injury risk**
- Stakeholders benefit from **interpretable, higher-level insights** rather than raw sensor noise

CQ is therefore positioned as a **research-aligned exploratory metric** with clear future potential.

---

## 🧠 Abandoned Experiment: “Hardcore Mode” (Postmortem)

An attempted hidden **“hardcore mode” Easter egg** was explored, intended to:

- Dynamically tighten cadence thresholds
- Adapt difficulty for advanced users

However:

- This introduced **significant platform constraints**
- Required shifting from a **Watch App → Activity App**
- Had broader implications than initially anticipated
- Ultimately delayed progress and was rolled back

This served as a valuable lesson in **Connect IQ platform boundaries** and **app-type tradeoffs**.

---

## 🛠️ Compilation Instructions

You must generate your own **Garmin developer key** before compiling.

From the project root:

```

```monkeyc -o TestingCadence.prg -f monkey.jungle -y developer_key.der -w

Run in the simulator:

```
monkeydo TestingCadence.prg fr165
```

If fr165 is not available in your SDK version, a similar device (e.g. venu2) can be used for simulation.

## 📌 Notes
- Cadence Quality is experimental and intended for exploration and research
- Thresholds, confidence bands, and weightings are configurable
- The system is designed for iteration, validation, and future expansion
