# WEB-02: FIT Data Summary and Database Design

Garmin Watch project, Web Development stream

Files checked: the 3 sample runs in the `TestingData` folder. Code: `WEB-02_FIT_data_exploration.ipynb`

## 1\. What is in a FIT file

| Data | Part of the file | Available | Notes |
| :---- | :---- | :---- | :---- |
| Date and start time | session | Yes |  |
| Duration | session | Yes | In seconds |
| Distance | record, session | Yes | In metres |
| Speed | record | Yes | In m/s |
| Heart rate | record, session | Yes | In bpm |
| Altitude | record | Yes | In metres |
| Cadence | record, session | Yes | Saved for one foot, so multiply by 2 for steps per minute |
| Height and body mass | user\_profile | Yes | In metres and kg |
| Device model | file\_id | Yes | Saved as a Garmin product ID |
| Stride length | record | No | Not in the sample files |
| Vertical oscillation | record | No | Not in the sample files |
| Ground contact time | record | No | Not in the sample files |
| Target cadence | \- | No | Will come from WCH-13 (Watch stream) |
| Feedback visible or hidden | \- | No | Will come from WCH-13 (Watch stream) |
| GPS position | record | Yes | Must be removed |
| Watch serial number | file\_id | Yes | Must be removed |

## 2\. Key findings

1. Cadence is saved for one foot. Multiply by 2 to get steps per minute.  
2. The sample files do not have running dynamics (stride length, vertical oscillation, ground contact time). We need a new test file from a watch that records them, for example a Forerunner 165\.  
3. Data is saved every 3 to 7 seconds, not every second. 1-second recording would make the feedback visible vs hidden graph more accurate.  
4. When the runner stops, cadence drops to 0\. These points should be ignored in averages and % in zone.  
5. No runner name was found, but GPS and the watch serial number could identify a runner, so both must be removed.

## 3\. Database design

Two tables: one row per run, and one row per data point.

### Table: runs

| Column | Type | Example |
| :---- | :---- | :---- |
| id | integer, primary key | 1 |
| runner\_id | text, entered by the user | R001 |
| device\_model | text | fr165 |
| start\_time | date and time | 2026-11-20 07:49 |
| duration\_s | number | 1244 |
| distance\_m | number | 4025 |
| avg\_cadence\_spm | number | 154 |
| avg\_heart\_rate | number | 162 |
| height\_m | number, optional | 1.81 |
| body\_mass\_kg | number, optional | 90 |
| target\_cadence\_spm | number, optional | 160 |
| pct\_in\_zone\_visible | number, optional | 92 |
| pct\_in\_zone\_hidden | number, optional | 78 |
| uploaded\_at | date and time | added by the backend |

### Table: run\_points

| Column | Type | Notes |
| :---- | :---- | :---- |
| id | integer, primary key |  |
| run\_id | integer | Links to runs.id |
| elapsed\_s | number | Seconds since the start of the run |
| cadence\_spm | number |  |
| speed\_mps | number |  |
| heart\_rate | number |  |
| distance\_m | number |  |
| altitude\_m | number |  |
| stride\_length\_m | number, optional | When available |
| vertical\_oscillation\_cm | number, optional | When available |
| ground\_contact\_ms | number, optional | When available |
| feedback\_visible | true or false, optional | From WCH-13 |

Not stored: names, GPS coordinates or the watch serial number.

These two tables cover the run summary, the feedback visible vs hidden graph, the running dynamics charts and all the CSV columns the Product Owners asked for.

## 4\. Previous work

The `develop` branch has an ML notebook and a Power BI dashboard from Trimester 1, 2026\. Both use a public running dataset (`cardioActivities.csv`), not FIT files from the watch. This is the first analysis of the app's own FIT data.

## 5\. Next steps

- Get a test FIT file with running dynamics from the Watch or Testing stream.  
- Ask Nick about 1-second recording and the WCH-13 fields.  
- Share this database design with Jia for WEB-09.