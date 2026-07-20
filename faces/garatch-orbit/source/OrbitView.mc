using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;

class OrbitView extends WatchUi.WatchFace {
    private const INK = 0xF4F2EB;
    private const ACCENT = 0x78E7C7;
    private const MUTED = 0x737873;
    private const TRACK = 0x202522;
    private const AOD = 0x4A514E;

    private var _w;
    private var _h;
    private var _cx;
    private var _m;
    private var _fTime;
    private var _fValue;
    private var _fSmall;
    private var _fTiny;
    private var _fAod;
    private var _timeY;
    private var _dateY;
    private var _lineY;
    private var _footerY;
    private var _aodY;
    private var _leftMetricX;
    private var _rightMetricX;
    private var _lowPower = false;

    function initialize() { WatchFace.initialize(); }

    function onLayout(dc) {
        _w = dc.getWidth();
        _h = dc.getHeight();
        _cx = _w / 2;
        _m = 30;
        _fTime = WatchUi.loadResource(Rez.Fonts.OrbitValue);
        _fValue = WatchUi.loadResource(Rez.Fonts.OrbitHero);
        _fSmall = WatchUi.loadResource(Rez.Fonts.OrbitValue);
        _fTiny = WatchUi.loadResource(Rez.Fonts.OrbitLabel);
        _fAod = Graphics.FONT_SYSTEM_NUMBER_MEDIUM;
        _timeY = 34;
        _dateY = 40;
        _lineY = 222;
        _footerY = 264;
        _aodY = (_h * 0.44).toNumber();
        _leftMetricX = _w / 4;
        _rightMetricX = (_w * 3) / 4;
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

        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateText = getDayName(date.day_of_week) + "  " + date.day.format("%02d") + " " + getMonthName(date.month);
        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_m, _timeY, _fTime, timeText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_w - _m, _dateY, _fTiny, dateText,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        drawHeroMetric(dc);
        drawProgress(dc);
        drawFooter(dc);
    }

    function drawHeroMetric(dc) {
        var activity = ActivityMonitor.getInfo();
        var steps = (activity != null && activity.steps != null) ? activity.steps : 0;
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx, 94, _fTiny, "TODAY'S STEPS",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx, 163, _fValue, formatNumber(steps),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawProgress(dc) {
        var activity = ActivityMonitor.getInfo();
        var steps = (activity != null && activity.steps != null) ? activity.steps : 0;
        var goal = (activity != null && activity.stepGoal != null && activity.stepGoal > 0) ? activity.stepGoal : 10000;
        var progress = steps.toFloat() / goal.toFloat();
        if (progress < 0.0) { progress = 0.0; }
        if (progress > 1.0) { progress = 1.0; }

        var lineW = _w - (_m * 2);
        dc.setColor(TRACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_m, _lineY, lineW, 2);
        dc.setColor(ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_m, _lineY, (lineW * progress).toNumber(), 2);
    }

    function drawFooter(dc) {
        var activity = ActivityMonitor.getInfo();
        var steps = (activity != null && activity.steps != null) ? activity.steps : 0;
        var calories = (activity != null && activity.calories != null) ? activity.calories : 0;
        var heart = "--";
        var current = Activity.getActivityInfo();
        if (current != null && current.currentHeartRate != null) {
            heart = current.currentHeartRate.format("%d");
        }

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_leftMetricX, _footerY, _fTiny, "HEART RATE",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(_rightMetricX, _footerY, _fTiny, "CALORIES",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        drawMetricValue(dc, _leftMetricX, _footerY + 38, heart, "BPM");
        drawMetricValue(dc, _rightMetricX, _footerY + 38, calories.format("%d"), "KCAL");
    }

    function drawMetricValue(dc, centerX, y, value, unit) {
        var valueWidth = dc.getTextWidthInPixels(value, _fSmall);
        var unitWidth = dc.getTextWidthInPixels(unit, _fTiny);
        var gap = 4;
        var startX = centerX - ((valueWidth + gap + unitWidth) / 2);
        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, y, _fSmall, value,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX + valueWidth + gap, y + 5, _fTiny, unit,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawAlwaysOn(dc) {
        var clock = System.getClockTime();
        var hour = displayHour(clock.hour);
        var timeText = Lang.format("$1$:$2$", [hour.format("%02d"), clock.min.format("%02d")]);
        var dx = ((clock.min % 3) - 1) * 2;
        var dy = (((clock.min / 3).toNumber() % 3) - 1) * 2;
        dc.setColor(AOD, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx + dx, _aodY + dy, _fAod, timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function displayHour(hour) {
        if (!System.getDeviceSettings().is24Hour) {
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
