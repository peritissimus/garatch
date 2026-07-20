# Data Sources & APIs

Always guard for `null` — every info object and its fields can be null on device or in the simulator.

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
