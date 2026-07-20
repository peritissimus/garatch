using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.SensorHistory;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;
using Toybox.Weather;

class TelemetryView extends WatchUi.WatchFace {
    private const INK = 0xF3F0E6;
    private const MUTED = 0x9B978C;
    private const AMBER = 0xE7A74E;
    private const MINT = 0x72D6B2;
    private const GRID = 0x2C2B27;
    private const TRACK = 0x242723;
    private const AOD = 0x55534D;

    private var _w;
    private var _h;
    private var _cx;
    private var _fTime;
    private var _fValue;
    private var _fLabel;
    private var _lowPower = false;
    private var _stress = null;
    private var _bodyBattery = null;
    private var _oxygen = null;
    private var _temperatureC = null;
    private var _slowDataStamp = -1;

    function initialize() { WatchFace.initialize(); }

    function onLayout(dc) {
        _w = dc.getWidth();
        _h = dc.getHeight();
        _cx = _w / 2;
        _fTime = WatchUi.loadResource(Rez.Fonts.TelemetryTime);
        _fValue = WatchUi.loadResource(Rez.Fonts.TelemetryValue);
        _fLabel = WatchUi.loadResource(Rez.Fonts.TelemetryLabel);
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (_lowPower) {
            drawAlwaysOn(dc);
            return;
        }

        refreshSlowData();

        var monitor = ActivityMonitor.getInfo();
        var steps = (monitor != null && monitor.steps != null) ? monitor.steps : 0;
        var goal = (monitor != null && monitor.stepGoal != null && monitor.stepGoal > 0) ? monitor.stepGoal : 10000;
        var calories = (monitor != null && monitor.calories != null) ? monitor.calories : 0;
        var stress = _stress;
        if (monitor != null && (monitor has :stressScore) && monitor.stressScore != null) {
            stress = monitor.stressScore;
        }

        var heart = null;
        var current = Activity.getActivityInfo();
        if (current != null && current.currentHeartRate != null) {
            heart = current.currentHeartRate;
        }
        if (current != null && (current has :currentOxygenSaturation) && current.currentOxygenSaturation != null) {
            _oxygen = current.currentOxygenSaturation;
        }

        var stats = System.getSystemStats();
        var battery = (stats != null && stats.battery != null) ? stats.battery : 0;

        drawHeader(dc, battery);
        drawTime(dc);
        drawDashboard(dc, steps, goal, heart, stress, calories);
    }

