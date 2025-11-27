# garmin-smartwatch
This is an app for the Garmin Forerunner 165, which allows a user to specify a cadence zone and be alerted when their running falls outside the zone.
The watch will vibrate as well as give visual display of the runners progress.

**Compilaton INstructions**
*You must have generated a developer key to compile the build. Then run:*

`monkeyc -o TestingCadence.prg -f monkey.jungle -y developer_key.der -w`

`monkeydo testingCadence.prg fr165`


![This is the version 1 layout of the App:](resources/images/AppInitial.png)

![This si the menu, which allows the user to select the min and max cadence zone values.](resources/images/AppMenu.png)

![This is the App whilst running when the user is out of the Target Zone.](resources/images/AppRunningOutZone.png)

![This is the App whilst running when the user is in the Target Zone.](resources/images/AppRunningInZone.png)

