using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;

class AtelierView extends WatchUi.WatchFace {
    private const INK = 0xF3F1E7;
    private const ACCENT = 0xD9FF57;
    private const MUTED = 0x969A90;
    private const TRACK = 0x2C302A;
    private const AOD = 0x55584F;

    private var _w;
    private var _h;
    private var _cx;
    private var _m;
    private var _fTime;
    private var _fValue;
    private var _fSmall;
    private var _fTiny;
    private var _timeY;
    private var _metricsY;
    private var _lowPower = false;

    function initialize() { WatchFace.initialize(); }

    function onLayout(dc) {
        _w = dc.getWidth();
        _h = dc.getHeight();
        _cx = _w / 2;
        _m = 24;
        _fTime = Graphics.FONT_SYSTEM_NUMBER_HOT;
        _fValue = Graphics.FONT_MEDIUM;
        _fSmall = Graphics.FONT_SMALL;
        _fTiny = Graphics.FONT_XTINY;
        _timeY = 132;
        _metricsY = 276;
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (_lowPower) {
            drawAlwaysOn(dc);
        } else {
            drawFull(dc);
        }
    }

    function drawFull(dc) {
        var clock = System.getClockTime();
        var hour = displayHour(clock.hour);
        var timeText = Lang.format("$1$:$2$", [hour.format("%02d"), clock.min.format("%02d")]);

        drawHeader(dc);

        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx, _timeY, _fTime, timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        drawRule(dc);
        drawMetrics(dc);
        drawStepProgress(dc);
    }

    function drawHeader(dc) {
        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateText = getDayName(date.day_of_week) + "  " + date.day.format("%02d") + " " + getMonthName(date.month);

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_m, 22, _fTiny, dateText, Graphics.TEXT_JUSTIFY_LEFT);

        var stats = System.getSystemStats();
        var battery = (stats != null && stats.battery != null) ? stats.battery : 0;
        var batteryText = battery.format("%d") + "%";
        var batteryW = dc.getTextWidthInPixels(batteryText, _fTiny);
        dc.setColor(ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_w - _m - batteryW - 10, 34, 3);
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_w - _m, 22, _fTiny, batteryText, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawRule(dc) {
        var y = 206;
        dc.setColor(TRACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_m, y, _w - (_m * 2), 2);
        dc.setColor(ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_m, y, 42, 2);
    }

    function drawMetrics(dc) {
        var activity = ActivityMonitor.getInfo();
        var steps = (activity != null && activity.steps != null) ? activity.steps : 0;
        var heart = "--";
        var current = Activity.getActivityInfo();
        if (current != null && current.currentHeartRate != null) {
            heart = current.currentHeartRate.format("%d");
        }

        var leftX = _m;
        var rightX = _cx + 16;

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(leftX, _metricsY - 56, _fTiny, "STEPS", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(rightX, _metricsY - 56, _fTiny, "PULSE", Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(leftX, _metricsY, _fSmall, compactNumber(steps),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(rightX, _metricsY, _fSmall, heart,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_w - _m, _metricsY - 13, _fTiny, "BPM", Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(TRACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_cx - 1, _metricsY - 56, 2, 80);
    }

    function drawStepProgress(dc) {
        var activity = ActivityMonitor.getInfo();
        var steps = (activity != null && activity.steps != null) ? activity.steps : 0;
        var goal = (activity != null && activity.stepGoal != null && activity.stepGoal > 0) ? activity.stepGoal : 10000;
        var pct = steps.toFloat() / goal.toFloat();
        if (pct < 0.0) { pct = 0.0; }
        if (pct > 1.0) { pct = 1.0; }

        var labelY = 312;
        var barY = 350;
        var width = _w - (_m * 2);
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_m, labelY, _fTiny, "MOVE GOAL", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(_w - _m, labelY, _fTiny, (pct * 100).toNumber().format("%d") + "%", Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(TRACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_m, barY, width, 5);
        dc.setColor(ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_m, barY, (width * pct).toNumber(), 5);
    }

    function drawAlwaysOn(dc) {
        var clock = System.getClockTime();
        var hour = displayHour(clock.hour);
        var timeText = Lang.format("$1$:$2$", [hour.format("%02d"), clock.min.format("%02d")]);
        var dx = ((clock.min % 3) - 1) * 2;
        var dy = (((clock.min / 3).toNumber() % 3) - 1) * 2;
        dc.setColor(AOD, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx + dx, _timeY + dy, _fTime, timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function displayHour(hour) {
        if (!System.getDeviceSettings().is24Hour) {
            if (hour == 0) { return 12; }
            if (hour > 12) { return hour - 12; }
        }
        return hour;
    }

    function compactNumber(value) {
        if (value >= 10000) { return (value / 1000).format("%d") + "K"; }
        if (value >= 1000) {
            var whole = value / 1000;
            var decimal = (value % 1000) / 100;
            return whole.format("%d") + "." + decimal.format("%d") + "K";
        }
        return value.format("%d");
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