    function drawHeader(dc, battery) {
        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateText = getDayName(date.day_of_week) + " " + date.day.format("%02d") + " " + getMonthName(date.month);

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(20, 22, _fLabel, dateText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        var tempText = (_temperatureC == null) ? "--" : displayTemperature(_temperatureC).format("%d");
        var tempWidth = dc.getTextWidthInPixels(tempText, _fLabel);
        var tempX = _cx - 4;
        dc.drawText(tempX, 22, _fLabel, tempText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setPenWidth(2);
        dc.drawCircle(tempX + tempWidth + 4, 16, 3);
        dc.setPenWidth(1);

        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_w - 20, 22, _fLabel, battery.format("%d") + "%",
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawTime(dc) {
        var clock = System.getClockTime();
        var hour = displayHour(clock.hour);
        var timeText = Lang.format("$1$:$2$", [hour.format("%02d"), clock.min.format("%02d")]);
        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx, 101, _fTime, timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawDashboard(dc, steps, goal, heart, stress, calories) {
        dc.setColor(AMBER, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(20, 158, _w - 40, 2);
        dc.drawText(20, 178, _fLabel, "DAILY TELEMETRY",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(GRID, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(107, 198, 107, 350);
        dc.drawLine(213, 198, 213, 350);
        dc.drawLine(20, 278, _w - 20, 278);

        var c1 = 53;
        var c2 = 160;
        var c3 = 267;
        var heartText = (heart == null) ? "--" : heart.format("%d");
        var bodyText = (_bodyBattery == null) ? "--" : _bodyBattery.format("%d");
        var stressText = (stress == null) ? "--" : stress.format("%d");
        var oxygenText = (_oxygen == null) ? "--" : _oxygen.format("%d");

        drawMetric(dc, c1, 215, 249, "STEPS", formatNumber(steps), "");
        drawMetric(dc, c2, 215, 249, "HEART", heartText, "BPM");
        drawMetric(dc, c3, 215, 249, "BODY", bodyText, "");
        drawMicroBar(dc, 20, 269, 66, clamp01(steps.toFloat() / goal.toFloat()), MINT);
        drawMicroBar(dc, 234, 269, 66, (_bodyBattery == null) ? 0.0 : clamp01(_bodyBattery.toFloat() / 100.0), AMBER);

        drawMetric(dc, c1, 299, 331, "STRESS", stressText, "");
        drawMetric(dc, c2, 299, 331, "SPO2", oxygenText, "%");
        drawMetric(dc, c3, 299, 331, "KCAL", calories.format("%d"), "");
    }

    function drawMetric(dc, centerX, labelY, valueY, label, value, unit) {
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, labelY, _fLabel, label,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if (unit.length() == 0) {
            dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, valueY, _fValue, value,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        var valueW = dc.getTextWidthInPixels(value, _fValue);
        var unitW = dc.getTextWidthInPixels(unit, _fLabel);
        var gap = 3;
        var startX = centerX - ((valueW + gap + unitW) / 2);
        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, valueY, _fValue, value,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX + valueW + gap, valueY + 5, _fLabel, unit,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawMicroBar(dc, x, y, width, pct, color) {
        dc.setColor(TRACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, width, 3);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, (width * pct).toNumber(), 3);
    }

    function refreshSlowData() {
        var clock = System.getClockTime();
        var stamp = (clock.hour * 60) + clock.min;
        if (stamp == _slowDataStamp) { return; }
        _slowDataStamp = stamp;
        _stress = readLatestStress();
        _bodyBattery = readLatestBodyBattery();
        _oxygen = readLatestOxygen();
        _temperatureC = readTemperature();
    }

    function readLatestStress() {
        try {
            if (!(Toybox has :SensorHistory) || !(SensorHistory has :getStressHistory)) { return null; }
            var iterator = SensorHistory.getStressHistory({
                :period => 1,
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            if (iterator != null) {
                var sample = iterator.next();
                if (sample != null && sample.data != null) { return sample.data; }
            }
        } catch (ex) {}
        return null;
    }

    function readLatestBodyBattery() {
        try {
            if (!(Toybox has :SensorHistory) || !(SensorHistory has :getBodyBatteryHistory)) { return null; }
            var iterator = SensorHistory.getBodyBatteryHistory({
                :period => 1,
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            if (iterator != null) {
                var sample = iterator.next();
                if (sample != null && sample.data != null) { return sample.data; }
            }
        } catch (ex) {}
        return null;
    }

    function readLatestOxygen() {
        try {
            if (!(Toybox has :SensorHistory) || !(SensorHistory has :getOxygenSaturationHistory)) { return null; }
            var iterator = SensorHistory.getOxygenSaturationHistory({
                :period => 1,
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            if (iterator != null) {
                var sample = iterator.next();
                if (sample != null && sample.data != null) { return sample.data; }
            }
        } catch (ex) {}
        return null;
    }

    function readTemperature() {
        try {
            if ((Toybox has :Weather) && (Weather has :getCurrentConditions)) {
                var conditions = Weather.getCurrentConditions();
                if (conditions != null && conditions.temperature != null) { return conditions.temperature; }
            }
        } catch (ex) {}
        return null;
    }

    function displayTemperature(celsius) {
        var settings = System.getDeviceSettings();
        if (settings != null && settings.temperatureUnits == System.UNIT_STATUTE) {
            return ((celsius * 9.0 / 5.0) + 32.0).toNumber();
        }
        return celsius.toNumber();
    }

    function drawAlwaysOn(dc) {
        var clock = System.getClockTime();
        var hour = displayHour(clock.hour);
        var timeText = Lang.format("$1$:$2$", [hour.format("%02d"), clock.min.format("%02d")]);
        var dx = ((clock.min % 3) - 1) * 2;
        var dy = (((clock.min / 3).toNumber() % 3) - 1) * 2;
        dc.setColor(AOD, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx + dx, 175 + dy, Graphics.FONT_SYSTEM_NUMBER_MEDIUM, timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function displayHour(hour) {
        var settings = System.getDeviceSettings();
        if (settings != null && !settings.is24Hour) {
            if (hour == 0) { return 12; }
            if (hour > 12) { return hour - 12; }
        }
        return hour;
    }

    function formatNumber(value) {
        var raw = value.format("%d");
        var result = "";
        var count = 0;
        for (var i = raw.length() - 1; i >= 0; i--) {
            if (count > 0 && (count % 3) == 0) { result = "," + result; }
            result = raw.substring(i, i + 1) + result;
            count++;
        }
        return result;
    }

    function clamp01(value) {
        if (value < 0.0) { return 0.0; }
        if (value > 1.0) { return 1.0; }
        return value;
    }

    function getDayName(day) {
        return ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"][day - 1];
    }

    function getMonthName(month) {
        return ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"][month - 1];
    }

    function onEnterSleep() { _lowPower = true; WatchUi.requestUpdate(); }
    function onExitSleep() { _lowPower = false; WatchUi.requestUpdate(); }
    function onHide() {}
}
