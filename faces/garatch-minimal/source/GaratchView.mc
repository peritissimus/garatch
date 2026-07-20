using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;
using Toybox.Activity;

class GaratchView extends WatchUi.WatchFace {
    private var _w;
    private var _h;
    private var _m;

    private var _fTime;
    private var _fDay;
    private var _fDate;
    private var _fValue;
    private var _fLabel;

    private var _hValue;
    private var _hLabel;
    private var _hDay;
    private var _hDate;
    private var _hTime;

    private var _timeY;
    private var _stepsY;
    private var _barY;
    private var _hrY;
    private var _graphY;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _w = dc.getWidth();
        _h = dc.getHeight();
        _m = 18;

        _fTime = Graphics.FONT_SYSTEM_NUMBER_HOT;
        _fDay = Graphics.FONT_XTINY;
        _fDate = Graphics.FONT_XTINY;
        _fValue = Graphics.FONT_SMALL;
        _fLabel = Graphics.FONT_TINY;

        _hValue = dc.getFontHeight(_fValue);
        _hLabel = dc.getFontHeight(_fLabel);
        _hDay = dc.getFontHeight(_fDay);
        _hDate = dc.getFontHeight(_fDate);
        _hTime = dc.getFontHeight(_fTime);

        _timeY = (_h * 0.35).toNumber();
        var timeBottom = _timeY + (_hTime / 2);
        _stepsY = timeBottom + 16;
        _barY = _stepsY + _hValue + 8;
        _hrY = _barY + 16;
        _graphY = _h - 26;
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawDateHeader(dc);
        drawTime(dc);
        drawStepsRow(dc);
        drawHrRow(dc);
        drawHrGraph(dc);
        drawBattery(dc);
    }

    function drawDateHeader(dc) {
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var dayStr = getDayName(info.day_of_week);
        var dateStr = Lang.format("$1$ $2$", [
            getMonthName(info.month),
            info.day.format("%02d")
        ]);

        var dayY = 6;
        var dayW = dc.getTextWidthInPixels(dayStr, _fDay);
        var dateW = dc.getTextWidthInPixels(dateStr, _fDate);
        var gap = 8;
        var totalW = dayW + gap + dateW;
        var startX = (_w - totalW) / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, dayY, _fDay, dayStr, Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX + dayW + gap, dayY, _fDate, dateStr, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawTime(dc) {
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours == 0) { hours = 12; }
            else if (hours > 12) { hours -= 12; }
        }

        var timeStr = Lang.format(
            "$1$:$2$",
            [hours.format("%02d"), clockTime.min.format("%02d")]
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _w / 2,
            _timeY,
            _fTime,
            timeStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawStepsRow(dc) {
        var info = ActivityMonitor.getInfo();
        var steps = (info != null && info.steps != null) ? info.steps : 0;
        var stepGoal = (info != null && info.stepGoal != null && info.stepGoal != 0) ? info.stepGoal : 10000;
        var stepsStr = formatNumber(steps);

        drawWalkIcon(dc, _m, _stepsY + 2);

        var label = "STEPS";
        var valueW = dc.getTextWidthInPixels(stepsStr, _fValue);
        var labelW = dc.getTextWidthInPixels(label, _fLabel);
        var gap = 6;
        var startX = _w - _m - (valueW + gap + labelW);
        var labelY = _stepsY + (_hValue - _hLabel);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, _stepsY, _fValue, stepsStr, Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX + valueW + gap, labelY, _fLabel, label, Graphics.TEXT_JUSTIFY_LEFT);

        var barX = _m;
        var barW = _w - (_m * 2);
        var barH = 4;
        var pct = steps.toFloat() / stepGoal.toFloat();
        if (pct > 1.0) { pct = 1.0; }
        if (pct < 0.0) { pct = 0.0; }

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, _barY, barW, barH);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, _barY, (barW * pct).toNumber(), barH);
    }

    function drawHrRow(dc) {
        var hr = "--";
        var actInfo = Activity.getActivityInfo();
        if (actInfo != null && actInfo.currentHeartRate != null) {
            hr = actInfo.currentHeartRate.format("%d");
        }

        drawHeartIcon(dc, _m, _hrY + 2);

        var valueStr = hr;
        var label = "BPM";
        var valueW = dc.getTextWidthInPixels(valueStr, _fValue);
        var labelW = dc.getTextWidthInPixels(label, _fLabel);
        var gap = 6;
        var labelY = _hrY + (_hValue - _hLabel);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_m + 22, _hrY, _fValue, valueStr, Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_m + 22 + valueW + gap, labelY, _fLabel, label, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawHrGraph(dc) {
        var hrVal = 0;
        var actInfo = Activity.getActivityInfo();
        if (actInfo != null && actInfo.currentHeartRate != null) {
            hrVal = actInfo.currentHeartRate;
        }

        var base = (hrVal > 0) ? (hrVal % 6) + 3 : 5;
        var data = [
            base - 2, base - 1, base, base + 1, base - 1, base + 2, base, base - 1, base + 1
        ];

        var maxVal = 9.0;
        var graphH = 14.0;
        var graphW = (_w - _m - 90).toFloat();
        if (graphW < 80) { graphW = 80.0; }

        var gap = graphW / (data.size() - 1);
        var x0 = _m.toFloat();
        var y0 = _graphY.toFloat();

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        for (var i = 0; i < data.size() - 1; i++) {
            var v1 = clamp(data[i], 1, 9);
            var v2 = clamp(data[i + 1], 1, 9);
            var x1 = x0 + (gap * i);
            var x2 = x0 + (gap * (i + 1));
            var y1 = y0 - (v1 / maxVal) * graphH;
            var y2 = y0 - (v2 / maxVal) * graphH;
            dc.drawLine(x1, y1, x2, y2);
        }
        dc.setPenWidth(1);
    }

    function drawBattery(dc) {
        var stats = System.getSystemStats();
        var bat = (stats != null && stats.battery != null) ? stats.battery : 0;
        var text = bat.format("%d") + "%";

        var textW = dc.getTextWidthInPixels(text, _fLabel);
        var iconW = 18;
        var iconH = 8;
        var iconX = _w - _m - textW - iconW - 6;
        var iconY = _h - 30;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(iconX, iconY, iconW, iconH);
        dc.fillRectangle(iconX + iconW, iconY + 2, 2, 4);

        var fillW = ((iconW - 2) * bat / 100).toNumber();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(iconX + 1, iconY + 1, fillW, iconH - 2);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_w - _m, _h - 32, _fLabel, text, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawWalkIcon(dc, x, y) {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(x + 2, y + 2, 2);
        dc.drawLine(x + 2, y + 4, x + 2, y + 10);
        dc.drawLine(x + 2, y + 6, x - 1, y + 8);
        dc.drawLine(x + 2, y + 6, x + 6, y + 6);
        dc.drawLine(x + 2, y + 10, x - 1, y + 13);
        dc.drawLine(x + 2, y + 10, x + 6, y + 13);
    }

    function drawHeartIcon(dc, x, y) {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x + 3, y + 3, 3);
        dc.fillCircle(x + 9, y + 3, 3);
        dc.drawLine(x, y + 4, x + 6, y + 11);
        dc.drawLine(x + 12, y + 4, x + 6, y + 11);
    }

    function formatNumber(val) {
        var s = val.format("%d");
        if (s.length() <= 3) { return s; }
        var out = "";
        var count = 0;
        for (var i = s.length() - 1; i >= 0; i--) {
            out = s.substring(i, i + 1) + out;
            count++;
            if (count == 3 && i > 0) {
                out = "," + out;
                count = 0;
            }
        }
        return out;
    }

    function clamp(val, minV, maxV) {
        if (val < minV) { return minV; }
        if (val > maxV) { return maxV; }
        return val;
    }

    function getDayName(dayVal) {
        var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        return days[dayVal - 1];
    }

    function getMonthName(monthVal) {
        var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        return months[monthVal - 1];
    }

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}
}
