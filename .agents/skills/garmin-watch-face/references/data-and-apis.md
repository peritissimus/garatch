# Data Sources & APIs

Always guard for `null` — every info object and its fields can be null on device or in the simulator.

## Venu SQ 2 metric inventory

The installed `venusq2` device API and Garmin's official API docs expose the following watch-face-relevant data. Availability still depends on permissions, firmware, user settings, sensor wear, phone sync, wheelchair mode, and a non-null sample.

### Daily activity (`ActivityMonitor.getInfo()`)

- Steps and step goal
- Distance
- Calories
- Floors climbed, floors goal, floors descended
- Meters climbed and descended
- Move-bar level
- Active minutes today (moderate, vigorous, total)
- Active minutes this week and weekly goal
- Current respiration rate
- Current stress score
- Recovery time
- Wheelchair pushes, push goal, and push distance

### Current and historical wellness

- Current heart rate (`Activity.getActivityInfo().currentHeartRate`)
- Current oxygen saturation (`currentOxygenSaturation`)
- Heart-rate history (`SensorHistory.getHeartRateHistory`)
- Body Battery history (`getBodyBatteryHistory`)
- Stress history (`getStressHistory`)
- Oxygen-saturation history (`getOxygenSaturationHistory`)
- Wrist-temperature history (`getTemperatureHistory`)

The Venu SQ 2 device API contains these five SensorHistory methods. Do not assume elevation or pressure history just because the generic SensorHistory documentation lists them; use `has` guards and the device API.

### Device and connectivity

- Battery percentage, battery days remaining, and charging state
- Phone connected / communication available
- Active notification count
- Alarm count
- 12/24-hour preference and date/time

### Weather (`Weather`, cached from phone/provider)

- Current condition and temperature
- Feels-like, daily high and low
- Humidity and precipitation chance
- Wind speed and bearing
- On newer API/firmware where present: cloud cover, dew point, pressure, UV index, visibility
- Hourly and daily forecast objects

### Profile-derived data

- Resting and average resting heart rate
- Heart-rate zones and max heart rate
- User profile fields such as age/birth year, height, weight, and gender when permission is granted

### Design rule

Do not display the whole inventory simultaneously. Choose 4–8 primary metrics, then make the remaining fields configurable. A strong default for a wellness face is steps, heart rate, Body Battery, stress, SpO2, calories, weather, and device battery.

The six-cell layout validated in `garatch-telemetry` uses steps, current heart rate, Body Battery, stress, SpO2, and calories, with temperature and device battery in the header. Keep units smaller than values and render unavailable metrics as `--` without collapsing the grid.

