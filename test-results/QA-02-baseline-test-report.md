QA-02: Baseline Testing Report

1. Test Environment

* Test date: 28 November 2026
* Application version: v1.0.4
* Device: Garmin Forerunner 165
* Connect IQ SDK: 9.3.0
* Platform: macOS
* Testing method: Manual simulator testing

2. Objective

The purpose of this testing was to establish a baseline for the Garmin smartwatch application, verify its core functionality and identify any issues that may require further investigation.

3. Test Results

Test ID	Test Case	Actual Result	Status
TC-01	Application launch	Application launched and displayed the main screen.	PASS
TC-02	Start activity	Activity started and the timer began counting.	PASS
TC-03	Pause activity	Activity paused and displayed the Resume and Stop options.	PASS
TC-04	Resume activity	Activity resumed successfully.	PASS
TC-05	Stop and save activity	Activity stopped and the workout summary appeared.	PASS
TC-06	Live activity metrics	Cadence, heart rate, distance and pace were displayed using simulated data.	PASS
TC-07	Workout summary with simulated data	Recorded metrics and QC score appeared in the workout summary.	PASS
TC-08	Settings menu access	Pressing and holding the UP button did not open the settings menu.	FAIL

4. Recorded Metrics

The following values were displayed in the workout summary after testing with simulated activity data:

* Duration: 00:01:15
* Distance: 0.27 km
* Cadence: 100 SPM
* Heart rate: 128 BPM
* Average pace: 4:43 min/km
* QC score: 29%

Steps and temperature were unavailable during testing.

5. Identified Issue

Settings Menu Access

Expected behaviour: Holding the UP button should open the application settings menu.

Actual behaviour: The settings menu did not open after multiple attempts to press and hold the UP button.

Environment: Forerunner 165 simulator, application version v1.0.4.

Recommendation: Investigate the UP button event handling and confirm whether the issue is related to the simulator or the application.

The root cause has not been confirmed. Retrieving the previously saved workout summary through the settings menu could not be verified.

6. Existing Regression Test Results

The existing repository test log dated 22 November 2026 reported:

* Total tests: 39
* Passed: 39
* Failed: 0
* Result: OK

These were existing source-regression checks and were not independently rerun as part of this manual testing session.

7. Overall Results

* Manual test cases: 8
* Passed: 7
* Failed: 1
* Pass rate: 87.5%

8. Limitations

Testing was performed using the Connect IQ simulator rather than a physical Garmin watch. Physical vibration, sensor accuracy, QC calculation accuracy and saved workout retrieval were not independently verified.

9. Conclusion

The baseline testing confirmed that the main activity recording workflow and live metric display were functional in the simulator. One issue was identified with accessing the settings menu using the UP button.

Further investigation is recommended before confirming full application functionality.