Official references: [Quantifying the user](https://developer.garmin.com/connect-iq/core-topics/quantifying-the-user/), [ActivityMonitor.Info](https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityMonitor/Info.html), [SensorHistory](https://developer.garmin.com/connect-iq/api-docs/Toybox/SensorHistory.html), [Weather.CurrentConditions](https://developer.garmin.com/connect-iq/api-docs/Toybox/Weather/CurrentConditions.html), [System.DeviceSettings](https://developer.garmin.com/connect-iq/api-docs/Toybox/System/DeviceSettings.html), and [System.Stats](https://developer.garmin.com/connect-iq/api-docs/Toybox/System/Stats.html).

## Time & date

```monkeyc
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

var clockTime = System.getClockTime();          // .hour .min .sec (local, 24h)
var is24 = System.getDeviceSettings().is24Hour; // convert to 12h if false

var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
// info.day (1-31), info.month (1-12), info.day_of_week (1=Sun..7=Sat)
```
12-hour conversion: if `!is24`, `hour==0 -> 12`, `hour>12 -> hour-12`.

## Steps & activity goals

```monkeyc
using Toybox.ActivityMonitor;
var info = ActivityMonitor.getInfo();
var steps    = (info != null && info.steps != null)    ? info.steps    : 0;
var stepGoal = (info != null && info.stepGoal != null && info.stepGoal != 0) ? info.stepGoal : 10000;
// also: info.calories, info.distance (cm), info.floorsClimbed, info.activeMinutesWeek
```

## Heart rate — current value

```monkeyc
using Toybox.Activity;
var hr = "--";
var act = Activity.getActivityInfo();
if (act != null && act.currentHeartRate != null) {
    hr = act.currentHeartRate.format("%d");
}
```

The Venu SQ 2 simulator may leave `currentHeartRate` null even while ActivityMonitor and SensorHistory values are populated. This is a valid fallback test. Do not hardcode sample HR in production code; verify the live value on a physical watch.

## SpO2 — current with history fallback

```monkeyc
var oxygen = null;
var act = Activity.getActivityInfo();
if (act != null && (act has :currentOxygenSaturation) && act.currentOxygenSaturation != null) {
    oxygen = act.currentOxygenSaturation;
}
if (oxygen == null && (Toybox has :SensorHistory) &&
        (SensorHistory has :getOxygenSaturationHistory)) {
    var iter = SensorHistory.getOxygenSaturationHistory({
        :period => 1,
        :order => SensorHistory.ORDER_NEWEST_FIRST
    });
    if (iter != null) {
        var sample = iter.next();
        if (sample != null && sample.data != null) { oxygen = sample.data; }
    }
}
```

Use the same newest-sample pattern for stress and Body Battery. Wrap optional history calls in `try/catch` when one face spans firmware/API variations.

Do not attempt generic reflection such as `SensorHistory.method(methodName).invoke(...)`: `SensorHistory` has no `method` symbol and Monkey C compilation fails. Write explicit guarded functions for `getStressHistory`, `getBodyBatteryHistory`, and `getOxygenSaturationHistory`.

## Cache slow data

Weather and newest SensorHistory samples do not need a per-second read. Cache them and refresh once per minute:

```monkeyc
var clock = System.getClockTime();
var stamp = (clock.hour * 60) + clock.min;
if (stamp != _slowDataStamp) {
    _slowDataStamp = stamp;
    _stress = readLatestStress();
    _bodyBattery = readLatestBodyBattery();
    _oxygen = readLatestOxygen();
    _temperatureC = readTemperature();
}
```

## Heart rate — REAL history graph (replaces the fake one)

`garatch-minimal`'s `drawHrGraph` currently **fabricates** a zig-zag from `hrVal % 6`. Replace it with real samples. Manifest already grants `SensorHistory`.

```monkeyc
using Toybox.SensorHistory;
using Toybox.ActivityMonitor;

// Returns an iterator of samples, newest first. Guard: SensorHistory may be
// absent on some devices → wrap in `has` check.
function getHrSamples(count) {
    var samples = [];
    if ((Toybox has :SensorHistory) && (SensorHistory has :getHeartRateHistory)) {
        var iter = SensorHistory.getHeartRateHistory({
            :period => count,
            :order  => SensorHistory.ORDER_NEWEST_FIRST
        });
        if (iter != null) {
            var s = iter.next();
            while (s != null && samples.size() < count) {
                if (s.data != null) { samples.add(s.data); }  // s.data = bpm, s.when = Moment
                s = iter.next();
            }
        }
    }
    return samples;   // newest-first; reverse before plotting left→right
}
```

Fallback for devices without `SensorHistory`: `ActivityMonitor.getHeartRateHistory(count, newestFirst)` (also an iterator of `ActivityMonitor.HeartRateSample`, `.heartRate` field, `INVALID_HR_SAMPLE` for gaps).

**Plotting:** collect samples → drop nulls/`INVALID_HR_SAMPLE` → compute min/max → map each to the graph box `[x0..x0+graphW] × [y0-graphH..y0]` → connect with `drawLine` at `setPenWidth(2)`. Reverse the newest-first array so time runs left→right.

## Battery

```monkeyc
var stats = System.getSystemStats();
var bat = (stats != null && stats.battery != null) ? stats.battery : 0; // float 0-100
// stats.batteryInDays also available on some devices
```
Minimal face draws a battery glyph + `"NN%"` — see `drawBattery`.

## User profile (needs UserProfile permission)

```monkeyc
using Toybox.UserProfile;
var prof = UserProfile.getProfile();     // .restingHeartRate, .heartRateZones(sport), etc.
```

## Weather (needs a permission + newer SDK)

```monkeyc
using Toybox.Weather;
var cond = Weather.getCurrentConditions(); // .temperature (°C), .condition, .windSpeed …
```
Add `<iq:uses-permission id="..."/>` and bump `minSdkVersion` if you use this.

## `has` guards — device capability checks

Not every API exists on every device. Guard optional APIs:
```monkeyc
if (Toybox has :SensorHistory) { ... }
if (act has :currentHeartRate && act.currentHeartRate != null) { ... }
```
This keeps one codebase compiling/running across products.
